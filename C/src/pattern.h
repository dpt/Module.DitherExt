#ifndef PATTERN_H
#define PATTERN_H

#include <stdint.h>

extern const uint32_t pattern_select_table[72];
extern const uint32_t pattern16_masks[144];
extern const uint32_t pattern16bpp_masks[16];
extern const uint32_t pattern_row_xor_table[72];
extern const uint32_t pattern_mask_table2[40];
extern const uint32_t pattern8bpp_masks[40];
extern const uint32_t pattern8bpp_masks2[144];
extern const uint32_t pattern_bit_table[20];
extern const uint32_t pattern_bit_table2[20];
extern const uint32_t pattern_word_table[20];
extern const uint32_t pattern_word_table2[20];
extern const uint8_t  pattern_level_table[256];
extern const uint16_t pattern_scale_table[256];

#endif
