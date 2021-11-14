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
	addi sp, sp, -12
	sw a2, 0(sp)
	sw a1, 4(sp)
	sw a3, 8(sp)
	sw a4, 12(sp)
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
			# 양수면 이어서 계산
			blt x0, t2, divisible_9

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
		beq x0, x0, divisible_9

		# 지금 쓸 수 있는 레지스터 t2, t3, t4, a3, a4, ra
		# 근데 여기 for문 두 개 돌리기 전에 메모리에서 c, d, a4 뽑아야 함
	prepare2_outer:
		# a3 = d
		lw a3, 0(sp)
		# a4 = c
		lw a4, 4(sp)
		# t2 = j = m
		addi t2, t0, 0
		# a4 = c + m
		add a4, a4, t0
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
			bge ra, t2, load_store_4byte
			add a4, a4, t4
			# srli a4, a4, 2 
			addi ra, ra, 1
			beq x0, x0, mul_m

	#t4 사용가능

	load_store_4byte:
	# 쓸 수 있는 것 ra, t4, a2, a1
	# t4 = k * 4 -> 현재 칸의 가로 바이트 수
		bge t3, a3, end_inner
		slli t4, t3, 2
	# 현재 읽어와야 할 메모리 주소 
		add t4, t4, a4
		add t4, t4, a0
		lw ra, 0(t4)
	# a4 스택에 저장했던 것 다시 달라진 a4에 돌려놓고 스택에서 빼기
		lw t4, 0(sp)
	# d, c 꺼내놓기
		lw a2, 4(sp)
		lw a1, 8(sp)
		addi sp, sp, 12

