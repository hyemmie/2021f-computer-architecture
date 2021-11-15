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
	.word	10
	.word	4
	# bitmap
	.word	0x00000000
	.word	0xf2350000
	.word	0xfbf235fb
	.word	0x35000000
  .word 0xf235fbf2
  .word 0x71f100fb
  .word 0xf246dd35
  .word 0x0000a06b

	.word	0x00000000
	.word	0xf2350000
	.word	0xfa6a0afb
	.word	0x35fa6a0a
  .word 0x6a0afbf2
  .word 0xe3370afa
  .word 0xfa00fffe
  .word 0x0000b154


	.word	0x35fbf235
	.word	0xf235fbf2
	.word	0xfbf235fb
	.word	0x35000000
  .word 0xf235fbf2
  .word 0x005500fb
  .word 0x00bfbb26
  .word 0x0000c232


	.word	0x35000000
	.word	0xf235fbf2
	.word	0x000000fb
	.word	0x35000000
  .word 0x0000fbf2
  .word 0x2a000000
  .word 0x2acfeecc
  .word 0x0000d300


ans1:
	.word	0x95fbf235
	.word	0xff60ffff
	.word	0x01882bfc
  .word 0x60fdff8b
  .word 0xff00ffff
  .word 0xa4ff00ff

	.word	0x00000000
	.word	0x6a0a0000
	.word	0xf90000fa
  .word 0x0affff3f
  .word 0x0085ff15
  .word 0xffffffff




ans_END:
	.word	0xdeadbeef
