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

####################
# void bmpconv(unsigned char *imgptr, int h, int w, unsigned char *k, unsigned char *outptr)
####################

# x0, sp, ra, a0 ~ a4, t0 ~ t4

	.globl bmpconv
bmpconv:
	# m = 0 (t0 = m)
	addi t0, x0, 0
	addi sp, sp, -8
	# k와 outputptr stack에 저장
	sw a3, 0(sp)
	sw a4, 4(sp)
	beq x0, x0, height_loop

height_loop: 
	ble t0, a1, end_height
	# t1 = h-1
	addi t1, a1, -1
	beq t0, t1, height_1
	# t1 = h-2
	addi t1, t1, -1
	beq t0, t1, height_2

	# t1이 일반적인 경우
	ble t0, t1, height_3

	height_1:
		# t2 = c (1)
		addi sp, sp, -4
		addi t2, x0, 1
		sw t2, 0(sp)
		ret
		# t2 써도 됨

	height_2: 
		# t2 = c (2)
		addi sp, sp, -4
		addi t2, x0, 2
		sw t2, 0(sp)
		ret
		# t2 써도 됨

	height_3: 
		# t2 = c (3)
		addi sp, sp, -4
		addi t2, x0, 3
		sw t2, 0(sp)
		ret
		# t2 써도 됨

	# t1 써도됨 그래서 t1 = i로
	addi t1, x0, 0
	# t2 = 3(w+1) / 4
	addi t2, a2, 1
	slli t3, t2, 1
	add t2, t3, t2
	srli t2, t2, 2
	# t2, t3 써도됨
	ble t1, t2, width_loop

# t2 바꿀거임 
	width_loop:
		bge t1, t2, end_width
		# t2 = 3(w+1) / 4 - 1
		addi t2, t2, -1
		beq t1, t2, width_1
		# t2 = 3(w+1) / 4 - 2
		addi t2, t2, -1
		beq t1, t2, width_2

		# t1(i)이 일반적인 경우
		ble t1, t2, width_3

		width_1:
			# t3 = d (1)
			addi sp, sp, -4
			addi t3, x0, 1
			sw t3, 0(sp)
			ret
			# t3 써도됨

		width_2: 
			# t3 = d (2)
			addi sp, sp, -4
			addi t3, x0, 2
			sw t3, 0(sp)
			ret
			# t3 써도됨

		width_3: 
			# t3 = d (2)
			addi sp, sp, -4
			addi t3, x0, 3
			sw t3, 0(sp)
			ret
			# t3 써도됨

			# t2 = 3(w+1) / 4 - 1 였는데 바꿀 것! 8의 배수인지 보려고
		andi t2, t1, 0x007
		# t2가 0이면, 즉 i가 8의 배수이면 i = i+1하고 width_loop로
		beq t2, x0, divisible_8

		divisible_8: 
			addi t1, t1, 1
			beq x0, x0, width_loop

		# 지금 쓸 수 있는 레지스터 t2, t3, t4, a3, a4, ra
		# 근데 여기 for문 두 개 돌리기 전에 메모리에서 c, d 뽑아야 함
		# a3 = d
		lw a3, 0(sp)
		# a4 = c
		lw a4, 4(sp)


		# t2 = j = m
		addi t2, t0, 0
		# a4 = c + m
		add a4, t0, t2

	outer: 
		# j >= m+c면 out
		bge t2, a4, end_outer
		# a4를 스택에 넣음! a4 사용가능!
		addi sp, sp, -4
		sw a4, 0(sp)
		# t3 = k = i
		addi t3, t1, 0
		# a3 = i + d
		add a3, a3, t1

	inner: 
		bge t3, a3, end_inner
		
		# t4 = (w+1)*3
		addi t4, a2, 1
		slli ra, t4, 1
		add t4, t4, ra
		# m과 곱해줌

		addi ra, x0, 0
		beq ra, x0, mul_m

		# a4에 m*3(w+1) 저장
		mul_m: 
			bge ra, t2, fin_mul
			add a4, a4, t4
			addi ra, ra, 1
			beq x0, x0, mul_m

	#t4 사용가능

	fin_mul:
		slli t4, t1, 2
		add t4, t4, a4
		# a4 사용가능
		add t4, t4, a0
		lw a4, 0(t4)
		addi sp, sp, -4
		sw a4, 0(sp)
		ebreak
		addi t3, t3, 1
		beq x0, x0, inner

	end_inner:
		addi t2, t2, 1
		# a4 스택에 저장했던 것 다시 a4에 돌려놓고 스택에서 빼기
		sw a4, 0(sp)
		addi sp, sp, 4
		beq x0, x0, outer

	end_outer:

		beq x0, x0, kernal

	kernal:
		


	# i <  3(w+1) / 4 - 1 면 돌아가기 값 t2에 넣으셈
	# t3 썼으면 다시 확인해라 !!!
	# d 꺼내기 다음 i에 의해서 결정됨
		addi sp, sp, 4
		addi t2, a2, 1
		slli t3, t2, 1
		add t2, t3, t2
		srli t2, t2, 2
		beq x0, x0, width_loop

	
	end_width: # c 꺼내기 다음 m에 의해서 결정됨
		addi sp, sp, 4
		# m < h 면 돌아가기 
		ble t0, a1, height_loop


end_height:

	ret


	ret
