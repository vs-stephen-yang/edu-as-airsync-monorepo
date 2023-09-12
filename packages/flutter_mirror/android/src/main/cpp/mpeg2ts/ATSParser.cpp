/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// #define LOG_NDEBUG 0
// #define LOG_TAG "ATSParser"

#include "ATSParser.h"
#include "ABitReader.h"
#include "ABuffer.h"
#include "ADebug.h"
#include "Utils.h"
#include "util/log.h"

#define DLOG(x, y)  // ALOGV(x, y)

// I want the expression "y" evaluated even if verbose logging is off.
#define MY_LOGV(x, y) \
  do {                \
    unsigned tmp = y; \
    DLOG(x, tmp);     \
  } while (0)

struct ATSParser::Program {
  Program(ATSParser* parser, unsigned programNumber, unsigned programMapPID);

  bool parsePSISection(
      unsigned pid,
      ABitReader* br,
      status_t* err);

  bool parsePID(
      unsigned pid,
      unsigned continuity_counter,
      unsigned payload_unit_start_indicator,
      unsigned random_access_indicator,
      ABitReader* br,
      status_t* err);

  int64_t convertPTSToTimestamp(uint64_t PTS);

  bool PTSTimeDeltaEstablished() const {
    return mFirstPTSValid;
  }

  unsigned number() const { return mProgramNumber; }

  void updateProgramMapPID(unsigned programMapPID) {
    mProgramMapPID = programMapPID;
  }

 private:
  ATSParser* mParser;
  unsigned mProgramNumber;
  unsigned mProgramMapPID;
  std::map<unsigned, std::shared_ptr<Stream>> mStreams;
  bool mFirstPTSValid;
  uint64_t mFirstPTS;

  status_t parseProgramMap(ABitReader* br);
};

struct ATSParser::Stream {
  Stream(ATSParser* parser,
         Program* program,
         unsigned elementaryPID,
         unsigned streamType,
         unsigned PCR_PID);

  unsigned type() const { return mStreamType; }
  unsigned pid() const { return mElementaryPID; }
  void setPID(unsigned pid) { mElementaryPID = pid; }

  status_t parse(
      unsigned continuity_counter,
      unsigned payload_unit_start_indicator,
      unsigned random_access_indicator,
      ABitReader* br);

  void signalEOS(status_t finalResult);

  virtual ~Stream();

 private:
  ATSParser* mParser;
  Program* mProgram;
  unsigned mElementaryPID;
  unsigned mStreamType;
  unsigned mPCR_PID;
  int32_t mExpectedContinuityCounter;

  std::shared_ptr<ABuffer> mBuffer;

  bool mPayloadStarted;
  short waitIDRFrame_;

  uint64_t mPrevPTS;

  status_t flush();
  status_t parsePES(ABitReader* br);

  void onPayloadData(
      unsigned PTS_DTS_flags,
      uint64_t PTS,
      uint64_t DTS,
      const uint8_t* data,
      size_t size);

  bool isAudio() const;
  bool isVideo() const;
  bool isSupportedAudio() const;
  bool isSupportedVideo() const;
};

struct ATSParser::PSISection {
  PSISection();

  status_t append(const void* data, size_t size);
  void clear();

  bool isComplete() const;
  bool isEmpty() const;

  const uint8_t* data() const;
  size_t size() const;

 public:
  virtual ~PSISection();

 private:
  std::shared_ptr<ABuffer> mBuffer;
};

////////////////////////////////////////////////////////////////////////////////

ATSParser::Program::Program(
    ATSParser* parser,
    unsigned programNumber,
    unsigned programMapPID)
    : mParser(parser),
      mProgramNumber(programNumber),
      mProgramMapPID(programMapPID),
      mFirstPTSValid(false),
      mFirstPTS(0) {
  ALOGV("new program number %u", programNumber);
}

bool ATSParser::Program::parsePSISection(
    unsigned pid,
    ABitReader* br,
    status_t* err) {
  *err = OK;

  if (pid != mProgramMapPID) {
    return false;
  }

  *err = parseProgramMap(br);

  return true;
}

