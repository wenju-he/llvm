; RUN: llc -mtriple=i686-unknown-unknown -mattr=+avx -fixup-byte-word-insts=1 < %s | FileCheck -check-prefixes=X86,X86-BWON %s
; RUN: llc -mtriple=i686-unknown-unknown -mattr=+avx -fixup-byte-word-insts=0 < %s | FileCheck -check-prefixes=X86,X86-BWOFF %s
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx -fixup-byte-word-insts=1 < %s | FileCheck -check-prefixes=X64,X64-BWON %s
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx -fixup-byte-word-insts=0 < %s | FileCheck -check-prefixes=X64,X64-BWOFF %s

%struct.A = type { i8, i8, i8, i8, i8, i8, i8, i8 }
%struct.B = type { i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.C = type { i8, i8, i8, i8, i32, i32, i32, i64 }

; save 1,2,3 ... as one big integer.
define void @merge_const_store(i32 %count, %struct.A* nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_const_store:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB0_3
; X86-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB0_2: # %.lr.ph
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    movl $67305985, (%ecx) # imm = 0x4030201
; X86-NEXT:    movl $134678021, 4(%ecx) # imm = 0x8070605
; X86-NEXT:    addl $8, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB0_2
; X86-NEXT:  .LBB0_3: # %._crit_edge
; X86-NEXT:    retl
;
; X64-LABEL: merge_const_store:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB0_3
; X64-NEXT:  # %bb.1: # %.lr.ph.preheader
; X64-NEXT:    movabsq $578437695752307201, %rax # imm = 0x807060504030201
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB0_2: # %.lr.ph
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    addq $8, %rsi
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB0_2
; X64-NEXT:  .LBB0_3: # %._crit_edge
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.A* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 4
  store i8 5, i8* %6, align 1
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 5
  store i8 6, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 6
  store i8 7, i8* %8, align 1
  %9 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 7
  store i8 8, i8* %9, align 1
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; No vectors because we use noimplicitfloat
define void @merge_const_store_no_vec(i32 %count, %struct.B* nocapture %p) noimplicitfloat{
; X86-LABEL: merge_const_store_no_vec:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB1_3
; X86-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB1_2: # %.lr.ph
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    movl $0, (%ecx)
; X86-NEXT:    movl $0, 4(%ecx)
; X86-NEXT:    movl $0, 8(%ecx)
; X86-NEXT:    movl $0, 12(%ecx)
; X86-NEXT:    movl $0, 16(%ecx)
; X86-NEXT:    movl $0, 20(%ecx)
; X86-NEXT:    movl $0, 24(%ecx)
; X86-NEXT:    movl $0, 28(%ecx)
; X86-NEXT:    addl $32, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB1_2
; X86-NEXT:  .LBB1_3: # %._crit_edge
; X86-NEXT:    retl
;
; X64-LABEL: merge_const_store_no_vec:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB1_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB1_1: # %.lr.ph
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    movq $0, (%rsi)
; X64-NEXT:    movq $0, 8(%rsi)
; X64-NEXT:    movq $0, 16(%rsi)
; X64-NEXT:    movq $0, 24(%rsi)
; X64-NEXT:    addq $32, %rsi
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB1_1
; X64-NEXT:  .LBB1_2: # %._crit_edge
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.B* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 0, i32* %3, align 4
  %4 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  store i32 0, i32* %4, align 4
  %5 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  store i32 0, i32* %5, align 4
  %6 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 4
  store i32 0, i32* %6, align 4
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 5
  store i32 0, i32* %7, align 4
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 6
  store i32 0, i32* %8, align 4
  %9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 7
  store i32 0, i32* %9, align 4
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Move the constants using a single vector store.
define void @merge_const_store_vec(i32 %count, %struct.B* nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_const_store_vec:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB2_3
; X86-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB2_2: # %.lr.ph
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    vmovups %ymm0, (%ecx)
; X86-NEXT:    addl $32, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB2_2
; X86-NEXT:  .LBB2_3: # %._crit_edge
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_const_store_vec:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB2_3
; X64-NEXT:  # %bb.1: # %.lr.ph.preheader
; X64-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB2_2: # %.lr.ph
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    vmovups %ymm0, (%rsi)
; X64-NEXT:    addq $32, %rsi
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB2_2
; X64-NEXT:  .LBB2_3: # %._crit_edge
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.B* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 0, i32* %3, align 4
  %4 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  store i32 0, i32* %4, align 4
  %5 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  store i32 0, i32* %5, align 4
  %6 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 4
  store i32 0, i32* %6, align 4
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 5
  store i32 0, i32* %7, align 4
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 6
  store i32 0, i32* %8, align 4
  %9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 7
  store i32 0, i32* %9, align 4
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Move the first 4 constants as a single vector. Move the rest as scalars.
define void @merge_nonconst_store(i32 %count, i8 %zz, %struct.A* nocapture %p) nounwind uwtable noinline ssp {
; X86-BWON-LABEL: merge_nonconst_store:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWON-NEXT:    testl %eax, %eax
; X86-BWON-NEXT:    jle .LBB3_3
; X86-BWON-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    movzbl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB3_2: # %.lr.ph
; X86-BWON-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movl $67305985, (%ecx) # imm = 0x4030201
; X86-BWON-NEXT:    movb %dl, 4(%ecx)
; X86-BWON-NEXT:    movw $1798, 5(%ecx) # imm = 0x706
; X86-BWON-NEXT:    movb $8, 7(%ecx)
; X86-BWON-NEXT:    addl $8, %ecx
; X86-BWON-NEXT:    decl %eax
; X86-BWON-NEXT:    jne .LBB3_2
; X86-BWON-NEXT:  .LBB3_3: # %._crit_edge
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: merge_nonconst_store:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWOFF-NEXT:    testl %eax, %eax
; X86-BWOFF-NEXT:    jle .LBB3_3
; X86-BWOFF-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    movb {{[0-9]+}}(%esp), %dl
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB3_2: # %.lr.ph
; X86-BWOFF-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movl $67305985, (%ecx) # imm = 0x4030201
; X86-BWOFF-NEXT:    movb %dl, 4(%ecx)
; X86-BWOFF-NEXT:    movw $1798, 5(%ecx) # imm = 0x706
; X86-BWOFF-NEXT:    movb $8, 7(%ecx)
; X86-BWOFF-NEXT:    addl $8, %ecx
; X86-BWOFF-NEXT:    decl %eax
; X86-BWOFF-NEXT:    jne .LBB3_2
; X86-BWOFF-NEXT:  .LBB3_3: # %._crit_edge
; X86-BWOFF-NEXT:    retl
;
; X64-LABEL: merge_nonconst_store:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB3_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB3_1: # %.lr.ph
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    movl $67305985, (%rdx) # imm = 0x4030201
; X64-NEXT:    movb %sil, 4(%rdx)
; X64-NEXT:    movw $1798, 5(%rdx) # imm = 0x706
; X64-NEXT:    movb $8, 7(%rdx)
; X64-NEXT:    addq $8, %rdx
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB3_1
; X64-NEXT:  .LBB3_2: # %._crit_edge
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.A* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 4
  store i8 %zz, i8* %6, align 1                     ;  <----------- Not a const;
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 5
  store i8 6, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 6
  store i8 7, i8* %8, align 1
  %9 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 7
  store i8 8, i8* %9, align 1
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

define void @merge_loads_i16(i32 %count, %struct.A* noalias nocapture %q, %struct.A* noalias nocapture %p) nounwind uwtable noinline ssp {
; X86-BWON-LABEL: merge_loads_i16:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    .cfi_offset %esi, -8
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWON-NEXT:    testl %eax, %eax
; X86-BWON-NEXT:    jle .LBB4_3
; X86-BWON-NEXT:  # %bb.1: # %.lr.ph
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB4_2: # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movzwl (%edx), %esi
; X86-BWON-NEXT:    movw %si, (%ecx)
; X86-BWON-NEXT:    addl $8, %ecx
; X86-BWON-NEXT:    decl %eax
; X86-BWON-NEXT:    jne .LBB4_2
; X86-BWON-NEXT:  .LBB4_3: # %._crit_edge
; X86-BWON-NEXT:    popl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: merge_loads_i16:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    .cfi_offset %esi, -8
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWOFF-NEXT:    testl %eax, %eax
; X86-BWOFF-NEXT:    jle .LBB4_3
; X86-BWOFF-NEXT:  # %bb.1: # %.lr.ph
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB4_2: # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movw (%edx), %si
; X86-BWOFF-NEXT:    movw %si, (%ecx)
; X86-BWOFF-NEXT:    addl $8, %ecx
; X86-BWOFF-NEXT:    decl %eax
; X86-BWOFF-NEXT:    jne .LBB4_2
; X86-BWOFF-NEXT:  .LBB4_3: # %._crit_edge
; X86-BWOFF-NEXT:    popl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: merge_loads_i16:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    testl %edi, %edi
; X64-BWON-NEXT:    jle .LBB4_2
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB4_1: # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movzwl (%rsi), %eax
; X64-BWON-NEXT:    movw %ax, (%rdx)
; X64-BWON-NEXT:    addq $8, %rdx
; X64-BWON-NEXT:    decl %edi
; X64-BWON-NEXT:    jne .LBB4_1
; X64-BWON-NEXT:  .LBB4_2: # %._crit_edge
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: merge_loads_i16:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    testl %edi, %edi
; X64-BWOFF-NEXT:    jle .LBB4_2
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB4_1: # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movw (%rsi), %ax
; X64-BWOFF-NEXT:    movw %ax, (%rdx)
; X64-BWOFF-NEXT:    addq $8, %rdx
; X64-BWOFF-NEXT:    decl %edi
; X64-BWOFF-NEXT:    jne .LBB4_1
; X64-BWOFF-NEXT:  .LBB4_2: # %._crit_edge
; X64-BWOFF-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 1
  br label %4

; <label>:4                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %9, %4 ]
  %.01 = phi %struct.A* [ %p, %.lr.ph ], [ %10, %4 ]
  %5 = load i8, i8* %2, align 1
  %6 = load i8, i8* %3, align 1
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 %5, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 %6, i8* %8, align 1
  %9 = add nsw i32 %i.02, 1
  %10 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %9, %count
  br i1 %exitcond, label %._crit_edge, label %4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; The loads and the stores are interleaved. Can't merge them.
define void @no_merge_loads(i32 %count, %struct.A* noalias nocapture %q, %struct.A* noalias nocapture %p) nounwind uwtable noinline ssp {
; X86-BWON-LABEL: no_merge_loads:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    .cfi_offset %ebx, -8
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWON-NEXT:    testl %eax, %eax
; X86-BWON-NEXT:    jle .LBB5_3
; X86-BWON-NEXT:  # %bb.1: # %.lr.ph
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB5_2: # %a4
; X86-BWON-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movzbl (%edx), %ebx
; X86-BWON-NEXT:    movb %bl, (%ecx)
; X86-BWON-NEXT:    movzbl 1(%edx), %ebx
; X86-BWON-NEXT:    movb %bl, 1(%ecx)
; X86-BWON-NEXT:    addl $8, %ecx
; X86-BWON-NEXT:    decl %eax
; X86-BWON-NEXT:    jne .LBB5_2
; X86-BWON-NEXT:  .LBB5_3: # %._crit_edge
; X86-BWON-NEXT:    popl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: no_merge_loads:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    .cfi_offset %ebx, -8
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-BWOFF-NEXT:    testl %eax, %eax
; X86-BWOFF-NEXT:    jle .LBB5_3
; X86-BWOFF-NEXT:  # %bb.1: # %.lr.ph
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB5_2: # %a4
; X86-BWOFF-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movb (%edx), %bl
; X86-BWOFF-NEXT:    movb %bl, (%ecx)
; X86-BWOFF-NEXT:    movb 1(%edx), %bl
; X86-BWOFF-NEXT:    movb %bl, 1(%ecx)
; X86-BWOFF-NEXT:    addl $8, %ecx
; X86-BWOFF-NEXT:    decl %eax
; X86-BWOFF-NEXT:    jne .LBB5_2
; X86-BWOFF-NEXT:  .LBB5_3: # %._crit_edge
; X86-BWOFF-NEXT:    popl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: no_merge_loads:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    testl %edi, %edi
; X64-BWON-NEXT:    jle .LBB5_2
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB5_1: # %a4
; X64-BWON-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movzbl (%rsi), %eax
; X64-BWON-NEXT:    movb %al, (%rdx)
; X64-BWON-NEXT:    movzbl 1(%rsi), %eax
; X64-BWON-NEXT:    movb %al, 1(%rdx)
; X64-BWON-NEXT:    addq $8, %rdx
; X64-BWON-NEXT:    decl %edi
; X64-BWON-NEXT:    jne .LBB5_1
; X64-BWON-NEXT:  .LBB5_2: # %._crit_edge
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: no_merge_loads:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    testl %edi, %edi
; X64-BWOFF-NEXT:    jle .LBB5_2
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB5_1: # %a4
; X64-BWOFF-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movb (%rsi), %al
; X64-BWOFF-NEXT:    movb %al, (%rdx)
; X64-BWOFF-NEXT:    movb 1(%rsi), %al
; X64-BWOFF-NEXT:    movb %al, 1(%rdx)
; X64-BWOFF-NEXT:    addq $8, %rdx
; X64-BWOFF-NEXT:    decl %edi
; X64-BWOFF-NEXT:    jne .LBB5_1
; X64-BWOFF-NEXT:  .LBB5_2: # %._crit_edge
; X64-BWOFF-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 1
  br label %a4

a4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %a9, %a4 ]
  %.01 = phi %struct.A* [ %p, %.lr.ph ], [ %a10, %a4 ]
  %a5 = load i8, i8* %2, align 1
  %a7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 %a5, i8* %a7, align 1
  %a8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  %a6 = load i8, i8* %3, align 1
  store i8 %a6, i8* %a8, align 1
  %a9 = add nsw i32 %i.02, 1
  %a10 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %a9, %count
  br i1 %exitcond, label %._crit_edge, label %a4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

define void @merge_loads_integer(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_loads_integer:
; X86:       # %bb.0:
; X86-NEXT:    pushl %edi
; X86-NEXT:    .cfi_def_cfa_offset 8
; X86-NEXT:    pushl %esi
; X86-NEXT:    .cfi_def_cfa_offset 12
; X86-NEXT:    .cfi_offset %esi, -12
; X86-NEXT:    .cfi_offset %edi, -8
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB6_3
; X86-NEXT:  # %bb.1: # %.lr.ph
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB6_2: # =>This Inner Loop Header: Depth=1
; X86-NEXT:    movl (%edx), %esi
; X86-NEXT:    movl 4(%edx), %edi
; X86-NEXT:    movl %esi, (%ecx)
; X86-NEXT:    movl %edi, 4(%ecx)
; X86-NEXT:    addl $32, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB6_2
; X86-NEXT:  .LBB6_3: # %._crit_edge
; X86-NEXT:    popl %esi
; X86-NEXT:    .cfi_def_cfa_offset 8
; X86-NEXT:    popl %edi
; X86-NEXT:    .cfi_def_cfa_offset 4
; X86-NEXT:    retl
;
; X64-LABEL: merge_loads_integer:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB6_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB6_1: # =>This Inner Loop Header: Depth=1
; X64-NEXT:    movq (%rsi), %rax
; X64-NEXT:    movq %rax, (%rdx)
; X64-NEXT:    addq $32, %rdx
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB6_1
; X64-NEXT:  .LBB6_2: # %._crit_edge
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  br label %4

; <label>:4                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %9, %4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %10, %4 ]
  %5 = load i32, i32* %2
  %6 = load i32, i32* %3
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 %5, i32* %7
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 %6, i32* %8
  %9 = add nsw i32 %i.02, 1
  %10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %9, %count
  br i1 %exitcond, label %._crit_edge, label %4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

define void @merge_loads_vector(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_loads_vector:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB7_3
; X86-NEXT:  # %bb.1: # %.lr.ph
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB7_2: # %block4
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    vmovups (%edx), %xmm0
; X86-NEXT:    vmovups %xmm0, (%ecx)
; X86-NEXT:    addl $32, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB7_2
; X86-NEXT:  .LBB7_3: # %._crit_edge
; X86-NEXT:    retl
;
; X64-LABEL: merge_loads_vector:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB7_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB7_1: # %block4
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    vmovups (%rsi), %xmm0
; X64-NEXT:    vmovups %xmm0, (%rdx)
; X64-NEXT:    addq $32, %rdx
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB7_1
; X64-NEXT:  .LBB7_2: # %._crit_edge
; X64-NEXT:    retq
  %a1 = icmp sgt i32 %count, 0
  br i1 %a1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %a2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %a3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  %a4 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 2
  %a5 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 3
  br label %block4

block4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %c9, %block4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %c10, %block4 ]
  %a7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  %a8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  %a9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  %a10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  %b1 = load i32, i32* %a2
  %b2 = load i32, i32* %a3
  %b3 = load i32, i32* %a4
  %b4 = load i32, i32* %a5
  store i32 %b1, i32* %a7
  store i32 %b2, i32* %a8
  store i32 %b3, i32* %a9
  store i32 %b4, i32* %a10
  %c9 = add nsw i32 %i.02, 1
  %c10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %c9, %count
  br i1 %exitcond, label %._crit_edge, label %block4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; On x86, even unaligned copies can be merged to vector ops.
define void @merge_loads_no_align(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_loads_no_align:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB8_3
; X86-NEXT:  # %bb.1: # %.lr.ph
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB8_2: # %block4
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    vmovups (%edx), %xmm0
; X86-NEXT:    vmovups %xmm0, (%ecx)
; X86-NEXT:    addl $32, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB8_2
; X86-NEXT:  .LBB8_3: # %._crit_edge
; X86-NEXT:    retl
;
; X64-LABEL: merge_loads_no_align:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB8_2
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB8_1: # %block4
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    vmovups (%rsi), %xmm0
; X64-NEXT:    vmovups %xmm0, (%rdx)
; X64-NEXT:    addq $32, %rdx
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB8_1
; X64-NEXT:  .LBB8_2: # %._crit_edge
; X64-NEXT:    retq
  %a1 = icmp sgt i32 %count, 0
  br i1 %a1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %a2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %a3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  %a4 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 2
  %a5 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 3
  br label %block4

block4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %c9, %block4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %c10, %block4 ]
  %a7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  %a8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  %a9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  %a10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  %b1 = load i32, i32* %a2, align 1
  %b2 = load i32, i32* %a3, align 1
  %b3 = load i32, i32* %a4, align 1
  %b4 = load i32, i32* %a5, align 1
  store i32 %b1, i32* %a7, align 1
  store i32 %b2, i32* %a8, align 1
  store i32 %b3, i32* %a9, align 1
  store i32 %b4, i32* %a10, align 1
  %c9 = add nsw i32 %i.02, 1
  %c10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %c9, %count
  br i1 %exitcond, label %._crit_edge, label %block4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy.
define void @MergeLoadStoreBaseIndexOffset(i64* %a, i8* %b, i8* %c, i32 %n) {
; X86-BWON-LABEL: MergeLoadStoreBaseIndexOffset:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    pushl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    pushl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    .cfi_offset %esi, -16
; X86-BWON-NEXT:    .cfi_offset %edi, -12
; X86-BWON-NEXT:    .cfi_offset %ebx, -8
; X86-BWON-NEXT:    xorl %eax, %eax
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movl (%edi,%eax,8), %ebx
; X86-BWON-NEXT:    movzwl (%edx,%ebx), %ebx
; X86-BWON-NEXT:    movw %bx, (%esi,%eax,2)
; X86-BWON-NEXT:    incl %eax
; X86-BWON-NEXT:    cmpl %eax, %ecx
; X86-BWON-NEXT:    jne .LBB9_1
; X86-BWON-NEXT:  # %bb.2:
; X86-BWON-NEXT:    popl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    popl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    popl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: MergeLoadStoreBaseIndexOffset:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    pushl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    pushl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    .cfi_offset %esi, -16
; X86-BWOFF-NEXT:    .cfi_offset %edi, -12
; X86-BWOFF-NEXT:    .cfi_offset %ebx, -8
; X86-BWOFF-NEXT:    xorl %eax, %eax
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movl (%edi,%eax,8), %ebx
; X86-BWOFF-NEXT:    movw (%edx,%ebx), %bx
; X86-BWOFF-NEXT:    movw %bx, (%esi,%eax,2)
; X86-BWOFF-NEXT:    incl %eax
; X86-BWOFF-NEXT:    cmpl %eax, %ecx
; X86-BWOFF-NEXT:    jne .LBB9_1
; X86-BWOFF-NEXT:  # %bb.2:
; X86-BWOFF-NEXT:    popl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    popl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    popl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: MergeLoadStoreBaseIndexOffset:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    movl %ecx, %eax
; X64-BWON-NEXT:    xorl %ecx, %ecx
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movq (%rdi,%rcx,8), %r8
; X64-BWON-NEXT:    movzwl (%rdx,%r8), %r8d
; X64-BWON-NEXT:    movw %r8w, (%rsi,%rcx,2)
; X64-BWON-NEXT:    incq %rcx
; X64-BWON-NEXT:    cmpl %ecx, %eax
; X64-BWON-NEXT:    jne .LBB9_1
; X64-BWON-NEXT:  # %bb.2:
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: MergeLoadStoreBaseIndexOffset:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    movl %ecx, %eax
; X64-BWOFF-NEXT:    xorl %ecx, %ecx
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movq (%rdi,%rcx,8), %r8
; X64-BWOFF-NEXT:    movw (%rdx,%r8), %r8w
; X64-BWOFF-NEXT:    movw %r8w, (%rsi,%rcx,2)
; X64-BWOFF-NEXT:    incq %rcx
; X64-BWOFF-NEXT:    cmpl %ecx, %eax
; X64-BWOFF-NEXT:    jne .LBB9_1
; X64-BWOFF-NEXT:  # %bb.2:
; X64-BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %11, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %10, %1 ]
  %.0 = phi i64* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i64, i64* %.0, i64 1
  %3 = load i64, i64* %.0, align 1
  %4 = getelementptr inbounds i8, i8* %c, i64 %3
  %5 = load i8, i8* %4, align 1
  %6 = add i64 %3, 1
  %7 = getelementptr inbounds i8, i8* %c, i64 %6
  %8 = load i8, i8* %7, align 1
  store i8 %5, i8* %.08, align 1
  %9 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %8, i8* %9, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 2
  %11 = add nsw i32 %.09, -1
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %13, label %1

; <label>:13
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy for complicated address calculation.
define void @MergeLoadStoreBaseIndexOffsetComplicated(i8* %a, i8* %b, i8* %c, i64 %n) {
; X86-BWON-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %ebp
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    pushl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    pushl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    pushl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 20
; X86-BWON-NEXT:    .cfi_offset %esi, -20
; X86-BWON-NEXT:    .cfi_offset %edi, -16
; X86-BWON-NEXT:    .cfi_offset %ebx, -12
; X86-BWON-NEXT:    .cfi_offset %ebp, -8
; X86-BWON-NEXT:    xorl %eax, %eax
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-BWON-NEXT:    xorl %ebp, %ebp
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movsbl (%edi), %ecx
; X86-BWON-NEXT:    movzbl (%esi,%ecx), %edx
; X86-BWON-NEXT:    movzbl 1(%esi,%ecx), %ecx
; X86-BWON-NEXT:    movb %dl, (%ebx,%eax)
; X86-BWON-NEXT:    movl %eax, %edx
; X86-BWON-NEXT:    orl $1, %edx
; X86-BWON-NEXT:    movb %cl, (%ebx,%edx)
; X86-BWON-NEXT:    incl %edi
; X86-BWON-NEXT:    addl $2, %eax
; X86-BWON-NEXT:    adcl $0, %ebp
; X86-BWON-NEXT:    cmpl {{[0-9]+}}(%esp), %eax
; X86-BWON-NEXT:    movl %ebp, %ecx
; X86-BWON-NEXT:    sbbl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    jl .LBB10_1
; X86-BWON-NEXT:  # %bb.2:
; X86-BWON-NEXT:    popl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    popl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    popl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    popl %ebp
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %ebp
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    pushl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    pushl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    pushl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 20
; X86-BWOFF-NEXT:    .cfi_offset %esi, -20
; X86-BWOFF-NEXT:    .cfi_offset %edi, -16
; X86-BWOFF-NEXT:    .cfi_offset %ebx, -12
; X86-BWOFF-NEXT:    .cfi_offset %ebp, -8
; X86-BWOFF-NEXT:    xorl %eax, %eax
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-BWOFF-NEXT:    xorl %ebp, %ebp
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movsbl (%edi), %ecx
; X86-BWOFF-NEXT:    movb (%esi,%ecx), %dl
; X86-BWOFF-NEXT:    movb 1(%esi,%ecx), %cl
; X86-BWOFF-NEXT:    movb %dl, (%ebx,%eax)
; X86-BWOFF-NEXT:    movl %eax, %edx
; X86-BWOFF-NEXT:    orl $1, %edx
; X86-BWOFF-NEXT:    movb %cl, (%ebx,%edx)
; X86-BWOFF-NEXT:    incl %edi
; X86-BWOFF-NEXT:    addl $2, %eax
; X86-BWOFF-NEXT:    adcl $0, %ebp
; X86-BWOFF-NEXT:    cmpl {{[0-9]+}}(%esp), %eax
; X86-BWOFF-NEXT:    movl %ebp, %ecx
; X86-BWOFF-NEXT:    sbbl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    jl .LBB10_1
; X86-BWOFF-NEXT:  # %bb.2:
; X86-BWOFF-NEXT:    popl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    popl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    popl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    popl %ebp
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    xorl %eax, %eax
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movsbq (%rsi), %r8
; X64-BWON-NEXT:    movzwl (%rdx,%r8), %r8d
; X64-BWON-NEXT:    movw %r8w, (%rdi,%rax)
; X64-BWON-NEXT:    incq %rsi
; X64-BWON-NEXT:    addq $2, %rax
; X64-BWON-NEXT:    cmpq %rcx, %rax
; X64-BWON-NEXT:    jl .LBB10_1
; X64-BWON-NEXT:  # %bb.2:
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    xorl %eax, %eax
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movsbq (%rsi), %r8
; X64-BWOFF-NEXT:    movw (%rdx,%r8), %r8w
; X64-BWOFF-NEXT:    movw %r8w, (%rdi,%rax)
; X64-BWOFF-NEXT:    incq %rsi
; X64-BWOFF-NEXT:    addq $2, %rax
; X64-BWOFF-NEXT:    cmpq %rcx, %rax
; X64-BWOFF-NEXT:    jl .LBB10_1
; X64-BWOFF-NEXT:  # %bb.2:
; X64-BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i64 [ 0, %0 ], [ %13, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %12, %1 ]
  %2 = load i8, i8* %.08, align 1
  %3 = sext i8 %2 to i64
  %4 = getelementptr inbounds i8, i8* %c, i64 %3
  %5 = load i8, i8* %4, align 1
  %6 = add nsw i64 %3, 1
  %7 = getelementptr inbounds i8, i8* %c, i64 %6
  %8 = load i8, i8* %7, align 1
  %9 = getelementptr inbounds i8, i8* %a, i64 %.09
  store i8 %5, i8* %9, align 1
  %10 = or i64 %.09, 1
  %11 = getelementptr inbounds i8, i8* %a, i64 %10
  store i8 %8, i8* %11, align 1
  %12 = getelementptr inbounds i8, i8* %.08, i64 1
  %13 = add nuw nsw i64 %.09, 2
  %14 = icmp slt i64 %13, %n
  br i1 %14, label %1, label %15

; <label>:15
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy even if there are intermediate sign
; extensions.
define void @MergeLoadStoreBaseIndexOffsetSext(i8* %a, i8* %b, i8* %c, i32 %n) {
; X86-BWON-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    pushl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    pushl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    .cfi_offset %esi, -16
; X86-BWON-NEXT:    .cfi_offset %edi, -12
; X86-BWON-NEXT:    .cfi_offset %ebx, -8
; X86-BWON-NEXT:    xorl %eax, %eax
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movsbl (%edi,%eax), %ebx
; X86-BWON-NEXT:    movzwl (%edx,%ebx), %ebx
; X86-BWON-NEXT:    movw %bx, (%esi,%eax,2)
; X86-BWON-NEXT:    incl %eax
; X86-BWON-NEXT:    cmpl %eax, %ecx
; X86-BWON-NEXT:    jne .LBB11_1
; X86-BWON-NEXT:  # %bb.2:
; X86-BWON-NEXT:    popl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    popl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    popl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    pushl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    pushl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    .cfi_offset %esi, -16
; X86-BWOFF-NEXT:    .cfi_offset %edi, -12
; X86-BWOFF-NEXT:    .cfi_offset %ebx, -8
; X86-BWOFF-NEXT:    xorl %eax, %eax
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movsbl (%edi,%eax), %ebx
; X86-BWOFF-NEXT:    movw (%edx,%ebx), %bx
; X86-BWOFF-NEXT:    movw %bx, (%esi,%eax,2)
; X86-BWOFF-NEXT:    incl %eax
; X86-BWOFF-NEXT:    cmpl %eax, %ecx
; X86-BWOFF-NEXT:    jne .LBB11_1
; X86-BWOFF-NEXT:  # %bb.2:
; X86-BWOFF-NEXT:    popl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    popl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    popl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    movl %ecx, %eax
; X64-BWON-NEXT:    xorl %ecx, %ecx
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movsbq (%rdi,%rcx), %r8
; X64-BWON-NEXT:    movzwl (%rdx,%r8), %r8d
; X64-BWON-NEXT:    movw %r8w, (%rsi,%rcx,2)
; X64-BWON-NEXT:    incq %rcx
; X64-BWON-NEXT:    cmpl %ecx, %eax
; X64-BWON-NEXT:    jne .LBB11_1
; X64-BWON-NEXT:  # %bb.2:
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    movl %ecx, %eax
; X64-BWOFF-NEXT:    xorl %ecx, %ecx
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movsbq (%rdi,%rcx), %r8
; X64-BWOFF-NEXT:    movw (%rdx,%r8), %r8w
; X64-BWOFF-NEXT:    movw %r8w, (%rsi,%rcx,2)
; X64-BWOFF-NEXT:    incq %rcx
; X64-BWOFF-NEXT:    cmpl %ecx, %eax
; X64-BWOFF-NEXT:    jne .LBB11_1
; X64-BWOFF-NEXT:  # %bb.2:
; X64-BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %12, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %11, %1 ]
  %.0 = phi i8* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i8, i8* %.0, i64 1
  %3 = load i8, i8* %.0, align 1
  %4 = sext i8 %3 to i64
  %5 = getelementptr inbounds i8, i8* %c, i64 %4
  %6 = load i8, i8* %5, align 1
  %7 = add i64 %4, 1
  %8 = getelementptr inbounds i8, i8* %c, i64 %7
  %9 = load i8, i8* %8, align 1
  store i8 %6, i8* %.08, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %9, i8* %10, align 1
  %11 = getelementptr inbounds i8, i8* %.08, i64 2
  %12 = add nsw i32 %.09, -1
  %13 = icmp eq i32 %12, 0
  br i1 %13, label %14, label %1

; <label>:14
  ret void
}

; However, we can only merge ignore sign extensions when they are on all memory
; computations;
define void @loadStoreBaseIndexOffsetSextNoSex(i8* %a, i8* %b, i8* %c, i32 %n) {
; X86-BWON-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; X86-BWON:       # %bb.0:
; X86-BWON-NEXT:    pushl %ebp
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    pushl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    pushl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    pushl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 20
; X86-BWON-NEXT:    .cfi_offset %esi, -20
; X86-BWON-NEXT:    .cfi_offset %edi, -16
; X86-BWON-NEXT:    .cfi_offset %ebx, -12
; X86-BWON-NEXT:    .cfi_offset %ebp, -8
; X86-BWON-NEXT:    xorl %eax, %eax
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWON-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWON-NEXT:    .p2align 4, 0x90
; X86-BWON-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; X86-BWON-NEXT:    movsbl (%edi,%eax), %ebx
; X86-BWON-NEXT:    movzbl (%edx,%ebx), %ecx
; X86-BWON-NEXT:    incb %bl
; X86-BWON-NEXT:    movsbl %bl, %ebx
; X86-BWON-NEXT:    movb (%edx,%ebx), %ch
; X86-BWON-NEXT:    movb %cl, (%esi,%eax,2)
; X86-BWON-NEXT:    movb %ch, 1(%esi,%eax,2)
; X86-BWON-NEXT:    incl %eax
; X86-BWON-NEXT:    cmpl %eax, %ebp
; X86-BWON-NEXT:    jne .LBB12_1
; X86-BWON-NEXT:  # %bb.2:
; X86-BWON-NEXT:    popl %esi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 16
; X86-BWON-NEXT:    popl %edi
; X86-BWON-NEXT:    .cfi_def_cfa_offset 12
; X86-BWON-NEXT:    popl %ebx
; X86-BWON-NEXT:    .cfi_def_cfa_offset 8
; X86-BWON-NEXT:    popl %ebp
; X86-BWON-NEXT:    .cfi_def_cfa_offset 4
; X86-BWON-NEXT:    retl
;
; X86-BWOFF-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; X86-BWOFF:       # %bb.0:
; X86-BWOFF-NEXT:    pushl %ebp
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    pushl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    pushl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    pushl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 20
; X86-BWOFF-NEXT:    .cfi_offset %esi, -20
; X86-BWOFF-NEXT:    .cfi_offset %edi, -16
; X86-BWOFF-NEXT:    .cfi_offset %ebx, -12
; X86-BWOFF-NEXT:    .cfi_offset %ebp, -8
; X86-BWOFF-NEXT:    xorl %eax, %eax
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-BWOFF-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-BWOFF-NEXT:    .p2align 4, 0x90
; X86-BWOFF-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; X86-BWOFF-NEXT:    movsbl (%edi,%eax), %ebx
; X86-BWOFF-NEXT:    movb (%edx,%ebx), %cl
; X86-BWOFF-NEXT:    incb %bl
; X86-BWOFF-NEXT:    movsbl %bl, %ebx
; X86-BWOFF-NEXT:    movb (%edx,%ebx), %ch
; X86-BWOFF-NEXT:    movb %cl, (%esi,%eax,2)
; X86-BWOFF-NEXT:    movb %ch, 1(%esi,%eax,2)
; X86-BWOFF-NEXT:    incl %eax
; X86-BWOFF-NEXT:    cmpl %eax, %ebp
; X86-BWOFF-NEXT:    jne .LBB12_1
; X86-BWOFF-NEXT:  # %bb.2:
; X86-BWOFF-NEXT:    popl %esi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 16
; X86-BWOFF-NEXT:    popl %edi
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 12
; X86-BWOFF-NEXT:    popl %ebx
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 8
; X86-BWOFF-NEXT:    popl %ebp
; X86-BWOFF-NEXT:    .cfi_def_cfa_offset 4
; X86-BWOFF-NEXT:    retl
;
; X64-BWON-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; X64-BWON:       # %bb.0:
; X64-BWON-NEXT:    movl %ecx, %eax
; X64-BWON-NEXT:    xorl %ecx, %ecx
; X64-BWON-NEXT:    .p2align 4, 0x90
; X64-BWON-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; X64-BWON-NEXT:    movsbq (%rdi,%rcx), %r8
; X64-BWON-NEXT:    movzbl (%rdx,%r8), %r9d
; X64-BWON-NEXT:    incl %r8d
; X64-BWON-NEXT:    movsbq %r8b, %r8
; X64-BWON-NEXT:    movzbl (%rdx,%r8), %r8d
; X64-BWON-NEXT:    movb %r9b, (%rsi,%rcx,2)
; X64-BWON-NEXT:    movb %r8b, 1(%rsi,%rcx,2)
; X64-BWON-NEXT:    incq %rcx
; X64-BWON-NEXT:    cmpl %ecx, %eax
; X64-BWON-NEXT:    jne .LBB12_1
; X64-BWON-NEXT:  # %bb.2:
; X64-BWON-NEXT:    retq
;
; X64-BWOFF-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; X64-BWOFF:       # %bb.0:
; X64-BWOFF-NEXT:    movl %ecx, %eax
; X64-BWOFF-NEXT:    xorl %ecx, %ecx
; X64-BWOFF-NEXT:    .p2align 4, 0x90
; X64-BWOFF-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; X64-BWOFF-NEXT:    movsbq (%rdi,%rcx), %r8
; X64-BWOFF-NEXT:    movb (%rdx,%r8), %r9b
; X64-BWOFF-NEXT:    incl %r8d
; X64-BWOFF-NEXT:    movsbq %r8b, %r8
; X64-BWOFF-NEXT:    movb (%rdx,%r8), %r8b
; X64-BWOFF-NEXT:    movb %r9b, (%rsi,%rcx,2)
; X64-BWOFF-NEXT:    movb %r8b, 1(%rsi,%rcx,2)
; X64-BWOFF-NEXT:    incq %rcx
; X64-BWOFF-NEXT:    cmpl %ecx, %eax
; X64-BWOFF-NEXT:    jne .LBB12_1
; X64-BWOFF-NEXT:  # %bb.2:
; X64-BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %12, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %11, %1 ]
  %.0 = phi i8* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i8, i8* %.0, i64 1
  %3 = load i8, i8* %.0, align 1
  %4 = sext i8 %3 to i64
  %5 = getelementptr inbounds i8, i8* %c, i64 %4
  %6 = load i8, i8* %5, align 1
  %7 = add i8 %3, 1
  %wrap.4 = sext i8 %7 to i64
  %8 = getelementptr inbounds i8, i8* %c, i64 %wrap.4
  %9 = load i8, i8* %8, align 1
  store i8 %6, i8* %.08, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %9, i8* %10, align 1
  %11 = getelementptr inbounds i8, i8* %.08, i64 2
  %12 = add nsw i32 %.09, -1
  %13 = icmp eq i32 %12, 0
  br i1 %13, label %14, label %1

; <label>:14
  ret void
}

; PR21711 ( http://llvm.org/bugs/show_bug.cgi?id=21711 )
define void @merge_vec_element_store(<8 x float> %v, float* %ptr) {
; X86-LABEL: merge_vec_element_store:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vmovups %ymm0, (%eax)
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_element_store:
; X64:       # %bb.0:
; X64-NEXT:    vmovups %ymm0, (%rdi)
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %vecext0 = extractelement <8 x float> %v, i32 0
  %vecext1 = extractelement <8 x float> %v, i32 1
  %vecext2 = extractelement <8 x float> %v, i32 2
  %vecext3 = extractelement <8 x float> %v, i32 3
  %vecext4 = extractelement <8 x float> %v, i32 4
  %vecext5 = extractelement <8 x float> %v, i32 5
  %vecext6 = extractelement <8 x float> %v, i32 6
  %vecext7 = extractelement <8 x float> %v, i32 7
  %arrayidx1 = getelementptr inbounds float, float* %ptr, i64 1
  %arrayidx2 = getelementptr inbounds float, float* %ptr, i64 2
  %arrayidx3 = getelementptr inbounds float, float* %ptr, i64 3
  %arrayidx4 = getelementptr inbounds float, float* %ptr, i64 4
  %arrayidx5 = getelementptr inbounds float, float* %ptr, i64 5
  %arrayidx6 = getelementptr inbounds float, float* %ptr, i64 6
  %arrayidx7 = getelementptr inbounds float, float* %ptr, i64 7
  store float %vecext0, float* %ptr, align 4
  store float %vecext1, float* %arrayidx1, align 4
  store float %vecext2, float* %arrayidx2, align 4
  store float %vecext3, float* %arrayidx3, align 4
  store float %vecext4, float* %arrayidx4, align 4
  store float %vecext5, float* %arrayidx5, align 4
  store float %vecext6, float* %arrayidx6, align 4
  store float %vecext7, float* %arrayidx7, align 4
  ret void

}

; PR21711 - Merge vector stores into wider vector stores.
; These should be merged into 32-byte stores.
define void @merge_vec_extract_stores(<8 x float> %v1, <8 x float> %v2, <4 x float>* %ptr) {
; X86-LABEL: merge_vec_extract_stores:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vmovups %ymm0, 48(%eax)
; X86-NEXT:    vmovups %ymm1, 80(%eax)
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_extract_stores:
; X64:       # %bb.0:
; X64-NEXT:    vmovups %ymm0, 48(%rdi)
; X64-NEXT:    vmovups %ymm1, 80(%rdi)
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 4
  %idx2 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 5
  %idx3 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 6
  %shuffle0 = shufflevector <8 x float> %v1, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %shuffle1 = shufflevector <8 x float> %v1, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %shuffle2 = shufflevector <8 x float> %v2, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %shuffle3 = shufflevector <8 x float> %v2, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  store <4 x float> %shuffle0, <4 x float>* %idx0, align 16
  store <4 x float> %shuffle1, <4 x float>* %idx1, align 16
  store <4 x float> %shuffle2, <4 x float>* %idx2, align 16
  store <4 x float> %shuffle3, <4 x float>* %idx3, align 16
  ret void

}

; Merging vector stores when sourced from vector loads.
define void @merge_vec_stores_from_loads(<4 x float>* %v, <4 x float>* %ptr) {
; X86-LABEL: merge_vec_stores_from_loads:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    vmovups (%ecx), %ymm0
; X86-NEXT:    vmovups %ymm0, (%eax)
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_stores_from_loads:
; X64:       # %bb.0:
; X64-NEXT:    vmovups (%rdi), %ymm0
; X64-NEXT:    vmovups %ymm0, (%rsi)
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %load_idx0 = getelementptr inbounds <4 x float>, <4 x float>* %v, i64 0
  %load_idx1 = getelementptr inbounds <4 x float>, <4 x float>* %v, i64 1
  %v0 = load <4 x float>, <4 x float>* %load_idx0
  %v1 = load <4 x float>, <4 x float>* %load_idx1
  %store_idx0 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 0
  %store_idx1 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 1
  store <4 x float> %v0, <4 x float>* %store_idx0, align 16
  store <4 x float> %v1, <4 x float>* %store_idx1, align 16
  ret void

}

define void @merge_vec_stores_of_zero(<4 x i32>* %ptr) {
; X86-LABEL: merge_vec_stores_of_zero:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X86-NEXT:    vmovups %ymm0, 48(%eax)
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_stores_of_zero:
; X64:       # %bb.0:
; X64-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X64-NEXT:    vmovups %ymm0, 48(%rdi)
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 4
  store <4 x i32> zeroinitializer, <4 x i32>* %idx0, align 16
  store <4 x i32> zeroinitializer, <4 x i32>* %idx1, align 16
  ret void
}

define void @merge_vec_stores_of_constant_splat(<4 x i32>* %ptr) {
; X86-LABEL: merge_vec_stores_of_constant_splat:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vbroadcastss {{.*#+}} xmm0 = [42,42,42,42]
; X86-NEXT:    vmovaps %xmm0, 48(%eax)
; X86-NEXT:    vmovaps %xmm0, 64(%eax)
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_stores_of_constant_splat:
; X64:       # %bb.0:
; X64-NEXT:    vbroadcastss {{.*#+}} xmm0 = [42,42,42,42]
; X64-NEXT:    vmovaps %xmm0, 48(%rdi)
; X64-NEXT:    vmovaps %xmm0, 64(%rdi)
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 4
  store <4 x i32> <i32 42, i32 42, i32 42, i32 42>, <4 x i32>* %idx0, align 16
  store <4 x i32> <i32 42, i32 42, i32 42, i32 42>, <4 x i32>* %idx1, align 16
  ret void
}

define void @merge_vec_stores_of_constants(<4 x i32>* %ptr) {
; X86-LABEL: merge_vec_stores_of_constants:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vmovaps {{.*#+}} xmm0 = [25,51,45,0]
; X86-NEXT:    vmovaps %xmm0, 48(%eax)
; X86-NEXT:    vmovaps {{.*#+}} xmm0 = [0,265,26,0]
; X86-NEXT:    vmovaps %xmm0, 64(%eax)
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_stores_of_constants:
; X64:       # %bb.0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [25,51,45,0]
; X64-NEXT:    vmovaps %xmm0, 48(%rdi)
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,265,26,0]
; X64-NEXT:    vmovaps %xmm0, 64(%rdi)
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 4
  store <4 x i32> <i32 25, i32 51, i32 45, i32 0>, <4 x i32>* %idx0, align 16
  store <4 x i32> <i32 0, i32 265, i32 26, i32 0>, <4 x i32>* %idx1, align 16
  ret void
}

define void @merge_vec_stores_of_constants_with_undefs(<4 x i32>* %ptr) {
; X86-LABEL: merge_vec_stores_of_constants_with_undefs:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X86-NEXT:    vmovups %ymm0, 48(%eax)
; X86-NEXT:    vzeroupper
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_stores_of_constants_with_undefs:
; X64:       # %bb.0:
; X64-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; X64-NEXT:    vmovups %ymm0, 48(%rdi)
; X64-NEXT:    vzeroupper
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 4
  store <4 x i32> <i32 0, i32 0, i32 0, i32 undef>, <4 x i32>* %idx0, align 16
  store <4 x i32> <i32 0, i32 undef, i32 0, i32 0>, <4 x i32>* %idx1, align 16
  ret void
}

; This is a minimized test based on real code that was failing.
; This should now be merged.
define void @merge_vec_element_and_scalar_load([6 x i64]* %array) {
; X86-LABEL: merge_vec_element_and_scalar_load:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl (%eax), %ecx
; X86-NEXT:    movl 4(%eax), %edx
; X86-NEXT:    movl %edx, 36(%eax)
; X86-NEXT:    movl %ecx, 32(%eax)
; X86-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    vmovsd %xmm0, 40(%eax)
; X86-NEXT:    retl
;
; X64-LABEL: merge_vec_element_and_scalar_load:
; X64:       # %bb.0:
; X64-NEXT:    vmovups (%rdi), %xmm0
; X64-NEXT:    vmovups %xmm0, 32(%rdi)
; X64-NEXT:    retq
  %idx0 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 0
  %idx1 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 1
  %idx4 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 4
  %idx5 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 5

  %a0 = load i64, i64* %idx0, align 8
  store i64 %a0, i64* %idx4, align 8

  %b = bitcast i64* %idx1 to <2 x i64>*
  %v = load <2 x i64>, <2 x i64>* %b, align 8
  %a1 = extractelement <2 x i64> %v, i32 0
  store i64 %a1, i64* %idx5, align 8
  ret void

}

; Don't let a non-consecutive store thwart merging of the last two.
define void @almost_consecutive_stores(i8* %p) {
; X86-LABEL: almost_consecutive_stores:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movb $0, (%eax)
; X86-NEXT:    movb $1, 42(%eax)
; X86-NEXT:    movw $770, 2(%eax) # imm = 0x302
; X86-NEXT:    retl
;
; X64-LABEL: almost_consecutive_stores:
; X64:       # %bb.0:
; X64-NEXT:    movb $0, (%rdi)
; X64-NEXT:    movb $1, 42(%rdi)
; X64-NEXT:    movw $770, 2(%rdi) # imm = 0x302
; X64-NEXT:    retq
  store i8 0, i8* %p
  %p1 = getelementptr i8, i8* %p, i64 42
  store i8 1, i8* %p1
  %p2 = getelementptr i8, i8* %p, i64 2
  store i8 2, i8* %p2
  %p3 = getelementptr i8, i8* %p, i64 3
  store i8 3, i8* %p3
  ret void
}

; We should be able to merge these.
define void @merge_bitcast(<4 x i32> %v, float* %ptr) {
; X86-LABEL: merge_bitcast:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    vmovups %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: merge_bitcast:
; X64:       # %bb.0:
; X64-NEXT:    vmovups %xmm0, (%rdi)
; X64-NEXT:    retq
  %fv = bitcast <4 x i32> %v to <4 x float>
  %vecext1 = extractelement <4 x i32> %v, i32 1
  %vecext2 = extractelement <4 x i32> %v, i32 2
  %vecext3 = extractelement <4 x i32> %v, i32 3
  %f0 = extractelement <4 x float> %fv, i32 0
  %f1 = bitcast i32 %vecext1 to float
  %f2 = bitcast i32 %vecext2 to float
  %f3 = bitcast i32 %vecext3 to float
  %idx0 = getelementptr inbounds float, float* %ptr, i64 0
  %idx1 = getelementptr inbounds float, float* %ptr, i64 1
  %idx2 = getelementptr inbounds float, float* %ptr, i64 2
  %idx3 = getelementptr inbounds float, float* %ptr, i64 3
  store float %f0, float* %idx0, align 4
  store float %f1, float* %idx1, align 4
  store float %f2, float* %idx2, align 4
  store float %f3, float* %idx3, align 4
  ret void
}

; same as @merge_const_store with heterogeneous types.
define void @merge_const_store_heterogeneous(i32 %count, %struct.C* nocapture %p) nounwind uwtable noinline ssp {
; X86-LABEL: merge_const_store_heterogeneous:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    jle .LBB23_3
; X86-NEXT:  # %bb.1: # %.lr.ph.preheader
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    .p2align 4, 0x90
; X86-NEXT:  .LBB23_2: # %.lr.ph
; X86-NEXT:    # =>This Inner Loop Header: Depth=1
; X86-NEXT:    movl $67305985, (%ecx) # imm = 0x4030201
; X86-NEXT:    movl $134678021, 4(%ecx) # imm = 0x8070605
; X86-NEXT:    addl $24, %ecx
; X86-NEXT:    decl %eax
; X86-NEXT:    jne .LBB23_2
; X86-NEXT:  .LBB23_3: # %._crit_edge
; X86-NEXT:    retl
;
; X64-LABEL: merge_const_store_heterogeneous:
; X64:       # %bb.0:
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    jle .LBB23_3
; X64-NEXT:  # %bb.1: # %.lr.ph.preheader
; X64-NEXT:    movabsq $578437695752307201, %rax # imm = 0x807060504030201
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB23_2: # %.lr.ph
; X64-NEXT:    # =>This Inner Loop Header: Depth=1
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    addq $24, %rsi
; X64-NEXT:    decl %edi
; X64-NEXT:    jne .LBB23_2
; X64-NEXT:  .LBB23_3: # %._crit_edge
; X64-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %7, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.C* [ %8, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 4
  store i32 134678021, i32* %6, align 1
  %7 = add nsw i32 %i.02, 1
  %8 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 1
  %exitcond = icmp eq i32 %7, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Merging heterogeneous integer types.
define void @merge_heterogeneous(%struct.C* nocapture %p, %struct.C* nocapture %q) {
; X86-LABEL: merge_heterogeneous:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl (%ecx), %edx
; X86-NEXT:    movl 4(%ecx), %ecx
; X86-NEXT:    movl %edx, (%eax)
; X86-NEXT:    movl %ecx, 4(%eax)
; X86-NEXT:    retl
;
; X64-LABEL: merge_heterogeneous:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, (%rsi)
; X64-NEXT:    retq
  %s0 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 0
  %s1 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 1
  %s2 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 2
  %s3 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 3
  %s4 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 4
  %d0 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 0
  %d1 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 1
  %d2 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 2
  %d3 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 3
  %d4 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 4
  %v0 = load i8, i8* %s0, align 1
  %v1 = load i8, i8* %s1, align 1
  %v2 = load i8, i8* %s2, align 1
  %v3 = load i8, i8* %s3, align 1
  %v4 = load i32, i32* %s4, align 1
  store i8 %v0, i8* %d0, align 1
  store i8 %v1, i8* %d1, align 1
  store i8 %v2, i8* %d2, align 1
  store i8 %v3, i8* %d3, align 1
  store i32 %v4, i32* %d4, align 4
  ret void
}

define i32 @merge_store_load_store_seq(i32* %buff) {
; X86-LABEL: merge_store_load_store_seq:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $0, (%ecx)
; X86-NEXT:    movl 4(%ecx), %eax
; X86-NEXT:    movl $0, 4(%ecx)
; X86-NEXT:    retl
;
; X64-LABEL: merge_store_load_store_seq:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl 4(%rdi), %eax
; X64-NEXT:    movq $0, (%rdi)
; X64-NEXT:    retq
entry:

  store i32 0, i32* %buff, align 4
  %arrayidx1 = getelementptr inbounds i32, i32* %buff, i64 1
  %0 = load i32, i32* %arrayidx1, align 4
  store i32 0, i32* %arrayidx1, align 4
  ret i32 %0
}

define i32 @merge_store_alias(i32* %buff, i32* %other) {
; X86-LABEL: merge_store_alias:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $0, (%ecx)
; X86-NEXT:    movl (%eax), %eax
; X86-NEXT:    movl $0, 4(%ecx)
; X86-NEXT:    retl
;
; X64-LABEL: merge_store_alias:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl $0, (%rdi)
; X64-NEXT:    movl (%rsi), %eax
; X64-NEXT:    movl $0, 4(%rdi)
; X64-NEXT:    retq
entry:

  store i32 0, i32* %buff, align 4
  %arrayidx1 = getelementptr inbounds i32, i32* %buff, i64 1
  %0 = load i32, i32* %other, align 4
  store i32 0, i32* %arrayidx1, align 4
  ret i32 %0
}
