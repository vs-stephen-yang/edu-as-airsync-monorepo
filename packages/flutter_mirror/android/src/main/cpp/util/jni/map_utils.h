#ifndef FLUTTER_MIRROR_PLUGIN_MAP_UTILS_H_
#define FLUTTER_MIRROR_PLUGIN_MAP_UTILS_H_

#include <map>
#include <string>
#include <jni.h>

namespace jni {

class MapUtils {
public:
    static std::map<std::string, int> toStdMap(
            JNIEnv *env,
            jobject obj);

};

} // namespace jni

#endif //FLUTTER_MIRROR_PLUGIN_MAP_UTILS_H_
