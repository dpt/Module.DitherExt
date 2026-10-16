/* DitherExtend colour-number SWIs and the palette search code.
   Ported from DitherExt.s: ReturnGCOL, ReturnColourNumber and their ForMode
   and Opp variants, ColourNumberToGCOL, GCOLToColourNumber, ModeToDepth,
   ReadHardwarePalette, FindPaletteType and the Nearest* and SearchPalette*
   routines. The asm passes results in registers (R2 index, FP colour). The
   C returns them as a Nearest. */

#include <stdlib.h>
#include <string.h>
#include "kernel.h"
#include "swis.h"
#include "colour.h"

#define PALETTEV 0x23

static const int palette_words[4] = { 2, 4, 16, 256 };

uint32_t colour_number_to_gcol(uint32_t n)
{
    uint32_t low = n & 0x87;
    uint32_t tint = n & 8;

    n = low | ((n & 0x70) >> 1);
    return tint ? n | 0x40 : n;
}

uint32_t gcol_to_colour_number(uint32_t g)
{
    uint32_t low = g & 0x87;
    uint32_t tint = g & 0x40;

    g = low | ((g & 0x38) << 1);
    return tint ? g | 8 : g;
}

/* Colour24To15 */
Nearest colour_to_15(uint32_t colour)
{
    uint32_t c[3];
    uint32_t e[3];
    Nearest n;
    int i;

    c[0] = RED(colour);
    c[1] = GRN(colour);
    c[2] = BLU(colour);
    for (i = 0; i < 3; i++) {
        c[i] += c[i] << 8;
        c[i] += 0x400;
        c[i] = (c[i] * 31) >> 16;
        e[i] = ((c[i] | c[i] << 5)) >> 3;
    }
    n.index = c[0] | c[1] << 5 | c[2] << 10;
    n.rgb = e[0] << 8 | e[1] << 16 | e[2] << 24;
    return n;
}

Nearest nearest_default_in(const uint32_t *table, uint32_t colour)
{
    const uint32_t top = 0x04040400;
    const uint32_t mask = top | top << 1;
    uint32_t above = mask & (colour >> 4);
    uint32_t key;
    uint32_t entry;
    uint32_t sum;
    uint32_t level;
    uint32_t fp;
    Nearest n;
    int i;

    key = (colour & 0x3800) | ((colour & 0x3C0000) >> 11) | ((colour & 0x38000000) >> 23);
    entry = table[key >> 4];

    sum = 0;
    for (i = 0; i < 3; i++) {
        uint32_t v = mask & entry;

        v |= (v & ~top) << 1;
        sum = v + above;
        if (!(sum & top << 2))
            break;
        entry >>= 2;
        if (i == 2)
            sum = above;
    }
    level = entry & 3;
    sum |= level << 8 | level << 16 | level << 24;
    fp = sum | sum << 4;

    n.index = level;
    if (fp & 1 << 15)
        n.index |= 0x10;
    if (fp & 1 << 14)
        n.index |= 4;
    n.index |= (fp & 0xC00000) >> 17;
    if (fp & 1u << 31)
        n.index |= 0x80;
    if (fp & 1 << 30)
        n.index |= 8;
    n.rgb = fp;
    return n;
}

Nearest nearest_default(uint32_t colour)
{
    return nearest_default_in(default_palette_table, colour);
}

Nearest nearest_grey(uint32_t colour)
{
    uint32_t grey;
    Nearest n;

    grey = LUMA(colour);
    grey += grey >> 8;
    grey >>= 8;
    n.index = grey;
    n.rgb = grey << 8 | grey << 16 | grey << 24;
    return n;
}

/* (x << 12) >> 20 with sign, plus rounding bit 7, then made positive. */
static int32_t cube_error(uint32_t c16)
{
    int32_t e = (int32_t)(c16 << 12) >> 20;

    if (c16 & 0x80)
        e++;
    return e < 0 ? -e : e;
}

/* Pick a 6x6x6 cube colour number. c16[i] is channel * 1285 << 4, so a
   blender can pass mixed channels with four extra bits of precision.
   *grey is set when the result came from the grey table. */
