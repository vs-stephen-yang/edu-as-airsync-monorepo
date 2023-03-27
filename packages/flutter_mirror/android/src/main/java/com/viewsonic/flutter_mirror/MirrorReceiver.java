package com.viewsonic.flutter_mirror;

public class MirrorReceiver implements
    MirrorListener {

  private long instance_;
  private MirrorListener mirrorListener_;

  public MirrorReceiver(
      MirrorListener mirrorListener,
      TexRegistry textureRegistry) {
    assert mirrorListener != null;
    assert textureRegistry != null;

    mirrorListener_ = mirrorListener;

    instance_ = createInstanceNative(
        textureRegistry);

    assert (instance_ != 0);
  }

  // start airplay
  public void startAirplay(String name) {
    assert instance_ != 0;

    startAirplayNative(
        instance_,
        name);
  }

  // stop a mirror session by its Id
  public void stopMirror(String mirrorId) {
    assert instance_ != 0;

    stopMirrorNative(
        instance_,
        mirrorId);
  }

  @Override
  public void onMirrorAuth(String pin, int timeoutSec) {
    mirrorListener_.onMirrorAuth(pin, timeoutSec);
  }

  @Override
  public void onMirrorStart(String mirrorId, long textureId) {
    mirrorListener_.onMirrorStart(mirrorId, textureId);
  }

  @Override
  public void onMirrorStop(String mirrorId) {
    mirrorListener_.onMirrorStop(mirrorId);
  }

  @Override
  public void onMirrorVideoResize(String mirrorId, int width, int height) {
    mirrorListener_.onMirrorVideoResize(mirrorId, width, height);
  }

  private native long createInstanceNative(
      TexRegistry textureRegistry);

  private native void DestroyInstanceNative(
      long instance);

  private native void startAirplayNative(
      long instance,
      String name);

  private native void stopMirrorNative(
      long instance,
      String mirrorId);
}
