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
	// if () // NaN
	if (n >= 0xFC00) return (ans + (31 << 4)); // Inf
	// negative sign
	if (n < 0) {
		ans += (0xFFFFFFFF << 9);
		n *= (-1);
	}
	int exp = 0;
	int temp_n = n;
	while (temp_n > 1) {
		temp_n >>= 1;
		if (++exp > 15) return (ans + (31 << 4));
	}
	int frac = (exp < 5) ? ((n - (1 << exp)) << (4 - exp)) : (((n - (1 << exp)) >> (exp - 4)));
	// calculate sticky bit
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
	
	return ans + ((exp + 15) << 4) + frac;
}

/* Convert 10-bit floating point to 32-bit signed integer */
int fp10_int(fp10 x)
{
	/* TODO */







	return 1;
}

/* Convert 32-bit single-precision floating point to 10-bit floating point */
fp10 float_fp10(float f)
{
	/* TODO */








	return 1;
}

/* Convert 10-bit floating point to 32-bit single-precision floating point */
float fp10_float(fp10 x)
{
	/* TODO */








	return 1.0;
}
