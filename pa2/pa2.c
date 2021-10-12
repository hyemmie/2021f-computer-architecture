//---------------------------------------------------------------
//
//  4190.308 Computer Architecture (Fall 2021)
//
//  Project #2: FP10 (10-bit floating point) Representation
//
//  October 5, 2021
//
//  Jaehoon Shim (mattjs@snu.ac.kr)
//  Ikjoon Son (ikjoon.son@snu.ac.kr)
//  Seongyeop Jeong (seongyeop.jeong@snu.ac.kr)
//  Systems Software & Architecture Laboratory
//  Dept. of Computer Science and Engineering
//  Seoul National University
//
//---------------------------------------------------------------

#include "pa2.h"
// #include <stdio.h>

/* Convert 32-bit signed integer to 10-bit floating point */
fp10 int_fp10(int n)
{
	fp10 ans = 0;
	if (n == 0) return ans; // 0
	// if (n == -1) return ans + (15 << 4) + (0xFFFF << 9);
	if (n >= 0xFC00) return (ans + (31 << 4)); // Inf
	// negative sign
	if (n < 0) {
		// if (n == 0x) return (0xFFFF << 9);

		ans += (0xFFFF << 9);
		// if (n == -1) return ans + (15 << 4);
		n *= (-1);
		if (n >= 0xFC00) return (ans + (31 << 4)); // -Inf
	}
	int exp = 0;
	int temp_n = n;
	while (temp_n > 1) {
		temp_n >>= 1;
		if (++exp > 15) return (ans + (31 << 4));
	}
	int frac = (exp < 5) ? ((n - (1 << exp)) << (4 - exp)) : (((n - (1 << exp)) >> (exp - 4)));
	// calculate sticky bit
	if (exp >= 5) {
		int s = n & ((1 << (exp - 5)) - 1);
		int r = n & (1 << (exp - 5));
		int l = n & (1 << (exp - 4));
		// rounding
		if (r > 0) {
			if (s > 0) frac += 1;
			if (s == 0 && l > 0) frac += 1;
		}
		if (frac > 15) {
			if (++exp > 15) return (ans + (31 << 4));
			frac = 0;
		}
	}

	ans += ((exp + 15) << 4) + frac;

	if (ans == 0xFE00) return (0xFFFF << 9);

	return ans;
}

/* Convert 10-bit floating point to 32-bit signed integer */
int fp10_int(fp10 x)
{
	if ((x == 0) || ((x - (0xFFFF << 9)) == 0)) return 0;
	int ans = (x >> 15) ? -1 : 1;
  x -= (0xFFFF << 9);
	int exp = ((x & (31 << 4)) >> 4) - 15;
	int frac = x & 15;
	if (exp <= 0) return 0;
	if (exp > 15) return 0x80000000;
	if (exp < 4) return ans * ((frac + 16) >> (4 - exp));
  return ans * ((frac + 16)<< (exp - 4));
}

