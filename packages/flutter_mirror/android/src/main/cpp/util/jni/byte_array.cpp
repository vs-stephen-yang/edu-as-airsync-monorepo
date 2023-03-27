#include "util/jni/byte_array.h"
#include <assert.h>

namespace jni {

ScopedByteArrayBuffer::ScopedByteArrayBuffer(
    JNIEnv* env,
    jbyteArray ba)
    : env_(env),
      ba_(ba) {
  assert(env);
  assert(ba);

  buffer_ = env->GetByteArrayElements(ba_, nullptr);

  assert(buffer_);
}

ScopedByteArrayBuffer::~ScopedByteArrayBuffer() {
  env_->ReleaseByteArrayElements(ba_, buffer_, JNI_ABORT);
}

jsize ScopedByteArrayBuffer::Size() const {
  return env_->GetArrayLength(ba_);
}

jbyte* ScopedByteArrayBuffer::Data() const {
  return buffer_;
}

std::string ByteArray::ToString(
    JNIEnv* env,
    jbyteArray ba) {
  assert(env);
  assert(ba);

  ScopedByteArrayBuffer buf(env, ba);

  std::string str;
  if (buf.Size() > 0) {
    str.resize(buf.Size());

    memcpy((void*)str.data(), buf.Data(), buf.Size());
  }

  return str;
}

}  // namespace jni