uint32_t cube_pick(const uint8_t *class_table, const uint8_t *grey_table, const uint32_t c16[3], int *grey)
{
    uint32_t lv[3];
    int32_t x[3];
    uint32_t chroma;
    uint32_t sum;
    uint32_t index;
    uint32_t luma;
    int32_t sq;
    int32_t dev;
    int i;

    *grey = 0;
    for (i = 0; i < 3; i++)
        lv[i] = (c16[i] >> 20) + ((c16[i] >> 19) & 1);
    index = lv[0] + 6 * lv[1] + 36 * lv[2];
    if (class_table[index] == 0)
        return index;

    for (i = 0; i < 3; i++)
        x[i] = (c16[i] >> 8) + ((c16[i] >> 7) & 1);
    chroma = 3 * ((uint32_t)(x[0] * x[0]) + x[1] * x[1] + x[2] * x[2]);
    sum = x[0] + x[1] + x[2];
    chroma -= sum * sum;
    if (chroma >= 0x2400000)
        return index;

    if (chroma > 0x800000) {
        sq = 0;
        for (i = 0; i < 3; i++) {
            dev = cube_error(c16[i]);
            sq += dev * dev;
        }
        if (chroma >= (uint32_t)(3 * sq))
            return index;
    }

    luma = 0x4D * (c16[0] >> 4) + 0x97 * (c16[1] >> 4) + 0x1C * (c16[2] >> 4);
    luma += luma << 3;
    sq = luma >> 24;
    sq += (luma >> 23) & 1;
    *grey = 1;
    return grey_table[sq];
}

Nearest nearest_cube(uint32_t colour)
{
    uint32_t c16[3];
    uint32_t lv;
    uint32_t fp;
    int grey;
    Nearest n;
    int i;

    c16[0] = RED(colour);
    c16[1] = GRN(colour);
    c16[2] = BLU(colour);
    for (i = 0; i < 3; i++)
        c16[i] = c16[i] * 1285 << 4;
    n.index = cube_pick(cube_class_table, grey_palette_table, c16, &grey);
    if (grey) {
        n.rgb = ws.palette_cache[n.index];
        return n;
    }
    fp = 0;
    for (i = 0; i < 3; i++) {
        lv = (c16[i] >> 20) + ((c16[i] >> 19) & 1);
        fp |= lv << (8 + 8 * i);
    }
    fp += fp << 1;
    fp += fp << 4;
    n.rgb = fp;
    return n;
}

/* One SearchPalette candidate. The asm adds the terms one at a time and gives
   up as soon as the partial sum is no better than the best so far. The C flag
   from the last compare is visible to callers, so *carry mirrors it. */
static int improves(uint32_t best, int dg, int dr, int db, uint32_t *dist, int *carry)
{
    uint32_t d = 3 * dg * dg;

    *carry = best >= d;
    if (best <= d)
        return 0;
    d += 2 * dr * dr;
    *carry = best >= d;
    if (best <= d)
        return 0;
    d += db * db;
    *carry = best >= d;
    if (best <= d)
        return 0;
    *dist = d;
    return 1;
}

/* SearchPalette: nearest by 2R² + 3G² + B², scanning down in pairs. */
Nearest search_rgb(PaletteRange range, int r, int g, int b)
{
    const uint32_t *p = range.end;
    uint32_t best = 0xFFFFFFFF;
    uint32_t index = 0;
    uint32_t d;
    int carry = 0;
    int k;
    Nearest n;

    while (p != range.start) {
        p -= 2;
        for (k = 0; k < 2; k++) {
            if (improves(best, g - (int)GRN(p[k]), r - (int)RED(p[k]),
                         b - (int)BLU(p[k]), &d, &carry)) {
                best = d;
                index = (p - range.start) + k;
            }
        }
    }
    n.index = index;
    n.rgb = range.start[index];
    n.carry = carry;
    return n;
}

Nearest search_palette(PaletteRange range, uint32_t colour)
{
    return search_rgb(range, RED(colour), GRN(colour), BLU(colour));
}

/* SearchPaletteAlt: the palette entry farthest from the colour. */
uint32_t search_palette_alt(PaletteRange range, uint32_t colour)
{
    const uint32_t *p = range.end;
    uint32_t best = 0;
    uint32_t index = colour >> 2;
    uint32_t d;
    int dr;
    int dg;
    int db;

    do {
        p--;
        dr = RED(colour) - (int)RED(*p);
        dg = GRN(colour) - (int)GRN(*p);
        db = BLU(colour) - (int)BLU(*p);
        d = 2 * dr * dr + 3 * dg * dg + db * db;
        if (best < d) {
            best = d;
            index = p - range.start;
        }
    } while (p != range.start);
    return index;
}

