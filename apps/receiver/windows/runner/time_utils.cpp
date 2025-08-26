#include <windows.h>
#include <string>
#include <thread>
#include <atomic>

#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/encodable_value.h>

namespace {

    bool Is24HourFormatFromRegistry() {
        HKEY hKey;
        if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\International",
                          0, KEY_QUERY_VALUE, &hKey) != ERROR_SUCCESS) {
            return false;
        }

        auto readStr = [&](const wchar_t *name) -> std::wstring {
            wchar_t buf[256] = {0};
            DWORD type = 0;
            DWORD size = sizeof(buf);
            if (RegQueryValueExW(hKey, name, nullptr, &type,
                                 reinterpret_cast<LPBYTE>(buf), &size) == ERROR_SUCCESS &&
                type == REG_SZ) {
                return std::wstring(buf);
            }
            return L"";
        };

        std::wstring s = readStr(L"sShortTime");
        if (s.empty()) s = readStr(L"sTimeFormat");

        RegCloseKey(hKey);
        if (s.empty()) return false;

        // 24h if pattern contains 'H' (e.g. "HH:mm")
        return s.find(L'H') != std::wstring::npos;
    }

    class TimeFormatStreamHandler final
            : public flutter::StreamHandler<flutter::EncodableValue> {
    public:
        TimeFormatStreamHandler() = default;

        ~TimeFormatStreamHandler() override { Stop(); }

    protected:
        std::unique_ptr <flutter::StreamHandlerError<flutter::EncodableValue>>
        OnListenInternal(const flutter::EncodableValue * /*arguments*/,
                         std::unique_ptr <flutter::EventSink<flutter::EncodableValue>> &&events) override {
            events_ = std::move(events);

            // push current value immediately
            Push(Is24HourFormatFromRegistry());

            running_.store(true);
            stop_event_ = CreateEventW(nullptr, TRUE, FALSE, nullptr);
            change_event_ = CreateEventW(nullptr, FALSE, FALSE, nullptr);

            if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\International",
                              0, KEY_NOTIFY | KEY_QUERY_VALUE, &hKey_) == ERROR_SUCCESS) {
                RegNotifyChangeKeyValue(hKey_, FALSE, REG_NOTIFY_CHANGE_LAST_SET,
                                        change_event_, TRUE);
            }

            worker_ = std::thread([this]() {
                HANDLE handles[2] = {change_event_, stop_event_};
                while (running_.load()) {
                    DWORD dw = WaitForMultipleObjects(2, handles, FALSE, INFINITE);
                    if (dw == WAIT_OBJECT_0) {
                        // registry changed
                        Push(Is24HourFormatFromRegistry());
                        if (hKey_) {
                            RegNotifyChangeKeyValue(hKey_, FALSE, REG_NOTIFY_CHANGE_LAST_SET,
                                                    change_event_, TRUE);
                        }
                    } else {
                        break;
                    }
                }
            });

            return nullptr;
        }

        std::unique_ptr <flutter::StreamHandlerError<flutter::EncodableValue>>
        OnCancelInternal(const flutter::EncodableValue * /*arguments*/) override {
            Stop();
            return nullptr;
        }

    private:
        void Push(bool is24) {
            if (events_) {
                events_->Success(flutter::EncodableValue(is24));
            }
        }

        void Stop() {
            if (!running_.load()) return;
            running_.store(false);

            if (stop_event_) SetEvent(stop_event_);
            if (worker_.joinable()) worker_.join();

            if (hKey_) {
                RegCloseKey(hKey_);
                hKey_ = nullptr;
            }
            if (change_event_) {
                CloseHandle(change_event_);
                change_event_ = nullptr;
            }
            if (stop_event_) {
                CloseHandle(stop_event_);
                stop_event_ = nullptr;
            }

            events_.reset();
        }

        std::unique_ptr <flutter::EventSink<flutter::EncodableValue>> events_;
        std::thread worker_;
        std::atomic<bool> running_{false};

        HKEY hKey_ = nullptr;
        HANDLE change_event_ = nullptr;
        HANDLE stop_event_ = nullptr;
    };

}