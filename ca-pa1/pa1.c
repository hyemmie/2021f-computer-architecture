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

    int run_length = 0;
    int find_case = 0;
    int current_dst_length = 0;
    int current_dst_bit = 0;
    char temp_dst_bit = 0;

    if (srclen == 0) return 0;
    for (int i = 0; i < srclen; i++) {
        for (int j = 7; j >= 0; j--) {
            int bit = (src[i] >> j) & 1;
            // counting current case
            if (find_case == bit) {
                // run length == 7
                if (run_length >= 6) {
                    run_length++;
                    for (int i = 2; i >= 0; i--) {
                        int temp = (run_length >> i) & 1;
                        if (current_dst_bit >= 7) {
                            if (current_dst_length >= dstlen) {
                                return -1;
                            }      
                            *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                            temp_dst_bit = 0;
                            current_dst_bit = 0;
                        } else {
                            current_dst_bit++;
                            temp_dst_bit = (temp_dst_bit << 1) | temp;
                        }
                    }
                    run_length = 0;
                    find_case = find_case == 1 ? 0 : 1;
                }
                // run length < 7
                else { 
                    run_length++; 
                }
            }
            // encounter diff -> write current number and switch case
            else {
                for (int i = 2; i >= 0; i--) {
                    int temp = (run_length >> i) & 1;
                        if (current_dst_bit >= 7) {
                            current_dst_bit = 0;
                            if (current_dst_length >= dstlen) {
                                return -1;
                            } 
                            *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                            temp_dst_bit = 0;
                        } else {
                            current_dst_bit++;
                            temp_dst_bit = (temp_dst_bit << 1) | temp;
                        }
                }
                run_length = 1;
                find_case = find_case == 1 ? 0 : 1;
            }
        }
    }
    // add remaining number
    if (run_length > 0) {
        // write number of zero to memory
        for (int i = 2; i >= 0; i--) {
            int temp = (run_length >> i) & 1;
            if (current_dst_bit >= 7) {
                current_dst_bit = 0;
                if (current_dst_length >= dstlen) {
                    return -1;
                } 
                *(dst+current_dst_length++) = (temp_dst_bit << 1) | temp;
                temp_dst_bit = 0;
            } else {
                current_dst_bit++;
                temp_dst_bit = (temp_dst_bit << 1) | temp;
            }
        }
        // add padding
        if (current_dst_bit > 0) {
            if (current_dst_length >= dstlen) {
                return -1;
            } 
            *(dst+current_dst_length++) = temp_dst_bit << (8 - current_dst_bit);
        }
    }

    // return the length of the output
    return current_dst_length;
}

/* TODO: Implement this function */
int decode(const char* const src, const int srclen, char* const dst, const int dstlen)
{
    int check_case = 0;
    int case_count = 0;
    int run_length = 0;
    int current_dst_length = 0;
    int current_dst_bit = 0;
    char temp_dst_bit = 0;

    if (srclen == 0) return 0;
    for (int i = 0; i < srclen; i++) {
        for (int j = 7; j >= 0; j--) {
            int bit = (src[i] >> j) & 1;
            if (run_length >= 3) {
                // write check_case to memory
                for (int i = case_count; i > 0; i--) {
                    if (current_dst_bit >= 7) {
                        if (current_dst_length >= dstlen) {
                            return -1;
                        } 
                        *(dst+current_dst_length++) = (temp_dst_bit << 1) | check_case;
                        temp_dst_bit = 0;
                        current_dst_bit = 0;
                    } else {
                        current_dst_bit++;
                        temp_dst_bit = (temp_dst_bit << 1) | check_case;
                    }
                }
                case_count = bit;
                check_case = check_case == 1 ? 0 : 1;
                run_length = 1;
            }
            // run length < 3
            else { 
                run_length++;
                case_count = (case_count << 1) | bit;
            }
        }
    }

    if (case_count > 0) {
        for (int i = case_count; i > 0; i--) {
            if (current_dst_bit >= 7) {
                if (current_dst_length >= dstlen) {
                    return -1;
                } 
                *(dst+current_dst_length++) = (temp_dst_bit << 1) | check_case;
                temp_dst_bit = 0;
                current_dst_bit = 0;
            } else {
                current_dst_bit++;
                temp_dst_bit = (temp_dst_bit << 1) | check_case;
            }
        }
        if (temp_dst_bit > 0) {
            if (current_dst_length >= dstlen) {
                return -1;
            } 
            *(dst+current_dst_length++) = temp_dst_bit;
        }
    }

    // return the length of the output
    return current_dst_length;
}
