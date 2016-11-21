# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %s -o %t1.o

# RUN: echo "SECTIONS { ASSERT(1, fail) }" > %t1.script
# RUN: ld.lld -shared -o %t1 --script %t1.script %t1.o
# RUN: llvm-readobj %t1 > /dev/null

# RUN: echo "SECTIONS { ASSERT(ASSERT(42, fail) == 42, fail) }" > %t2.script
# RUN: ld.lld -shared -o %t2 --script %t2.script %t1.o
# RUN: llvm-readobj %t2 > /dev/null

# RUN: echo "SECTIONS { ASSERT(0, fail) }" > %t3.script
# RUN: not ld.lld -shared -o %t3 --script %t3.script %t1.o > %t.log 2>&1
# RUN: FileCheck %s -check-prefix=FAIL < %t.log
# FAIL: fail

# RUN: echo "SECTIONS { . = ASSERT(0x1000, fail); }" > %t4.script
# RUN: ld.lld -shared -o %t4 --script %t4.script %t1.o
# RUN: llvm-readobj %t4 > /dev/null

# RUN: echo "SECTIONS { .foo : { *(.foo) } }" > %t5.script
# RUN: echo "ASSERT(SIZEOF(.foo) == 8, fail);" >> %t5.script
# RUN: ld.lld -shared -o %t5 --script %t5.script %t1.o
# RUN: llvm-readobj %t5 > /dev/null

## Even without SECTIONS block we still use section names
## in expressions
# RUN: echo "ASSERT(SIZEOF(.foo) == 8, fail);" > %t5.script
# RUN: ld.lld -shared -o %t5 --script %t5.script %t1.o
# RUN: llvm-readobj %t5 > /dev/null

.section .foo, "a"
 .quad 0