bool ATSParser::Program::parsePID(
    unsigned pid,
    unsigned continuity_counter,
    unsigned payload_unit_start_indicator,
    unsigned random_access_indicator,
    ABitReader* br,
    status_t* err) {
  *err = OK;

  std::map<unsigned, std::shared_ptr<Stream>>::iterator it = mStreams.find(pid);
  if (it == mStreams.end()) {
    return false;
  }

  std::shared_ptr<Stream> stream = it->second;

  *err = stream->parse(continuity_counter, payload_unit_start_indicator, random_access_indicator, br);

  return true;
}

struct StreamInfo {
  unsigned mType;
  unsigned mPID;
};

status_t ATSParser::Program::parseProgramMap(ABitReader* br) {
  unsigned table_id = br->getBits(8);
  CHECK_EQ(table_id, 0x02u);

  unsigned section_syntax_indicator = br->getBits(1);
  CHECK_EQ(section_syntax_indicator, 1u);

  CHECK_EQ(br->getBits(1), 0u);
  MY_LOGV("  reserved = %u", br->getBits(2));

  unsigned section_length = br->getBits(12);
  CHECK_EQ(section_length & 0xc00, 0u);
  CHECK_LE(section_length, 1021u);

  MY_LOGV("  program_number = %u", br->getBits(16));
  MY_LOGV("  reserved = %u", br->getBits(2));
  MY_LOGV("  version_number = %u", br->getBits(5));
  MY_LOGV("  current_next_indicator = %u", br->getBits(1));
  MY_LOGV("  section_number = %u", br->getBits(8));
  MY_LOGV("  last_section_number = %u", br->getBits(8));
  MY_LOGV("  reserved = %u", br->getBits(3));

  unsigned PCR_PID = br->getBits(13);

  MY_LOGV("  reserved = %u", br->getBits(4));

  unsigned program_info_length = br->getBits(12);
  CHECK_EQ(program_info_length & 0xc00, 0u);

  br->skipBits(program_info_length * 8);  // skip descriptors

  std::vector<StreamInfo> infos;

  // infoBytesRemaining is the number of bytes that make up the
  // variable length section of ES_infos. It does not include the
  // final CRC.
  size_t infoBytesRemaining = section_length - 9 - program_info_length - 4;

  while (infoBytesRemaining > 0) {
    CHECK_GE(infoBytesRemaining, 5u);

    unsigned streamType = br->getBits(8);

    MY_LOGV("    reserved = %u", br->getBits(3));

    unsigned elementaryPID = br->getBits(13);

    MY_LOGV("    reserved = %u", br->getBits(4));

    unsigned ES_info_length = br->getBits(12);
    CHECK_EQ(ES_info_length & 0xc00, 0u);

    CHECK_GE(infoBytesRemaining - 5, ES_info_length);

    unsigned info_bytes_remaining = ES_info_length;
    while (info_bytes_remaining >= 2) {
      MY_LOGV("      tag = 0x%02x", br->getBits(8));

      unsigned descLength = br->getBits(8);

      CHECK_GE(info_bytes_remaining, 2 + descLength);

      br->skipBits(descLength * 8);

      info_bytes_remaining -= descLength + 2;
    }
    CHECK_EQ(info_bytes_remaining, 0u);

    StreamInfo info;
    info.mType = streamType;
    info.mPID = elementaryPID;
    infos.push_back(info);

    infoBytesRemaining -= 5 + ES_info_length;
  }

  CHECK_EQ(infoBytesRemaining, 0u);
  MY_LOGV("  CRC = 0x%08x", br->getBits(32));

  bool PIDsChanged = false;
  for (size_t i = 0; i < infos.size(); ++i) {
    StreamInfo info = infos[i];

    std::map<unsigned, std::shared_ptr<Stream>>::iterator it = mStreams.find(info.mPID);
    if (it != mStreams.end() && it->second->type() != info.mType) {
      ALOGI("uh oh. stream PIDs have changed.");
      PIDsChanged = true;
      break;
    }
  }

  if (PIDsChanged) {
#if 0
        ALOGI("before:");
        for (size_t i = 0; i < mStreams.size(); ++i) {
            sp<Stream> stream = mStreams.editValueAt(i);

            ALOGI("PID 0x%08x => type 0x%02x", stream->pid(), stream->type());
        }

        ALOGI("after:");
        for (size_t i = 0; i < infos.size(); ++i) {
            StreamInfo &info = infos.editItemAt(i);

            ALOGI("PID 0x%08x => type 0x%02x", info.mPID, info.mType);
        }
#endif

    // The only case we can recover from is if we have two streams
    // and they switched PIDs.

    bool success = false;

    if (mStreams.size() == 2 && infos.size() == 2) {
      const StreamInfo& info1 = infos[0];
      const StreamInfo& info2 = infos[1];

      std::map<unsigned, std::shared_ptr<Stream>>::iterator it = mStreams.begin();
      std::shared_ptr<Stream> s1 = it->second;
      std::shared_ptr<Stream> s2 = (++it)->second;

      bool caseA =
          info1.mPID == s1->pid() && info1.mType == s2->type() && info2.mPID == s2->pid() && info2.mType == s1->type();

      bool caseB =
          info1.mPID == s2->pid() && info1.mType == s1->type() && info2.mPID == s1->pid() && info2.mType == s2->type();

      if (caseA || caseB) {
        unsigned pid1 = s1->pid();
        unsigned pid2 = s2->pid();
        s1->setPID(pid2);
        s2->setPID(pid1);

        mStreams.clear();
        mStreams.insert(std::pair<unsigned, std::shared_ptr<Stream>>(s1->pid(), s1));
        mStreams.insert(std::pair<unsigned, std::shared_ptr<Stream>>(s2->pid(), s2));

        success = true;
      }
    }

    if (!success) {
      ALOGI("Stream PIDs changed and we cannot recover.");
      return BAD_VALUE;
    }
  }

  for (size_t i = 0; i < infos.size(); ++i) {
    StreamInfo& info = infos[i];

    std::map<unsigned, std::shared_ptr<Stream>>::iterator it = mStreams.find(info.mPID);

    if (it == mStreams.end()) {
      std::shared_ptr<Stream> stream = std::make_shared<Stream>(mParser, this, info.mPID, info.mType, PCR_PID);
      mStreams.insert(std::pair<unsigned, std::shared_ptr<Stream>>(info.mPID, stream));
      ALOGD("Insert mStreams pid=%d mType=%d PCR_PID=%d", info.mPID, info.mType, PCR_PID);
    }
  }

  return OK;
}

