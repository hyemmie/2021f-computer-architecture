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

/* Convert 32-bit signed integer to 10-bit floating point */
fp10 int_fp10(int n)
{
	fp10 ans = 0;
	if (n == 0) return ans; // 0
	if (n >= 0xFC00) return (ans + (31 << 4)); // Inf
	// negative sign
	if (n < 0) {
		ans += (0xFFFF << 9);
		n *= (-1);
		if (n >= 0xFC00) return (ans + (31 << 4)); // -Inf
	}
	int exp = 0;
	int temp_n = n;
	while (temp_n > 1) {
		temp_n >>= 1;
		if (++exp > 15) return (ans + (31 << 4)); // Inf
	}
	int frac = (exp < 5) ? ((n - (1 << exp)) << (4 - exp)) : (((n - (1 << exp)) >> (exp - 4)));
	if (exp >= 5) {
		int s = n & ((1 << (exp - 5)) - 1);
		int r = n & (1 << (exp - 5));
		int l = n & (1 << (exp - 4));
		// rounding
		if ((r > 0) && ((s > 0) || (s == 0 && l > 0))) {
			frac += 1;
		}
		if (frac > 15) {
			if (++exp > 15) return (ans + (31 << 4)); // Inf
			frac = 0;
		}
	}

	ans += ((exp + 15) << 4) + frac;
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
	ans *= (frac + 16) << (exp - 4);
  return ans;
}

/* Convert 32-bit single-precision floating point to 10-bit floating point */
fp10 float_fp10(float f)
{
	fp10 ans = 0;
	int denormalized = 0;
	union {
		unsigned int i;
		float f;
	} uni;
	uni.f = f;
	if (uni.i & (1 << 31))
	{
			ans += (0xFFFF << 9);
			uni.i -= (1 << 31);
	}
	int exp = ((uni.i & 0x7f800000) >> 23) - 127;
	int frac = (uni.i & (15 << 19)) >> 19;
	if (uni.i > 0x7f800000) return ans + (31 << 4) + 1; // NaN
	if (exp > 15) return ans + (31 << 4); // Inf
	if (exp < -19) return ans; // underflow
	int l, r, s;
	l = (uni.i >> 19) & 1;
	r = (uni.i >> 18) & 1;
	s = (uni.i) & (0x3ff);
	// denormalized
	if (exp < -14) {
		denormalized = 1;
		int full_frac = ((uni.i & (15 << 19)) + (1 << 23));
		frac = full_frac >> (20 + -15 - exp);
		l = (full_frac >> (20 + -15 - exp)) & 1;
		r = (full_frac >> (19 + -15 - exp)) & 1;
		s = (full_frac) & ((1 << (19 + -15 - exp)) - 1);
	}

	if ((r > 0) && (s > 0) || (s == 0 && l > 0)) {
		frac += 1;
	}
	if (frac > 15) {
		if (exp == -15) {
			denormalized = 0;
		}
		if (++exp > 15) return (ans + (31 << 4));
		frac = 0;
	}
	if (denormalized) {
		ans += frac;
	} else {
		ans += ((exp + 15) << 4) + frac;
	}

	return ans;
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
		// NaN
		if(frac != 0) {
			if(ans == -1) uni.i = (511 << 23) + 1;
			else uni.i = (255 << 23) + 1;
			return uni.f;
		}
		// Inf
		if(ans == -1) uni.i = (511 << 23);
		else uni.i = (255 << 23);
		return uni.f;
	}
	ans *= (frac + (1 << 4)) * (float)(1 << (exp - 4));
	return ans;
}
