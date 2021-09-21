//---------------------------------------------------------------
//
//  4190.308 Computer Architecture (Fall 2021)
//
//  Project #1: Run-Length Encoding
//
//  September 14, 2021
//
//  Jaehoon Shim (mattjs@snu.ac.kr)
//  Ikjoon Son (ikjoon.son@snu.ac.kr)
//  Seongyeop Jeong (seongyeop.jeong@snu.ac.kr)
//  Systems Software & Architecture Laboratory
//  Dept. of Computer Science and Engineering
//  Seoul National University
//
//---------------------------------------------------------------

#include <stdio.h>
#include <string.h>

/* TODO: Implement this function */
int encode(const char* const src, const int srclen, char* const dst, const int dstlen)
{

    int zero_count = 0;
    int one_count = 0;
    int find_case = 0;
    int current_dst_length = 0;
    int current_dst_bit = 0;

    if (srclen == 0) return 0;
    for (int i = 0; i < srclen; i++) {
        for (int j = 7; j >= 0; j--) {
            int bit = (src[i] >> j) & 1;
            if (find_case == 0) {
                if (bit == 0) {
                    if (zero_count >= 6) {
                        // TODO : write current zero count
                        zero_count++;
                        for (int i = 0; i < 3; i++) {
                            int temp = (zero_count >> i) & 1;
                            if (current_dst_bit >= 7) {
                                current_dst_bit = 0;
                                current_dst_length++;
                                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                            } else {
                                current_dst_bit++;
                                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                            }
                        }
                        // printf("zero : %d\n", zero_count);
                        zero_count = 0;
                        find_case = 1;
                        // continue;
                    } else { 
                        zero_count++; 
                        // continue;
                    }
                } else {
                    // TODO: write current zero count
                    for (int i = 0; i < 3; i++) {
                        int temp = (zero_count >> i) & 1;
                        if (current_dst_bit >= 7) {
                            current_dst_bit = 0;
                            current_dst_length++;
                            *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                        } else {
                            current_dst_bit++;
                            *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                        }
                    }
                    // printf("zero : %d\n", zero_count);
                    zero_count = 0;
                    find_case = 1;
                    one_count++;
                    // continue;
                }
            }
            else {
                if (bit == 1) {
                    if (one_count >= 6) {
                        one_count++;
                        // TODO : write current one count
                        for (int i = 0; i < 3; i++) {
                            int temp = (one_count >> i) & 1;
                            if (current_dst_bit >= 7) {
                                current_dst_bit = 0;
                                current_dst_length++;
                                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                            } else {
                                current_dst_bit++;
                                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                            }
                    }
                        // printf("one : %d\n", one_count);
                        one_count = 0;
                        find_case = 0;
                        // continue;
                    } else { 
                        one_count++;
                        // continue;
                    }
                } else {
                    // TODO : write current one count
                    for (int i = 0; i < 3; i++) {
                        int temp = (one_count >> i) & 1;
                        if (current_dst_bit >= 7) {
                            current_dst_bit = 0;
                            current_dst_length++;
                            *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                        } else {
                            current_dst_bit++;
                            *(dst+(current_dst_length*8)+current_dst_bit) = temp;
                        }
                    }
                    // printf("one : %d\n", one_count);
                    one_count = 0;
                    find_case = 0;
                    zero_count++;
                    // continue;
                }
            }
        }
    }
    if (find_case == 0) {
        // TODO :write final zero count
        // printf("zero : %d\n", zero_count);
        for (int i = 0; i < 3; i++) {
            int temp = (zero_count >> i) & 1;
            if (current_dst_bit >= 7) {
                current_dst_bit = 0;
                current_dst_length++;
                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
            } else {
                current_dst_bit++;
                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
            }
        }
        // TODO : add padding
    } else {
        // TODO : write final one count
        // printf("one : %d\n", one_count);
        for (int i = 0; i < 3; i++) {
            int temp = (one_count >> i) & 1;
            if (current_dst_bit >= 7) {
                current_dst_bit = 0;
                current_dst_length++;
                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
            } else {
                current_dst_bit++;
                *(dst+(current_dst_length*8)+current_dst_bit) = temp;
            }
        }
        // TODO : add padding
    }

    return current_dst_length;
}

/* TODO: Implement this function */
int decode(const char* const src, const int srclen, char* const dst, const int dstlen)
{















    return 0;
}