int64_t ATSParser::Program::convertPTSToTimestamp(uint64_t PTS) {
  if (!(mParser->mFlags & TS_TIMESTAMPS_ARE_ABSOLUTE)) {
    if (!mFirstPTSValid) {
      mFirstPTSValid = true;
      mFirstPTS = PTS;
      PTS = 0;
    } else if (PTS < mFirstPTS) {
      PTS = 0;
    } else {
      PTS -= mFirstPTS;
    }
  }

  int64_t timeUs = (PTS * 100) / 9;

  if (mParser->mAbsoluteTimeAnchorUs >= 0ll) {
    timeUs += mParser->mAbsoluteTimeAnchorUs;
  }

  return timeUs;
}

//////////////////////////////////////////////////////////////////////////////////

ATSParser::Stream::Stream(
    ATSParser* parser,
    Program* program,
    unsigned elementaryPID,
    unsigned streamType,
    unsigned PCR_PID)
    : mParser(parser),
      mProgram(program),
      mElementaryPID(elementaryPID),
      mStreamType(streamType),
      mPCR_PID(PCR_PID),
      mExpectedContinuityCounter(-1),
      mPayloadStarted(false),
      waitIDRFrame_(false),
      mPrevPTS(0) {
  mBuffer = std::make_shared<ABuffer>(192 * 1024);
  mBuffer->setRange(0, 0);
}

ATSParser::Stream::~Stream() {
}

