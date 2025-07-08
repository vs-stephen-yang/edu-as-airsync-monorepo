#import "VideoTexture.h"
#import <Accelerate/Accelerate.h>

@implementation VideoTexture

- (instancetype)init {
    self = [super init];
    if (self) {
        _bufferSemaphore = dispatch_semaphore_create(1);
        _lastWidth = 0;
        _lastHeight = 0;
        _lastUpdateTime = 0;
        _droppedFrameCount = 0;
        [self createInitialBuffer];
    }
    return self;
}

- (void)createInitialBuffer {
    NSLog(@"[VideoTexture] Creating initial buffer");

    // 創建初始 640x480 buffer
    [self createBufferPoolForWidth:640 height:480];
    [self createBufferFromPool];

    if (_currentBuffer) {
        // 使用 vImage 快速填充初始顏色
        [self fillBufferWithColor:_currentBuffer red:0 green:0 blue:50 alpha:255];
        NSLog(@"[VideoTexture] Initial buffer ready with vImage");
    }
}

- (void)fillBufferWithColor:(CVPixelBufferRef)buffer
                        red:(uint8_t)r
                      green:(uint8_t)g
                       blue:(uint8_t)b
                      alpha:(uint8_t)a {
    CVPixelBufferLockBaseAddress(buffer, 0);

    void *baseAddress = CVPixelBufferGetBaseAddress(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);

    if (baseAddress) {
        vImage_Buffer vBuffer = {.data = baseAddress,
                                 .height = height,
                                 .width = CVPixelBufferGetWidth(buffer),
                                 .rowBytes = bytesPerRow};

        // BGRA 格式的顏色值
        Pixel_8888 fillColor = {b, g, r, a};
        vImageBufferFill_ARGB8888(&vBuffer, fillColor, kvImageNoFlags);
    }

    CVPixelBufferUnlockBaseAddress(buffer, 0);
}

