#include <android/log.h>
#include <fcntl.h>
#include <jni.h>
#include <linux/uinput.h>
#include <unistd.h>
#include <cassert>
#include <cerrno>
#include <string>

#include "keybits.h"

#define TAG "libuinput"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

#define INVALID_FD (-1)
//
static int g_input_fd = -1;

static void emitEvent(int fd, int type, int code, int val) {
  if (fd == INVALID_FD) {
    return;
  }

  struct input_event ie = {};
  memset(&ie, 0, sizeof(ie));

  ie.type = type;
  ie.code = code;
  ie.value = val;
  /* timestamp values below are ignored */
  ie.time.tv_sec = 0;
  ie.time.tv_usec = 0;

  write(fd, &ie, sizeof(ie));
}

static void closeDevice() {
  LOGI("Closing the virtual input device");

  if (g_input_fd == INVALID_FD) {
    return;
  }

  close(g_input_fd);
  g_input_fd = INVALID_FD;
  LOGI("Closed the virtual input device");
}

static void writeABS_SETUP(int fd, int code, int minValue, int maxValue) {
  struct uinput_abs_setup abs_setup = {};
  memset(&abs_setup, 0, sizeof(abs_setup));

  abs_setup.code = code;
  abs_setup.absinfo.minimum = minValue;
  abs_setup.absinfo.maximum = maxValue;

  ioctl(fd, UI_ABS_SETUP, &abs_setup);
}