/* The cache is 32768 index bytes then a 4096 byte "searched" bitmap. */
Nearest nearest_custom_in(const Workspace *w, uint32_t colour)
{
    uint32_t c[3];
    uint32_t key;
    uint8_t *cache;
    PaletteRange range;
    Nearest n;
    int i;

    c[0] = RED(colour);
    c[1] = GRN(colour);
    c[2] = BLU(colour);
    for (i = 0; i < 3; i++) {
        c[i] = c[i] * 31;
        c[i] += c[i] << 8;
        c[i] = (c[i] >> 16) + ((c[i] >> 15) & 1);
    }
    range.start = w->palette_cache;
    range.end = w->palette_cache + 256;

    cache = w->palette_block;
    if (cache == NULL) {
        /* The original searches with the 5-bit values here, unscaled. */
        return search_rgb(range, c[0], c[1], c[2]);
    }

    key = c[0] | c[1] << 5 | c[2] << 10;
    if (cache[key] != 0) {
        n.index = cache[key];
        n.rgb = w->palette_cache[n.index];
        return n;
    }
    if (cache[0x8000 + (key >> 3)] & 1 << (key & 7)) {
        n.index = 0;
        n.rgb = w->palette_cache[0];
        return n;
    }
    cache[0x8000 + (key >> 3)] |= 1 << (key & 7);
    for (i = 0; i < 3; i++)
        c[i] = (c[i] | c[i] << 5) >> 2;
    n = search_rgb(range, c[0], c[1], c[2]);
    cache[key] = n.index;
    return n;
}

Nearest nearest_custom(uint32_t colour)
{
    if (ws.palette_block == NULL)
        ws.palette_block = calloc(1, 0x9000);
    return nearest_custom_in(&ws, colour);
}

Nearest nearest_by_type(int type, uint32_t colour)
{
    switch (type) {
    case PALETTE_GREY:   return nearest_grey(colour);
    case PALETTE_CUBE:   return nearest_cube(colour);
    case PALETTE_CUSTOM: return nearest_custom(colour);
    default:             return nearest_default(colour);
    }
}

int find_palette_type(const uint32_t *start, const uint32_t *end)
{
    const uint32_t *p;
    uint32_t w;
    uint32_t b;
    uint32_t low;
    uint32_t high;
    uint32_t sum;
    uint32_t low_at;
    uint32_t high_at;
    int grey;
    int same;

    if (end - start != 256) {
        for (p = start; p != end; p++) {
            b = BLU(*p);
            if ((*p ^ b << 8 ^ b << 16 ^ b << 24) != 0)
                return PALETTE_CUSTOM;
        }
        return PALETTE_GREY;
    }

    grey = 1;
    for (p = start; p != end; p++) {
        w = *p;
        if (RED(w) != GRN(w) || RED(w) != BLU(w)) {
            grey = 0;
            break;
        }
    }
    if (grey)
        return PALETTE_GREY;

    same = 1;
    for (p = start; p != end; p++) {
        if (*p != default_palette_256[p - start]) {
            same = 0;
            break;
        }
    }
    if (same)
        return PALETTE_DEFAULT;

    low = 0x7FFFFFFF;
    high = 0;
    low_at = 0;
    high_at = 0;
    for (p = end; p != start;) {
        p--;
        w = *p;
        sum = 3 * GRN(w) + 2 * RED(w) + BLU(w);
        if (low > sum) {
            low = sum;
            low_at = (p - start) * 4;
        }
        if (high < sum) {
            high = sum;
            high_at = (p - start) * 4;
        }
    }
    return (low_at == 0 && high_at == 0x35C) ? PALETTE_CUBE : PALETTE_CUSTOM;
}

PaletteRange select_pattern_pointers(int depth)
{
    PaletteRange range;

    range.start = ws.palette_cache;
    range.end = ws.palette_cache + palette_words[depth];
    return range;
}

