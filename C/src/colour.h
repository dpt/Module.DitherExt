#ifndef COLOUR_H
#define COLOUR_H

#include "dither.h"

/* Colours are &BBGGRR00 words. */
#define RED(c)     (((c) >> 8) & 0xFF)
#define GRN(c)     (((c) >> 16) & 0xFF)
#define BLU(c)     ((c) >> 24)
#define LUMA(c)    (0x4D * RED(c) + 0x97 * GRN(c) + 0x1C * BLU(c))
#define CHAN(c, i) (((c) >> (8 + 8 * (i))) & 0xFF)
typedef struct {
    uint32_t index;     /* colour number (the original's R2) */
    uint32_t rgb;       /* matching &BBGGRR00 colour (the original's FP) */
    int      carry;     /* search_palette only: the asm's C flag on exit */
} Nearest;

typedef struct {
    const uint32_t *start;
    const uint32_t *end;
} PaletteRange;

extern const uint32_t default_palette_2[2];
extern const uint32_t default_palette_4[4];
extern const uint32_t default_palette_16[16];
extern const uint32_t default_palette_256[256];
extern const uint32_t default_palette_table[1024];
extern const uint8_t  cube_class_table[216];
extern const uint8_t  grey_palette_table[48];
extern const uint32_t cube_blend_table[256];

/* colour.c */
uint32_t     colour_number_to_gcol(uint32_t colour_number);
uint32_t     gcol_to_colour_number(uint32_t gcol);
Nearest      colour_to_15(uint32_t colour);
Nearest      nearest_default(uint32_t colour);
Nearest      nearest_default_in(const uint32_t *table, uint32_t colour);
Nearest      nearest_grey(uint32_t colour);
Nearest      nearest_cube(uint32_t colour);
uint32_t     cube_pick(const uint8_t *class_table, const uint8_t *grey_table, const uint32_t c16[3], int *grey);
Nearest      nearest_custom(uint32_t colour);
Nearest      nearest_custom_in(const Workspace *w, uint32_t colour);
Nearest      nearest_by_type(int type, uint32_t colour);
Nearest      search_rgb(PaletteRange range, int r, int g, int b);
Nearest      search_palette(PaletteRange range, uint32_t colour);
uint32_t     search_palette_alt(PaletteRange range, uint32_t colour);
int          find_palette_type(const uint32_t *start, const uint32_t *end);
PaletteRange select_pattern_pointers(int depth);
PaletteRange pointers_for_mode(int depth, const uint32_t *palette);
_kernel_oserror *read_hardware_palette(PaletteRange range);
_kernel_oserror *mode_to_depth(int mode, int *depth);
uint32_t     return_gcol(uint32_t colour, uint32_t *rgb);
uint32_t     return_opp_gcol(uint32_t colour);

/* select.c */
_kernel_oserror *select_table(int src_mode, const uint32_t *src_palette,
                              int dst_mode, const uint32_t *dst_palette, uint8_t *out);
_kernel_oserror *select_gcol_table(int src_mode, const uint32_t *src_palette,
                                   int dst_mode, const uint32_t *dst_palette, uint8_t *out);
_kernel_oserror *select_halftone_table(int mode, const uint32_t *palette, uint8_t *out);

/* misc.c */
_kernel_oserror *read_palette(int mode, const uint32_t *palette, uint32_t *out);
_kernel_oserror *return_halftone_table(uint32_t a, uint32_t b, uint8_t *out);
const uint32_t   *pattern_array(_kernel_oserror **error);

/* SWIs */
_kernel_oserror *swi_read_palette(_kernel_swi_regs *r);
_kernel_oserror *swi_return_halftone_intensity(_kernel_swi_regs *r);
_kernel_oserror *swi_return_halftone_table(_kernel_swi_regs *r);
_kernel_oserror *swi_return_colour_pattern_array(_kernel_swi_regs *r);
_kernel_oserror *swi_return_gcol(_kernel_swi_regs *r);
_kernel_oserror *swi_return_colour_number(_kernel_swi_regs *r);
_kernel_oserror *swi_return_gcol_for_mode(_kernel_swi_regs *r);
_kernel_oserror *swi_return_colour_number_for_mode(_kernel_swi_regs *r);
_kernel_oserror *swi_return_opp_gcol(_kernel_swi_regs *r);
_kernel_oserror *swi_return_opp_colour_number(_kernel_swi_regs *r);
_kernel_oserror *swi_return_opp_gcol_for_mode(_kernel_swi_regs *r);
_kernel_oserror *swi_return_opp_colour_number_for_mode(_kernel_swi_regs *r);
_kernel_oserror *swi_select_table(_kernel_swi_regs *r);
_kernel_oserror *swi_select_gcol_table(_kernel_swi_regs *r);
_kernel_oserror *swi_select_halftone_table(_kernel_swi_regs *r);
_kernel_oserror *swi_gcol_to_colour_number(_kernel_swi_regs *r);
_kernel_oserror *swi_colour_number_to_gcol(_kernel_swi_regs *r);

/* pattern.c. flags is the asm R3 (negative: write 32 bytes to arg; else b7
   selects the half of the pattern area and arg&7 the mask row). *ret gets
   the asm R0 on exit. */
_kernel_oserror *set_gcol_core(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret);
_kernel_oserror *set_opp_gcol_core(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret);
_kernel_oserror *swi_set_gcol(_kernel_swi_regs *r);
_kernel_oserror *swi_set_opp_gcol(_kernel_swi_regs *r);


_kernel_oserror *return_colour_pattern(uint32_t colour, uint32_t *out);
_kernel_oserror *return_colour_pattern_table(uint32_t c0, uint32_t c1, uint32_t *out);
_kernel_oserror *select_colour_pattern_table(int mode, const uint32_t *palette, uint32_t *out);
_kernel_oserror *swi_return_colour_pattern(_kernel_swi_regs *r);
_kernel_oserror *swi_return_colour_pattern_table(_kernel_swi_regs *r);
_kernel_oserror *swi_select_colour_pattern_table(_kernel_swi_regs *r);

/* screen.c */
_kernel_oserror *cache_screen(uint32_t key, uint32_t *bitmap, uint32_t *length);
_kernel_oserror *swi_cache_screen(_kernel_swi_regs *r);


/* setscreen.c */
_kernel_oserror *set_screen_core(int32_t fn, int32_t angle, int32_t sx, int32_t sy,
                                 int32_t arg, uint8_t *thr,
                                 uint32_t *width, uint32_t *height, uint32_t *shift);
_kernel_oserror *swi_set_screen(_kernel_swi_regs *r);

/* antialias.c */
_kernel_oserror *swi_antialias(_kernel_swi_regs *r);

/* blend.c */
void blend_2bpp(const uint32_t *mask, const uint8_t *src, uint8_t *dst, uint32_t count);
void blend_4bpp(const uint8_t *mask, const uint8_t *src, uint8_t *dst, uint32_t count, const Workspace *w);
void blend_grey8(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count);
void blend_default8(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count, const Workspace *w);
void blend_cube8(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count, const Workspace *w);
void blend_custom8(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count, const Workspace *w);
void blend_16bpp(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count);
void blend_32bpp(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count);

#endif
