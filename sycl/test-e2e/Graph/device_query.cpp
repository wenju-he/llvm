// REQUIRES: cuda || level_zero, gpu
// RUN: %{build} -o %t.out
// RUN: %{run} %t.out

// Tests the using device query for graphs support, and that the return value
// matches expectations.

#include "graph_common.hpp"

int main() {
  queue Queue;

  if (!are_graphs_supported(Queue)) {
    return 0;
  }

  auto Device = Queue.get_device();

  exp_ext::graph_support_level SupportsGraphs =
      Device.get_info<exp_ext::info::device::graph_support>();
  auto Backend = Device.get_backend();

  if ((Backend == backend::ext_oneapi_level_zero) ||
      (Backend == backend::ext_oneapi_cuda)) {
    assert(SupportsGraphs == exp_ext::graph_support_level::native);
  } else {
    assert(SupportsGraphs == exp_ext::graph_support_level::unsupported);
  }
}
