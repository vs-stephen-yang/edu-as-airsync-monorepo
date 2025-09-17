#include <android/log.h>
#include <jni.h>
#include <cstdint>
#include "../media/rtp_mpegts_player_gst.h"

static inline jlong ptr_to_jlong(void* p) {
  return reinterpret_cast<jlong>(p);
}

static inline RtpMpegTsPlayerGst* jlong_to_player(jlong h) {
  return reinterpret_cast<RtpMpegTsPlayerGst*>(h);
}

extern "C" JNIEXPORT jlong JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeCreate(JNIEnv* env, jobject thiz) {
  (void)env;
  (void)thiz;
  RtpMpegTsPlayerGst* p = new (std::nothrow) RtpMpegTsPlayerGst();
  if (!p) {
    return 0;
  }
  p->SetJavaInstance(env, thiz);
  return ptr_to_jlong(p);
}

extern "C" JNIEXPORT void JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeDestroy(JNIEnv* env, jobject thiz, jlong handle) {
  (void)env;
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return;
  }
  delete p;
}

extern "C" JNIEXPORT jboolean JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeStart(JNIEnv* env, jobject thiz, jlong handle) {
  (void)env;
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return JNI_FALSE;
  }

  bool ok = p->Start();
  return ok ? JNI_TRUE : JNI_FALSE;
}

extern "C" JNIEXPORT void JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeStop(JNIEnv* env, jobject thiz, jlong handle) {
  (void)env;
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return;
  }
  p->Stop();
}

extern "C" JNIEXPORT void JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeSetSurface(JNIEnv* env, jobject thiz, jlong handle, jobject surface) {
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return;
  }
  p->SetSurface(env, surface);
}

extern "C" JNIEXPORT jint JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeGetPort(JNIEnv* env, jobject thiz, jlong handle) {
  (void)env;
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return 0;
  }
  return static_cast<jint>(p->GetPort());
}

extern "C" JNIEXPORT void JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativePause(JNIEnv* env, jobject thiz, jlong handle) {
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return;
  }
  p->Pause();
}

extern "C" JNIEXPORT void JNICALL Java_com_viewsonic_miracast_rtp_RtpMpegTsPlayer_nativeRestart(JNIEnv* env, jobject thiz, jlong handle, jobject surface) {
  (void)thiz;
  RtpMpegTsPlayerGst* p = jlong_to_player(handle);
  if (!p) {
    return;
  }
  p->Restart(env, surface);
}