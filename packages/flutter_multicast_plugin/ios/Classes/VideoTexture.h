#import <CoreVideo/CoreVideo.h>
#import <Flutter/Flutter.h>

// 前向宣告 C 函數
void set_global_texture_variables(void *videoTexture, void *textureRegistry, int64_t textureId);
void update_flutter_texture_from_cpp(const uint8_t *data, size_t width, size_t height,
                                     size_t stride);

@interface VideoTexture : NSObject <FlutterTexture>
@property(nonatomic, assign) CVPixelBufferRef currentBuffer;
@property(nonatomic, assign) CVPixelBufferPoolRef bufferPool;
@property(nonatomic, strong) dispatch_semaphore_t bufferSemaphore;
@property(nonatomic, assign) size_t lastWidth;
@property(nonatomic, assign) size_t lastHeight;
@property(nonatomic, assign) CFTimeInterval lastUpdateTime;
@property(nonatomic, assign) NSInteger droppedFrameCount;
- (void)updateWithRGBAData:(const uint8_t *)data
                     width:(size_t)width
                    height:(size_t)height
                    stride:(size_t)stride;
@end