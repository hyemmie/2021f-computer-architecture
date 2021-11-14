#----------------------------------------------------------------
#
#  4190.308 Computer Architecture (Fall 2021)
#
#  Project #3: Image Convolution in RISC-V Assembly
#
#  October 25, 2021
#
#  Jaehoon Shim (mattjs@snu.ac.kr)
#  Ikjoon Son (ikjoon.son@snu.ac.kr)
#  Seongyeop Jeong (seongyeop.jeong@snu.ac.kr)
#  Systems Software & Architecture Laboratory
#  Dept. of Computer Science and Engineering
#  Seoul National University
#
#----------------------------------------------------------------

	.data
	.align	2

	.globl	test
test:
	.word	test1
	.word	0


	.globl	ans
ans:
	.word	ans1
	.word	ans_END


test1:
	# kernel
	.word	0xff000101
	.word	0x0100ff00
	.word	0x00000001
	# width, height
	.word	4
	.word	4
	# bitmap
	.word	0x00000000
	.word	0xf2350000
	.word	0xfbf235fb

	.word	0x00000000
	.word	0xf2350000
	.word	0xfa6a0afb

	.word	0x35fbf235
	.word	0xf235fbf2
	.word	0xfbf235fb

	.word	0x35000000
	.word	0xf235fbf2
	.word	0x000000fb

ans1:
	.word	0x95fbf235
	.word	0x0000ffff

	.word	0x00000000
	.word	0x00000000



ans_END:
	.word	0xdeadbeef
