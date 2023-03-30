#ifndef FLUTTER_MIRROR_PLUGIN_MIRACAST_MIRROR_SESSION_H_
#define FLUTTER_MIRROR_PLUGIN_MIRACAST_MIRROR_SESSION_H_

#include <memory>
#include <string>
#include <vector>
#include "jni/texture_registry.h"
#include "media/audio_decoder.h"
#include "media/surface_texture.h"
#include "media/video_decoder.h"
#include "mirror_listener.h"
#include "mpeg2ts/ATSParser.h"

class MiracastReceiver;

class MiracastMirrorSession
    : public VideoDecoder::Callback,
      public ATSParser::Callback {
 public:
  MiracastMirrorSession(
      int id,
      jni::TextureRegistry& texture_registry,
      MiracastReceiver& receiver);

  int Id() const;
  SurfaceTexture GetTexture() const;

  bool StartMirror();

  void StopMirror();

  void processRTPData(const uint8_t* data, int length);

  void UpdateAudioFormat(
      const std::string& codecName,
      int sampleRate,
      int channelCount);

  // implements ATSParser::Callback
  virtual void OnAudioFrame(
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  virtual void OnAudioFrame(
      const uint8_t* frame,
      size_t frameSize,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      std::shared_ptr<std::vector<uint8_t>> frame,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      const uint8_t* frame,
      size_t frameSize,
      uint64_t timestamp_us) override;

  virtual void OnPacketLoss() override;

  // implements VideoDecoder::Callback
  virtual void OnVideoFormatChanged(
      int width,
      int height) override;

 private:
  void CreateAudioDecoder();

 private:
  const int id_ = 0;
  jni::TextureRegistry& texture_registry_;
  MiracastReceiver& receiver_;

  ATSParserPtr ts_parser_;

  // video
  std::unique_ptr<VideoDecoder> video_decoder_;
  SurfaceTexture texture_;

  // audio
  std::unique_ptr<AudioDecoder> audio_decoder_;
  std::string codec_name_;
  int sample_rate_ = 0;
  int channel_count_ = 0;

  int64_t num_packets_received_ = 0;
  uint64_t packets_offset_ = 0;
};
typedef std::unique_ptr<MiracastMirrorSession> MiracastMirrorSessionPtr;
#endif  // FLUTTER_MIRROR_PLUGIN_MIRACAST_MIRROR_SESSION_H_
