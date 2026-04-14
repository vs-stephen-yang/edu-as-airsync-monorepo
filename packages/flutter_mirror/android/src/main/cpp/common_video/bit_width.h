#ifndef COMMON_VIDEO_BIT_WIDTH
#define COMMON_VIDEO_BIT_WIDTH

#include <bit>
#include <limits>

// std::bit_width
template <class T>
constexpr int bit_width(T x) {
  // This function is equivalent to return std::numeric_limits<T>::digits - std::countl_zero(x);.
  return std::numeric_limits<T>::digits - std::countl_zero(x);
}

#endif  // COMMON_VIDEO_BIT_WIDTH
