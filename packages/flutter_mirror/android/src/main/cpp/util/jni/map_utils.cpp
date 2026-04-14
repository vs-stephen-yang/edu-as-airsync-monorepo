#include "map_utils.h"

namespace jni {

std::map<std::string, int> MapUtils::toStdMap(
        JNIEnv *env,
        jobject obj) {
    std::map<std::string, int> result;

    // entrySet
    jclass mapClass = env->GetObjectClass(obj);
    jmethodID entrySetMethod = env->GetMethodID(mapClass, "entrySet", "()Ljava/util/Set;");
    jobject entrySet = env->CallObjectMethod(obj, entrySetMethod);

    // entrySet.iterator
    jclass setClass = env->GetObjectClass(entrySet);
    jmethodID iteratorMethod = env->GetMethodID(setClass, "iterator", "()Ljava/util/Iterator;");
    jobject iterator = env->CallObjectMethod(entrySet, iteratorMethod);

    // iterator.hasNext and iterator.next
    jclass iteratorClass = env->GetObjectClass(iterator);
    jmethodID hasNextMethod = env->GetMethodID(iteratorClass, "hasNext", "()Z");
    jmethodID nextMethod = env->GetMethodID(iteratorClass, "next", "()Ljava/lang/Object;");

    // loop through the entrySet
    while (env->CallBooleanMethod(iterator, hasNextMethod)) {
        jobject entry = env->CallObjectMethod(iterator, nextMethod);

        // entry.getKey and entry.getValue
        jclass entryClass = env->GetObjectClass(entry);
        jmethodID getKeyMethod = env->GetMethodID(entryClass, "getKey", "()Ljava/lang/Object;");
        jmethodID getValueMethod = env->GetMethodID(entryClass, "getValue", "()Ljava/lang/Object;");
        jobject key = env->CallObjectMethod(entry, getKeyMethod);
        jobject value = env->CallObjectMethod(entry, getValueMethod);

        // convert key and value to std::string and int
        jstring keyStr = (jstring) key;
        const char* keyChars = env->GetStringUTFChars(keyStr, NULL);

        jclass integerClass = env->GetObjectClass(value);
        jmethodID intValueMethod = env->GetMethodID(integerClass, "intValue", "()I");
        jint valueInt = env->CallIntMethod(value, intValueMethod);

        result[std::string(keyChars)] = (int)valueInt;

        // release the key string
        env->ReleaseStringUTFChars(keyStr, keyChars);
    }

    return result;
}

std::map<std::string, std::pair<int, int>> MapUtils::toStdMapOfPair(JNIEnv* env, jobject mapObject) {
  std::map<std::string, std::pair<int, int>> result;

  jclass mapClass = env->GetObjectClass(mapObject);
  jmethodID entrySetMethod = env->GetMethodID(mapClass, "entrySet", "()Ljava/util/Set;");
  jobject entrySet = env->CallObjectMethod(mapObject, entrySetMethod);

  jclass setClass = env->GetObjectClass(entrySet);
  jmethodID iteratorMethod = env->GetMethodID(setClass, "iterator", "()Ljava/util/Iterator;");
  jobject iterator = env->CallObjectMethod(entrySet, iteratorMethod);

  jclass iteratorClass = env->GetObjectClass(iterator);
  jmethodID hasNextMethod = env->GetMethodID(iteratorClass, "hasNext", "()Z");
  jmethodID nextMethod = env->GetMethodID(iteratorClass, "next", "()Ljava/lang/Object;");

  while (env->CallBooleanMethod(iterator, hasNextMethod)) {
    jobject entry = env->CallObjectMethod(iterator, nextMethod);

    jclass entryClass = env->GetObjectClass(entry);
    jmethodID getKeyMethod = env->GetMethodID(entryClass, "getKey", "()Ljava/lang/Object;");
    jmethodID getValueMethod = env->GetMethodID(entryClass, "getValue", "()Ljava/lang/Object;");
    jstring jKey = (jstring)env->CallObjectMethod(entry, getKeyMethod);
    jobject jValueMap = env->CallObjectMethod(entry, getValueMethod);

    const char* keyChars = env->GetStringUTFChars(jKey, NULL);
    std::string keyStr(keyChars);
    env->ReleaseStringUTFChars(jKey, keyChars);
    env->DeleteLocalRef(jKey);

    jclass valueMapClass = env->GetObjectClass(jValueMap);
    jmethodID getMethod = env->GetMethodID(valueMapClass, "get", "(Ljava/lang/Object;)Ljava/lang/Object;");

    // width
    jstring widthKey = env->NewStringUTF("width");
    jobject widthValue = env->CallObjectMethod(jValueMap, getMethod, widthKey);
    jint width = env->CallIntMethod(widthValue, env->GetMethodID(env->GetObjectClass(widthValue), "intValue", "()I"));
    env->DeleteLocalRef(widthKey);
    env->DeleteLocalRef(widthValue);

    // height
    jstring heightKey = env->NewStringUTF("height");
    jobject heightValue = env->CallObjectMethod(jValueMap, getMethod, heightKey);
    jint height = env->CallIntMethod(heightValue, env->GetMethodID(env->GetObjectClass(heightValue), "intValue", "()I"));
    env->DeleteLocalRef(heightKey);
    env->DeleteLocalRef(heightValue);

    result[keyStr] = std::make_pair((int)width, (int)height);

    env->DeleteLocalRef(jValueMap);
    env->DeleteLocalRef(entry);
  }

  return result;
}

} // namespace jni
