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


/* TODO: Implement this function */
int encode(const char* const src, const int srclen, char* const dst, const int dstlen)
{

    int zero_count = 0;
    int one_count = 0;
    int find_case = 0;
    int current_dst_length = 0;
    int current_dst_bit = 0;
    char temp_dst_bit = 0;

    if (srclen == 0) return 0;
    for (int i = 0; i < srclen; i++) {
        for (int j = 7; j >= 0; j--) {
            int bit = (src[i] >> j) & 1;
            // counting zero
            if (find_case == 0) {
                // encounter zero
                if (bit == 0) {
                    // add 7th zero to 6 zeros (run length == 7)
                    if (zero_count >= 6) {
                        zero_count++;
                        // write number of zero to memory
                        for (int i = 2; i >= 0; i--) {
                            int temp = (zero_count >> i) & 1;
                            if (current_dst_bit >= 7) {
                                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                                temp_dst_bit = 0;
                                current_dst_bit = 0;
                            } else {
                                current_dst_bit++;
                                temp_dst_bit = (temp_dst_bit << 1) | temp;
                            }
                        }
                        zero_count = 0;
                        find_case = 1;
                    }
                    // run length < 7
                    else { 
                        zero_count++; 
                    }
                }
                // encounter one
                else {
                    // write number of zero to memory
                    for (int i = 2; i >= 0; i--) {
                        int temp = (zero_count >> i) & 1;
                            if (current_dst_bit >= 7) {
                                current_dst_bit = 0;
                                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                                temp_dst_bit = 0;
                            } else {
                                current_dst_bit++;
                                temp_dst_bit = (temp_dst_bit << 1) | temp;
                            }
                    }
                    zero_count = 0;
                    find_case = 1;
                    one_count++;
                }
            }
            // counting one
            else {
                // encounter one
                if (bit == 1) {
                    // add 7th one to 6 one(run length == 7)
                    if (one_count >= 6) {
                        one_count++;
                        // write number of one to memory
                        for (int i = 2; i >= 0; i--) {
                            int temp = (one_count >> i) & 1;
                            if (current_dst_bit >= 7) {
                                current_dst_bit = 0;
                                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                                temp_dst_bit = 0;
                            } else {
                                current_dst_bit++;
                                temp_dst_bit = (temp_dst_bit << 1) | temp;
                            }
                        }
                        one_count = 0;
                        find_case = 0;
                    }
                    // run length < 7
                    else { 
                        one_count++;
                    }
                }
                // encounter zero
                else {
                    // write number of one to memory
                    for (int i = 2; i >= 0; i--) {
                        int temp = (one_count >> i) & 1;
                        if (current_dst_bit >= 7) {
                            current_dst_bit = 0;
                            *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                            temp_dst_bit = 0;
                        } else {
                            current_dst_bit++;
                            temp_dst_bit = (temp_dst_bit << 1) | temp;
                        }
                    }
                    one_count = 0;
                    find_case = 0;
                    zero_count++;
                }
            }
        }
    }
    // add remaining counted zero
    if (find_case == 0) {
        // write number of zero to memory
        for (int i = 2; i >= 0; i--) {
            int temp = (zero_count >> i) & 1;
            if (current_dst_bit >= 7) {
                current_dst_bit = 0;
                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                temp_dst_bit = 0;
            } else {
                current_dst_bit++;
                temp_dst_bit = (temp_dst_bit << 1) | temp;
            }
        }
        // add padding
        if (current_dst_bit > 0) {
            *(dst+current_dst_length++) = temp_dst_bit << (8 - current_dst_bit);
        }
    }
    // add remaining counted one
    else {
        // write number of one to memory
        for (int i = 2; i >= 0; i--) {
            int temp = (one_count >> i) & 1;
            if (current_dst_bit >= 7) {
                current_dst_bit = 0;
                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                temp_dst_bit = 0;
            } else {
                current_dst_bit++;
                temp_dst_bit = (temp_dst_bit << 1) | temp;
            }
        }
        // add padding
        if (current_dst_bit > 0) {
            *(dst+current_dst_length++) = temp_dst_bit << (8 - current_dst_bit);
        }    
    }

    // output is bigger than dstlen
    if (current_dst_length > dstlen) {
        return -1;
    }

    // return the length of the output
    return current_dst_length;
}

/* TODO: Implement this function */
int decode(const char* const src, const int srclen, char* const dst, const int dstlen)
{















    return 0;
}
