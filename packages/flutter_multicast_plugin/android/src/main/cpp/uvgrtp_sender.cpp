#include <jni.h>
#include <uvgrtp/lib.hh>
#include <string.h>
#include "log.h"


static uvgrtp::context *ctx = nullptr;

struct StreamPair {
    uvgrtp::media_stream *videoStream;
    uvgrtp::media_stream *audioStream;
    uvgrtp::session *session;
    std::string local_ip;
};

static std::vector<StreamPair> streamPairs;

static void cleanupStreamPairs() {
    if (!ctx) return;

    for (auto& pair : streamPairs) {
        if (!pair.session) continue;

        if (pair.videoStream) {
            pair.session->destroy_stream(pair.videoStream);
            pair.videoStream = nullptr;
        }

        if (pair.audioStream) {
            pair.session->destroy_stream(pair.audioStream);
            pair.audioStream = nullptr;
        }

        ctx->destroy_session(pair.session);
        pair.session = nullptr;
    }
    streamPairs.clear();
}

static void initializeContext() {
    if (!ctx) {
        ctx = new uvgrtp::context();
    }
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_startRtpStream(JNIEnv *env, jobject thiz, jobjectArray local_ips, jstring ip, jint video_port, jint audio_port, jbyteArray jKey, jbyteArray jSalt, jint ssrc)
{
    const char *c_ip = env->GetStringUTFChars(ip, nullptr);
    int flags = RCE_SEND_ONLY | RCE_SRTP | RCE_SRTP_KMNGMNT_USER | RCE_SRTP_AUTHENTICATE_RTP;

    std::vector<std::string> local_ip_list;
    jsize len = env->GetArrayLength(local_ips);
    for (jsize i = 0; i < len; ++i) {
        jstring jstr = (jstring)env->GetObjectArrayElement(local_ips, i);
        const char* ip_cstr = env->GetStringUTFChars(jstr, nullptr);
        local_ip_list.emplace_back(ip_cstr);
        env->ReleaseStringUTFChars(jstr, ip_cstr);
        env->DeleteLocalRef(jstr);
    }

    cleanupStreamPairs();

    initializeContext();

    std::vector<uint8_t> key(16);
    std::vector<uint8_t> salt(14);
    env->GetByteArrayRegion(jKey, 0, 16, reinterpret_cast<jbyte *>(key.data()));
    env->GetByteArrayRegion(jSalt, 0, 14, reinterpret_cast<jbyte *>(salt.data()));

    uint32_t native_ssrc = static_cast<uint32_t>(ssrc);

    for (const std::string& local_ip : local_ip_list) {
        StreamPair pair;
        pair.local_ip = local_ip;

        // 建立 session，指定 local IP
        pair.session = ctx->create_session(local_ip);
        // pair.session = ctx->create_session(c_ip);
        if (!pair.session) {
            ALOGE("Failed to create session for local IP: %s", local_ip.c_str());
            continue;
        }
        pair.session->set_multicast_address(c_ip);

        // 建立 video stream
        pair.videoStream = pair.session->create_stream(video_port, RTP_FORMAT_H264, flags);
        if (!pair.videoStream) {
            ALOGE("Failed to create video stream for local IP: %s", local_ip.c_str());
            ctx->destroy_session(pair.session);
            continue;
        }

        // 建立 audio stream
        pair.audioStream = pair.session->create_stream(audio_port, RTP_FORMAT_OPUS, flags);
        if (!pair.audioStream) {
            ALOGE("Failed to create audio stream for local IP: %s", local_ip.c_str());
            pair.session->destroy_stream(pair.videoStream);
            ctx->destroy_session(pair.session);
            continue;
        }

        // 配置 SRTP
        ALOGI("Configuring SRTP for local IP: %s", local_ip.c_str());
        pair.videoStream->add_srtp_ctx(key.data(), salt.data());
        pair.audioStream->add_srtp_ctx(key.data(), salt.data());

        // 配置 SSRC
        pair.videoStream->configure_ctx(RCC_SSRC, native_ssrc);
        pair.audioStream->configure_ctx(RCC_SSRC, native_ssrc);

        // 配置 payload type
        pair.videoStream->configure_ctx(RCC_DYN_PAYLOAD_TYPE, 96);
        pair.audioStream->configure_ctx(RCC_DYN_PAYLOAD_TYPE, 97);

        streamPairs.push_back(pair);
        ALOGI("Successfully created streams for local IP: %s", local_ip.c_str());
    }

    env->ReleaseStringUTFChars(ip, c_ip);

    if (streamPairs.empty()) {
        ALOGE("Failed to create any streams");
        return JNI_FALSE;
    }

    ALOGI("uvgRTP streams and sessions created successfully for %zu local IPs", streamPairs.size());
    return JNI_TRUE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_sendRtpFrame(JNIEnv *env, jobject thiz, jbyteArray frame)
{
    if (streamPairs.empty()) {
        ALOGE("No video streams available");
        return;
    }

    jbyte *buf = env->GetByteArrayElements(frame, nullptr);
    jsize len = env->GetArrayLength(frame);

    for (auto& pair : streamPairs) {
        if (pair.videoStream) {
            rtp_error_t ret = pair.videoStream->push_frame(reinterpret_cast<uint8_t*>(buf), len, RTP_NO_FLAGS);
            if (ret != RTP_OK) {
                ALOGE("Failed to send video data via local IP: %s", pair.local_ip.c_str());
                continue;
            }
        }
    }

    env->ReleaseByteArrayElements(frame, buf, JNI_ABORT);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_sendAudioRtpFrame(JNIEnv *env, jobject thiz, jbyteArray frame)
{
    if (streamPairs.empty()) {
        ALOGE("No video streams available");
        return;
    }

    jbyte *buf = env->GetByteArrayElements(frame, nullptr);
    jsize len = env->GetArrayLength(frame);

    for (auto& pair : streamPairs) {
        if (pair.audioStream) {
            rtp_error_t ret = pair.audioStream->push_frame(reinterpret_cast<uint8_t*>(buf), len, RTP_NO_FLAGS);
            if (ret != RTP_OK) {
                ALOGE("Failed to send audio data via local IP: %s", pair.local_ip.c_str());
                continue;
            }
        }
    }

    env->ReleaseByteArrayElements(frame, buf, JNI_ABORT);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1multicast_1plugin_NativeBridge_stopRtpStream(JNIEnv *env, jobject thiz)
{
    cleanupStreamPairs();
    if (ctx)
    {
        delete ctx;
        ctx = nullptr;
    }
    ALOGI("RTP stream stopped");
}