status_t ATSParser::Stream::parse(
    unsigned continuity_counter,
    unsigned payload_unit_start_indicator,
    unsigned random_access_indicator,
    ABitReader* br) {
  if (mExpectedContinuityCounter >= 0 && (unsigned)mExpectedContinuityCounter != continuity_counter) {
    ALOGI("discontinuity on stream pid 0x%04x", mElementaryPID);

    mPayloadStarted = false;
    mBuffer->setRange(0, 0);
    mExpectedContinuityCounter = -1;
    if (isVideo() && !waitIDRFrame_) {
      mParser->callback_->OnPacketLoss();
      //            waitIDRFrame_ = true;
      //            ALOGI("wait for IDR frame.");
    }

    return OK;
  }

  mExpectedContinuityCounter = (continuity_counter + 1) & 0x0f;

  if (payload_unit_start_indicator) {
    if (mPayloadStarted) {
      // Otherwise we run the danger of receiving the trailing bytes
      // of a PES packet that we never saw the start of and assuming
      // we have a a complete PES packet.

      status_t err = flush();

      if (err != OK) {
        return err;
      }
    }

    mPayloadStarted = true;

    if (isVideo() && waitIDRFrame_) {
      if (random_access_indicator) {
        waitIDRFrame_ = false;
      } else {
        mPayloadStarted = false;
      }
    }
  }

  if (!mPayloadStarted) {
    return OK;
  }

  size_t payloadSizeBits = br->numBitsLeft();
  CHECK_EQ(payloadSizeBits % 8, 0u);

  size_t neededSize = mBuffer->size() + payloadSizeBits / 8;
  if (mBuffer->capacity() < neededSize) {
    // Increment in multiples of 64K.
    neededSize = (neededSize + 65535) & ~65535;

    ALOGI("resizing buffer to %u bytes", (unsigned int)neededSize);

    std::shared_ptr<ABuffer> newBuffer = std::make_shared<ABuffer>(neededSize);
    memcpy(newBuffer->data(), mBuffer->data(), mBuffer->size());
    newBuffer->setRange(0, mBuffer->size());
    mBuffer = newBuffer;
  }

  memcpy(mBuffer->data() + mBuffer->size(), br->data(), payloadSizeBits / 8);
  mBuffer->setRange(0, mBuffer->size() + payloadSizeBits / 8);

  return OK;
}

bool ATSParser::Stream::isVideo() const {
  switch (mStreamType) {
    case STREAMTYPE_H264:
    case STREAMTYPE_MPEG1_VIDEO:
    case STREAMTYPE_MPEG2_VIDEO:
    case STREAMTYPE_MPEG4_VIDEO:
      return true;
    default:
      return false;
  }
}

bool ATSParser::Stream::isSupportedVideo() const {
  switch (mStreamType) {
    case STREAMTYPE_H264:
      return true;
    default:
      return false;
  }
}

bool ATSParser::Stream::isAudio() const {
  switch (mStreamType) {
    case STREAMTYPE_MPEG1_AUDIO:
    case STREAMTYPE_MPEG2_AUDIO:
    case STREAMTYPE_MPEG2_AUDIO_ADTS:
    case STREAMTYPE_PCM_AUDIO:
      return true;

    default:
      return false;
  }
}

bool ATSParser::Stream::isSupportedAudio() const {
  switch (mStreamType) {
    case STREAMTYPE_MPEG2_AUDIO:
    case STREAMTYPE_MPEG2_AUDIO_ADTS:
      return true;
    default:
      return false;
  }
}