- (void)createBufferPoolForWidth:(size_t)width height:(size_t)height {
    // 如果已有相同尺寸的 pool，直接返回
    if (_bufferPool && _lastWidth == width && _lastHeight == height) {
        return;
    }

    // 釋放舊的 pool
    if (_bufferPool) {
        CVPixelBufferPoolRelease(_bufferPool);
        _bufferPool = NULL;
    }

    // 創建 buffer pool 配置（增加到 5 個 buffer 提升效能）
    NSDictionary *poolAttributes = @{
        (NSString *)kCVPixelBufferPoolMinimumBufferCountKey : @5, // 增加到 5 個 buffer
        (NSString *)kCVPixelBufferPoolMaximumBufferAgeKey : @0    // 不限制年齡
    };

    NSDictionary *bufferAttributes = @{
        (NSString *)kCVPixelBufferCGImageCompatibilityKey : @YES,
        (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
        (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (NSString *)kCVPixelBufferWidthKey : @(width),
        (NSString *)kCVPixelBufferHeightKey : @(height),
        (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
        // 記憶體對齊優化
        (NSString *)kCVPixelBufferBytesPerRowAlignmentKey : @64
    };

    CVReturn result =
        CVPixelBufferPoolCreate(kCFAllocatorDefault, (__bridge CFDictionaryRef)poolAttributes,
                                (__bridge CFDictionaryRef)bufferAttributes, &_bufferPool);

    if (result == kCVReturnSuccess) {
        _lastWidth = width;
        _lastHeight = height;
        NSLog(@"[VideoTexture] ✅ Created optimized buffer pool for %zux%zu", width, height);
    } else {
        NSLog(@"[VideoTexture] ❌ Failed to create buffer pool: %d", result);
    }
}

- (CVPixelBufferRef)createBufferFromPool {
    if (!_bufferPool) {
        return NULL;
    }

    CVPixelBufferRef buffer = NULL;
    CVReturn result = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _bufferPool, &buffer);

    if (result == kCVReturnSuccess) {
        return buffer;
    } else {
        NSLog(@"[VideoTexture] Failed to create buffer from pool: %d", result);
        return NULL;
    }
}

- (void)updateWithRGBAData:(const uint8_t *)data
                     width:(size_t)width
                    height:(size_t)height
                    stride:(size_t)stride {
    if (!data || width == 0 || height == 0) {
        return;
    }

    // 非阻塞檢查，避免累積延遲
    if (dispatch_semaphore_wait(_bufferSemaphore, DISPATCH_TIME_NOW) != 0) {
        _droppedFrameCount++;
        if (_droppedFrameCount % 30 == 0) { // 每 30 幀報告一次
            NSLog(@"[VideoTexture] ⚠️ Frame dropped (total: %ld), previous frame still processing ",
                  _droppedFrameCount);
        }
        return;
    }

    @try {
        // 效能測量
        CFTimeInterval startTime = CACurrentMediaTime();

        // 只在尺寸真的改變時才重建 pool
        if (_lastWidth != width || _lastHeight != height) {
            [self createBufferPoolForWidth:width height:height];
        }

        // 從 pool 獲取新 buffer
        CVPixelBufferRef newBuffer = [self createBufferFromPool];
        if (!newBuffer) {
            NSLog(@"[VideoTexture] Failed to get buffer from pool");
            return;
        }

        // 使用 vImage 進行高效能顏色轉換
        CVReturn lockResult = CVPixelBufferLockBaseAddress(newBuffer, 0);
        if (lockResult == kCVReturnSuccess) {

            BOOL success = [self copyDataWithvImage:data
                                             stride:stride
                                              width:width
                                             height:height
                                         destBuffer:newBuffer];

            CVPixelBufferUnlockBaseAddress(newBuffer, 0);

            if (success) {
                // 原子性替換當前 buffer
                CVPixelBufferRef oldBuffer = _currentBuffer;
                _currentBuffer = newBuffer;

                if (oldBuffer) {
                    CVPixelBufferRelease(oldBuffer);
                }

                // 效能日誌
                CFTimeInterval processingTime = CACurrentMediaTime() - startTime;
                _lastUpdateTime = startTime;

                if (processingTime > 0.016) { // 超過 16ms (60fps 限制)
                    NSLog(@"[VideoTexture] ⚠️ Slow frame processing: %.2fms", processingTime * 1000);
                }

            } else {
                CVPixelBufferRelease(newBuffer);
                NSLog(@"[VideoTexture] vImage conversion failed");
            }

        } else {
            CVPixelBufferRelease(newBuffer);
            NSLog(@"[VideoTexture] Failed to lock new buffer: %d", lockResult);
        }

    } @finally {
        dispatch_semaphore_signal(_bufferSemaphore);
    }
}

- (CVPixelBufferRef)copyPixelBuffer {
    // 非阻塞獲取 buffer
    if (dispatch_semaphore_wait(_bufferSemaphore, DISPATCH_TIME_NOW) != 0) {
        // 如果無法立即獲取，返回 nil 讓 Flutter 重用上一幀
        return nil;
    }

    CVPixelBufferRef buffer = _currentBuffer;
    if (buffer) {
        CVPixelBufferRetain(buffer);
    }

    dispatch_semaphore_signal(_bufferSemaphore);
    return buffer;
}

- (BOOL)copyDataWithvImage:(const uint8_t *)srcData
                    stride:(size_t)srcStride
                     width:(size_t)width
                    height:(size_t)height
                destBuffer:(CVPixelBufferRef)destBuffer {

    void *destBaseAddress = CVPixelBufferGetBaseAddress(destBuffer);
    size_t destBytesPerRow = CVPixelBufferGetBytesPerRow(destBuffer);

    if (!destBaseAddress) {
        return NO;
    }

    // 設定 vImage buffer 結構
    vImage_Buffer srcBuffer = {
        .data = (void *)srcData, .height = height, .width = width, .rowBytes = srcStride};

    vImage_Buffer destBuffer_vImage = {
        .data = destBaseAddress, .height = height, .width = width, .rowBytes = destBytesPerRow};

    // 使用 vImage 進行高效能拷貝
    vImage_Error error = vImageCopyBuffer(&srcBuffer, &destBuffer_vImage, 4, kvImageNoFlags);

    if (error != kvImageNoError) {
        NSLog(@"[VideoTexture] vImageCopyBuffer failed: %ld", error);
        return NO;
    }

    return YES;
}

- (void)dealloc {
    NSLog(@"[VideoTexture] Deallocating, total dropped frames: %ld", _droppedFrameCount);

    if (_currentBuffer) {
        CVPixelBufferRelease(_currentBuffer);
        _currentBuffer = NULL;
    }
    if (_bufferPool) {
        CVPixelBufferPoolRelease(_bufferPool);
        _bufferPool = NULL;
    }
}

@end

static VideoTexture *g_video_texture = nil;
static NSObject<FlutterTextureRegistry> *g_texture_registry = nil;
static int64_t g_texture_id = -1;

void set_global_texture_variables(void *videoTexture, void *textureRegistry, int64_t textureId) {
    g_video_texture = (__bridge VideoTexture *)videoTexture;
    g_texture_registry = (__bridge NSObject<FlutterTextureRegistry> *)textureRegistry;
    g_texture_id = textureId;
}

void update_flutter_texture_from_cpp(const uint8_t *data, size_t width, size_t height,
                                     size_t stride) {
    if (g_video_texture && g_texture_registry && g_texture_id >= 0) {
        [g_video_texture updateWithRGBAData:data width:width height:height stride:stride];
        [g_texture_registry textureFrameAvailable:g_texture_id];
    }
}