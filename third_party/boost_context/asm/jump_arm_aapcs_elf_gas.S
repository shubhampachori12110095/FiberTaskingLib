/*
            Copyright Oliver Kowalke 2009.
            Copyright Adrian Astley 2017 - 2018.
   Distributed under the Boost Software License, Version 1.0.
      (See accompanying file LICENSE_1_0.txt or copy at
          http://www.boost.org/LICENSE_1_0.txt)
*/

/*******************************************************
 *                                                     *
 *  -------------------------------------------------  *
 *  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  *
 *  -------------------------------------------------  *
 *  | 0x0 | 0x4 | 0x8 | 0xc | 0x10| 0x14| 0x18| 0x1c|  *
 *  -------------------------------------------------  *
 *  | s16 | s17 | s18 | s19 | s20 | s21 | s22 | s23 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  8  |  9  |  10 |  11 |  12 |  13 |  14 |  15 |  *
 *  -------------------------------------------------  *
 *  | 0x20| 0x24| 0x28| 0x2c| 0x30| 0x34| 0x38| 0x3c|  *
 *  -------------------------------------------------  *
 *  | s24 | s25 | s26 | s27 | s28 | s29 | s30 | s31 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  16 |  17 |  18 |  19 |  20 |  21 |  22 |  23 |  *
 *  -------------------------------------------------  *
 *  | 0x40| 0x44| 0x48| 0x4c| 0x50| 0x54| 0x58| 0x5c|  *
 *  -------------------------------------------------  *
 *  |  v1 |  v2 |  v3 |  v4 |  v5 |  v6 |  v7 |  v8 |  *
 *  -------------------------------------------------  *
 *  -------------------------------------------------  *
 *  |  24 |  25 |  26 |  27 |  28 |  29 |  30 |  31 |  *
 *  -------------------------------------------------  *
 *  | 0x60| 0x64| 0x68| 0x6c| 0x70| 0x74| 0x78| 0x7c|  *
 *  -------------------------------------------------  *
 *  |  lr |  pc |                                   |  *
 *  -------------------------------------------------  *
 *                                                     *
 *******************************************************/

.text
.globl jump_fcontext
.align 2
.type jump_fcontext,%function
jump_fcontext:
    @ save LR as PC
    push {lr}
    @ save V1-V8,LR
    push {v1-v8,lr}

    @ prepare stack for storing FPU
    sub  sp, sp, #64
#if (defined(__VFP_FP__) && !defined(__SOFTFP__))
    @ save S16-S31
    vstmia sp, {d8-d15}
#endif

    @ store RSP (pointing to context-data) at address pointed at by A1
    str sp, [a1]

    @ restore RSP (pointing to context-data) from A2
    mov  sp, a2

#if (defined(__VFP_FP__) && !defined(__SOFTFP__))
    @ restore S16-S31
    vldmia  sp, {d8-d15}
#endif
    @ prepare stack for restoring other register
    add  sp, sp, #64

    @ restore V1-V8,LR
    pop {v1-v8,lr}

    @ pass data (third arg passed to jump_fcontext) as first arg passed to context function
    mov  a1, a3

    @ restore PC
    pop {pc}
.size jump_fcontext,.-jump_fcontext

@ Mark that we don't need executable stack.
.section .note.GNU-stack,"",%progbits
