#ifndef __SN_ERROR_H__
#define __SN_ERROR_H__

#include <string>

namespace virtual_display_client {

enum Error {
  ERROR_NONE = 0,
  ERROR_FAILED_TO_CONNECT_TO_SERVER = -1,
  ERROR_WINDOW_SERVICE_NOT_RUNNING = -2,
  ERROR_UNKNOWN = -100,
}; // enum Error

std::string GetErrorString(Error error);

} // namespace virtual_display_client

#endif //__SN_ERROR_H__