/* Convert 32-bit single-precision floating point to 10-bit floating point */
fp10 float_fp10(float f)
{
	fp10 ans = 0;
	union {
    unsigned int int_f;
    float f_f;
  } uni;
	uni.f_f = f;
	int exp = ((uni.int_f & 0x7f800000) >> 23) - 127;
	int frac = (uni.int_f & (15 << 19)) >> 19;
	// printf("exp: %d, frac = %d ", exp, frac);
	if (f < 0) {
		ans += (0xFFFF << 9);
		uni.int_f -= (1 << 31);
	}
	if ((exp == 0) && (frac == 0)) return ans + (15 << 4); // zero
	if ((exp > 127) && (frac > 0)) return 1 + ans + (31 << 4); // nan
	if (exp > 15) return ans + (31 << 4); // overflow
	if (exp < -19) return ans; // underflow
	// if ((exp == -15) && (frac == 15)) return ans + (1 << 4); // corner

	int s;
	int r;
	int l;
	// printf("exp: %d, frac: %d ", exp, frac);
	int tmp = ((uni.int_f << 8) | (1 << 31));
	// printf("exp: %d, tmp: %d ", exp, tmp);
	int de_frac = (tmp >> (-14 - exp)) < 0 ? ((tmp >> (-14 - exp)) - (1 << 31)) : (tmp >> (-14 - exp));
	// printf("exp: %d, de_frac: %d ", exp, de_frac);

	// denomalized
	if ((exp < -14) && (de_frac > 0)) { // frac 4비트로 자르기 전 체크해보기
		// int frac = ((uni.int_f << 8) + (1 << 31)) >> (exp + 23);
		exp = -14;
		s = frac & (0xFFFFFFFF >> 6);
		r = frac & (1 << 26);
		l = frac & (1 << 27);
		// printf("exp: %d, frac: %d ", exp, frac);


		if (r > 0) {
			if (s > 0) frac = (frac >> 28) + 1;
			if (s == 0 && l > 0) frac = (frac >> 28) + 1;
		}
		// printf("exp: %d, frac: %d ", exp, frac);
		if (frac > 15) {
			// if (++exp > 15) return (ans + (31 << 4));
			exp++;
			frac = 0;
		}
		// printf("exp: %d, frac: %d ", exp, frac);
		return ans + ((exp + 15) << 4) + frac;

	} else {
		s = uni.int_f & (0xFFFFFFFF >> 14);
		r = uni.int_f & (1 << 18);
		l = uni.int_f & (1 << 19);

		// rounding
		if (r > 0) {
			if (s > 0) frac += 1;
			if (s == 0 && l > 0) frac += 1;
		}
		if (frac > 15) {
			if (++exp > 15) return (ans + (31 << 4));
			frac = 0;
		}
		return ans + ((exp + 15) << 4) + frac;
	}

	// fp10 ans = 0;
	// union {
	// 		unsigned int u;
	// 		float fp;
	// } ori_f;
	// ori_f.fp = f;
	// if(ori_f.u & (1 << 31))
	// {
	// 		ans += (0xFFFF << 9);
	// 		ori_f.u -= (1 << 31);
	// }
	// int E = (((ori_f.u) & (255 << 23)) >> 23) - 127;
	// int exp = ((ori_f.u & 0x7f800000) >> 23) - 127;
	// int frac = (ori_f.u & (15 << 19)) >> 19;
	// // if (ori_f.u > 0x7f800000) return 1 + ans + (31 << 4); //nan
	// // if (ori_f.u == 0x7f800000 || E >= 16) return ans + (31 << 4); //overflow
	// if ((exp == 0) && (frac == 0)) return ans + (15 << 4); // zero
	// if ((exp > 127) && (frac > 0)) return 1 + ans + (31 << 4); // nan
	// if (exp > 15) return ans + (31 << 4); // overflow
	// if (exp < -19) return ans; // underflow
	// int rb, stb;
	// ans += (((ori_f.u) & (0x7fffff)) >> 19) + ((E + 15) << 4);
	// rb = (ori_f.u >> 12) & 1;
	// stb = (ori_f.u) & (0xfff);
	// if((rb && ((ans & (31<<4))!= 31<<4)) && (stb || (!stb && (ans & 1)))) ans += 1;
	// return ans;
}


/* Convert 10-bit floating point to 32-bit single-precision floating point */
float fp10_float(fp10 x)
{
	float ans = 1.0;
    if (x >> 15) {
			x -= (1 << 15);
			ans *= -1.0;
    }
    union {
        unsigned int i;
        float f;
    } uni;
    if (x == 0) return (ans * 0.0);
    int exp = ((x & (31 << 4)) >> 4) - 15;
    int frac = (x & ((1 << 4) - 1));
		if (exp == -15) return ans * frac * (1.0 / (1 << 14));
    if (exp <= 4) return ans * (frac + (1 << 4)) * (1.0 / (float)(1 << (4 - exp)));
    if(exp == 16) {
			if(frac != 0) {
					if(ans == -1) uni.i = (511 << 23) + 1;
					else uni.i = (255 << 23) + 1;
					return uni.f;
			}
			if(ans == -1) uni.i = (511 << 23);
			else uni.i = (255 << 23);
			return uni.f;
    }
	return ans * ((frac + (1 << 4)) * (float)(1 << (exp - 4)));
}
