#import "MulticastBridge.h"

#import "gst_video_pipeline.h"
#import "rtp_receiver_core.h"

static std::unique_ptr<GstVideoPipeline> g_pipeline;
static std::unique_ptr<RtpReceiverCore> g_receiver;

@implementation MulticastBridge

+ (void)receiveStart:(NSArray<NSString *> *)localIps
         multicastIp:(NSString *)multicastIp
           videoPort:(int)videoPort
           audioPort:(int)audioPort
                ssrc:(uint32_t)ssrc
             keyData:(NSData *)keyData
            saltData:(NSData *)saltData
            videoRoc:(uint32_t)videoRoc
            audioRoc:(uint32_t)audioRoc {

    NSLog(@"[MulticastBridge] Starting receive with parameters:");
    NSLog(@"  - Multicast IP: %@", multicastIp);
    NSLog(@"  - Video Port: %d, Audio Port: %d", videoPort, audioPort);
    NSLog(@"  - SSRC: %u", ssrc);
    NSLog(@"  - Video ROC: %u, Audio ROC: %u", videoRoc, audioRoc);
    NSLog(@"  - Local IPs count: %zu", localIps.count);

    // 停止現有的接收
    [self receiveStop];

    @try {
        // 1. 轉換 local IPs 到 std::vector<std::string>
        std::vector<std::string> local_ips_vector;
        for (NSString *ip in localIps) {
            if (ip && ip.length > 0) {
                std::string ip_str([ip UTF8String]);
                local_ips_vector.push_back(ip_str);
                NSLog(@"  - Local IP: %@", ip);
            }
        }

        // 2. 轉換 multicast IP 到 std::string
        std::string multicast_ip_str([multicastIp UTF8String]);

        // 3. 轉換 key 和 salt 到 std::vector<uint8_t>
        std::vector<uint8_t> key_vector;
        std::vector<uint8_t> salt_vector;

        if (keyData && keyData.length > 0) {
            const uint8_t *keyBytes = (const uint8_t *)keyData.bytes;
            key_vector.assign(keyBytes, keyBytes + keyData.length);
        }

        if (saltData && saltData.length > 0) {
            const uint8_t *saltBytes = (const uint8_t *)saltData.bytes;
            salt_vector.assign(saltBytes, saltBytes + saltData.length);
        }

        NSLog(@"[MulticastBridge] Converted parameters successfully");

        // 4. 初始化 GStreamer pipeline
        g_pipeline = std::make_unique<GstVideoPipeline>();
        if (!g_pipeline->init(nullptr)) {
            NSLog(@"[MulticastBridge] ❌ Failed to initialize GStreamer pipeline");
            return;
        }
        NSLog(@"[MulticastBridge] ✅ GStreamer pipeline initialized");

        // 5. 建立 RTP receiver
        g_receiver = std::make_unique<RtpReceiverCore>();

        // 6. 定義視訊回調函數
        auto video_callback = [](const std::vector<uint8_t> &au) {
            NSLog(@"[MulticastBridge] Video callback triggered with AU size: %zu", au.size());
            if (g_pipeline) {
                g_pipeline->push_au(au);
                NSLog(@"[MulticastBridge] Video AU pushed to pipeline");
            } else {
                NSLog(@"[MulticastBridge] ❌ g_pipeline is null in video callback!");
            }
        };

        // 7. 定義音訊回調函數
        auto audio_callback = [](const std::vector<uint8_t> &au) {
            NSLog(@"[MulticastBridge] Audio callback triggered with AU size: %zu", au.size());
            // 如果需要處理音訊，在這裡加入邏輯
            // 目前暫時只記錄
        };

        // 8. 啟動 RTP 接收
        NSLog(@"[MulticastBridge] Starting RTP receiver...");
        g_receiver->start(local_ips_vector, multicast_ip_str, videoPort, audioPort, key_vector,
                          salt_vector, ssrc, videoRoc, audioRoc, video_callback, audio_callback);

        NSLog(@"[MulticastBridge] ✅ RTP receiver started successfully");

    } @catch (NSException *exception) {
        NSLog(@"[MulticastBridge] ❌ Exception during start: %@", exception.reason);
        [self receiveStop];
    } @catch (...) {
        NSLog(@"[MulticastBridge] ❌ Unknown C++ exception during start");
        [self receiveStop];
    }
}

+ (void)receiveStop {
    if (g_receiver) {
        g_receiver->stop();
        g_receiver.reset();
    }
    if (g_pipeline) {
        g_pipeline->stop();
        g_pipeline.reset();
    }
}

@end