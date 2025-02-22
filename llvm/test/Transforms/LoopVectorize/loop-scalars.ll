; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; REQUIRES: asserts
; RUN: opt < %s -loop-vectorize -force-vector-width=2 -force-vector-interleave=1 -instcombine -debug-only=loop-vectorize -disable-output -print-after=instcombine -enable-new-pm=0 2>&1 | FileCheck %s
; RUN: opt < %s -aa-pipeline=basic-aa -passes=loop-vectorize,instcombine -force-vector-width=2 -force-vector-interleave=1 -debug-only=loop-vectorize -disable-output -print-after=instcombine 2>&1 | FileCheck %s

target datalayout = "e-m:e-i64:64-i128:128-n32:64-S128"

;
define void @vector_gep(i32** %a, i32 *%b, i64 %n) {
; CHECK-LABEL: @vector_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 1)
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[SMAX]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i64 [[SMAX]], 9223372036854775806
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <2 x i64> [ <i64 0, i64 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], <2 x i64> [[VEC_IND]]
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i32*, i32** [[A:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i32** [[TMP1]] to <2 x i32*>*
; CHECK-NEXT:    store <2 x i32*> [[TMP0]], <2 x i32*>* [[TMP2]], align 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <2 x i64> [[VEC_IND]], <i64 2, i64 2>
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP3]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[SMAX]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ [[I_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[VAR0:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[I]]
; CHECK-NEXT:    [[VAR1:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[I]]
; CHECK-NEXT:    store i32* [[VAR0]], i32** [[VAR1]], align 8
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 1
; CHECK-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]
  %var0 = getelementptr inbounds i32, i32* %b, i64 %i
  %var1 = getelementptr inbounds i32*, i32** %a, i64 %i
  store i32* %var0, i32** %var1, align 8
  %i.next = add nuw nsw i64 %i, 1
  %cond = icmp slt i64 %i.next, %n
  br i1 %cond, label %for.body, label %for.end

for.end:
  ret void
}

;
define void @scalar_store(i32** %a, i32 *%b, i64 %n) {
; CHECK-LABEL: @scalar_store(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 2)
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i64 [[SMAX]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i64 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp eq i64 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i64 [[TMP2]], 9223372036854775806
; CHECK-NEXT:    [[IND_END:%.*]] = shl nuw i64 [[N_VEC]], 1
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = shl i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = or i64 [[OFFSET_IDX]], 2
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[OFFSET_IDX]]
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32*, i32** [[A:%.*]], i64 [[OFFSET_IDX]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[TMP3]]
; CHECK-NEXT:    store i32* [[TMP4]], i32** [[TMP6]], align 8
; CHECK-NEXT:    store i32* [[TMP5]], i32** [[TMP7]], align 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP8:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP8]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ [[I_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[VAR0:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[I]]
; CHECK-NEXT:    [[VAR1:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[I]]
; CHECK-NEXT:    store i32* [[VAR0]], i32** [[VAR1]], align 8
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 2
; CHECK-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP5:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]
  %var0 = getelementptr inbounds i32, i32* %b, i64 %i
  %var1 = getelementptr inbounds i32*, i32** %a, i64 %i
  store i32* %var0, i32** %var1, align 8
  %i.next = add nuw nsw i64 %i, 2
  %cond = icmp slt i64 %i.next, %n
  br i1 %cond, label %for.body, label %for.end

for.end:
  ret void
}

;
define void @expansion(i32** %a, i64 *%b, i64 %n) {
; CHECK-LABEL: @expansion(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 2)
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i64 [[SMAX]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i64 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp eq i64 [[TMP1]], 0
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i64 [[TMP2]], 9223372036854775806
; CHECK-NEXT:    [[IND_END:%.*]] = shl nuw i64 [[N_VEC]], 1
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = shl i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = or i64 [[OFFSET_IDX]], 2
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i64, i64* [[B:%.*]], i64 [[OFFSET_IDX]]
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i64, i64* [[B]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32*, i32** [[A:%.*]], i64 [[OFFSET_IDX]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i32** [[TMP6]] to i64**
; CHECK-NEXT:    store i64* [[TMP4]], i64** [[TMP8]], align 8
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i32** [[TMP7]] to i64**
; CHECK-NEXT:    store i64* [[TMP5]], i64** [[TMP9]], align 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ [[I_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[VAR0:%.*]] = getelementptr inbounds i64, i64* [[B]], i64 [[I]]
; CHECK-NEXT:    [[VAR3:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[I]]
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast i32** [[VAR3]] to i64**
; CHECK-NEXT:    store i64* [[VAR0]], i64** [[TMP11]], align 8
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 2
; CHECK-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP7:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]
  %var0 = getelementptr inbounds i64, i64* %b, i64 %i
  %var1 = bitcast i64* %var0 to i32*
  %var2 = getelementptr inbounds i32*, i32** %a, i64 0
  %var3 = getelementptr inbounds i32*, i32** %var2, i64 %i
  store i32* %var1, i32** %var3, align 8
  %i.next = add nuw nsw i64 %i, 2
  %cond = icmp slt i64 %i.next, %n
  br i1 %cond, label %for.body, label %for.end

for.end:
  ret void
}

;
define void @no_gep_or_bitcast(i32** noalias %a, i64 %n) {
; CHECK-LABEL: @no_gep_or_bitcast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 1)
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[SMAX]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i64 [[SMAX]], 9223372036854775806
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds i32*, i32** [[A:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i32** [[TMP0]] to <2 x i32*>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <2 x i32*>, <2 x i32*>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i32*> [[WIDE_LOAD]], i64 0
; CHECK-NEXT:    store i32 0, i32* [[TMP2]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <2 x i32*> [[WIDE_LOAD]], i64 1
; CHECK-NEXT:    store i32 0, i32* [[TMP3]], align 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP4:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP4]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP8:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[SMAX]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ [[I_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[VAR0:%.*]] = getelementptr inbounds i32*, i32** [[A]], i64 [[I]]
; CHECK-NEXT:    [[VAR1:%.*]] = load i32*, i32** [[VAR0]], align 8
; CHECK-NEXT:    store i32 0, i32* [[VAR1]], align 8
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 1
; CHECK-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP9:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]
  %var0 = getelementptr inbounds i32*, i32** %a, i64 %i
  %var1 = load i32*, i32** %var0, align 8
  store i32 0, i32* %var1, align 8
  %i.next = add nuw nsw i64 %i, 1
  %cond = icmp slt i64 %i.next, %n
  br i1 %cond, label %for.body, label %for.end

for.end:
  ret void
}