status_t ATSParser::Stream::parsePES(ABitReader* br) {
  unsigned packet_startcode_prefix = br->getBits(24);

  if (packet_startcode_prefix != 1) {
    ALOGV(
        "Supposedly payload_unit_start=1 unit does not start "
        "with startcode.");

    return BAD_VALUE;
  }

  CHECK_EQ(packet_startcode_prefix, 0x000001u);

  unsigned stream_id = br->getBits(8);

  unsigned PES_packet_length = br->getBits(16);

  if (stream_id != 0xbc        // program_stream_map
      && stream_id != 0xbe     // padding_stream
      && stream_id != 0xbf     // private_stream_2
      && stream_id != 0xf0     // ECM
      && stream_id != 0xf1     // EMM
      && stream_id != 0xff     // program_stream_directory
      && stream_id != 0xf2     // DSMCC
      && stream_id != 0xf8) {  // H.222.1 type E
    CHECK_EQ(br->getBits(2), 2u);

    MY_LOGV("PES_scrambling_control = %u", br->getBits(2));
    MY_LOGV("PES_priority = %u", br->getBits(1));
    MY_LOGV("data_alignment_indicator = %u", br->getBits(1));
    MY_LOGV("copyright = %u", br->getBits(1));
    MY_LOGV("original_or_copy = %u", br->getBits(1));

    unsigned PTS_DTS_flags = br->getBits(2);

    unsigned ESCR_flag = br->getBits(1);

    unsigned ES_rate_flag = br->getBits(1);

    unsigned DSM_trick_mode_flag = br->getBits(1);

    unsigned additional_copy_info_flag = br->getBits(1);

    MY_LOGV("PES_CRC_flag = %u", br->getBits(1));
    MY_LOGV("PES_extension_flag = %u", br->getBits(1));

    unsigned PES_header_data_length = br->getBits(8);

    unsigned optional_bytes_remaining = PES_header_data_length;

    uint64_t PTS = 0, DTS = 0;

    if (PTS_DTS_flags == 2 || PTS_DTS_flags == 3) {
      CHECK_GE(optional_bytes_remaining, 5u);

      CHECK_EQ(br->getBits(4), PTS_DTS_flags);

      PTS = ((uint64_t)br->getBits(3)) << 30;
      CHECK_EQ(br->getBits(1), 1u);
      PTS |= ((uint64_t)br->getBits(15)) << 15;
      CHECK_EQ(br->getBits(1), 1u);
      PTS |= br->getBits(15);
      CHECK_EQ(br->getBits(1), 1u);

      optional_bytes_remaining -= 5;

      if (PTS_DTS_flags == 3) {
        CHECK_GE(optional_bytes_remaining, 5u);

        CHECK_EQ(br->getBits(4), 1u);

        DTS = ((uint64_t)br->getBits(3)) << 30;
        CHECK_EQ(br->getBits(1), 1u);
        DTS |= ((uint64_t)br->getBits(15)) << 15;
        CHECK_EQ(br->getBits(1), 1u);
        DTS |= br->getBits(15);
        CHECK_EQ(br->getBits(1), 1u);

        optional_bytes_remaining -= 5;
      }
    }

    if (ESCR_flag) {
      CHECK_GE(optional_bytes_remaining, 6u);

      br->getBits(2);

      uint64_t ESCR = ((uint64_t)br->getBits(3)) << 30;
      CHECK_EQ(br->getBits(1), 1u);
      ESCR |= ((uint64_t)br->getBits(15)) << 15;
      CHECK_EQ(br->getBits(1), 1u);
      ESCR |= br->getBits(15);
      CHECK_EQ(br->getBits(1), 1u);

      MY_LOGV("ESCR_extension = %u", br->getBits(9));

      CHECK_EQ(br->getBits(1), 1u);

      optional_bytes_remaining -= 6;
    }

    if (ES_rate_flag) {
      CHECK_GE(optional_bytes_remaining, 3u);

      CHECK_EQ(br->getBits(1), 1u);
      MY_LOGV("ES_rate = %u", br->getBits(22));
      CHECK_EQ(br->getBits(1), 1u);

      optional_bytes_remaining -= 3;
    }

    br->skipBits(optional_bytes_remaining * 8);

    // ES data follows.

    if (PES_packet_length != 0) {
      CHECK_GE(PES_packet_length, PES_header_data_length + 3);

      unsigned dataLength =
          PES_packet_length - 3 - PES_header_data_length;

      if (br->numBitsLeft() < dataLength * 8) {
        ALOGE(
            "PES packet does not carry enough data to contain "
            "payload. (numBitsLeft = %u, required = %u)",
            (unsigned int)br->numBitsLeft(), (unsigned int)(dataLength * 8));

        return BAD_VALUE;
      }

      CHECK_GE(br->numBitsLeft(), dataLength * 8);

      onPayloadData(
          PTS_DTS_flags, PTS, DTS, br->data(), dataLength);

    } else {
      onPayloadData(
          PTS_DTS_flags, PTS, DTS,
          br->data(), br->numBitsLeft() / 8);

      size_t payloadSizeBits = br->numBitsLeft();
      CHECK_EQ(payloadSizeBits % 8, 0u);
    }
  } else if (stream_id == 0xbe) {  // padding_stream
    CHECK_NE(PES_packet_length, 0u);
    br->skipBits(PES_packet_length * 8);
  } else {
    CHECK_NE(PES_packet_length, 0u);
    br->skipBits(PES_packet_length * 8);
  }

  return OK;
}

