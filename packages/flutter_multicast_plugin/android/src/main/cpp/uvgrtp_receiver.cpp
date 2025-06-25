#include <jni.h>
// Android log
#include <android/native_window.h>
#include <android/native_window_jni.h>

// uvgrtp
#include <uvgrtp/lib.hh>

// C++
#include <thread>
#include <atomic>

#include "log.h"
#include "rtp_receiver_core.h"
#include "gst_video_pipeline.h"

static std::thread receiver_thread;
static std::atomic<bool> running{false};

static std::unique_ptr<RtpReceiverCore> g_receiver;
static std::unique_ptr<GstVideoPipeline> g_pipeline;

static JavaVM *java_vm;

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_receiveStart(JNIEnv *env, jobject thiz, jobject surface, jobjectArray localIps, jstring multicastIp, jint port, jbyteArray jKey, jbyteArray jSalt, jint ssrc, jlong roc)
{
    ANativeWindow *native_window = ANativeWindow_fromSurface(env, surface);
    ALOGD("Received surface %p (native window %p)", surface, native_window);

    g_pipeline = std::make_unique<GstVideoPipeline>();
    g_pipeline->init(native_window);
    ANativeWindow_release(native_window);

    std::vector<uint8_t> key(16);
    std::vector<uint8_t> salt(14);

    env->GetByteArrayRegion(jKey, 0, 16, reinterpret_cast<jbyte *>(key.data()));
    env->GetByteArrayRegion(jSalt, 0, 14, reinterpret_cast<jbyte *>(salt.data()));

    const char *c_ip = env->GetStringUTFChars(multicastIp, nullptr);
    uint32_t native_ssrc = static_cast<uint32_t>(ssrc);

    uint32_t rocValue = static_cast<uint32_t>(roc);

    std::vector<std::string> local_ip_list;

    jsize len = env->GetArrayLength(localIps);
    for (jsize i = 0; i < len; ++i) {
        jstring jstr = (jstring)env->GetObjectArrayElement(localIps, i);
        const char* ip_cstr = env->GetStringUTFChars(jstr, nullptr);
        local_ip_list.emplace_back(ip_cstr);
        env->ReleaseStringUTFChars(jstr, ip_cstr);
        env->DeleteLocalRef(jstr);
    }

    g_receiver = std::make_unique<RtpReceiverCore>();
    g_receiver->start(local_ip_list, c_ip, port, key, salt, native_ssrc, rocValue,
                      [](const std::vector<uint8_t> &au)
                      {
                          g_pipeline->push_au(au);
                      }
    );

    env->ReleaseStringUTFChars(multicastIp, c_ip);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_receiveStop(JNIEnv *, jobject)
{
    if (g_receiver)
        g_receiver->stop();
    if (g_pipeline)
        g_pipeline->stop();
    g_receiver.reset();
    g_pipeline.reset();
}

jint JNI_OnLoad(JavaVM *vm, void *reserved)
{
    java_vm = vm;

    return JNI_VERSION_1_4;
}