/* ReadHardwarePalette: fill range from PaletteV, else OS_ReadPalette. */
_kernel_oserror *read_hardware_palette(PaletteRange range)
{
    _kernel_swi_regs r;
    _kernel_oserror *e;
    uint32_t *dest = (uint32_t *)range.start;
    uint32_t mask = 0xF0F0F000;
    int entry = 0;

    r.r[0] = 0;
    r.r[1] = 0x10;
    r.r[4] = 1;
    r.r[9] = PALETTEV;
    e = _kernel_swi(OS_CallAVector, &r, &r);
    if (e != NULL)
        return e;
    if (r.r[4] == 0) {
        *dest++ = r.r[2];
        while (dest != range.end) {
            r.r[0] = ++entry;
            r.r[4] = 1;
            e = _kernel_swi(OS_CallAVector, &r, &r);
            if (e != NULL)
                return e;
            *dest++ = r.r[2];
        }
        return NULL;
    }
    for (;;) {
        e = _kernel_swi(OS_ReadPalette, &r, &r);
        if (e != NULL)
            return e;
        r.r[2] &= mask;
        r.r[2] |= (uint32_t)r.r[2] >> 4;
        *dest++ = r.r[2];
        if (dest == range.end)
            return NULL;
        r.r[0]++;
    }
}

/* ModeToDepth: mode -1 means the current mode. */
_kernel_oserror *mode_to_depth(int mode, int *depth)
{
    _kernel_swi_regs r;
    _kernel_oserror *e;
    int carry;

    if (mode == -1) {
        *depth = ws.depth;
        ws.depth_scratch = ws.depth;
        return NULL;
    }
    r.r[0] = mode;
    r.r[1] = 9;
    e = _kernel_swi_c(OS_ReadModeVariable, &r, &r, &carry);
    if (carry)
        return make_error(0x803003, "Bad mode");
    if (e != NULL)
        return e;
    if (r.r[2] != 4) {
        *depth = r.r[2];
        ws.depth_scratch = *depth;
        return NULL;
    }
    r.r[0] = mode;
    r.r[1] = 3;
    e = _kernel_swi_c(OS_ReadModeVariable, &r, &r, &carry);
    if (carry)
        return make_error(0x803003, "Bad mode");
    if (e != NULL)
        return e;
    *depth = r.r[2] == 0xF ? 5 : 4;
    ws.depth_scratch = *depth;
    return NULL;
}

/* SelectPatternPointersForMode: palette 0 is the default for the depth and
   -1 is the workspace palette. Anything else is a caller-supplied palette. */
PaletteRange pointers_for_mode(int depth, const uint32_t *palette)
{
    static const uint32_t *const defaults[4] = {
        default_palette_2, default_palette_4, default_palette_16, default_palette_256
    };
    PaletteRange range;

    if (palette == NULL)
        palette = defaults[depth];
    else if (palette == (const uint32_t *)-1)
        palette = ws.palette_cache;
    range.start = palette;
    range.end = palette + palette_words[depth];
    return range;
}

/* Nearest colour for the current mode. Records the depth in ws.depth_scratch
   for the GCOL conversion. rgb is only meaningful for depths 0 to 4. */
static Nearest current_nearest(uint32_t colour)
{
    int depth = ws.depth;
    Nearest n = { 0, 0, 0 };

    ws.depth_scratch = depth;
    if (depth == 5)
        n.index = colour >> 8;
    else if (depth > 3)
        n = colour_to_15(colour);
    else if (depth == 3)
        n = nearest_by_type(ws.palette_type, colour);
    else
        n = search_palette(select_pattern_pointers(depth), colour);
    return n;
}

/* ReturnColourNumberForMode. The asm picks the path from the flags left by
   SelectPatternPointersForMode (carry only when palette == -1) and then from
   those left by SearchPalette. */
