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
# outputptr 초기화하기

	.globl bmpconv
bmpconv:
	# m = 0 (t0 = m)
	addi t0, x0, 0
	addi sp, sp, -4
	# k와 outptr stack에 저장 -> 이걸 커널 계산하면서 뽑을 수 있게 해야함
	sw a3, 0(sp)
	sw a4, 4(sp)
	beq x0, x0, height_loop

height_loop: 
	bge t0, a1, end_height
	# t1 = h-1
	addi t1, a1, -1
	beq t0, t1, height_1
	# t1 = h-2
	addi t1, t1, -1
	beq t0, t1, height_2

	# t1이 일반적인 경우
	blt t0, t1, height_3

	height_1:
		# t2 = c (1)
		addi sp, sp, -4
		addi t2, x0, 1
		sw t2, 0(sp)
		beq x0, x0, prepare_width
		# t2 써도 됨

	height_2: 
		# t2 = c (2)
		addi sp, sp, -4
		addi t2, x0, 2
		sw t2, 0(sp)
		beq x0, x0, prepare_width
		# t2 써도 됨

	height_3: 
		# t2 = c (3)
		addi sp, sp, -4
		addi t2, x0, 3
		sw t2, 0(sp)
		beq x0, x0, prepare_width
		# t2 써도 됨
	
	prepare_width: # t1 써도됨 그래서 t1 = i로
		addi t1, x0, 0
		# t2 = 3(w+1) / 4
		addi t2, a2, 1
		slli t3, t2, 1
		add t2, t3, t2
		srli t2, t2, 2
		# t2, t3 써도됨
		beq x0, x0, width_loop

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
		blt t1, t2, width_3

		width_1:
			# t3 = d (1)
			addi sp, sp, -4
			addi t3, x0, 1
			sw t3, 0(sp)
			beq x0, x0, prepare_outer
			# t3 써도됨

		width_2: 
			# t3 = d (2)
			addi sp, sp, -4
			addi t3, x0, 2
			sw t3, 0(sp)
			beq x0, x0, prepare_outer
			# t3 써도됨

		width_3: 
			# t3 = d (3)
			addi sp, sp, -4
			addi t3, x0, 3
			sw t3, 0(sp)
			beq x0, x0, prepare_outer
			# t3 써도됨
		
		# t2가 0이면, 즉 i+1이 9의 배수이면 i = i+1하고 width_loop로
		# i+1이 9의 배수이면 i = i+1
		divisible_9: 
			addi t2, t2, -9
			# 9의 배수이면
			beq t2, x0, divided_9
			# 9의 배수가 아니면 계속 진행
			blt t2, x0, prepare2_outer
			# 계산중이면 돌아감
			beq x0, x0, divisible_9

		divided_9: 
			# i = i+1
			addi t1, t1, 1
			# width_loop로 돌아가기 전에 t2 = 3(w+1) / 4 계산
			addi t2, a2, 1
			slli t3, t2, 1
			add t2, t3, t2
			srli t2, t2, 2
			# 들어가있는 d값 빼줌
			addi sp, sp, 4
			beq x0, x0, width_loop

	prepare_outer:
		# t2 = 3(w+1) / 4 - 2 였는데 바꿀 것! 8의 배수인지 보려고
		# t2에 현재 i+1값인 t1 옮겨둠
		addi t2, t1, 1
		jal divisible_9

		# 지금 쓸 수 있는 레지스터 t2, t3, t4, a3, a4, ra
		# 근데 여기 for문 두 개 돌리기 전에 메모리에서 c, d 뽑아야 함
	prepare2_outer:
		# a3 = d
		lw a3, 0(sp)
		# a4 = c
		lw a4, 4(sp)
		# t2 = j = m
		addi t2, t0, 0
		# a4 = c + m
		add a4, a4, t2
		beq x0, x0, outer

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
		beq x0, x0, inner

	inner: 
		bge t3, a3, end_inner
		# t4 = (w+1)*3 에서 하위2비트 버림  -> 총 가로 바이트 수
		addi t4, a2, 1
		slli ra, t4, 1
		add t4, t4, ra
		srli t4, t4, 2
		slli t4, t4, 2
		# m과 곱해줌

		addi ra, x0, 0
		addi a4, x0, 0
		beq ra, x0, mul_m

		# a4에 j * 가로 바이트 수 저장
		mul_m: 
			bge ra, t2, fin_mul
			add a4, a4, t4
			# srli a4, a4, 2 
			addi ra, ra, 1
			beq x0, x0, mul_m

	#t4 사용가능

	# temp:
	# 		ebreak

	fin_mul:
	# t4 = k * 4 -> 현재 칸의 가로 바이트 수
		slli t4, t3, 2
	# 현재 읽어와야 할 메모리 주소 
		add t4, t4, a4
		add t4, t4, a0
			# a4 사용가능


		# lw a4, 0(t4)

		# addi sp, sp, -4
		# sw a4, 0(sp)
		
		# 여기서 outputptr과 k에 접근할 방법이 없음
		
		# addi ra, x0, 0
		# beq t4, ra, temp

		addi t3, t3, 1
		beq x0, x0, inner

	end_inner:
		# j 증가
		addi t2, t2, 1
		# a4 스택에 저장했던 것 다시 a4에 돌려놓고 스택에서 빼기
		lw a4, 0(sp)
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
		# i = i+2
		addi t1, t1, 2
		beq x0, x0, width_loop

	
	end_width: 
		# 현재 c 꺼내기 다음 c는 다음 m에 의해서 결정됨
		addi sp, sp, 4
		# m = m + 3
		addi t0, t0, 3
		beq x0, x0, height_loop


end_height:

	# k랑 outputptr 꺼내기 근데 여기가 아니라 kernal에서 해야함 사실
	addi sp, sp, 4
	
	addi a0, x0, 0
	lui a0, 0x80000
	addi a0, a0, 0x008
	jalr ra, a0
ret