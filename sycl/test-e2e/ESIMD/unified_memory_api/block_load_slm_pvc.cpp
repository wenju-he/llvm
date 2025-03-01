//==------- block_load_slm_pvc.cpp - DPC++ ESIMD on-device test ------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// REQUIRES: gpu-intel-pvc
// RUN: %{build} -o %t.out
// RUN: %{run} %t.out

// The test verifies esimd::slm_block_load() functions reading from SLM memory
// and using optional compile-time esimd::properties.
// The esimd::slm_block_load() calls in this test use the mask operand which
// require PVC+ target device.

#include "Inputs/block_load.hpp"

int main() {
  auto Q = queue{gpu_selector_v};
  esimd_test::printTestLabel(Q);

  constexpr bool TestPVCFeatures = true;
  bool Passed = true;

  Passed &= testSLM<int8_t, TestPVCFeatures>(Q);
  Passed &= testSLM<int16_t, TestPVCFeatures>(Q);
  if (Q.get_device().has(sycl::aspect::fp16))
    Passed &= testSLM<sycl::half, TestPVCFeatures>(Q);
  Passed &= testSLM<uint32_t, TestPVCFeatures>(Q);
  Passed &= testSLM<float, TestPVCFeatures>(Q);
  Passed &=
      testSLM<ext::intel::experimental::esimd::tfloat32, TestPVCFeatures>(Q);
  Passed &= testSLM<int64_t, TestPVCFeatures>(Q);
  if (Q.get_device().has(sycl::aspect::fp64))
    Passed &= testSLM<double, TestPVCFeatures>(Q);

  std::cout << (Passed ? "Passed\n" : "FAILED\n");
  return Passed ? 0 : 1;
}
