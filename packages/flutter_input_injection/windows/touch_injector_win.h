// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef REMOTING_HOST_TOUCH_INJECTOR_WIN_H_
#define REMOTING_HOST_TOUCH_INJECTOR_WIN_H_

#include <windows.h>
#include <stdint.h>
#include <map>
#include <memory>
#include <vector>
#include "screen_capture_utils.h"

namespace remoting {

namespace protocol {

    class TouchEventPoint
    {
    public:
        int id() const
        {
            return id_;
        }
        float pressure() const
        {
            return 1;
        }
        int radius_x() const
        {
            return 2;
        }
        int radius_y() const
        {
            return 2;
        }
        int x() const
        {
            return x_;
        }
        int y() const
        {
            return y_;
        }
        void set_x(int x)
        {
            x_ = x;
        }
        void set_y(int y)
        {
            y_ = y;
        }
        int angle() const
        {
            return angle_;
        }
        void set_angle(int angle)
        {
            angle_ = angle;
        }
        bool has_pressure() const
        {
            return true;
        }

        int x_, y_, angle_;
        int id_;
    };


    class TouchEvent
    {
    public:
        int event_type()const
        {
            return event_type_;
        }
        std::vector<TouchEventPoint> touch_points() const
        {
            return points_;
        }
        static const int TOUCH_POINT_START;
        static const int TOUCH_POINT_MOVE;
        static const int TOUCH_POINT_END;
        static const int TOUCH_POINT_CANCEL;

        int event_type_;
        std::vector<TouchEventPoint> points_;
    };

}  // namespace protocol

// This class calls InitializeTouchInjection() and InjectTouchInput() functions.
// The methods are virtual for mocking.
class TouchInjectorWinDelegate {
 public:
  virtual ~TouchInjectorWinDelegate();

  // Determines whether Windows touch injection functions can be used.
  // Returns a non-null TouchInjectorWinDelegate on success.
  static std::unique_ptr<TouchInjectorWinDelegate> Create();

  // These match the functions in MSDN.
  virtual BOOL InitializeTouchInjection(UINT32 max_count, DWORD dw_mode);
  virtual DWORD InjectTouchInput(UINT32 count,
                                 const POINTER_TOUCH_INFO* contacts);

 protected:
  // Ctor in protected scope for mocking.
  // This object takes ownership of the |library|.
  TouchInjectorWinDelegate();

 private:    
};

// This class converts TouchEvent objects to POINTER_TOUCH_INFO so that it can
// be injected using the Windows touch injection API, and calls the injection
// functions.
// This class expects good inputs and does not sanity check the inputs.
// This class just converts the object and hands it off to the Windows API.
class TouchInjectorWin {
 public:
  TouchInjectorWin();
  ~TouchInjectorWin();

  // Returns false if initialization of touch injection APIs fails.
  bool Init();

  // Deinitializes the object so that it can be reinitialized.
  void Deinitialize();

  // Inject touch events.
  void InjectTouchEvent(const protocol::TouchEvent& event);

  // Inject a normalized touch event.
  void InjectNormalizedTouchEvent(ScreenId screen_id,
                                  bool autoVirtualScreen,
                                  int id,
                                  int event_type,
                                  double x,
                                  double y);

  void SetInjectorDelegateForTest(
      std::unique_ptr<TouchInjectorWinDelegate> functions);

 private:
  // Helper methods called from InjectTouchEvent().
  // These helpers adapt Chromoting touch events, which convey changes to touch
  // points, to Windows touch descriptions, which must include descriptions for
  // all currently-active touch points, not just the changed ones.
  void AddNewTouchPoints(const protocol::TouchEvent& event);
  void MoveTouchPoints(const protocol::TouchEvent& event);
  void EndTouchPoints(const protocol::TouchEvent& event);
  void CancelTouchPoints(const protocol::TouchEvent& event);

  // Set to null if touch injection is not available from the OS.
  std::unique_ptr<TouchInjectorWinDelegate> delegate_;

  // TODO(rkuroiwa): crbug.com/470203
  // This is a naive implementation. Check if we can achieve
  // better performance by reducing the number of copies.
  // To reduce the number of copies, we can have a vector of
  // POINTER_TOUCH_INFO and a map from touch ID to index in the vector.
  // When removing points from the vector, just swap it with the last element
  // and resize the vector.
  // All the POINTER_TOUCH_INFOs are stored as "move" points.
  std::map<uint32_t, POINTER_TOUCH_INFO> touches_in_contact_;

  // Screen ID to inject touch events to.
  ScreenId screen_id_ = kInvalidScreenId;
};

}  // namespace remoting

#endif  // REMOTING_HOST_TOUCH_INJECTOR_WIN_H_