static _kernel_oserror *colour_number_for_mode(uint32_t colour, int mode,
                                               const uint32_t *palette, uint32_t *out)
{
    PaletteRange range;
    Nearest found;
    _kernel_oserror *e;
    int depth;
    int type;

    e = mode_to_depth(mode, &depth);
    if (e != NULL)
        return e;
    if (depth == 5) {
        *out = colour >> 8;
    } else if (depth > 3) {
        *out = colour_to_15(colour).index;
    } else {
        range = pointers_for_mode(depth, palette);
        if (palette != (const uint32_t *)-1) {
            found = search_palette(range, colour);
            if (!found.carry) {
                *out = found.index;
                return NULL;
            }
            /* The asm tests the flags left by SearchPalette here, not those
               of SelectPatternPointersForMode. When carry is set it carries
               on with the palette index in place of the colour. */
            colour = found.index;
        }
        type = find_palette_type(range.start, range.end);
        if (type == PALETTE_CUSTOM)
            *out = search_palette(range, colour).index;
        else
            *out = nearest_by_type(type, colour).index;
    }
    return NULL;
}

static _kernel_oserror *opp_colour_number_for_mode(uint32_t colour, int mode,
                                                   const uint32_t *palette, uint32_t *out)
{
    _kernel_oserror *e;
    int depth;

    e = mode_to_depth(mode, &depth);
    if (e != NULL)
        return e;
    *out = colour;
    if (depth < 4)
        *out = search_palette_alt(pointers_for_mode(depth, palette), colour);
    return NULL;
}

/* ToRGBIfDepth3: GCOL form only in the 256 colour modes. */
static uint32_t gcol_if_depth3(uint32_t n)
{
    return ws.depth_scratch == 3 ? colour_number_to_gcol(n) : n;
}

_kernel_oserror *swi_return_colour_number(_kernel_swi_regs *r)
{
    r->r[0] = current_nearest(r->r[0]).index;
    return NULL;
}

_kernel_oserror *swi_return_gcol(_kernel_swi_regs *r)
{
    r->r[0] = gcol_if_depth3(current_nearest(r->r[0]).index);
    return NULL;
}

_kernel_oserror *swi_return_colour_number_for_mode(_kernel_swi_regs *r)
{
    uint32_t n;
    _kernel_oserror *e = colour_number_for_mode(r->r[0], r->r[1], (const uint32_t *)r->r[2], &n);

    if (e == NULL)
        r->r[0] = n;
    return e;
}

_kernel_oserror *swi_return_gcol_for_mode(_kernel_swi_regs *r)
{
    _kernel_oserror *e = swi_return_colour_number_for_mode(r);

    if (e == NULL)
        r->r[0] = gcol_if_depth3(r->r[0]);
    return e;
}

_kernel_oserror *swi_return_opp_colour_number_for_mode(_kernel_swi_regs *r)
{
    uint32_t n;
    _kernel_oserror *e = opp_colour_number_for_mode(r->r[0], r->r[1], (const uint32_t *)r->r[2], &n);

    if (e == NULL)
        r->r[0] = n;
    return e;
}

_kernel_oserror *swi_return_opp_gcol_for_mode(_kernel_swi_regs *r)
{
    _kernel_oserror *e = swi_return_opp_colour_number_for_mode(r);

    if (e == NULL)
        r->r[0] = gcol_if_depth3(r->r[0]);
    return e;
}

_kernel_oserror *swi_return_opp_colour_number(_kernel_swi_regs *r)
{
    r->r[1] = -1;
    r->r[2] = -1;
    return swi_return_opp_colour_number_for_mode(r);
}

_kernel_oserror *swi_return_opp_gcol(_kernel_swi_regs *r)
{
    r->r[1] = -1;
    r->r[2] = -1;
    return swi_return_opp_gcol_for_mode(r);
}

_kernel_oserror *swi_gcol_to_colour_number(_kernel_swi_regs *r)
{
    r->r[0] = gcol_to_colour_number(r->r[0]);
    return NULL;
}

_kernel_oserror *swi_colour_number_to_gcol(_kernel_swi_regs *r)
{
    r->r[0] = colour_number_to_gcol(r->r[0]);
    return NULL;
}

/* ReturnGCOL for the current mode. Also gives the palette colour the
   asm leaves in FP (only meaningful for depths 0 to 4). */
uint32_t return_gcol(uint32_t colour, uint32_t *rgb)
{
    Nearest n = current_nearest(colour);

    *rgb = n.rgb;
    return gcol_if_depth3(n.index);
}

/* ReturnOppGCOL for the current mode. */
uint32_t return_opp_gcol(uint32_t colour)
{
    _kernel_swi_regs r;

    r.r[0] = colour;
    swi_return_opp_gcol(&r);
    return r.r[0];
}
