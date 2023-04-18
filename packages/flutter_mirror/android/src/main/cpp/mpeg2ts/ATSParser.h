#ifndef TS_PARSER_H_
#define TS_PARSER_H_

#include <stdint.h>
#include <map>
#include <memory>
#include <vector>
#include "Errors.h"

struct ABitReader;
struct ABuffer;
struct MediaSource;

struct ATSParser {
  enum DiscontinuityType {
    DISCONTINUITY_NONE = 0,
    DISCONTINUITY_TIME = 1,
    DISCONTINUITY_AUDIO_FORMAT = 2,
    DISCONTINUITY_VIDEO_FORMAT = 4,
    DISCONTINUITY_ABSOLUTE_TIME = 8,

    DISCONTINUITY_SEEK = DISCONTINUITY_TIME,

    // For legacy reasons this also implies a time discontinuity.
    DISCONTINUITY_FORMATCHANGE =
        DISCONTINUITY_AUDIO_FORMAT | DISCONTINUITY_VIDEO_FORMAT | DISCONTINUITY_TIME,
  };

  enum Flags {
    // The 90kHz clock (PTS/DTS) is absolute, i.e. PTS=0 corresponds to
    // a media time of 0.
    // If this flag is _not_ specified, the first PTS encountered in a
    // program of this stream will be assumed to correspond to media time 0
    // instead.
    TS_TIMESTAMPS_ARE_ABSOLUTE = 1,
    // Video PES packets contain exactly one (aligned) access unit.
    ALIGNED_VIDEO_DATA = 2,
  };

  class Callback {
   public:
    virtual ~Callback() {}

    virtual void OnAudioFrame(
        const uint8_t* frame,
        size_t frameSize,
        uint64_t timestamp_us) = 0;

    virtual void OnVideoFrame(
        bool key_frame,
        const uint8_t* frame,
        size_t frameSize,
        uint64_t timestamp_us) = 0;

    virtual void OnPacketLoss() = 0;
  };

  ATSParser(Callback* callback, uint32_t flags = 0);

  bool feedTSPacket(const void* data, size_t size);

  enum SourceType {
    VIDEO,
    AUDIO
  };

  bool PTSTimeDeltaEstablished();

  enum {
    // From ISO/IEC 13818-1: 2000 (E), Table 2-29
    STREAMTYPE_RESERVED = 0x00,
    STREAMTYPE_MPEG1_VIDEO = 0x01,
    STREAMTYPE_MPEG2_VIDEO = 0x02,
    STREAMTYPE_MPEG1_AUDIO = 0x03,
    STREAMTYPE_MPEG2_AUDIO = 0x04,
    STREAMTYPE_MPEG2_AUDIO_ADTS = 0x0f,
    STREAMTYPE_MPEG4_VIDEO = 0x10,
    STREAMTYPE_H264 = 0x1b,
    STREAMTYPE_PCM_AUDIO = 0x83,
  };

  virtual ~ATSParser();

 private:
  struct Program;
  struct Stream;
  struct PSISection;

  uint32_t mFlags;
  std::vector<std::shared_ptr<Program>> mPrograms;

  // Keyed by PID
  std::map<unsigned, std::shared_ptr<PSISection>> mPSISections;

  int64_t mAbsoluteTimeAnchorUs;

  size_t mNumTSPacketsParsed;

  void parseProgramAssociationTable(ABitReader* br);

  status_t parsePID(
      ABitReader* br,
      unsigned PID,
      unsigned continuity_counter,
      unsigned payload_unit_start_indicator,
      unsigned random_access_indicator);

  void parseAdaptationField(ABitReader* br, unsigned PID, unsigned* random_access_indicator);
  status_t parseTS(ABitReader* br);

  void updatePCR(unsigned PID, uint64_t PCR, size_t byteOffsetFromStart);

  uint64_t mPCR[2];
  size_t mPCRBytes[2];
  int64_t mSystemTimeUs[2];
  size_t mNumPCRs;
  Callback* callback_ = nullptr;
};

typedef std::unique_ptr<ATSParser> ATSParserPtr;
static const size_t kTSPacketSize = 188;
#endif  // TS_PARSER_H_
