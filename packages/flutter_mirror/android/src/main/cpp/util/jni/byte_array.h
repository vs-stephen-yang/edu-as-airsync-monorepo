#ifndef FLUTTER_MIRROR_PLUGIN_BYTE_ARRAY_H_
#define FLUTTER_MIRROR_PLUGIN_BYTE_ARRAY_H_

#include <jni.h>
#include <string>

namespace jni {

class ScopedByteArrayBuffer {
 public:
  ScopedByteArrayBuffer(
      JNIEnv* env,
      jbyteArray ba);

  ~ScopedByteArrayBuffer();

  jsize Size() const;
  jbyte* Data() const;

 private:
  JNIEnv* env_ = nullptr;
  jbyteArray ba_ = nullptr;
  jbyte* buffer_ = nullptr;
};

class ByteArray {
 public:
  static std::string ToString(
      JNIEnv* env,
      jbyteArray ba);
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_BYTE_ARRAY_H_
