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
    : public MirrorSession,
      public MediaSession::Listener,
      public ATSParser::Callback {
 public:
  MiracastMirrorSession(
      const std::string& mirrorId,
      const std::string& device_name,
      MirrorListener& mirror_listener,
      MiracastReceiver& receiver);

  ~MiracastMirrorSession();

  // implements MirrorSession
  virtual bool StartMirror(
      MediaSessionPtr media_session) override;

  virtual std::string GetMirrorId() override;
  virtual SurfaceTexture GetTexture() override;
  virtual std::string GetSourceDisplayName() override;

  virtual MirrorType GetMirrorType() override;

  virtual void EnableAudio(bool enable) override;

  virtual void StopMirror() override;
  virtual void Close() override;

  //
  void OnMirrorStop();

  void processRTPData(const uint8_t* data, int length);

  void UpdateAudioFormat(
      const std::string& codecName,
      int sampleRate,
      int channelCount);

  // implements ATSParser::Callback
  virtual void OnAudioFrame(
      const uint8_t* frame,
      size_t frameSize,
      uint64_t timestamp_us) override;

  virtual void OnVideoFrame(
      bool key_frame,
      const uint8_t* frame,
      size_t frameSize,
      uint64_t timestamp_us) override;

  virtual void OnPacketLoss() override;

  // implements MediaSession::Listener
  virtual void OnVideoFormatChanged(
      int width,
      int height) override;

  virtual void OnVideoFrameRate(int fps) override;

 private:
  std::string mirror_id_;
  std::string device_name_;

  MiracastReceiver& receiver_;
  MirrorListener& mirror_listener_;

  MediaSessionPtr media_session_;

  ATSParserPtr ts_parser_;

  std::string codec_name_;
  int sample_rate_ = 0;
  int channel_count_ = 0;

  int64_t num_packets_received_ = 0;
  uint64_t packets_offset_ = 0;
};
typedef std::shared_ptr<MiracastMirrorSession> MiracastMirrorSessionPtr;
#endif  // FLUTTER_MIRROR_PLUGIN_MIRACAST_MIRROR_SESSION_H_
