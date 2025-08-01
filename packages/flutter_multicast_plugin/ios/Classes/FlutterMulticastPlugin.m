#import "FlutterMulticastPlugin.h"
#import "MulticastBridge.h"
#import "VideoTexture.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <net/if.h>

void set_plugin_instance(FlutterMulticastPlugin *instance);

@implementation FlutterMulticastPlugin {
    VideoTexture *_videoTexture;
    NSObject<FlutterTextureRegistry> *_textureRegistry;
    int64_t _textureId;
    BOOL _hasNotifiedResolution;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"flutter_multicast_plugin"
                                    binaryMessenger:[registrar messenger]];
    FlutterMulticastPlugin *instance = [[FlutterMulticastPlugin alloc] init];
    instance.registrar = registrar;
    instance.channel = channel;
    set_plugin_instance(instance);
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _textureId = -1;
        _videoTexture = nil;
        _textureRegistry = nil;
        _hasNotifiedResolution = NO;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"receiveStart" isEqualToString:call.method]) {
        // 取得所有參數
        NSString *multicastIp = call.arguments[@"ip"];
        NSNumber *videoPortNumber = call.arguments[@"videoPort"];
        NSNumber *audioPortNumber = call.arguments[@"audioPort"];
        NSNumber *ssrcNumber = call.arguments[@"ssrc"];
        FlutterStandardTypedData *keyData = call.arguments[@"key"];
        FlutterStandardTypedData *saltData = call.arguments[@"salt"];
        NSNumber *videoRocNumber = call.arguments[@"videoRoc"];
        NSNumber *audioRocNumber = call.arguments[@"audioRoc"];

        // 檢查所有必要參數是否存在
        if (!multicastIp || !videoPortNumber || !audioPortNumber || !ssrcNumber || !keyData ||
            !saltData || !videoRocNumber || !audioRocNumber) {
            result([FlutterError errorWithCode:@"MISSING_ARGUMENT"
                                       message:@"One or more arguments are missing or null"
                                       details:nil]);
            return;
        }

        // 轉換參數類型
        int videoPort = [videoPortNumber intValue];
        int audioPort = [audioPortNumber intValue];
        uint32_t ssrc = [ssrcNumber unsignedIntValue];
        uint32_t videoRoc = [videoRocNumber unsignedIntValue];
        uint32_t audioRoc = [audioRocNumber unsignedIntValue];

        NSData *keyNSData = keyData.data;
        NSData *saltNSData = saltData.data;

        [self startReceiving:multicastIp
                   videoPort:videoPort
                   audioPort:audioPort
                        ssrc:ssrc
                     keyData:keyNSData
                    saltData:saltNSData
                    videoRoc:videoRoc
                    audioRoc:audioRoc];

        if (_textureId >= 0) {
            result(@(_textureId));
        } else {
            result([FlutterError errorWithCode:@"RECEIVE_START_ERROR"
                                       message:@"Failed to start receiving"
                                       details:nil]);
        }
    } else if ([@"receiveStop" isEqualToString:call.method]) {
        [self stopReceiving];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (int64_t)startReceiving:(NSString *)multicastIp
                videoPort:(int)videoPort
                audioPort:(int)audioPort
                     ssrc:(uint32_t)ssrc
                  keyData:(FlutterStandardTypedData *)keyData
                 saltData:(FlutterStandardTypedData *)saltData
                 videoRoc:(uint32_t)videoRoc
                 audioRoc:(uint32_t)audioRoc {
    _textureRegistry = [self.registrar textures];
    _videoTexture = [[VideoTexture alloc] init];
    _textureId = [_textureRegistry registerTexture:_videoTexture];

    NSLog(@"[FlutterMulticastPlugin] Using texture with ID: %lld", _textureId);

    if (_textureId < 0) {
        NSLog(@"[FlutterMulticastPlugin] ❌ Invalid texture ID!");
        return -1;
    }

    [self setupGlobalTextureVariables];
    [_textureRegistry textureFrameAvailable:_textureId];

    NSArray<NSString *> *localIps = [self getAllLocalIPv4s];

    [MulticastBridge receiveStart:localIps
                      multicastIp:multicastIp
                        videoPort:videoPort
                        audioPort:audioPort
                             ssrc:ssrc
                          keyData:keyData
                         saltData:saltData
                         videoRoc:videoRoc
                         audioRoc:audioRoc];

    _hasNotifiedResolution = NO;

    return _textureId;
}

- (void)stopReceiving {
    NSLog(@"[FlutterMulticastPlugin] Stopping RTP receiver");

    [MulticastBridge receiveStop];

    if (_textureRegistry && _textureId >= 0) {
        [_textureRegistry unregisterTexture:_textureId];
        _textureId = -1;
    }

    _videoTexture = nil;
    _textureRegistry = nil;
    [self clearGlobalTextureVariables];
}

- (NSArray<NSString *> *)getAllLocalIPv4s {
    NSMutableArray *ipArray = [[NSMutableArray alloc] init];

    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;

    // 取得所有網路介面
    if (getifaddrs(&interfaces) == 0) {
        temp_addr = interfaces;

        while (temp_addr != NULL) {
            // 只處理 IPv4 (AF_INET)
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // 檢查介面是否啟用且非 loopback
                if ((temp_addr->ifa_flags & IFF_UP) && !(temp_addr->ifa_flags & IFF_LOOPBACK)) {
                    // 轉換 IP 地址
                    char addressBuffer[INET_ADDRSTRLEN];
                    struct sockaddr_in *addr_in = (struct sockaddr_in *)temp_addr->ifa_addr;

                    if (inet_ntop(AF_INET, &(addr_in->sin_addr), addressBuffer, INET_ADDRSTRLEN)) {
                        NSString *ipString = [NSString stringWithUTF8String:addressBuffer];
                        [ipArray addObject:ipString];

                        NSLog(@"Found IP: %@ on interface: %s", ipString, temp_addr->ifa_name);
                    }
                }
            }

            temp_addr = temp_addr->ifa_next;
        }

        freeifaddrs(interfaces);
    }

    return [ipArray copy];
}

- (void)setupGlobalTextureVariables {
    set_global_texture_variables((__bridge void *)_videoTexture, (__bridge void *)_textureRegistry,
                                 _textureId);
}

- (void)clearGlobalTextureVariables {
    set_global_texture_variables(NULL, NULL, -1);
}

- (void)notifyVideoResolution:(int)width height:(int)height {
    if (self.channel && !_hasNotifiedResolution) {
        [self.channel invokeMethod:@"onVideoSize"
                         arguments:@{@"width" : @(width), @"height" : @(height)}];
        _hasNotifiedResolution = YES;
    }
}

@end

static FlutterMulticastPlugin *g_plugin_instance = nil;

void set_plugin_instance(FlutterMulticastPlugin *instance) { g_plugin_instance = instance; }

void notify_flutter_video_resolution(int width, int height) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (g_plugin_instance) {
          [g_plugin_instance notifyVideoResolution:width height:height];
      }
    });
}