# 이미지 비트값 불러옴
		addi sp, sp, -16
		sw t4, 0(sp)
		sw a2, 4(sp)
		sw a1, 8(sp)
		sw ra, 12(sp)
		addi t3, t3, 1
		beq x0, x0, load_store_4byte

	end_inner:
		# j 증가
		addi t2, t2, 1
		# a4 스택에 저장했던 것 다시 a4에 돌려놓고 스택에서 빼기
		lw a4, 0(sp)
		addi sp, sp, 4
		# a3 d로 돌려놔야 함
		lw a3, 0(sp)
		beq x0, x0, outer

	end_outer:
		
		beq x0, x0, kernal

	kernal:
	# 쓸 수 있는 레지스터 ra, a2, a1, a4, a3

		# a1 = d
		lw a1, 0(sp)
		# a2 = c
		lw a2, 4(sp)

		addi a3, x0, 0
		addi ra, x0, 0

		mul_cd: 
			add ra, ra, a1
			addi a3, a3, 1
			blt a3, a2, mul_cd

		slli ra, ra, 2
		addi ra, ra, 8
		add ra, ra, sp

		# # i+1 9의 배수 판별
		addi a1, t1, 1
		addi a3, x0, 9

		check_mode: 
			addi a1, a1, -9
			addi a4, x0, 1
			beq a1, a4, mode1
			addi a4, x0, 3
			beq a1, a4, mode2
			addi a4, x0, 5
			beq a1, a4, mode3
			addi a4, x0, 7
			beq a1, a4, mode4
			bge a1, a3, check_mode

	# ra = cd * 4
	# a1, a2, a3, a4, t2, t3, t4

		mode1:
			andi a2, x0, 0 
			andi a3, x0, 0 
			andi a4, x0, 0

		mode1_1: 
			lw a1, 0(ra)
			andi t2, a1, 0xFF
			add a2, a2, t2
			srli t2, a1, 24
			add a2, a2, t2
			slli t3, a1, 8
			srli t3, t3, 24
			add a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 24
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode1_4

		mode1_2:
			lw a1, -4(ra)
			srli t3, a1, 8
			add a3, a3, t3
			andi t4, a1, 0xFF
			add a4, a4, t3

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode1_4

		mode1_3:
			lw a1, -8(ra)

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range


		mode1_4:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m1_4_d_is_1
			addi t3, x0, 2
			beq t2, t3, m1_4_d_is_2
			lw a1, -12(ra)
			
		m1_4_cal:
			andi t2, a1, 0xFF
			sub a2, a2, t2
			srli t3, a1, 16
			sub a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 24
			sub a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode1_7

		mode1_5:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_5_d_is_2
			lw a1, -16(ra)

		m1_5_cal:
			slli t2, a1, 8
			srli t2, t2, 24
			sub a2, a2, t2
			srli t4, a1, 24
			sub a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode1_7

		mode1_6:
			lw a1, -20(ra)
			andi t3, a1, 0xFF
			sub a3, a3, t3

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		mode1_7:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m1_7_d_is_1
			addi t3, x0, 2
			beq t2, t3, m1_7_d_is_2

			lw a1, -24(ra)

		m1_7_cal: 
			srli t2, a1, 24
			add a2, a2, t2

		mode1_8:
		# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_8_d_is_2

			lw a1, -28(ra)
			
		m1_8_cal: 
			slli t2, a1, 8
			srli t2, t2, 24
			add a2, a2, t2
			slli t3, a1, 16
			srli t3, t3, 24
			add a3, a3, t3
			andi t4, a1, 0xFF
			add a4, a4, t4
			srli t4, a1, 24
			add a4, a4, t4

		mode1_9:
			lw a1, -32(ra)
			andi t3, a1, 0xFF
			add a3, a3, t3

		beq x0, x0, check_range


		mode2:
			andi a2, x0, 0 
			andi a3, x0, 0 
			andi a4, x0, 0

		mode2_1: 
			lw a1, 0(ra)
			slli t2, a1, 16
			srli t2, t2, 24
			add a2, a2, t2
			srli t3, a1, 24
			add a3, a3, t3
			slli t4, a1, 8
			srli t4, t4, 24
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode2_4

		mode2_2:
			lw a1, -4(ra)
			andi t2, a1, 0xFF
			add a2, a2, t2
			slli t3, a1, 8
			srli t3, t3, 24
			add a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 23
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode2_4

		mode2_3:
			lw a1, -8(ra)

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

		mode2_4:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m2_4_d_is_1
			addi t3, x0, 2
			beq t2, t3, m2_4_d_is_2
			lw a1, -12(ra)

		m2_4_cal:
			slli t2, a1, 16
			srli t2, t2, 24
			sub a2, a2, t2
			srli t3, a1, 24
			sub a3, a3, t3
			slli t4, a1, 8
			srli t4, t4, 24
			sub a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode2_7

		mode2_5:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_5_d_is_2
			lw a1, -16(ra)

		m2_5_cal:
			srli t2, a1, 24
			sub a2, a2, t2

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode2_7

		mode2_6:
			lw a1, -20(ra)
			slli t3, a1, 16
			srli t3, t3, 24
			sub a3, a3, t3
			andi t4, a1, 0xFF
			sub a4, a4, t4

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		mode2_7:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m2_7_d_is_1
			addi t3, x0, 2
			beq t2, t3, m2_7_d_is_2

			lw a1, -24(ra)

		m2_7_cal: 

		mode2_8:
		# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m2_8_d_is_2

			lw a1, -28(ra)

		m2_8_cal: 
			andi t2, a1, 0xFF
			add a2, a2, t2
			srli t2, a1, 24
			add a2, a2, t2
			slli t3, a1, 8
			srli t3, t3, 24
			add a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 24
			add a4, a4, t4

		mode2_9:
			lw a1, -32(ra)
			srli t3, a1, 8
			add a3, a3, t3
			andi t4, a1, 0xFF
			add a4, a4, t3

			beq x0, x0, check_range

		mode3:
			andi a2, x0, 0
			andi a3, x0, 0
			andi a4, x0, 0

		mode3_1: 
			lw a1, 0(ra)
			slli t2, a1, 8
			srli t2, t2, 24
			add a2, a2, t2
			srli t4, a1, 24
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode3_4

		mode3_2:
			lw a1, -4(ra)
			slli t2, a1, 16
			srli t2, t2, 24
			add a2, a2, t2
			andi t3, a1, 0xFF
			add a3, a3, t3
			srli t3, a1, 24
			add a3, a3, t3
			slli t4, a1, 8
			srli t4, t4, 24
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode2_4

		mode3_3:
			lw a1, -8(ra)

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

		mode3_4:
		# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m1_4_d_is_1
			addi t3, x0, 2
			beq t2, t3, m1_4_d_is_2
			lw a1, -12(ra)

		m3_4_cal:
			slli t2, a1, 8
			srli t2, t2, 24
			sub a2, a2, t2
			srli t4, a1, 24
			sub a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode4_7

		mode3_5:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m3_5_d_is_2
			lw a1, -16(ra)

		m3_5_cal:
			andi t3, a1, 0xFF
			sub a3, a3, t3

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode3_7

		mode3_6:
			lw a1, -20(ra)
			andi t2, a1, 0xFF
			sub a2, a2, t2
			slli t3, a1, 8
			srli t3, t3, 24
			sub a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 24
			sub a4, a4, t4

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		mode3_7:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m3_7_d_is_1
			addi t3, x0, 2
			beq t2, t3, m3_7_d_is_2

			lw a1, -24(ra)

		m3_7_cal: 

		mode3_8:
		# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m3_8_d_is_2
		
		m3_8_cal:
			lw a1, -28(ra)
			slli t2, a1, 16
			srli t2, t2, 24
			add a2, a2, t2
			srli t3, a1, 24
			add a3, a3, t3
			slli t4, a1, 8
			srli t4, t4, 24
			add a4, a4, t4

		mode3_9:
			lw a1, -32(ra)
			andi t2, a1, 0xFF
			add a2, a2, t2
			slli t3, a1, 8
			srli t3, t3, 24
			add a3, a3, t3
			slli t4, a1, 16
			srli t4, t4, 24
			add a4, a4, t4

		beq x0, x0, check_range

		mode4:
			andi a2, x0, 0
			andi a3, x0, 0
			andi a4, x0, 0

		mode4_1: 
			lw a1, 0(ra)
			srli t2, a1, 24
			add a2, a2, t2

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, mode4_4

		mode4_2:
			lw a1, -4(ra)
			slli t2, a1, 8
			srli t2, t2, 24
			add a2, a2, t2
			slli t3, a1, 16
			srli t3, t3, 24
			add a3, a3, t3
			srli t4, a1, 24
			add a4, a4, t4
			andi t4, a1, 0xFF
			add a4, a4, t4

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode2_4

		mode4_3:
			lw a1, -8(ra)
			andi t3, a1, 0xFF
			add a3, a3, t3

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

		mode4_4:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m4_4_d_is_1
			addi t3, x0, 2
			beq t2, t3, m4_4_d_is_2
			lw a1, -12(ra)
			
		m4_4_cal:
			srli t2, a1, 24
			sub a2, a2, t2

		mode4_5:
		# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 1
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m4_5_d_is_2
			lw a1, -16(ra)

		m4_5_cal:
			slli t3, a1, 16
			srli t3, t3, 24
			sub a3, a3, t3
			andi t4, a1, 0xFF
			sub a4, a4, t4

		# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, mode4_7

		mode4_6:
			lw a1, -20(ra)
			slli t2, a1, 16
			srli t2, t2, 24
			sub a2, a2, t2
			srli t3, a1, 24
			sub a3, a3, t3
			slli t4, a2, 8
			srli t4, t4, 24
			sub a4, a4, t4

			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		mode4_7:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 1
			beq t2, t3, m1_7_d_is_1
			addi t3, x0, 2
			beq t2, t3, m1_7_d_is_2

			lw a1, -24(ra)

		m4_7_cal: 

		mode4_8:
			# t2 = c
			lw t2, 4(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m4_8_d_is_2

			lw a1, -28(ra)
			
		m4_8_cal: 
			slli t2, a1, 8
			srli t2, t2, 24
			add a2, a2, t2
			srli t4, a1, 24
			add a4, a4, t4

		mode4_9:
			lw a1, -32(ra)
			slli t2, a1, 16
			srli t2, t2, 24
			add a2, a2, t2
			andi t3, a1, 0xFF
			add a3, a3, t3
			srli t3, a1, 24
			add a3, a3, t3
			slli t4, a1, 8
			srli t4, t4, 24
			add a4, a4, t4

		beq x0, x0, check_range


	write_output:
		sub ra, ra, sp

	# d, c 다시 불러와라
		lw t2, 0(sp)
		lw t3, 4(sp)
	# c, d, bmp 바이트들 뽑기
		add sp, sp, ra

	# d, c 다시 넣어주기! 이미 바이트들 빠진 상태에서 sp 
		addi sp, sp, -8
		sw t2, 0(sp)
		sw t3, 4(sp)


	# ... 여기서 입력
		# addi t4, x0, 0
		# slli a2, 
		# and t4, 

	# d 꺼내기 다음 i에 의해서 결정됨
		addi sp, sp, 4
	# w a2에 로드
		lw a2, 4(sp)
		addi t2, a2, 1
		slli ra, t2, 1
		add t2, ra, t2
		srli t2, t2, 2
		# i = i+2
		addi t1, t1, 2
		beq x0, x0, width_loop

	check_range: 
		blt a2, x0, neg_a2
		addi t2, x0, 255
		blt t2, a2, over_a2
		blt a3, x0, neg_a3
		blt t2, a3, over_a3
		blt a4, x0, neg_a4
		blt t2, a4, over_a4
		beq x0, x0, write_output

	neg_a2: 
		addi a2, x0, 0
		beq x0, x0, check_range

	over_a2:
		addi a2, x0, 0xFF
		beq x0, x0, check_range

	neg_a3: 
		addi a3, x0, 0
		beq x0, x0, check_range

	over_a3:
		addi a3, x0, 0xFF
		beq x0, x0, check_range

	neg_a4: 
		addi a4, x0, 0
		beq x0, x0, check_range

	over_a4:
		addi a4, x0, 0xFF
		beq x0, x0, check_range

	m1_4_d_is_1:
		lw a1, -4(ra)
		beq x0, x0, m1_4_cal

	m1_4_d_is_2:
		lw a1, -8(ra)
		beq x0, x0, m1_4_cal

	m1_5_d_is_2:
		lw a1, -16(ra)
		beq x0, x0, m1_5_cal

	m1_7_d_is_1:
		lw a1, -8(ra)
		beq x0, x0, m1_7_cal

	m1_7_d_is_2:
		lw a1, -20(ra)
		beq x0, x0, m1_7_cal

	m1_8_d_is_2:
		lw a1, -24(ra)
		beq x0, x0, m1_8_cal

	m2_4_d_is_1:
		lw a1, -4(ra)
		beq x0, x0, m2_4_cal

	m2_4_d_is_2:
		lw a1, -8(ra)
		beq x0, x0, m2_4_cal

	m2_5_d_is_2:
		lw a1, -16(ra)
		beq x0, x0, m2_5_cal

	m2_7_d_is_1:
		lw a1, -8(ra)
		beq x0, x0, m2_7_cal

	m2_7_d_is_2:
		lw a1, -20(ra)
		beq x0, x0, m2_7_cal

	m2_8_d_is_2:
		lw a1, -24(ra)
		beq x0, x0, m2_8_cal

	m3_4_d_is_1:
		lw a1, -4(ra)
		beq x0, x0, m3_4_cal

	m3_4_d_is_2:
		lw a1, -8(ra)
		beq x0, x0, m3_4_cal

	m3_5_d_is_2:
		lw a1, -16(ra)
		beq x0, x0, m3_5_cal

	m3_7_d_is_1:
		lw a1, -8(ra)
		beq x0, x0, m3_7_cal

	m3_7_d_is_2:
		lw a1, -20(ra)
		beq x0, x0, m3_7_cal

	m3_8_d_is_2:
		lw a1, -24(ra)
		beq x0, x0, m3_8_cal

	m4_4_d_is_1:
		lw a1, -4(ra)
		beq x0, x0, m4_4_cal

	m4_4_d_is_2:
		lw a1, -8(ra)
		beq x0, x0, m4_4_cal

	m4_5_d_is_2:
		lw a1, -16(ra)
		beq x0, x0, m4_5_cal

	m4_7_d_is_1:
		lw a1, -8(ra)
		beq x0, x0, m4_7_cal

	m4_7_d_is_2:
		lw a1, -20(ra)
		beq x0, x0, m4_7_cal

	m4_8_d_is_2:
		lw a1, -24(ra)
		beq x0, x0, m4_8_cal

	
	end_width: 
		# 현재 c 꺼내기 다음 c는 다음 m에 의해서 결정됨
		addi sp, sp, 4
		# m = m + 3
		addi t0, t0, 3
		lw a1, 4(sp)
		beq x0, x0, height_loop

	end_height:

		addi a0, x0, 0
		lui a0, 0x80000
		addi a0, a0, 0x008
		jalr ra, a0

	ret