static bool setupDevice(
    int fd,
    int maxTrackingId,
    int maxSlot,
    int width,
    int height) {
  assert(fd != INVALID_FD);
  assert(width > 0);
  assert(height > 0);
  assert(maxTrackingId > 0);
  assert(maxSlot > 0);

  // enable key events
  ioctl(fd, UI_SET_EVBIT, EV_KEY);
  for (int key : kKeyBits) {
    ioctl(fd, UI_SET_KEYBIT, key);
  }

  // ABS
  // https://source.android.com/devices/input/touch-devices#touch-device-classification
  // single-touch device: ABS_X, ABS_Y, BTN_TOUCH
  ioctl(fd, UI_SET_EVBIT, EV_ABS);
  ioctl(fd, UI_SET_ABSBIT, ABS_X);
  ioctl(fd, UI_SET_ABSBIT, ABS_Y);

  // multi-touch device: ABS_MT_POSITION_X, ABS_MT_POSITION_Y
  ioctl(fd, UI_SET_ABSBIT, ABS_MT_SLOT);
  ioctl(fd, UI_SET_ABSBIT, ABS_MT_POSITION_X);
  ioctl(fd, UI_SET_ABSBIT, ABS_MT_POSITION_Y);
  ioctl(fd, UI_SET_ABSBIT, ABS_MT_TRACKING_ID);

  // https://source.android.com/devices/input/touch-devices#touch-device-classification
  // Fpr INPUT_PROP_DIRECT, device type will be set to touch screen
  ioctl(fd, UI_SET_PROPBIT, INPUT_PROP_DIRECT);

  // https://www.kernel.org/doc/html/v4.12/input/uinput.html
  // https://elixir.bootlin.com/linux/v4.7/source/include/uapi/linux/uinput.h#L66
  int version = 0;
  int rc = ioctl(fd, UI_GET_VERSION, &version);

  if (rc == -1) {
    LOGE("Failed to get uinput version. %s", strerror(errno));
    return false;
  }
  LOGI("uinput version: %d", version);

  if (version >= 5) {
    struct uinput_setup usetup = {};
    memset(&usetup, 0, sizeof(usetup));

    usetup.id.bustype = BUS_USB;
    usetup.id.vendor = 0x1234;  /* sample vendor */
    usetup.id.product = 0x5678; /* sample product */
    strcpy(usetup.name, "input-injection");

    ioctl(fd, UI_DEV_SETUP, &usetup);

    // Set up ABS_MT_TRACKING_ID
    writeABS_SETUP(fd, ABS_MT_TRACKING_ID, 0, maxTrackingId);

    // Set up ABS_MT_SLOT
    writeABS_SETUP(fd, ABS_MT_SLOT, 0, maxSlot);

    // Set up ABS_MT_POSITION_X
    writeABS_SETUP(fd, ABS_MT_POSITION_X, 0, width);
    // Set up ABS_MT_POSITION_Y
    writeABS_SETUP(fd, ABS_MT_POSITION_Y, 0, height);
  } else {
    struct uinput_user_dev device = {};
    memset(&device, 0, sizeof(device));

    device.id.bustype = BUS_USB;
    device.id.vendor = 0x1234;
    device.id.product = 0x5678;
    strcpy(device.name, "input-injection");

    device.absmin[ABS_MT_TRACKING_ID] = 0;
    device.absmax[ABS_MT_TRACKING_ID] = maxTrackingId;

    device.absmin[ABS_MT_SLOT] = 0;
    device.absmax[ABS_MT_SLOT] = maxSlot;

    device.absmin[ABS_MT_POSITION_X] = 0;
    device.absmax[ABS_MT_POSITION_X] = width;

    device.absmin[ABS_MT_POSITION_Y] = 0;
    device.absmax[ABS_MT_POSITION_Y] = height;

    write(fd, &device, sizeof(device));
  }

  ioctl(fd, UI_DEV_CREATE);
  return true;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_init(
    JNIEnv* /* env */,
    jclass /* this */,
    jint maxTrackingId,
    jint maxSlot,
    jint width,
    jint height) {
  assert(width > 0);
  assert(height > 0);
  // assert(g_input_fd == INVALID_FD);

  LOGI("Creating a virtual input device");
  if (g_input_fd != INVALID_FD) {
    LOGW("Virtual input device has already been created");
    return JNI_FALSE;
  }

  int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
  if (fd < 0) {
    LOGE("Failed to create a virtual input device. %s", strerror(errno));
    return JNI_FALSE;
  }

  g_input_fd = fd;

  if (!setupDevice(
          fd,
          maxTrackingId,
          maxSlot,
          width,
          height)) {
    LOGE("Failed to setup virtual input device. Close the device");
    closeDevice();

    return JNI_FALSE;
  }

  LOGI("A virtual input device is created successfully");

  return JNI_TRUE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_close(
    JNIEnv* /* env */,
    jclass /* this */) {
  closeDevice();
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_injectKey(
    JNIEnv* /*env*/,
    jclass /* this */,
    int nativeKeyCode,
    int pressed) {
  // https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
  emitEvent(g_input_fd, EV_KEY, nativeKeyCode, pressed);
  emitEvent(g_input_fd, EV_SYN, SYN_REPORT, 0);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_injectTouchStart(
    JNIEnv* /* env */,
    jclass /* this */,
    int slot,
    int trackingId,
    int x,
    int y) {
  emitEvent(g_input_fd, EV_ABS, ABS_MT_SLOT, slot);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_TRACKING_ID, trackingId);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_POSITION_X, x);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_POSITION_Y, y);

  emitEvent(g_input_fd, EV_SYN, SYN_REPORT, 0);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_injectTouchEnd(
    JNIEnv* /* env */,
    jclass /* this */,
    int slot) {
  emitEvent(g_input_fd, EV_ABS, ABS_MT_SLOT, slot);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_TRACKING_ID, -1);

  emitEvent(g_input_fd, EV_SYN, SYN_REPORT, 0);
}

extern "C" JNIEXPORT void JNICALL
Java_com_viewsonic_flutter_1input_1injection_UInput_injectTouchMove(
    JNIEnv* /* env */,
    jclass /* this */,
    int slot,
    int x,
    int y) {
  emitEvent(g_input_fd, EV_ABS, ABS_MT_SLOT, slot);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_POSITION_X, x);
  emitEvent(g_input_fd, EV_ABS, ABS_MT_POSITION_Y, y);

  emitEvent(g_input_fd, EV_SYN, SYN_REPORT, 0);
}
