#import <Foundation/Foundation.h>

@class FlutterStandardTypedData;

@interface MulticastBridge : NSObject
+ (void)receiveStart:(NSArray<NSString *> *)localIps
         multicastIp:(NSString *)multicastIp
           videoPort:(int)videoPort
           audioPort:(int)audioPort
                ssrc:(uint32_t)ssrc
             keyData:(NSData *)keyData
            saltData:(NSData *)saltData
            videoRoc:(uint32_t)videoRoc
            audioRoc:(uint32_t)audioRoc;

+ (void)receiveStop;
@end