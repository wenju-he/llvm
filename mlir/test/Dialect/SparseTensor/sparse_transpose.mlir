// RUN: mlir-opt %s --sparse-reinterpret-map -sparsification | FileCheck %s

#DCSR = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : compressed, d1 : compressed)
}>

#transpose_trait = {
  indexing_maps = [
    affine_map<(i,j) -> (j,i)>,  // A
    affine_map<(i,j) -> (i,j)>   // X
  ],
  iterator_types = ["parallel", "parallel"],
  doc = "X(i,j) = A(j,i)"
}

// TODO: improve auto-conversion followed by yield

// CHECK-LABEL:   func.func @sparse_transpose_auto(
// CHECK-SAME:      %[[VAL_0:.*]]: tensor<3x4xf64, #sparse_tensor.encoding<{{{.*}}}>>) -> tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> {
// CHECK-DAG:       %[[VAL_1:.*]] = arith.constant 0 : index
// CHECK-DAG:       %[[VAL_2:.*]] = arith.constant 1 : index
// CHECK-DAG:       %[[VAL_3:.*]] = tensor.empty() : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_4:.*]] = sparse_tensor.convert %[[VAL_0]] : tensor<3x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to tensor<3x4xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:           %[[DEMAP:.*]] = sparse_tensor.reinterpret_map %[[VAL_4]] : tensor<3x4xf64, #sparse_tensor.encoding<{{{.*}}}>> to tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK-DAG:       %[[VAL_5:.*]] = sparse_tensor.positions %[[DEMAP]] {level = 0 : index} : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_6:.*]] = sparse_tensor.coordinates %[[DEMAP]] {level = 0 : index} : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_7:.*]] = sparse_tensor.positions %[[DEMAP]] {level = 1 : index} : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_8:.*]] = sparse_tensor.coordinates %[[DEMAP]] {level = 1 : index} : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xindex>
// CHECK-DAG:       %[[VAL_9:.*]] = sparse_tensor.values %[[DEMAP]] : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>> to memref<?xf64>
// CHECK:           %[[VAL_10:.*]] = memref.load %[[VAL_5]]{{\[}}%[[VAL_1]]] : memref<?xindex>
// CHECK:           %[[VAL_11:.*]] = memref.load %[[VAL_5]]{{\[}}%[[VAL_2]]] : memref<?xindex>
// CHECK:           %[[VAL_12:.*]] = scf.for %[[VAL_13:.*]] = %[[VAL_10]] to %[[VAL_11]] step %[[VAL_2]] iter_args(%[[VAL_14:.*]] = %[[VAL_3]]) -> (tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>) {
// CHECK:             %[[VAL_15:.*]] = memref.load %[[VAL_6]]{{\[}}%[[VAL_13]]] : memref<?xindex>
// CHECK:             %[[VAL_16:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_13]]] : memref<?xindex>
// CHECK:             %[[VAL_17:.*]] = arith.addi %[[VAL_13]], %[[VAL_2]] : index
// CHECK:             %[[VAL_18:.*]] = memref.load %[[VAL_7]]{{\[}}%[[VAL_17]]] : memref<?xindex>
// CHECK:             %[[VAL_19:.*]] = scf.for %[[VAL_20:.*]] = %[[VAL_16]] to %[[VAL_18]] step %[[VAL_2]] iter_args(%[[VAL_21:.*]] = %[[VAL_14]]) -> (tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>) {
// CHECK:               %[[VAL_22:.*]] = memref.load %[[VAL_8]]{{\[}}%[[VAL_20]]] : memref<?xindex>
// CHECK:               %[[VAL_23:.*]] = memref.load %[[VAL_9]]{{\[}}%[[VAL_20]]] : memref<?xf64>
// CHECK:               %[[VAL_24:.*]] = sparse_tensor.insert %[[VAL_23]] into %[[VAL_21]]{{\[}}%[[VAL_15]], %[[VAL_22]]] : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:               scf.yield %[[VAL_24]] : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:             }
// CHECK:             scf.yield %[[VAL_25:.*]] : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:           }
// CHECK:           %[[VAL_26:.*]] = sparse_tensor.load %[[VAL_27:.*]] hasInserts : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:           return %[[VAL_26]] : tensor<4x3xf64, #sparse_tensor.encoding<{{{.*}}}>>
// CHECK:         }
func.func @sparse_transpose_auto(%arga: tensor<3x4xf64, #DCSR>)
                                     -> tensor<4x3xf64, #DCSR> {
  %i = tensor.empty() : tensor<4x3xf64, #DCSR>
  %0 = linalg.generic #transpose_trait
     ins(%arga: tensor<3x4xf64, #DCSR>)
     outs(%i: tensor<4x3xf64, #DCSR>) {
     ^bb(%a: f64, %x: f64):
       linalg.yield %a : f64
  } -> tensor<4x3xf64, #DCSR>
  return %0 : tensor<4x3xf64, #DCSR>
}
