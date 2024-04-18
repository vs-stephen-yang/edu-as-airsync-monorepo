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

} // namespace jni
