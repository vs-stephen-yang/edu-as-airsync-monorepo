#include "sn_error.h"

namespace virtual_display_client {

std::string GetErrorString(Error error) {
  switch (error) {
    case Error::ERROR_NONE:
      return "No error";
    case Error::ERROR_FAILED_TO_CONNECT_TO_SERVER:
      return "Failed to connect to server";
    case Error::ERROR_WINDOW_SERVICE_NOT_RUNNING:
      return "Window service not running";
    default:
      return "Unknown error";
  }
}

} // namespace virtual_display_client
