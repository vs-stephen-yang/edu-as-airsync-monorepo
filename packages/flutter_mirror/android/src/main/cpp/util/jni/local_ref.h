#ifndef FLUTTER_MIRROR_PLUGIN_LOCAL_REF_H_
#define FLUTTER_MIRROR_PLUGIN_LOCAL_REF_H_

namespace jni {

// When the native method returns to Java, any leaked local references are automatically cleaned up.
// So if you are sure your ultimate caller is in a Java thread, then you can safely leak the reference.
// if you are running in the context of a native thread - say,
// some event reporting thread making callbacks to Java - there never is a return to Java,
// so you must call DeleteLocalRef() yourself

template <class T>
class LocalRef {
 public:
  LocalRef(
      JNIEnv* env,
      T obj)
      : env_(env),
        obj_(obj) {
  }
  LocalRef(
      JNIEnv* env,
      jobject obj)
      : env_(env),
        obj_(reinterpret_cast<T>(obj)) {
  }

  ~LocalRef() {
    env_->DeleteLocalRef(obj_);
  }

  operator T() {
    return obj_;
  }
  jobject operator*() {
    return obj_;
  }

 private:
  JNIEnv* env_ = nullptr;
  T obj_;
};

}  // namespace jni

#endif  // FLUTTER_MIRROR_PLUGIN_LOCAL_REF_H_