status_t ATSParser::Stream::flush() {
  if (mBuffer->size() == 0) {
    return OK;
  }

  ABitReader br(mBuffer->data(), mBuffer->size());

  status_t err = parsePES(&br);

  mBuffer->setRange(0, 0);

  return err;
}

void ATSParser::Stream::onPayloadData(
    unsigned PTS_DTS_flags,
    uint64_t PTS,
    uint64_t DTS,
    const uint8_t* data,
    size_t size) {
  mPrevPTS = PTS;
  int64_t timeUs = 0ll;  // no presentation timestamp available.
  if (PTS_DTS_flags == 2 || PTS_DTS_flags == 3) {
    timeUs = mProgram->convertPTSToTimestamp(PTS);
  }

  if (isSupportedAudio()) {
    mParser->callback_->OnAudioFrame(data, size, timeUs);
  } else if (isSupportedVideo()) {
    mParser->callback_->OnVideoFrame(false, data, size, timeUs);
  }
}

////////////////////////////////////////////////////////////////////////////////

ATSParser::ATSParser(Callback* callback, uint32_t flags)
    : mFlags(flags),
      mAbsoluteTimeAnchorUs(-1ll),
      mNumTSPacketsParsed(0),
      mNumPCRs(0) {
  callback_ = callback;
  mPSISections.insert(std::pair<unsigned, std::shared_ptr<PSISection>>(0 /* PID */, std::make_shared<PSISection>()));
}

ATSParser::~ATSParser() {
}

bool ATSParser::feedTSPacket(const void* data, size_t size) {
  CHECK_EQ(size, kTSPacketSize);

  ABitReader br((const uint8_t*)data, kTSPacketSize);
  return parseTS(&br);
}

void ATSParser::parseProgramAssociationTable(ABitReader* br) {
  unsigned table_id = br->getBits(8);
  CHECK_EQ(table_id, 0x00u);

  unsigned section_syntax_indictor = br->getBits(1);
  CHECK_EQ(section_syntax_indictor, 1u);

  CHECK_EQ(br->getBits(1), 0u);
  MY_LOGV("  reserved = %u", br->getBits(2));

  unsigned section_length = br->getBits(12);
  CHECK_EQ(section_length & 0xc00, 0u);

  MY_LOGV("  transport_stream_id = %u", br->getBits(16));
  MY_LOGV("  reserved = %u", br->getBits(2));
  MY_LOGV("  version_number = %u", br->getBits(5));
  MY_LOGV("  current_next_indicator = %u", br->getBits(1));
  MY_LOGV("  section_number = %u", br->getBits(8));
  MY_LOGV("  last_section_number = %u", br->getBits(8));

  size_t numProgramBytes = (section_length - 5 /* header */ - 4 /* crc */);
  CHECK_EQ((numProgramBytes % 4), 0u);

  for (size_t i = 0; i < numProgramBytes / 4; ++i) {
    unsigned program_number = br->getBits(16);

    MY_LOGV("    reserved = %u", br->getBits(3));

    if (program_number == 0) {
      MY_LOGV("    network_PID = 0x%04x", br->getBits(13));
    } else {
      unsigned programMapPID = br->getBits(13);

      bool found = false;
      for (size_t index = 0; index < mPrograms.size(); ++index) {
        // const sp<Program> &program = mPrograms.itemAt(index);
        std::shared_ptr<Program> program = mPrograms[i];

        if (program->number() == program_number) {
          program->updateProgramMapPID(programMapPID);
          found = true;
          break;
        }
      }

      if (!found) {
        mPrograms.push_back(std::make_shared<Program>(this, program_number, programMapPID));
      }

      std::map<unsigned, std::shared_ptr<PSISection>>::iterator it = mPSISections.find(programMapPID);
      if (it == mPSISections.end()) {
        mPSISections.insert(std::pair<unsigned, std::shared_ptr<PSISection>>(programMapPID /* PID */, std::make_shared<PSISection>()));
      }
    }
  }

  MY_LOGV("  CRC = 0x%08x", br->getBits(32));
}

