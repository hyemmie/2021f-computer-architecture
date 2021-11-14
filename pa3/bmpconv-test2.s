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
	.word	test2
	.word	0


	.globl	ans
ans:
	.word	ans2
	.word	ans_END

test2:
	# kernel
	.word	0xff000001
	.word	0x0101ff01
	.word	0x00000001
	# width, height
	.word	5
	.word	8
	# bitmap
	.word	0x913e3d3c
	.word	0x33328e90
	.word	0x3e3d3c34
	.word	0x00434241
	.word	0x808e3d4d
	.word	0x9e8e3e92
	.word	0x001ebcaa
	.word	0x00871300
	.word	0x988234d3
	.word	0x11443122
	.word	0xeed32200
	.word	0x00e342d1
	.word	0x00000000
	.word	0x00000000
	.word	0x00000000
	.word	0x00000000
	.word	0x913e3d3c
	.word	0x33328e90
	.word	0x3e3d3c34
	.word	0x00434241
	.word	0x988234d3
	.word	0x11443122
	.word	0xeed32200
	.word	0x00e342d1
	.word	0x00000000
	.word	0x00000000
	.word	0x00000000
	.word	0x00000000
	.word	0x808e3d4d
	.word	0x9e8e3e92
	.word	0x001ebcaa
	.word	0x00871300


ans2:
	.word	0xe1005bff
	.word	0xc6ffffff
	.word	0x000000d4
	.word	0x0a3d1a00
	.word	0xff000000
	.word	0x000000b5
	.word	0xffffffff
	.word	0xc3f3ffff
	.word	0x000000b5
	.word	0x63cf87ff
	.word	0xeeff876c
	.word	0x000000ff
	.word	0x1b001a00
	.word	0xb3000000
	.word	0x0000003f
	.word	0xffffffff
	.word	0xe0ffffff
	.word	0x000000ff


ans_END:
	.word	0xdeadbeef
