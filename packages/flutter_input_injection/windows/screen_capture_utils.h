#ifndef MODULES_DESKTOP_CAPTURE_WIN_SCREEN_CAPTURE_UTILS_H_
#define MODULES_DESKTOP_CAPTURE_WIN_SCREEN_CAPTURE_UTILS_H_

#include <stdint.h>
#include <string>
#include "desktop_geometry.h"

typedef int64_t ScreenId;

#define kInvalidScreenId -1

ScreenId GetPrimaryScreen();
ScreenId GetVirtualScreen();
DesktopRect GetScreenRect(ScreenId screen);

#endif // MODULES_DESKTOP_CAPTURE_WIN_SCREEN_CAPTURE_UTILS_H_
