// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#define NOMINMAX
#include "touch_injector_win.h"

#include <string>
#include <utility>
#include <iostream>
#include <algorithm>

namespace remoting {

    namespace protocol {
        const int TouchEvent::TOUCH_POINT_START = 0;
        const int TouchEvent::TOUCH_POINT_MOVE = 1;
        const int TouchEvent::TOUCH_POINT_END = 2;
        const int TouchEvent::TOUCH_POINT_CANCEL = 3;
    }
using protocol::TouchEvent;
using protocol::TouchEventPoint;

namespace {

typedef BOOL(NTAPI* InitializeTouchInjectionFunction)(UINT32, DWORD);
typedef BOOL(NTAPI* InjectTouchInputFunction)(UINT32,
                                              const POINTER_TOUCH_INFO*);
const uint32_t kMaxSimultaneousTouchCount = 255;

// This is used to reinject all points that have not changed as "move"ed points,
// even if they have not actually moved.
// This is required for multi-touch to work, e.g. pinching and zooming gestures
// (handled by apps) won't work without reinjecting the points, even though the
// user moved only one finger and held the other finger in place.
void AppendMapValuesToVector(
    std::map<uint32_t, POINTER_TOUCH_INFO>* touches_in_contact,
    std::vector<POINTER_TOUCH_INFO>* output_vector) {
  for (auto& id_and_pointer_touch_info : *touches_in_contact) {
    POINTER_TOUCH_INFO& pointer_touch_info = id_and_pointer_touch_info.second;
    output_vector->push_back(pointer_touch_info);
  }
}

void ConvertToPointerTouchInfoImpl(
    const TouchEventPoint& touch_point,
    POINTER_TOUCH_INFO* pointer_touch_info) {
  pointer_touch_info->touchMask =
      TOUCH_MASK_CONTACTAREA | TOUCH_MASK_ORIENTATION;
  pointer_touch_info->touchFlags = TOUCH_FLAG_NONE;

  // Although radius_{x,y} can be undefined (i.e. has_radius_{x,y} == false),
  // the default value (0.0) will set the area correctly.
  // MSDN mentions that if the digitizer does not detect the size of the touch
  // point, rcContact should be set to 0 by 0 rectangle centered at the
  // coordinate.
  pointer_touch_info->rcContact.left =
      touch_point.x() - touch_point.radius_x();
  pointer_touch_info->rcContact.top = touch_point.y() - touch_point.radius_y();
  pointer_touch_info->rcContact.right =
      touch_point.x() + touch_point.radius_x();
  pointer_touch_info->rcContact.bottom =
      touch_point.y() + touch_point.radius_y();

  pointer_touch_info->orientation = touch_point.angle();

  if (touch_point.has_pressure()) {
    pointer_touch_info->touchMask |= TOUCH_MASK_PRESSURE;
    const float kMinimumPressure = 0.0;
    const float kMaximumPressure = 1.0;
    const float clamped_touch_point_pressure =
        std::max(kMinimumPressure,
                 std::min(kMaximumPressure, touch_point.pressure()));

    const int kWindowsMaxTouchPressure = 1024;  // Defined in MSDN.
    const int pressure =
        (int) (clamped_touch_point_pressure * kWindowsMaxTouchPressure);
    pointer_touch_info->pressure = pressure;
  }

  pointer_touch_info->pointerInfo.pointerType = PT_TOUCH;
  pointer_touch_info->pointerInfo.pointerId = touch_point.id();
  pointer_touch_info->pointerInfo.ptPixelLocation.x = touch_point.x();
  pointer_touch_info->pointerInfo.ptPixelLocation.y = touch_point.y();
}

// The caller should set memset(0) the struct and set
// pointer_touch_info->pointerInfo.pointerFlags.
void ConvertToPointerTouchInfo(
    const ScreenId screen_id,
    const TouchEventPoint& touch_point,
    POINTER_TOUCH_INFO* pointer_touch_info) {

  DesktopVector top_left = GetScreenRect(screen_id).top_left();
  if (top_left.is_zero()) {
    ConvertToPointerTouchInfoImpl(touch_point, pointer_touch_info);
    return;
  }

  TouchEventPoint point(touch_point);
  point.set_x(point.x() + top_left.x());
  point.set_y(point.y() + top_left.y());

  ConvertToPointerTouchInfoImpl(point, pointer_touch_info);
}

}  // namespace

TouchInjectorWinDelegate::~TouchInjectorWinDelegate() {}

// static.
std::unique_ptr<TouchInjectorWinDelegate> TouchInjectorWinDelegate::Create() {
  
    return std::unique_ptr<TouchInjectorWinDelegate>(new TouchInjectorWinDelegate());
}

TouchInjectorWinDelegate::TouchInjectorWinDelegate()
{

}

BOOL TouchInjectorWinDelegate::InitializeTouchInjection(UINT32 max_count,
                                                        DWORD dw_mode) {
  return InitializeTouchInjection(max_count, dw_mode);
}

DWORD TouchInjectorWinDelegate::InjectTouchInput(
    UINT32 count,
    const POINTER_TOUCH_INFO* contacts) {
  return InjectTouchInput(count, contacts);
}

TouchInjectorWin::TouchInjectorWin() = default;

TouchInjectorWin::~TouchInjectorWin() = default;

// Note that TouchInjectorWinDelegate::Create() is not called in this method
// so that a mock delegate can be injected in tests and set expectations on the
// mock and return value of this method.
bool TouchInjectorWin::Init() {
  if (!delegate_)
    delegate_ = TouchInjectorWinDelegate::Create();

  // If initializing the delegate failed above, then the platform likely doesn't
  // support touch (or the libraries failed to load for some reason).
  if (!delegate_)
    return false;

  InitializeTouchInjection(kMaxSimultaneousTouchCount, TOUCH_FEEDBACK_DEFAULT);
  
  /*if (!delegate_->InitializeTouchInjection(
    //      kMaxSimultaneousTouchCount, TOUCH_FEEDBACK_NONE)) {
    // delagate_ is reset here so that the function that need the delegate
    // can check if it is null.
    delegate_.reset();
    std::cout<< "Failed to initialize touch injection.";
    return false;
  }*/

  return true;
}

void TouchInjectorWin::Deinitialize() {
  touches_in_contact_.clear();
  // Same reason as TouchInjectorWin::Init(). For injecting mock delegates for
  // tests, a new delegate is created here.
  delegate_ = TouchInjectorWinDelegate::Create();
}

void TouchInjectorWin::InjectTouchEvent(const TouchEvent& event) {
  if (!delegate_) {
    std::cout << "Touch injection functions are not initialized." << std::endl;
    return;
  }

  switch (event.event_type()) {
    case TouchEvent::TOUCH_POINT_START:
      AddNewTouchPoints(event);
      break;
    case TouchEvent::TOUCH_POINT_MOVE:
      MoveTouchPoints(event);
      break;
    case TouchEvent::TOUCH_POINT_END:
      EndTouchPoints(event);
      break;
    case TouchEvent::TOUCH_POINT_CANCEL:
      CancelTouchPoints(event);
      break;
    default:
      
      return;
  }
}

void TouchInjectorWin::InjectNormalizedTouchEvent(
    ScreenId screen_id,
    bool auto_virtual_screen,
    int id,
    int event_type,
    double x,
    double y) {

  if (auto_virtual_screen) {
    ScreenId virtual_screen_id = GetVirtualScreen();
    if (virtual_screen_id != kInvalidScreenId) {
      screen_id_ = virtual_screen_id;
    } else {
      screen_id_ = GetPrimaryScreen();
    }
  } else {
    screen_id_ = screen_id;
  }

  DesktopRect desktop_rect = GetScreenRect(screen_id_);

  remoting::protocol::TouchEvent event;
  remoting::protocol::TouchEventPoint tp;
  tp.id_ = id % kMaxSimultaneousTouchCount;
  tp.x_ = (int)(x * desktop_rect.width());
  tp.y_ = (int)(y * desktop_rect.height());
  tp.angle_ = 0;

  event.event_type_ = event_type;
  event.points_.push_back(tp);

  InjectTouchEvent(event);
}

void TouchInjectorWin::SetInjectorDelegateForTest(
    std::unique_ptr<TouchInjectorWinDelegate> functions) {
  delegate_ = std::move(functions);
}

void TouchInjectorWin::AddNewTouchPoints(const TouchEvent& event) {
  //DCHECK_EQ(event.event_type(), TouchEvent::TOUCH_POINT_START);

  std::vector<POINTER_TOUCH_INFO> touches;
  // Must inject already touching points as move events.
  AppendMapValuesToVector(&touches_in_contact_, &touches);

  for (const TouchEventPoint& touch_point : event.touch_points()) {
    POINTER_TOUCH_INFO pointer_touch_info;

    memset(&pointer_touch_info, 0, sizeof(pointer_touch_info));

    pointer_touch_info.pointerInfo.pointerFlags =
        POINTER_FLAG_INRANGE | POINTER_FLAG_INCONTACT | POINTER_FLAG_DOWN;

    ConvertToPointerTouchInfo(screen_id_, touch_point, &pointer_touch_info);

    touches.push_back(pointer_touch_info);

    // All points in the map should be a move point.
    pointer_touch_info.pointerInfo.pointerFlags =
        POINTER_FLAG_INRANGE | POINTER_FLAG_INCONTACT | POINTER_FLAG_UPDATE;
    touches_in_contact_[touch_point.id()] = pointer_touch_info;
  }

  if (InjectTouchInput((UINT32)touches.size(), touches.data()) == 0) {
    std::cout << "Failed to inject a touch start event. " << GetLastError() << std::endl;
  }
}

void TouchInjectorWin::MoveTouchPoints(const TouchEvent& event) {
  //DCHECK_EQ(event.event_type(), TouchEvent::TOUCH_POINT_MOVE);

  for (const TouchEventPoint& touch_point : event.touch_points()) {
    POINTER_TOUCH_INFO* pointer_touch_info =
        &touches_in_contact_[touch_point.id()];
    memset(pointer_touch_info, 0, sizeof(*pointer_touch_info));
    pointer_touch_info->pointerInfo.pointerFlags =
        POINTER_FLAG_INRANGE | POINTER_FLAG_INCONTACT | POINTER_FLAG_UPDATE;
    ConvertToPointerTouchInfo(screen_id_, touch_point, pointer_touch_info);
  }

  std::vector<POINTER_TOUCH_INFO> touches;
  // Must inject already touching points as move events.
  AppendMapValuesToVector(&touches_in_contact_, &touches);
  if (InjectTouchInput((UINT32)touches.size(), touches.data()) == 0) {
    std::cout << "Failed to inject a touch move event. " << GetLastError() << std::endl;
  }
}

void TouchInjectorWin::EndTouchPoints(const TouchEvent& event) {
  //DCHECK_EQ(event.event_type(), TouchEvent::TOUCH_POINT_END);

  std::vector<POINTER_TOUCH_INFO> touches;
  for (const TouchEventPoint& touch_point : event.touch_points()) {
    POINTER_TOUCH_INFO pointer_touch_info =
        touches_in_contact_[touch_point.id()];
    pointer_touch_info.pointerInfo.pointerFlags = POINTER_FLAG_UP;

    touches_in_contact_.erase(touch_point.id());
    touches.push_back(pointer_touch_info);
  }

  AppendMapValuesToVector(&touches_in_contact_, &touches);
  if (InjectTouchInput((UINT32)touches.size(), touches.data()) == 0) {
    std::cout << "Failed to inject a touch end event. " << GetLastError() << std::endl;
  }
}

void TouchInjectorWin::CancelTouchPoints(const TouchEvent& event) {
  //DCHECK_EQ(event.event_type(), TouchEvent::TOUCH_POINT_CANCEL);

  std::vector<POINTER_TOUCH_INFO> touches;
  for (const TouchEventPoint& touch_point : event.touch_points()) {
    POINTER_TOUCH_INFO pointer_touch_info =
        touches_in_contact_[touch_point.id()];
    pointer_touch_info.pointerInfo.pointerFlags =
        POINTER_FLAG_UP | POINTER_FLAG_CANCELED;

    touches_in_contact_.erase(touch_point.id());
    touches.push_back(pointer_touch_info);
  }

  AppendMapValuesToVector(&touches_in_contact_, &touches);
  if (InjectTouchInput((UINT32)touches.size(), touches.data()) == 0) {
    std::cout << "Failed to inject a touch cancel event. " << GetLastError() << std::endl;
  }
}

}  // namespace remoting
