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
	addi sp, sp, -28
	sw a0, 0(sp)
	sw a3, 4(sp)
	sw a2, 8(sp)
	sw a1, 12(sp)
	sw a4, 20(sp)
	addi a4, a4, -4
	sw a4, 16(sp)
	sw ra, 24(sp)
	beq x0, x0, height_loop

height_loop: 
	# m = h-2이면 루프 끝
	addi t1, a1, -2
	bge t0, t1, end_height

	# t2 = c (3)
	addi sp, sp, -4
	addi t2, x0, 3
	sw t2, 0(sp)
	# t2 써도 됨
	# t1 써도됨 그래서 t1 = i로
	addi t1, x0, 0
	# t2 = 3(w+1) / 4
	addi t2, a2, 1
	slli t3, t2, 1
	add t2, t3, t2
	srli t2, t2, 2
	# t2, t3 써도됨

	# t2 바꿀거임
	width_loop:
		# t2 = 3(w+1) / 4 - 1면 끝
		addi t2, t2, -1
		bge t1, t2, end_width
		# t2 = 3(w+1) / 4 - 2
		addi t2, t2, -1
		beq t1, t2, width_2
		# t1(i)이 일반적인 경우
		blt t1, t2, width_3

		width_2: 
			# t3 = d (2)
			addi sp, sp, -4
			addi t3, x0, 2
			sw t3, 0(sp)
			addi t2, a2, 0
			addi t2, t2, -4
			blt t2, x0, skip_by_rem
			beq x0, x0, divisible_4
			# t3 써도됨

		width_3: 
			# t3 = d (3)
			addi sp, sp, -4
			addi t3, x0, 3
			sw t3, 0(sp)
			beq x0, x0, prepare_outer
			# t3 써도됨
		
		# w의 4로 나눈 나머지가 3, 2일 때는 d = 2칸짜리 스킵
		divisible_4: 
			andi t3, t2, 0x03
			addi t2, x0, 3
			# 나머지가 3이면
			beq t2, t3, skip_by_rem
			addi t2, x0, 2
			# 나머지가 2이면
			beq t2, t3, skip_by_rem
			# 나머지가 2보다 작으면 그대로 진행
			blt t3, t2, prepare_outer

		skip_by_rem: 
			# i = i+1
			addi t1, t1, 1
			# width_loop로 돌아가기 전에 t2 = 3(w+1) / 4 계산
			lw a2, 16(sp)
			addi t2, a2, 1
			slli t3, t2, 1
			add t2, t3, t2
			srli t2, t2, 2
			# 들어가있는 d값 빼줌
			addi sp, sp, 4
			beq x0, x0, width_loop

	prepare_outer:
		# 지금 쓸 수 있는 레지스터 t2, t3, t4, a3, a4, ra
		# 근데 여기 for문 두 개 돌리기 전에 메모리에서 c, d, a4 뽑아야 함
		# a3 = d
		lw a3, 0(sp)
		# a4 = c
		lw a4, 4(sp)
		# t2 = j = m
		addi t2, t0, 0
		# a4 = c + m
		add a4, a4, t0

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
		lw a0, 12(sp)
		add t4, t4, a0
		# ra = 이미지 바이트
		lw ra, 0(t4)
		# a4 
		lw t4, 0(sp)
		addi sp, sp, -4
		# a4
		sw t4, 0(sp)
		# d
		lw a2, 8(sp)
		sw a2, 4(sp)
		# c
		lw a1, 12(sp)
		sw a1, 8(sp)
		# imgptr
		sw a0, 12(sp)
		lw a0, 20(sp)
		# kernal
		sw a0, 16(sp)
		sw ra, 20(sp)
	
		addi t3, t3, 1
		beq x0, x0, load_store_4byte

	end_inner:
		# j 증가
		addi t2, t2, 1
		# j = j+1 - m (첫 행에서도 1이 나와야 하므로)
		sub t2, t2, t0
		# a4 스택에 저장했던 것 다시 a4에 돌려놓고 스택에서 빼기
		addi sp, sp, 4
		# a3 d로 돌려놔야 함
		lw a3, 0(sp)
		addi a4, x0, 0
		addi a2, x0, 0

		# a2 width로 돌려놔야 함
		mul_jm_d:	
			add a2, a2, a3
			addi a4, a4, 1
			blt a4, t2, mul_jm_d

		slli a2, a2, 2
		add a2, a2, sp
		addi a2, a2, 16
		lw a2, 0(a2)

		# a4 스택에 저장했던 것 다시 a4에 돌려놓고 스택에서 빼기
		lw a4, -4(sp)

		add t2, t2, t0
		beq x0, x0, outer

	end_outer:
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
		addi ra, ra, 12
		add ra, ra, sp

	# ra = cd * 4

	kernal:
		addi a2, x0, 0 
		addi a3, x0, 0 
		addi a4, x0, 0
		addi a0, x0, 0
		beq x0, x0, kernal_1

		back3_add: 
			andi t4, a1, 0xFF
			add a2, a2, t4
			slli t4, a1, 16
			srli t4, t4, 24
			add a4, a4, t4
			slli t4, a1, 8
			srli t4, t4, 24
			add a3, a3, t4

			addi t4, x0, 1
			beq t3, t4, k1_a0
			addi t4, x0, 4
			beq t3, t4, k4_a0
			addi t4, x0, 7
			beq t3, t4, k7_a0

		back3_sub:
			andi t4, a1, 0xFF
			sub a2, a2, t4
			slli t4, a1, 16
			srli t4, t4, 24
			sub a4, a4, t4
			slli t4, a1, 8
			srli t4, t4, 24
			sub a3, a3, t4

			addi t4, x0, 1
			beq t3, t4, k1_a0
			addi t4, x0, 4
			beq t3, t4, k4_a0
			addi t4, x0, 7
			beq t3, t4, k7_a0

		front_a0_add:
			srli t4, a1, 24
			add a0, a0, t4

			addi t4, x0, 1
			beq t3, t4, k1_front
			addi t4, x0, 4
			beq t3, t4, k4_front
			addi t4, x0, 7
			beq t3, t4, k7_front

		front_a0_sub:
			srli t4, a1, 24
			sub a0, a0, t4

			addi t4, x0, 1
			beq t3, t4, k1_front
			addi t4, x0, 4
			beq t3, t4, k4_front
			addi t4, x0, 7
			beq t3, t4, k7_front

		front_a2_add:
			srli t4, a1, 24
			add a2, a2, t4

			addi t4, x0, 1
			beq t3, t4, kernal_2
			addi t4, x0, 4
			beq t3, t4, kernal_5
			addi t4, x0, 7
			beq t3, t4, kernal_8

		front_a2_sub:
			srli t4, a1, 24
			add a2, a2, t4

			addi t4, x0, 1
			beq t3, t4, kernal_2
			addi t4, x0, 4
			beq t3, t4, kernal_5
			addi t4, x0, 7
			beq t3, t4, kernal_8

		back_add:
			andi t4, a1, 0xFF
			add a3, a3, t4

			addi t4, x0, 3
			beq t3, t4, k3_a0
			addi t4, x0, 6
			beq t3, t4, k6_a0
			addi t4, x0, 9
			beq t3, t4, k9_a0

		back_sub:
			andi t4, a1, 0xFF
			sub a3, a3, t4

			addi t4, x0, 3
			beq t3, t4, k3_a0
			addi t4, x0, 6
			beq t3, t4, k6_a0
			addi t4, x0, 9
			beq t3, t4, k9_a0


		back_a0_add:
			slli t4, a1, 16
			srli t4, t4, 24
			add a0, a0, t4

			addi t4, x0, 3
			beq t3, t4, kernal_4
			addi t4, x0, 6
			beq t3, t4, kernal_7
			addi t4, x0, 9
			beq t3, t4, check_range


		back_a0_sub:
			slli t4, a1, 16
			srli t4, t4, 24
			sub a0, a0, t4

			addi t4, x0, 3
			beq t3, t4, kernal_4
			addi t4, x0, 6
			beq t3, t4, kernal_7
			addi t4, x0, 9
			beq t3, t4, check_range

		back2_add:
			andi t4, a1, 0xFF
			add a4, a4, t4
			slli t4, a1, 16
			srli t4, t4, 24
			add a3, a3, t4

			addi t4, x0, 2
			beq t3, t4, k2_a0
			addi t4, x0, 5
			beq t3, t4, k5_a0
			addi t4, x0, 8
			beq t3, t4, k8_a0

		back2_sub:
			andi t4, a1, 0xFF
			sub a4, a4, t4
			slli t4, a1, 16
			srli t4, t4, 24
			sub a3, a3, t4

			addi t4, x0, 2
			beq t3, t4, k2_a0
			addi t4, x0, 5
			beq t3, t4, k5_a0
			addi t4, x0, 8
			beq t3, t4, k8_a0

		middle_a0_add:
			slli t4, a1, 8
			srli t4, t4, 24
			add a0, a0, t4

			addi t4, x0, 2
			beq t3, t4, k2_middle
			addi t4, x0, 5
			beq t3, t4, k5_middle
			addi t4, x0, 8
			beq t3, t4, k8_middle


		middle_a0_sub:
			slli t4, a1, 8
			srli t4, t4, 24
			sub a0, a0, t4

			addi t4, x0, 2
			beq t3, t4, k2_middle
			addi t4, x0, 5
			beq t3, t4, k5_middle
			addi t4, x0, 8
			beq t3, t4, k8_middle


		middle_a2_add:
			slli t4, a1, 8
			srli t4, t4, 24
			add a2, a2, t4
			addi t4, x0, 2
			beq t3, t4, k2_front
			addi t4, x0, 5
			beq t3, t4, k5_front
			addi t4, x0, 8
			beq t3, t4, k8_front


		middle_a2_sub:
			slli t4, a1, 8
			srli t4, t4, 24
			sub a2, a2, t4

			addi t4, x0, 2
			beq t3, t4, k2_front
			addi t4, x0, 5
			beq t3, t4, k5_front
			addi t4, x0, 8
			beq t3, t4, k8_front

		front_a4_add:
			srli t4, a1, 24
			add a4, a4, t4

			addi t4, x0, 2
			beq t3, t4, k2_check
			addi t4, x0, 5
			beq t3, t4, k5_check
			addi t4, x0, 8
			beq t3, t4, k8_check

		front_a4_sub:
			srli t4, a1, 24
			sub a4, a4, t4

			addi t4, x0, 2
			beq t3, t4, k2_check
			addi t4, x0, 5
			beq t3, t4, k5_check
			addi t4, x0, 8
			beq t3, t4, k8_check

	kernal_1: 
		lw a1, 0(ra)
		addi t3, x0, 1

		k1_back: 
			lw t2, 12(sp)
			lw t2, 0(t2)
			andi t2, t2, 0xFF
			addi t4, x0, 0x01
			beq t2, t4, back3_add
			addi t4, x0, 0xFF
			beq t2, t4, back3_sub

		k1_a0:
			addi t4, x0, 0x01
			beq t2, t4, front_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a0_sub

		k1_front:
			lw t2, 12(sp)
			lw t2, 0(t2)
			slli t2, t2, 16
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, front_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a2_sub

		kernal_2:
			lw a1, -4(ra)
			addi t3, x0, 2

		k2_back: 
			lw t2, 12(sp)
			lw t2, 0(t2)
			slli t2, t2, 16
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, back2_add
			addi t4, x0, 0xFF
			beq t2, t4, back2_sub

		k2_a0:
			addi t4, x0, 0x01
			beq t2, t4, middle_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a0_sub

		k2_middle:
			lw t2, 12(sp)
			lw t2, 0(t2)
			slli t2, t2, 8
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, middle_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a2_sub

		k2_front:
			addi t4, x0, 0x01
			beq t2, t4, front_a4_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a4_sub

		k2_check: 
			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, kernal_4

		kernal_3:
			lw a1, -8(ra)
			addi t3, x0, 3

			k3_back:
				lw t2, 12(sp)
				lw t2, 0(t2)
				slli t2, t2, 8
				srli t2, t2, 24
				addi t4, x0, 0x01
				beq t2, t4, back_add
				addi t4, x0, 0xFF
				beq t2, t4, back_sub

			k3_a0:
				addi t4, x0, 0x01
				beq t2, t4, back_a0_add
				addi t4, x0, 0xFF
				beq t2, t4, back_a0_sub

		kernal_4:
			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_4_d_is_2
			lw a1, -12(ra)
						
	m1_4_cal:
		addi t3, x0, 4
		k4_back: 
			lw t2, 12(sp)
			lw t2, 0(t2)
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, back3_add
			addi t4, x0, 0xFF
			beq t2, t4, back3_sub

		k4_a0:
			addi t4, x0, 0x01
			beq t2, t4, front_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a0_sub

		k4_front:
			lw t2, 12(sp)
			lw t2, 4(t2)
			andi t2, t2, 0xFF
			addi t4, x0, 0x01
			beq t2, t4, front_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a2_sub

		kernal_5:
			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_5_d_is_2
			lw a1, -16(ra)
		m1_5_cal:
		addi t3, x0, 5
		k5_back: 
			lw t2, 12(sp)
			lw t2, 4(t2)
			andi t2, t2, 0xFF
			addi t4, x0, 0x01
			beq t2, t4, back2_add
			addi t4, x0, 0xFF
			beq t2, t4, back2_sub

		k5_a0:
			addi t4, x0, 0x01
			beq t2, t4, middle_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a0_sub

		k5_middle:
			lw t2, 12(sp)
			lw t2, 4(t2)
			slli t2, t2, 16
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, middle_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a2_sub

		k5_front:
			addi t4, x0, 0x01
			beq t2, t4, front_a4_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a4_sub

		k5_check: 
			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, kernal_7

		kernal_6:
			lw a1, -20(ra)
			addi t3, x0, 6
			k6_back:
				lw t2, 12(sp)
				lw t2, 4(t2)
				slli t2, t2, 16
				srli t2, t2, 24
				addi t4, x0, 0x01
				beq t2, t4, back_add
				addi t4, x0, 0xFF
				beq t2, t4, back_sub

			k6_a0:
				addi t4, x0, 0x01
				beq t2, t4, back_a0_add
				addi t4, x0, 0xFF
				beq t2, t4, back_a0_sub

		kernal_7:
			# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_7_d_is_2

			lw a1, -24(ra)
		m1_7_cal: 	
			addi t3, x0, 7
			k7_back: 
			lw t2, 12(sp)
			lw t2, 4(t2)
			slli t2, t2, 8
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, back3_add
			addi t4, x0, 0xFF
			beq t2, t4, back3_sub

		k7_a0:
			addi t4, x0, 0x01
			beq t2, t4, front_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a0_sub

		k7_front:
			lw t2, 12(sp)
			lw t2, 4(t2)
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, front_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a2_sub

		kernal_8:
		# t2 = d
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, m1_8_d_is_2

			lw a1, -28(ra)
			
		m1_8_cal: 
		addi t3, x0, 8
		k8_back: 
			lw t2, 12(sp)
			lw t2, 4(t2)
			srli t2, t2, 24
			addi t4, x0, 0x01
			beq t2, t4, back2_add
			addi t4, x0, 0xFF
			beq t2, t4, back2_sub

		k8_a0:
			addi t4, x0, 0x01
			beq t2, t4, middle_a0_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a0_sub

		k8_middle:
			lw t2, 12(sp)
			lw t2, 8(t2)
			andi t2, t2, 0xFF
			addi t4, x0, 0x01
			beq t2, t4, middle_a2_add
			addi t4, x0, 0xFF
			beq t2, t4, middle_a2_sub

		k8_front:
			addi t4, x0, 0x01
			beq t2, t4, front_a4_add
			addi t4, x0, 0xFF
			beq t2, t4, front_a4_sub

		k8_check: 
			lw t2, 0(sp)
			addi t3, x0, 2
			beq t2, t3, check_range

		kernal_9:
			lw a1, -32(ra)
			addi t3, x0, 9
			k9_back:
				lw t2, 12(sp)
				lw t2, 8(t2)
				andi t2, t2, 0xFF
				addi t4, x0, 0x01
				beq t2, t4, back_add
				addi t4, x0, 0xFF
				beq t2, t4, back_sub

			k9_a0:
				addi t4, x0, 0x01
				beq t2, t4, back_a0_add
				addi t4, x0, 0xFF
				beq t2, t4, back_a0_sub

		beq x0, x0, check_range

	write_output:
		sub ra, ra, sp
	# d, c, imgptr, k 다시 불러와라
		lw t2, 0(sp)
		lw t3, 4(sp)
		lw t4, 8(sp)
		lw a1, 12(sp)
	# c, d, imgptr, k, bmp 바이트들 뽑기
		add sp, sp, ra

	# d, c, imgptr 다시 넣어주기! 이미 바이트들 빠진 상태에서 sp 
		addi sp, sp, -12
		sw t2, 0(sp)
		sw t3, 4(sp)
		sw t4, 8(sp)
		sw a1, 12(sp)

		# i의 3으로 나눈 나머지 판별
		addi a1, t1, 0
		addi t3, x0, 3

		addi t4, x0, 0
		beq a1, t4, mode1
		addi t4, x0, 1
		beq a1, t4, mode2
		addi t4, x0, 2
		beq a1, t4, mode3

	check_mode: 
		addi t4, x0, 0
		beq a1, t4, mode1
		addi t4, x0, 1
		beq a1, t4, mode2
		addi t4, x0, 2
		beq a1, t4, mode3
		addi a1, a1, -3

		bge a1, x0, check_mode

	mode1:
	# a2 blue a3 red a4 green a0 blue
	# 마지막인지 확인, w가 4의 배수인 경우는 해당x
		slli a0, a0, 24
		slli a4, a4, 8
		slli a3, a3, 16
		or a0, a0, a4
		or a0, a0, a3
		or a0, a0, a2

	# a2 = w
	lw a2, 16(sp)
	andi a3, a2, 0x03
	beq a3, x0, store

	# i = 3(w+1) / 4 - 3
		addi a2, a2, 1
		slli a3, a2, 1
		add a2, a2, a3
		srli a2, a2, 2
		addi a2, a2, -3

		beq t1, a2, mode1_1
		beq x0, x0, store

		mode1_1:
			slli a0, a0, 8
			srli a0, a0, 8
			beq x0, x0, store

	mode2:
		# a2 green a3 blue a4 red a0 green
		# d가 2인지 확인
		slli a0, a0, 24
		slli a4, a4, 8
		slli a3, a3, 16
		or a0, a0, a4
		or a0, a0, a3
		or a0, a0, a2

		lw a2, 0(sp)

		addi a3, x0, 2
		beq a2, a3, mode2_1
		beq x0, x0, store

		mode2_1: 
			slli a0, a0, 16
			srli a0, a0, 16
			beq x0, x0, store

	mode3:
		# a2 red a3 green a4 blue a0 red
		# d가 2인지 확인
		slli a0, a0, 24
		slli a4, a4, 8
		slli a3, a3, 16
		or a0, a0, a4
		or a0, a0, a3
		or a0, a0, a2

		lw a2, 0(sp)
		addi a3, x0, 2
		beq a2, a3, mode3_1
		beq x0, x0, store

		mode3_1: 
			slli a0, a0, 24
			srli a0, a0, 24
			beq x0, x0, store

	store: 
		# a0가 저장할 값
		# a2 = curr output
		lw a2, 24(sp)
		addi a2, a2, 4
		sw a0, 0(a2)
		sw a2, 24(sp)

	# d 꺼내기 다음 i에 의해서 결정됨
		addi sp, sp, 4
	# w a2에 로드
		lw a2, 12(sp)
		addi t2, a2, 1
		slli ra, t2, 1
		add t2, ra, t2
		srli t2, t2, 2
		# i = i+1
		addi t1, t1, 1
		beq x0, x0, width_loop

	check_range: 
		addi t2, x0, 255
		blt a2, x0, neg_a2
		blt t2, a2, over_a2
		blt a3, x0, neg_a3
		blt t2, a3, over_a3
		blt a4, x0, neg_a4
		blt t2, a4, over_a4
		blt a0, x0, neg_a0
		blt t2, a0, over_a0
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

	neg_a0: 
		addi a0, x0, 0
		beq x0, x0, check_range

	over_a0:
		addi a0, x0, 0xFF
		beq x0, x0, check_range

	m1_4_d_is_2:
		lw a1, -8(ra)
		beq x0, x0, m1_4_cal

	m1_5_d_is_2:
		lw a1, -12(ra)
		beq x0, x0, m1_5_cal

	m1_7_d_is_2:
		lw a1, -16(ra)
		beq x0, x0, m1_7_cal

	m1_8_d_is_2:
		lw a1, -20(ra)
		beq x0, x0, m1_8_cal
	
	end_width: 
		# 현재 c 꺼내기 다음 c는 다음 m에 의해서 결정됨
		addi sp, sp, 4
		# m = m + 1
		addi t0, t0, 1
		# ai에 height 로드
		lw a1, 12(sp)
		# a2에 width 로드
		lw a2, 8(sp)
		beq x0, x0, height_loop

	end_height:
		addi sp, sp, 24
		lw ra, 0(sp)
		addi sp, sp, 4
		ret