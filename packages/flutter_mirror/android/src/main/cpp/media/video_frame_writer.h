#ifndef FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_WRITER_H_
#define FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_WRITER_H_

#include <arpa/inet.h>  // For htonl and htonll (if not available, implement it)
#include <cstdint>
#include <cstdio>
#include <stdexcept>
#include <vector>

class VideoFrameWriter {
 private:
  FILE* outputFile;

  // Helper function for 64-bit conversion (if htonll is not available)
  uint64_t htonll(uint64_t value) const {
    return (((uint64_t)htonl(value & 0xFFFFFFFF)) << 32) | htonl(value >> 32);
  }

 public:
  VideoFrameWriter(const std::string& filePath)
      : outputFile(nullptr) {
    outputFile = fopen(filePath.c_str(), "wb");
    if (!outputFile) {
      throw std::runtime_error("Failed to open file: " + filePath);
    }
  }

  ~VideoFrameWriter() {
    if (outputFile) {
      fclose(outputFile);
    }
  }

  void writeFrame(const std::vector<uint8_t>& payload, uint64_t timestamp) {
    if (!outputFile) {
      throw std::runtime_error("Output file is not open.");
    }

    // Convert values to network byte order
    uint32_t length = htonl(static_cast<uint32_t>(payload.size()));
    uint64_t networkTimestamp = htonll(timestamp);

    // Write the length (4 bytes)
    if (fwrite(&length, sizeof(length), 1, outputFile) != 1) {
      throw std::runtime_error("Failed to write frame length.");
    }

    // Write the timestamp (8 bytes)
    if (fwrite(&networkTimestamp, sizeof(networkTimestamp), 1, outputFile) != 1) {
      throw std::runtime_error("Failed to write frame timestamp.");
    }

    // Write the payload data
    if (!payload.empty()) {
      if (fwrite(payload.data(), 1, payload.size(), outputFile) != payload.size()) {
        throw std::runtime_error("Failed to write frame payload.");
      }
    }
  }
};
#endif  // FLUTTER_MIRROR_PLUGIN_VIDEO_FRAME_WRITER_H_
