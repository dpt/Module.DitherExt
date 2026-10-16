/* DitherExtend ReadPalette, ReturnHalftoneIntensity, ReturnHalftoneTable and
   ReturnColourPatternArray. Ported from DitherExt.s. */

#include <stdlib.h>
#include <string.h>
#include "kernel.h"
#include "colour.h"

#define PATTERN_ARRAY_SIZE 0x20000
#define PATTERN_ARRAY_FILL 0xC90FDAA2u

_kernel_oserror *read_palette(int mode, const uint32_t *palette, uint32_t *out)
{
    PaletteRange range;
    _kernel_oserror *e;
    int depth;

    e = mode_to_depth(mode, &depth);
    if (e != NULL)
        return e;
    if (depth > 3)
        return make_error(0x803003, "Bad mode");     /* the asm reads past its tables */
    range = pointers_for_mode(depth, palette);
    memcpy(out, range.start, (range.end - range.start) * sizeof(uint32_t));
    return NULL;
}

/* Interpolated colour i of 256 from a to b, one channel at a time. */
static uint32_t ramp_colour(const int *from, const int *step, int i)
{
    uint32_t colour = 0;
    uint32_t x;
    int c;

    for (c = 0; c < 3; c++) {
        x = from[c] * 255 + i * step[c];
        x += x << 8;
        colour |= ((x >> 16) + ((x >> 15) & 1)) << (8 * (c + 1));
    }
    return colour;
}

_kernel_oserror *return_halftone_table(uint32_t a, uint32_t b, uint8_t *out)
{
    int from[3];
    int step[3];
    int i;

    from[0] = RED(a);
    from[1] = GRN(a);
    from[2] = BLU(a);
    step[0] = RED(b) - from[0];
    step[1] = GRN(b) - from[1];
    step[2] = BLU(b) - from[2];
    for (i = 0; i < 256; i++)
        out[i] = nearest_grey(ramp_colour(from, step, i)).index;
    return NULL;
}

const uint32_t *pattern_array(_kernel_oserror **error)
{
    uint32_t *block = ws.screen_cache;
    size_t i;

    *error = NULL;
    if (block != NULL)
        return block;
    block = malloc(PATTERN_ARRAY_SIZE);
    if (block == NULL) {
        *error = make_error(0x1E4, "No room in the module area");
        return NULL;
    }
    ws.screen_cache = block;
    for (i = 0; i < PATTERN_ARRAY_SIZE / 4; i++)
        block[i] = PATTERN_ARRAY_FILL;
    return block;
}

_kernel_oserror *swi_read_palette(_kernel_swi_regs *r)
{
    return read_palette(r->r[0], (const uint32_t *)r->r[1], (uint32_t *)r->r[2]);
}

_kernel_oserror *swi_return_halftone_intensity(_kernel_swi_regs *r)
{
    r->r[0] = nearest_grey(r->r[0]).index;
    return NULL;
}

_kernel_oserror *swi_return_halftone_table(_kernel_swi_regs *r)
{
    return return_halftone_table(r->r[0], r->r[1], (uint8_t *)r->r[2]);
}

_kernel_oserror *swi_return_colour_pattern_array(_kernel_swi_regs *r)
{
    _kernel_oserror *e;
    const uint32_t *block = pattern_array(&e);

    if (e == NULL)
        r->r[0] = (int)block;
    return e;
}

/* PatternToBuffer: a 32 byte pattern for a colour. */
static _kernel_oserror *pattern_to_buffer(uint32_t colour, uint32_t *buffer)
{
    uint32_t ret;

    return set_gcol_core(colour, -1, (uintptr_t)buffer, &ret);
}

_kernel_oserror *return_colour_pattern(uint32_t colour, uint32_t *out)
{
    return pattern_to_buffer(colour, out);
}

_kernel_oserror *swi_return_colour_pattern(_kernel_swi_regs *r)
{
    return return_colour_pattern(r->r[0], (uint32_t *)r->r[2]);
}

/* 256 patterns blending from colour R0 to colour R1. */
_kernel_oserror *return_colour_pattern_table(uint32_t c0, uint32_t c1, uint32_t *out)
{
    int32_t start[3];
    int32_t step[3];
    int32_t acc[3];
    uint32_t colour;
    uint32_t v;
    _kernel_oserror *e;
    int i;
    int k;

    for (k = 0; k < 3; k++) {
        start[k] = (c0 >> (8 * (k + 1))) & 0xFF;
        step[k] = ((c1 >> (8 * (k + 1))) & 0xFF) - start[k];
        acc[k] = start[k] * 255;
    }
    for (i = 0; i < 256; i++) {
        colour = 0;
        for (k = 0; k < 3; k++) {
            v = (uint32_t)acc[k] + ((uint32_t)acc[k] << 8);
            v = (v >> 16) + ((v >> 15) & 1);
            colour |= v << (8 * (k + 1));
            acc[k] += step[k];
        }
        e = pattern_to_buffer(colour, out + 8 * i);
        if (e != NULL)
            return e;
    }
    return NULL;
}

_kernel_oserror *swi_return_colour_pattern_table(_kernel_swi_regs *r)
{
    return return_colour_pattern_table(r->r[0], r->r[1], (uint32_t *)r->r[2]);
}

/* One pattern for each palette entry of a mode, written 32 bytes apart. */
_kernel_oserror *select_colour_pattern_table(int mode, const uint32_t *palette, uint32_t *out)
{
    PaletteRange range;
    const uint32_t *p;
    _kernel_oserror *e;
    int depth;

    e = mode_to_depth(mode, &depth);
    if (e != NULL)
        return e;
    range = pointers_for_mode(depth, palette);
    for (p = range.start; p != range.end; p++) {
        e = pattern_to_buffer(*p, out);
        if (e != NULL)
            return e;
        out += 8;
    }
    return NULL;
}

_kernel_oserror *swi_select_colour_pattern_table(_kernel_swi_regs *r)
{
    return select_colour_pattern_table(r->r[0], (const uint32_t *)r->r[1], (uint32_t *)r->r[4]);
}
