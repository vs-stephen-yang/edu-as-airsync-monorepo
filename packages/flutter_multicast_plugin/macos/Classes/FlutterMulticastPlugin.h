#import <FlutterMacOS/FlutterMacOS.h>
#import <Foundation/Foundation.h>

@interface FlutterMulticastPlugin : NSObject <FlutterPlugin>
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end