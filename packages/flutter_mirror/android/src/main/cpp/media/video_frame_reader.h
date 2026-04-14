#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_READER_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_READER_H_

#include <arpa/inet.h>  // For ntohl and ntohll (if not available, implement it)
#include <cstdint>
#include <cstdio>
#include <stdexcept>
#include <vector>
#include "util/log.h"

class VideoFrameReader {
 private:
  FILE* inputFile;

  // Helper function for 64-bit conversion (if ntohll is not available)
  uint64_t ntohll(uint64_t value) const {
    return (((uint64_t)ntohl(value & 0xFFFFFFFF)) << 32) | ntohl(value >> 32);
  }

 public:
  VideoFrameReader(const std::string& filePath)
      : inputFile(nullptr) {
    ALOGV("Opening %s", filePath.c_str());

    inputFile = fopen(filePath.c_str(), "rb");
    if (!inputFile) {
      throw std::runtime_error("Failed to open file: " + filePath);
    }
    ALOGV("Opened %s", filePath.c_str());
  }

  ~VideoFrameReader() {
    if (inputFile) {
      fclose(inputFile);
    }
  }

  bool readFrame(std::vector<uint8_t>& payload, uint64_t& timestamp) {
    if (!inputFile) {
      return false;
    }

    // Read the payload length (4 bytes)
    uint32_t networkLength = 0;
    if (fread(&networkLength, sizeof(networkLength), 1, inputFile) != 1) {
      return false;
    }

    // Convert length to host byte order
    uint32_t length = ntohl(networkLength);

    // Read the timestamp (8 bytes)
    uint64_t networkTimestamp = 0;
    if (fread(&networkTimestamp, sizeof(networkTimestamp), 1, inputFile) != 1) {
      return false;
    }

    // Convert timestamp to host byte order
    timestamp = ntohll(networkTimestamp);

    // Read the payload data
    payload.resize(length);
    if (length > 0 && fread(payload.data(), 1, length, inputFile) != length) {
      return false;
    }

    return true;
  }
};

#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_READER_H_
