#include <jni.h>
#include <uvgrtp/lib.hh>
#include <string.h>
#include "log.h"


static uvgrtp::context *ctx = nullptr;
static uvgrtp::media_stream *stream = nullptr;
static uvgrtp::session *sess = nullptr;

std::string to_hex_string(const std::vector<uint8_t> &data);

extern "C" JNIEXPORT jboolean JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_startRtpStream(JNIEnv *env, jobject thiz, jstring ip, jint port, jbyteArray jKey, jbyteArray jSalt, jint ssrc)
{
    const char *c_ip = env->GetStringUTFChars(ip, nullptr);
    int flags = RCE_SEND_ONLY | RCE_SRTP | RCE_SRTP_KMNGMNT_USER;

    ctx = new uvgrtp::context();
    sess = ctx->create_session(c_ip);
    stream = sess->create_stream(port, RTP_FORMAT_H264, flags);

    if (!stream)
    {
        ALOGE("Failed to create RTP stream");
        return JNI_FALSE;
    }

    stream->configure_ctx(RCC_DYN_PAYLOAD_TYPE, 96);

    std::vector<uint8_t> key(16);
    std::vector<uint8_t> salt(14);

    env->GetByteArrayRegion(jKey, 0, 16, reinterpret_cast<jbyte *>(key.data()));
    env->GetByteArrayRegion(jSalt, 0, 14, reinterpret_cast<jbyte *>(salt.data()));

    ALOGI("SRTP sendKey: %s", to_hex_string(key).c_str());
    ALOGI("SRTP recvKey: %s", to_hex_string(salt).c_str());
    ALOGI("Calling add_srtp_ctx");
    stream->add_srtp_ctx(key.data(), salt.data());
    ALOGI("Finished add_srtp_ctx");

    uint32_t native_ssrc = static_cast<uint32_t>(ssrc);
    stream->configure_ctx(RCC_SSRC, native_ssrc);

    ALOGI("SRTP keys configured successfully");
    stream->configure_ctx(RCC_DYN_PAYLOAD_TYPE, 96);

    ALOGI("RTP stream started to %s:%d", c_ip, port);
    env->ReleaseStringUTFChars(ip, c_ip);
    ALOGI("uvgRTP stream and session created successfully");
    return JNI_TRUE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_sendRtpFrame(JNIEnv *env, jobject thiz, jbyteArray frame)
{
    if (!stream)
        return;

    jbyte *buf = env->GetByteArrayElements(frame, nullptr);
    jsize len = env->GetArrayLength(frame);

    stream->push_frame(reinterpret_cast<uint8_t *>(buf), len, RTP_NO_FLAGS);
    env->ReleaseByteArrayElements(frame, buf, JNI_ABORT);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_stopRtpStream(JNIEnv *env, jobject thiz)
{
    if (stream && ctx)
    {
        sess->destroy_stream(stream);
        stream = nullptr;

        ctx->destroy_session(sess);
        sess = nullptr;
    }
    if (ctx)
    {
        delete ctx;
        ctx = nullptr;
    }
    ALOGI("RTP stream stopped");
}

std::string to_hex_string(const std::vector<uint8_t> &data)
{
    std::string hex;
    char buf[4];
    for (size_t i = 0; i < data.size(); ++i)
    {
        snprintf(buf, sizeof(buf), "%02x", data[i]);
        hex += buf;
    }
    return hex;
}