status_t ATSParser::parsePID(
    ABitReader* br,
    unsigned PID,
    unsigned continuity_counter,
    unsigned payload_unit_start_indicator,
    unsigned random_access_indicator) {
  std::map<unsigned, std::shared_ptr<PSISection>>::iterator it = mPSISections.find(PID);
  if (it != mPSISections.end()) {
    const std::shared_ptr<PSISection> section = it->second;

    if (payload_unit_start_indicator) {
      CHECK(section->isEmpty());

      unsigned skip = br->getBits(8);
      br->skipBits(skip * 8);
    }

    CHECK((br->numBitsLeft() % 8) == 0);
    status_t err = section->append(br->data(), br->numBitsLeft() / 8);

    if (err != OK) {
      return err;
    }

    if (!section->isComplete()) {
      return OK;
    }

    ABitReader sectionBits(section->data(), section->size());

    if (PID == 0) {
      parseProgramAssociationTable(&sectionBits);
    } else {
      bool handled = false;
      for (size_t i = 0; i < mPrograms.size(); ++i) {
        status_t err;
        if (!mPrograms[i]->parsePSISection(
                PID, &sectionBits, &err)) {
          continue;
        }

        if (err != OK) {
          return err;
        }

        handled = true;
        break;
      }

      if (!handled) {
        mPSISections.erase(it);
      }
    }

    section->clear();

    return OK;
  }

  bool handled = false;
  for (size_t i = 0; i < mPrograms.size(); ++i) {
    status_t err;
    if (mPrograms[i]->parsePID(
            PID, continuity_counter, payload_unit_start_indicator, random_access_indicator,
            br, &err)) {
      if (err != OK) {
        return err;
      }

      handled = true;
      break;
    }
  }

  if (!handled) {
    ALOGV("PID 0x%04x not handled.", PID);
  }

  return OK;
}

void ATSParser::parseAdaptationField(ABitReader* br, unsigned PID, unsigned* random_access_indicator) {
  unsigned adaptation_field_length = br->getBits(8);

  if (adaptation_field_length > 0) {
    unsigned discontinuity_indicator = br->getBits(1);

    if (discontinuity_indicator) {
      ALOGV("PID 0x%04x: discontinuity_indicator = 1 (!!!)", PID);
    }

    *random_access_indicator = br->getBits(1);
    br->skipBits(1);
    unsigned PCR_flag = br->getBits(1);

    size_t numBitsRead = 4;

    if (PCR_flag) {
      br->skipBits(4);
      uint64_t PCR_base = br->getBits(32);
      PCR_base = (PCR_base << 1) | br->getBits(1);

      br->skipBits(6);
      unsigned PCR_ext = br->getBits(9);

      // The number of bytes from the start of the current
      // MPEG2 transport stream packet up and including
      // the final byte of this PCR_ext field.
      size_t byteOffsetFromStartOfTSPacket =
          (188 - br->numBitsLeft() / 8);

      uint64_t PCR = PCR_base * 300 + PCR_ext;

      // The number of bytes received by this parser up to and
      // including the final byte of this PCR_ext field.
      size_t byteOffsetFromStart =
          mNumTSPacketsParsed * 188 + byteOffsetFromStartOfTSPacket;

      for (size_t i = 0; i < mPrograms.size(); ++i) {
        updatePCR(PID, PCR, byteOffsetFromStart);
      }

      numBitsRead += 52;
    }

    CHECK_GE(adaptation_field_length * 8, numBitsRead);

    br->skipBits(adaptation_field_length * 8 - numBitsRead);
  }
}

