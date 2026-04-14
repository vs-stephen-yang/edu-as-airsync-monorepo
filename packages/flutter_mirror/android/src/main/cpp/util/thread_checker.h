#ifndef FLUTTER_MIRROR_UTIL_THREAD_CHECKER_H_
#define FLUTTER_MIRROR_UTIL_THREAD_CHECKER_H_

#include <assert.h>
#include <thread>

#define DCHECK_RUN_ON(thread_id) \
  assert(thread_id == std::this_thread::get_id())

#endif  // FLUTTER_MIRROR_UTIL_THREAD_CHECKER_H_
