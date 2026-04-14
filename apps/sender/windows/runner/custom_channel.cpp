#include "flutter_window.h"
#include "flutter/generated_plugin_registrant.h"
#include <string>

#include <flutter/binary_messenger.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/encodable_value.h>
#include <../standard_codec.cc>
#include <windows.h>

namespace custom_channels {
    class minimizeWindow {
    public:
        minimizeWindow(flutter::FlutterEngine *engine){initialize(engine);}
        void initialize(flutter::FlutterEngine *FlEngine){
            const static std::string channel_name("com.viewsonic.display.cast/window_manager");
            flutter::BinaryMessenger *messenger = FlEngine->messenger();
            const flutter::StandardMethodCodec *codec = &flutter::StandardMethodCodec::GetInstance();
            auto channel = std::make_unique<flutter::MethodChannel<>>(messenger ,channel_name ,codec);
            channel->SetMethodCallHandler(
                    [&](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
                        AddMethodHandlers(call,&result);
                    });
        }

        void AddMethodHandlers(const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> *result){
            if (call.method_name().compare("minimizeWindow") == 0) {
                try {
                    minimize(call, result);
                }catch (...) {
                    (*result)->Error("An error was caught");
                }
            }
            else {
                (*result)->NotImplemented();
            }

        }

        void minimize(const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> *resPointer){
            HWND hWnd = GetActiveWindow();
            if (hWnd != nullptr) {
                ShowWindow(hWnd, SW_MINIMIZE);
            }
            flutter::EncodableValue res ;
            res = flutter::EncodableValue("");
            (*resPointer)->Success(res);
        }
    };

    class debugChannel {
    public:
        debugChannel(flutter::FlutterEngine *engine){initialize(engine);}
        void initialize(flutter::FlutterEngine *FlEngine){
            const static std::string channel_name("com.viewsonic.display.cast/debug");
            flutter::BinaryMessenger *messenger = FlEngine->messenger();
            const flutter::StandardMethodCodec *codec = &flutter::StandardMethodCodec::GetInstance();
            auto channel = std::make_unique<flutter::MethodChannel<>>(messenger ,channel_name ,codec);
            channel->SetMethodCallHandler(
                    [&](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
                        AddMethodHandlers(call,&result);
                    });
        }

        void AddMethodHandlers(const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> *result){
            if (call.method_name().compare("triggerNativeCrash") == 0) {
                (*result)->Success();
                int* ptr = nullptr;
                *ptr = 42;  // Access violation
            }
            else {
                (*result)->NotImplemented();
            }
        }
    };

}