status_t ATSParser::parseTS(ABitReader* br) {
  unsigned sync_byte = br->getBits(8);
  CHECK_EQ(sync_byte, 0x47u);

  MY_LOGV("transport_error_indicator = %u", br->getBits(1));

  unsigned payload_unit_start_indicator = br->getBits(1);

  MY_LOGV("transport_priority = %u", br->getBits(1));

  unsigned PID = br->getBits(13);

  MY_LOGV("transport_scrambling_control = %u", br->getBits(2));

  unsigned adaptation_field_control = br->getBits(2);

  unsigned continuity_counter = br->getBits(4);

  // Adaptation field control values:
  // 00 Reserved for future use by ISO/IEC
  // 01 No adaptation_field, payload only
  // 10 Adaptation_field only, no payload
  // 11 Adaptation_field followed by payload
  unsigned random_access_indicator = 0;
  if (adaptation_field_control == 2 || adaptation_field_control == 3) {
    parseAdaptationField(br, PID, &random_access_indicator);
  }

  status_t err = OK;

  if (adaptation_field_control == 1 || adaptation_field_control == 3) {
    err = parsePID(
        br, PID, continuity_counter, payload_unit_start_indicator, random_access_indicator);
  }

  ++mNumTSPacketsParsed;

  return err;
}

bool ATSParser::PTSTimeDeltaEstablished() {
  if (mPrograms.empty()) {
    return false;
  }

  return mPrograms[0]->PTSTimeDeltaEstablished();
}

void ATSParser::updatePCR(
    unsigned PID,
    uint64_t PCR,
    size_t byteOffsetFromStart) {
  if (mNumPCRs == 2) {
    mPCR[0] = mPCR[1];
    mPCRBytes[0] = mPCRBytes[1];
    mSystemTimeUs[0] = mSystemTimeUs[1];
    mNumPCRs = 1;
  }

  mPCR[mNumPCRs] = PCR;
  mPCRBytes[mNumPCRs] = byteOffsetFromStart;
  // mSystemTimeUs[mNumPCRs] = ALooper::GetNowUs();

  ++mNumPCRs;

  if (mNumPCRs == 2) {
    double transportRate =
        (mPCRBytes[1] - mPCRBytes[0]) * 27E6 / (mPCR[1] - mPCR[0]);
  }
}

////////////////////////////////////////////////////////////////////////////////

ATSParser::PSISection::PSISection() {
}

ATSParser::PSISection::~PSISection() {
}

status_t ATSParser::PSISection::append(const void* data, size_t size) {
  if (mBuffer == NULL || mBuffer->size() + size > mBuffer->capacity()) {
    size_t newCapacity =
        (mBuffer == NULL) ? size : mBuffer->capacity() + size;

    newCapacity = (newCapacity + 1023) & ~1023;

    std::shared_ptr<ABuffer> newBuffer = std::make_shared<ABuffer>(newCapacity);

    if (mBuffer != NULL) {
      memcpy(newBuffer->data(), mBuffer->data(), mBuffer->size());
      newBuffer->setRange(0, mBuffer->size());
    } else {
      newBuffer->setRange(0, 0);
    }

    mBuffer = newBuffer;
  }

  memcpy(mBuffer->data() + mBuffer->size(), data, size);
  mBuffer->setRange(0, mBuffer->size() + size);

  return OK;
}

void ATSParser::PSISection::clear() {
  if (mBuffer != NULL) {
    mBuffer->setRange(0, 0);
  }
}

bool ATSParser::PSISection::isComplete() const {
  if (mBuffer == NULL || mBuffer->size() < 3) {
    return false;
  }

  unsigned sectionLength = U16_AT(mBuffer->data() + 1) & 0xfff;
  return mBuffer->size() >= sectionLength + 3;
}

bool ATSParser::PSISection::isEmpty() const {
  return mBuffer == NULL || mBuffer->size() == 0;
}

const uint8_t* ATSParser::PSISection::data() const {
  return mBuffer == NULL ? NULL : mBuffer->data();
}

size_t ATSParser::PSISection::size() const {
  return mBuffer == NULL ? 0 : mBuffer->size();
}
