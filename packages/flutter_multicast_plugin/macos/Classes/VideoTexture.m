#import "VideoTexture.h"
#import <Accelerate/Accelerate.h>

@interface VideoTexture ()
@property(nonatomic) CVPixelBufferRef displayBuffer; // 專門給 Flutter 顯示的
@property(nonatomic) CVPixelBufferRef workingBuffer; // 正在處理的
@end

@implementation VideoTexture

- (instancetype)init {
  self = [super init];
  if (self) {
    _bufferSemaphore = dispatch_semaphore_create(1);
    _lastWidth = 0;
    _lastHeight = 0;
    _lastUpdateTime = 0;
    _droppedFrameCount = 0;
    _displayBuffer = NULL;
    _workingBuffer = NULL;
    [self createInitialBuffer];
  }
  return self;
}

- (void)createInitialBuffer {
  NSLog(@"[VideoTexture] Creating initial buffer");

  // 創建初始 640x480 buffer
  [self createBufferPoolForWidth:640 height:480];
  CVPixelBufferRef initialBuffer = [self createBufferFromPool];

  if (initialBuffer) {
    [self fillBufferWithColor:initialBuffer red:0 green:0 blue:50 alpha:255];
    _displayBuffer = initialBuffer;
    NSLog(@"[VideoTexture] Initial display buffer ready");
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
  size_t width = CVPixelBufferGetWidth(buffer);

  if (baseAddress) {
    vImage_Buffer vBuffer = {.data = baseAddress,
                             .height = height,
                             .width = width,
                             .rowBytes = bytesPerRow};

    // BGRA 格式的顏色值
    Pixel_8888 fillColor = {b, g, r, a};
    vImageBufferFill_ARGB8888(&vBuffer, fillColor, kvImageNoFlags);
  }

  CVPixelBufferUnlockBaseAddress(buffer, 0);
}

- (void)createBufferPoolForWidth:(size_t)width height:(size_t)height {
  if (_bufferPool && _lastWidth == width && _lastHeight == height) {
    return;
  }

  if (_bufferPool) {
    CVPixelBufferPoolRelease(_bufferPool);
    _bufferPool = NULL;
  }

  NSDictionary *poolAttributes = @{
    (NSString *)kCVPixelBufferPoolMinimumBufferCountKey : @3,
    (NSString *)kCVPixelBufferPoolMaximumBufferAgeKey : @0
  };

  NSDictionary *bufferAttributes = @{
    (NSString *)kCVPixelBufferCGImageCompatibilityKey : @YES,
    (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
    (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
    (NSString *)kCVPixelBufferWidthKey : @(width),
    (NSString *)kCVPixelBufferHeightKey : @(height),
    (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
    (NSString *)kCVPixelBufferBytesPerRowAlignmentKey : @64
  };

  CVReturn result = CVPixelBufferPoolCreate(
      kCFAllocatorDefault, (__bridge CFDictionaryRef)poolAttributes,
      (__bridge CFDictionaryRef)bufferAttributes, &_bufferPool);

  if (result == kCVReturnSuccess) {
    _lastWidth = width;
    _lastHeight = height;
    NSLog(@"[VideoTexture] ✅ Created buffer pool for %zux%zu", width, height);
  } else {
    NSLog(@"[VideoTexture] ❌ Failed to create buffer pool: %d", result);
  }
}

- (CVPixelBufferRef)createBufferFromPool {
  if (!_bufferPool) {
    return NULL;
  }

  CVPixelBufferRef buffer = NULL;
  CVReturn result = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,
                                                       _bufferPool, &buffer);

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

  if (dispatch_semaphore_wait(_bufferSemaphore, DISPATCH_TIME_NOW) != 0) {
    _droppedFrameCount++;
    return;
  }

  @try {
    if (_lastWidth != width || _lastHeight != height) {
      [self createBufferPoolForWidth:width height:height];

      if (_workingBuffer) {
        CVPixelBufferRelease(_workingBuffer);
        _workingBuffer = NULL;
      }
      if (_displayBuffer) {
        CVPixelBufferRelease(_displayBuffer);
        _displayBuffer = NULL;
      }

      _displayBuffer = [self createBufferFromPool];
      if (_displayBuffer) {
        [self fillBufferWithColor:_displayBuffer
                              red:0
                            green:0
                             blue:50
                            alpha:255];
      }
    }

    if (!_workingBuffer) {
      _workingBuffer = [self createBufferFromPool];
      if (!_workingBuffer) {
        return;
      }
    }

    CVReturn lockResult = CVPixelBufferLockBaseAddress(_workingBuffer, 0);
    if (lockResult == kCVReturnSuccess) {

      BOOL success = [self copyDataWithvImage:data
                                       stride:stride
                                        width:width
                                       height:height
                                   destBuffer:_workingBuffer];

      CVPixelBufferUnlockBaseAddress(_workingBuffer, 0);

      if (success) {
        CVPixelBufferRef oldDisplay = _displayBuffer;
        _displayBuffer = _workingBuffer;
        _workingBuffer = oldDisplay;
      }
    }

  } @finally {
    dispatch_semaphore_signal(_bufferSemaphore);
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
  if (_displayBuffer) {
    CVPixelBufferRetain(_displayBuffer);
    return _displayBuffer;
  }
  return nil;
}

- (BOOL)copyDataWithvImage:(const uint8_t *)srcData
                    stride:(size_t)srcStride
                     width:(size_t)width
                    height:(size_t)height
                destBuffer:(CVPixelBufferRef)destBuffer {

  void *destBaseAddress = CVPixelBufferGetBaseAddress(destBuffer);
  size_t destBytesPerRow = CVPixelBufferGetBytesPerRow(destBuffer);

  vImage_Buffer srcBuffer = {.data = (void *)srcData,
                             .height = height,
                             .width = width,
                             .rowBytes = srcStride};

  vImage_Buffer destBuffer_vImage = {.data = destBaseAddress,
                                     .height = height,
                                     .width = width,
                                     .rowBytes = destBytesPerRow};

  vImage_Error error =
      vImageCopyBuffer(&srcBuffer, &destBuffer_vImage, 4, kvImageNoFlags);

  return (error == kvImageNoError);
}

- (void)dealloc {
  NSLog(@"[VideoTexture] Deallocating, total dropped frames: %ld",
        _droppedFrameCount);

  if (_displayBuffer) {
    CVPixelBufferRelease(_displayBuffer);
    _displayBuffer = NULL;
  }
  if (_workingBuffer) {
    CVPixelBufferRelease(_workingBuffer);
    _workingBuffer = NULL;
  }
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

void set_global_texture_variables(void *videoTexture, void *textureRegistry,
                                  int64_t textureId) {
  g_video_texture = (__bridge VideoTexture *)videoTexture;
  g_texture_registry =
      (__bridge NSObject<FlutterTextureRegistry> *)textureRegistry;
  g_texture_id = textureId;
}

void update_flutter_texture_from_cpp(const uint8_t *data, size_t width,
                                     size_t height, size_t stride) {
  if (g_video_texture && g_texture_registry && g_texture_id >= 0) {
    [g_video_texture updateWithRGBAData:data
                                  width:width
                                 height:height
                                 stride:stride];
    [g_texture_registry textureFrameAvailable:g_texture_id];
  }
}