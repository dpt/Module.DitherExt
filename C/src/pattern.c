/* Pattern builder core: SetGCOLCore and the helpers it reaches in
   DitherExt.s. A pattern is two 32 bit rows (even and odd scan lines)
   that are rotated by the halftone origin and stored either as a 32 byte
   buffer or as 16 words in the pattern area. */

#include "dither.h"
#include "colour.h"
#include "pattern.h"

#ifdef HOST_TEST
extern uint32_t *host_pattern;
#define PATTERN_AREA() host_pattern
#else
#define PATTERN_AREA() ((uint32_t *)(uintptr_t)ws.pattern)
#endif

#define FLAG_BUFFER_HALF    0x80u
#define FLAGS_SOLID         0x10000u
#define FLAGS_BUILDER_A     0x4u
#define FLAGS_BUILDER_B     0x20000u

static const uint32_t dither_mask_table[8][4] = {
    {0xFFFFFFFF, 0x00000000, 0x00000000, 0xFFFFFFFF},
    {0x00000000, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF},
    {0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF},
    {0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000},
    {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000},
    {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF},
    {0x00000000, 0x00000000, 0x00000000, 0x00000000},
    {0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF},
};

static uint32_t ror(uint32_t v, unsigned n)
{
    n &= 31;
    return n ? (v >> n) | (v << (32 - n)) : v;
}

/* SetGCOLCore_8: rotate by the origin, then store. */
static void finish(uint32_t even, uint32_t odd, int32_t flags, uintptr_t arg)
{
    const uint32_t *m;
    uint32_t *out;
    uint32_t t;
    uint32_t e;
    uint32_t o;
    uint32_t row[4];
    unsigned rot;
    int i;

    rot = 32 - (ws.origin_x & 0x1F);
    if (ws.origin_y & 1) {
        t = even;
        even = odd;
        odd = t;
    }
    e = ror(even, rot);
    o = ror(odd, rot);
    if (flags < 0) {
        out = (uint32_t *)arg;
        row[0] = e;
        row[1] = o;
        row[2] = e;
        row[3] = o;
    } else {
        m = dither_mask_table[arg & 7];
        out = PATTERN_AREA();
        if (flags & FLAG_BUFFER_HALF)
            out += 16;
        row[0] = m[1] ^ (m[0] | e);
        row[1] = m[3] ^ (m[2] | e);
        row[2] = m[1] ^ (m[0] | o);
        row[3] = m[3] ^ (m[2] | o);
    }
    for (i = 0; i < (flags < 0 ? 8 : 16); i++)
        out[i] = row[i & 3];
}

/* SetOppGCOL_2: one colour everywhere. */
static void solid_pattern(uint32_t c, int32_t flags, uintptr_t arg)
{
    int depth = ws.depth;
    uint32_t row;

    if (depth == 5) {
        row = c;
    } else {
        if (depth == 3)
            c = gcol_to_colour_number(c);
        if (depth < 1)
            c |= c << 1;
        if (depth <= 1)
            c |= c << 2;
        if (depth < 3)
            c |= c << 4;
        if (depth <= 3)
            c |= c << 8;
        row = c | (c << 16);
    }
    finish(row, row, flags, arg);
}

/* SetOppGCOL_1: the colour is also the SWI result. */
static _kernel_oserror *solid(uint32_t c, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    *ret = c;
    solid_pattern(c, flags, arg);
    return NULL;
}

/* SetGCOLCore_6 and _7: two colours as a checkerboard. */
static void pair_pattern(uint32_t n, uint32_t o, int32_t flags, uintptr_t arg)
{
    int d = ws.depth;
    uint32_t x;
    uint32_t y;
    uint32_t t;
    uint32_t row;

    if (n == o) {
        solid_pattern(n, flags, arg);
        return;
    }
    if (d == 3) {
        x = gcol_to_colour_number(o);
        y = gcol_to_colour_number(n);
    } else {
        x = n;
        y = o;
    }
    if (x > y) {
        t = x;
        x = y;
        y = t;
    }
    if (d < 1) {
        x |= y << 1;
        x |= x << 2;
    } else if (d == 1) {
        x |= y << 2;
    }
    if (d < 2)
        x |= x << 4;
    else if (d == 2)
        x |= y << 4;
    if (d <= 2)
        x |= x << 8;
    else
        x |= y << 8;
    row = x | (x << 16);
    finish(row, ror(row, d < 1 ? 1 : d == 1 ? 2 : d == 2 ? 4 : 8), flags, arg);
}

/* SetGCOLCore_11 to _13 and the depth 3 tail of _10: three colours. */
static void triple_pattern(uint32_t c1, uint32_t c2, uint32_t c3, int32_t flags, uintptr_t arg)
{
    int d = ws.depth;
    unsigned k;
    unsigned s;
    uint32_t lo;
    uint32_t hi;
    uint32_t t;
    uint32_t x;
    uint32_t y;

    if (d == 3) {
        c1 = gcol_to_colour_number(c1);
        c2 = gcol_to_colour_number(c2);
        c3 = gcol_to_colour_number(c3);
    }
    lo = c2;
    hi = c3;
    if (lo > hi) {
        t = lo;
        lo = hi;
        hi = t;
    }
    k = 1u << d;
    x = c1 | (lo << k);
    y = hi | (c1 << k);
    if (ws.xeig == ws.yeig) {
        x |= x << (2 * k);
        y |= y << (2 * k);
    } else {
        x |= y << (2 * k);
        y = ror(x, 2 * k);
    }
    for (s = 4 * k; s < 32; s *= 2) {
        x |= ror(x, s);
        y |= ror(y, s);
    }
    finish(x, y, flags, arg);
}

/* ConvertColourForDepth. Components may be out of range. */
static uint32_t convert_for_depth(int r, int g, int b, uint32_t *rgb)
{
    Nearest n;
    int depth = ws.depth;

    ws.depth_scratch = depth;
    if (depth < 3) {
        n = search_rgb(select_pattern_pointers(depth), r, g, b);
        *rgb = n.rgb;
        return n.index;
    }
    r = r < 0 ? 0 : r > 255 ? 255 : r;
    g = g < 0 ? 0 : g > 255 ? 255 : g;
    b = b < 0 ? 0 : b > 255 ? 255 : b;
    if (depth == 4) {
        n = colour_to_15((uint32_t)r << 8 | (uint32_t)g << 16 | (uint32_t)b << 24);
        *rgb = n.rgb;
        return n.index;
    }
    n = nearest_by_type(ws.palette_type, (uint32_t)r << 8 | (uint32_t)g << 16 | (uint32_t)b << 24);
    *rgb = n.rgb;
    return colour_number_to_gcol(n.index);
}

/* Weighted error of one channel: a * wanted - b * got. */
#define ERR(ch, got, a, b) ((a) * (int)ch(colour) - (b) * (int)ch(got))

/* SetGCOLCore_10: error diffusion over three colours. */
static _kernel_oserror *diffuse3(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t rgb1;
    uint32_t rgb2;
    uint32_t rgb3;
    uint32_t c1;
    uint32_t c2;
    uint32_t c3;
    int er;
    int eg;
    int eb;

    c1 = return_gcol(colour, &rgb1);
    *ret = c1;
    er = ERR(RED, rgb1, 3, 2);
    eg = ERR(GRN, rgb1, 3, 2);
    eb = ERR(BLU, rgb1, 3, 2);
    c2 = convert_for_depth(er, eg, eb, &rgb2);
    er += ERR(RED, rgb2, 1, 1);
    eg += ERR(GRN, rgb2, 1, 1);
    eb += ERR(BLU, rgb2, 1, 1);
    c3 = convert_for_depth(er, eg, eb, &rgb3);
    if (c3 == c2)
        pair_pattern(c3, c1, flags, arg);
    else
        triple_pattern(c1, c2, c3, flags, arg);
    return NULL;
}

/* SetGCOLCore_5: error diffusion over two colours. */
static _kernel_oserror *diffuse2(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t rgb1;
    uint32_t rgb2;
    uint32_t c1;
    uint32_t c2;

    c1 = return_gcol(colour, &rgb1);
    *ret = c1;
    c2 = convert_for_depth(ERR(RED, rgb1, 2, 1), ERR(GRN, rgb1, 2, 1), ERR(BLU, rgb1, 2, 1), &rgb2);
    pair_pattern(c2, c1, flags, arg);
    return NULL;
}

/* ---- Builders that finish through FinishPattern: four rows ---- */

typedef struct {
    uint32_t w[4];
} Rows;

static uint32_t mix(uint32_t lo, uint32_t hi, uint32_t mask)
{
    return (lo & ~mask) | (hi & mask);
}

static uint32_t rep8(uint32_t b)
{
    b |= b << 8;
    return b | (b << 16);
}

static uint32_t rep16(uint32_t h)
{
    return (h & 0xFFFF) | (h << 16);
}

/* The asm's "MOVS x, LSR #n; ADDHS x, x, #1": shift with rounding. */
static uint32_t round_shift(uint32_t v, unsigned n)
{
    return (v >> n) + ((v >> (n - 1)) & 1);
}

#define RET_FINISH 0xFFu    /* the asm leaves a pushed 0xFF in R0 here */

/* FinishPattern */
static _kernel_oserror *finish_rows(Rows r, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    const uint32_t *m;
    uint32_t *out;
    uint32_t t;
    uint32_t a;
    uint32_t b;
    unsigned rot;
    unsigned y;
    int i;

    *ret = RET_FINISH;
    rot = 32 - (ws.origin_x & 0x1F);
    for (i = 0; i < 4; i++)
        r.w[i] = ror(r.w[i], rot);
    y = ws.origin_y & 3;
    if (y & 2) {
        t = r.w[0];
        r.w[0] = r.w[2];
        r.w[2] = t;
        t = r.w[1];
        r.w[1] = r.w[3];
        r.w[3] = t;
    }
    if (y == 1 || y == 3) {
        t = r.w[3];
        r.w[3] = r.w[2];
        r.w[2] = r.w[1];
        r.w[1] = r.w[0];
        r.w[0] = t;
    }
    if (flags < 0) {
        out = (uint32_t *)arg;
        for (i = 0; i < 8; i++)
            out[i] = r.w[i & 3];
        return NULL;
    }
    m = dither_mask_table[arg & 7];
    out = PATTERN_AREA();
    if (flags & FLAG_BUFFER_HALF)
        out += 16;
    for (i = 0; i < 4; i++) {
        a = m[1] ^ (m[0] | r.w[i]);
        b = m[3] ^ (m[2] | r.w[i]);
        out[2 * i] = out[8 + 2 * i] = a;
        out[2 * i + 1] = out[8 + 2 * i + 1] = b;
    }
    return NULL;
}

/* SelectPatternBuilder_9: blend two colour words through four mask words. */
static Rows blend(uint32_t lo, uint32_t hi, const uint32_t *m)
{
    Rows r;
    int i;

    for (i = 0; i < 4; i++)
        r.w[i] = mix(lo, hi, m[i]);
    return r;
}

/* SelectPatternBuilder_8: pick a mask row and blend. */
static Rows blend_row(const uint32_t *table, unsigned row, uint32_t lo, uint32_t hi)
{
    return blend(rep8(lo), rep8(hi), table + 4 * row);
}

/* Pairs of 16 bit masks (Pattern8bppMasks) widened to four words. */
static void masks_from_pairs(const uint32_t *p, uint32_t m[4])
{
    m[0] = rep16(p[0]);
    m[1] = rep16(p[0] >> 16);
    m[2] = rep16(p[1]);
    m[3] = rep16(p[1] >> 16);
}

/* BuildFromPalette: nearest grey entries either side of a grey level. */
typedef struct {
    int32_t lo_off;
    int32_t hi_off;
    int32_t lo_level;
    int32_t hi_level;
} Bounds;

static Bounds grey_bounds(PaletteRange range, int32_t target)
{
    const uint32_t *p;
    Bounds b;
    Bounds f;
    int32_t level;
    int32_t luma;
    int32_t min_luma;
    int32_t max_luma;
    int32_t off;

    b.lo_off = -1;
    b.hi_off = -1;
    b.lo_level = INT32_MIN;
    b.hi_level = INT32_MAX;
    for (p = range.end; p != range.start;) {
        p--;
        level = RED(*p);
        if (level != (int32_t)GRN(*p) || level != (int32_t)BLU(*p))
            continue;
        off = (int32_t)(p - range.start) * 4;
        if (level <= target && b.lo_level <= level) {
            b.lo_level = level;
            b.lo_off = off;
        }
        if (level >= target && b.hi_level >= level) {
            b.hi_level = level;
            b.hi_off = off;
        }
    }
    if ((b.lo_off | b.hi_off) >= 0)
        return b;
    f.lo_off = -1;
    f.hi_off = -1;
    min_luma = INT32_MAX;
    max_luma = INT32_MIN;
    for (p = range.end; p != range.start;) {
        p--;
        luma = 3 * (int32_t)GRN(*p) + 2 * (int32_t)RED(*p)
             + (int32_t)BLU(*p);
        off = (int32_t)(p - range.start) * 4;
        if (min_luma > luma) {
            min_luma = luma;
            f.lo_off = off;
        }
        if (max_luma < luma) {
            max_luma = luma;
            f.hi_off = off;
        }
    }
    if (b.lo_off >= 0) {
        f.lo_off = b.lo_off;
        f.lo_level = b.lo_level;
    } else {
        f.lo_level = 0;
    }
    if (b.hi_off >= 0) {
        f.hi_off = b.hi_off;
        f.hi_level = b.hi_level;
    } else {
        f.hi_level = 0xFF;
    }
    return f;
}

/* BuildFromPalette_1 onwards: target is a grey level 0 to 255. */
static _kernel_oserror *build_from_palette(PaletteRange range, uint32_t target,
                                           int32_t flags, uintptr_t arg, uint32_t *ret)
{
    Bounds b;
    uint32_t lo;
    uint32_t hi;
    uint32_t t;
    uint32_t span;
    uint32_t w;
    uint32_t m[4];
    const uint32_t *tab;
    int square = ws.xeig == ws.yeig;
    int depth = ws.depth_scratch;
    int i;

    b = grey_bounds(range, (int32_t)target);
    lo = (uint32_t)b.lo_off >> 2;
    hi = (uint32_t)b.hi_off >> 2;
    span = (uint32_t)(b.hi_level - b.lo_level);
    t = target - (uint32_t)b.lo_level;
    if (span != 1)
        t *= pattern_scale_table[span & 0xFF];
    switch (depth) {
    case 0:
        lo = lo ? 0xFFFFFFFF : 0;
        hi = hi ? 0xFFFFFFFF : 0;
        tab = square ? pattern_word_table : pattern_word_table2;
        w = tab[round_shift(t, square ? 12 : 13)];
        for (i = 0; i < 4; i++)
            m[i] = rep8((w >> (8 * i)) & 0xFF);
        return finish_rows(blend(lo, hi, m), flags, arg, ret);
    case 1:
        lo |= lo << 2;
        lo |= lo << 4;
        hi |= hi << 2;
        hi |= hi << 4;
        lo = rep8(lo);
        hi = rep8(hi);
        tab = square ? pattern_bit_table : pattern_bit_table2;
        w = tab[round_shift(t, square ? 12 : 13)];
        for (i = 0; i < 4; i++)
            m[i] = rep8((w >> (8 * i)) & 0xFF);
        return finish_rows(blend(lo, hi, m), flags, arg, ret);
    case 2:
        lo |= lo << 4;
        hi |= hi << 4;
        lo = rep8(lo);
        hi = rep8(hi);
        if (square) {
            masks_from_pairs(pattern8bpp_masks + 2 * round_shift(t, 12), m);
        } else {
            tab = pattern8bpp_masks2 + 4 * round_shift(t, 11);
            for (i = 0; i < 4; i++)
                m[i] = tab[i];
        }
        return finish_rows(blend(lo, hi, m), flags, arg, ret);
    default:
        if (square)
            return finish_rows(blend_row(pattern_row_xor_table, round_shift(t, 12), lo, hi),
                               flags, arg, ret);
        return finish_rows(blend_row(pattern_mask_table2, round_shift(t, 13), lo, hi),
                           flags, arg, ret);
    }
}

/* SelectPatternBuilder_1 for depth 3 */
static _kernel_oserror *select_depth3(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t l = LUMA(colour);
    int square = ws.xeig == ws.yeig;
    uint32_t lo;
    uint32_t row;
    const uint8_t *grey;

    static const uint8_t level_pairs[16] = {
        0x00, 0x01, 0x02, 0x03, 0x2C, 0x2D, 0x2E, 0x2F,
        0xD0, 0xD1, 0xD2, 0xD3, 0xFC, 0xFD, 0xFE, 0xFF,
    };
    const uint32_t *rows = square ? pattern_row_xor_table : pattern_mask_table2;
    unsigned sh = square ? 12 : 13;
    unsigned idx_sh = square ? 4 : 3;
    uint32_t mask = square ? 0xF : 7;

    /* The asm jump tables treat types -1 and 0 alike. */
    switch (ws.palette_type < 0 ? 0 : ws.palette_type) {
    case PALETTE_DEFAULT:
        l += l >> 8;
        l = l * 15;
        row = round_shift(l, sh);
        return finish_rows(blend_row(rows, row & mask, level_pairs[row >> idx_sh],
                                     level_pairs[(row >> idx_sh) + 1]), flags, arg, ret);
    case PALETTE_GREY:
        l += l >> 8;
        l = l * 255;
        row = round_shift(l, sh);
        lo = row >> idx_sh;
        return finish_rows(blend_row(rows, row & mask, lo, lo + 1), flags, arg, ret);
    case PALETTE_CUBE:
        l += l >> 8;
        l += l << 2;
        l += l << 3;
        grey = grey_palette_table;
        row = round_shift(l, sh);
        return finish_rows(blend_row(rows, row & mask, grey[row >> idx_sh],
                                     grey[(row >> idx_sh) + 1]), flags, arg, ret);
    default:
        return build_from_palette(select_pattern_pointers(3), l >> 8, flags, arg, ret);
    }
}

/* SelectPatternBuilder */
static _kernel_oserror *select_pattern_builder(uint32_t colour, int32_t flags, uintptr_t arg,
                                               uint32_t *ret)
{
    int depth = ws.depth;

    ws.depth_scratch = depth;
    if (depth != 3)
        return build_from_palette(select_pattern_pointers(depth), LUMA(colour) >> 8,
                                  flags, arg, ret);
    return select_depth3(colour, flags, arg, ret);
}

/* Three bit planes of 4 levels each, combined as bit 0, 1 and 2. */
static Rows planes(const uint32_t *table, uint32_t l0, uint32_t l1, uint32_t l2)
{
    Rows r;
    int i;

    for (i = 0; i < 4; i++)
        r.w[i] = table[4 * l0 + i] | (table[4 * l1 + i] << 1) | (table[4 * l2 + i] << 2);
    return r;
}

/* RotatePattern: map 3 bit values through the halftone table. */
static uint32_t rotate_pattern(uint32_t v)
{
    const uint8_t *t = (const uint8_t *)ws.table;
    uint32_t x;

    x = t[v & 7] | (t[(v >> 8) & 7] << 4) | (t[(v >> 16) & 7] << 8) | (t[(v >> 24) & 7] << 12);
    return x | (x << 16);
}

/* RemapNibbles: map each nibble through the halftone table. */
static uint32_t remap_nibbles(uint32_t v)
{
    const uint8_t *t = (const uint8_t *)ws.table;
    uint32_t x = 0;
    int k;

    for (k = 0; k < 8; k++)
        x |= (uint32_t)t[(v >> (4 * k)) & 0xF] << (4 * k);
    return x;
}

/* Build4bpp (square pixels). r, g, b are the colour bytes doubled up. */
static _kernel_oserror *build_4bpp(uint32_t r, uint32_t g, uint32_t b, int32_t flags,
                                   uintptr_t arg, uint32_t *ret)
{
    PaletteRange range;
    Bounds bd;
    Rows rows;
    Rows rot;
    uint32_t grey;
    uint32_t lr;
    uint32_t lg;
    uint32_t lb;
    uint32_t top;
    uint32_t sum;
    uint32_t inten;
    uint32_t t;
    uint32_t lo;
    uint32_t hi;
    uint32_t m[4];
    uint32_t keep[4];
    int32_t s;
    int i;

    grey = r;
    if (grey > g)
        grey = g;
    if (grey > b)
        grey = b;
    r -= grey;
    g -= grey;
    b -= grey;
    lr = round_shift(r, 12);
    lg = round_shift(g, 12);
    lb = round_shift(b, 12);
    r -= lr << 12;
    g -= lg << 12;
    b -= lb << 12;
    s = (int32_t)(g + (g << 1) + (r << 1) + b);
    s += s >> 2;
    s += s >> 4;
    s += s >> 8;
    sum = (uint32_t)(s >> 3) + ((uint32_t)(s >> 2) & 1) + grey;
    inten = (int32_t)sum < 0 ? 0 : sum;
    top = lr;
    if (top < lg)
        top = lg;
    if (top < lb)
        top = lb;
    if (top > 0xF) {
        inten = 0x100000;
    } else {
        if (top == 0xF)
            inten <<= 4;
        if (top < 0xF) {
            inten *= pattern_scale_table[16 - top];
            inten = round_shift(inten, 12);
        }
    }
    t = round_shift(inten, 8);
    if (t > 0xFF)
        t = 0xFF;
    range.start = ws.palette_cache;
    range.end = ws.palette_cache + 16;
    bd = grey_bounds(range, (int32_t)t);
    lo = (uint32_t)bd.lo_off >> 2;
    hi = (uint32_t)bd.hi_off >> 2;
    t -= (uint32_t)bd.lo_level;
    t *= pattern_scale_table[(uint32_t)(bd.hi_level - bd.lo_level) & 0xFF];
    t *= 16 - top;
    t = (t >> 4) + ((t >> 3) & 1) + (top << 12);
    lo |= lo << 4;
    lo = rep8(lo);
    hi |= hi << 4;
    hi = rep8(hi);
    t >>= 12;
    if (t > 0x10)
        t = 0x10;
    masks_from_pairs(pattern8bpp_masks + 2 * t, m);
    rows = blend(lo, hi, m);
    for (i = 0; i < 4; i++)
        ws.reserved_6c[i] = rows.w[i];
    rows = planes(pattern_select_table, lr, lg, lb);
    for (i = 0; i < 4; i++)
        rot.w[i] = rotate_pattern(rows.w[i]);
    masks_from_pairs(pattern8bpp_masks + 2 * top, m);
    for (i = 0; i < 4; i++)
        keep[i] = ws.reserved_6c[i];
    for (i = 0; i < 4; i++)
        rows.w[i] = mix(keep[i], rot.w[i], m[i]);
    return finish_rows(rows, flags, arg, ret);
}

/* SetGCOLCore_14 and _15: build the 8 entry halftone table once. */
static void build_halftone_table(void)
{
    static const uint32_t colours[8] = {
        0x00000000, 0x0000FF00, 0x00FF0000, 0x00FFFF00,
        0xFF000000, 0xFF00FF00, 0xFFFF0000, 0xFFFFFF00,
    };
    PaletteRange range;
    uint8_t *t = (uint8_t *)ws.table;
    int i;

    if (ws.table_built)
        return;
    range = select_pattern_pointers(ws.depth);
    for (i = 0; i < 8; i++)
        t[i] = (uint8_t)search_palette(range, colours[i]).index;
    ws.table_built = 0xFFFFFFFF;
}

/* SetGCOLCore_14 to _16 and RotatePattern_1: 4bpp halftone patterns. */
static _kernel_oserror *build_halftone(uint32_t colour, int32_t flags, uintptr_t arg,
                                       uint32_t *ret)
{
    Rows rows;
    uint32_t r = RED(colour);
    uint32_t g = GRN(colour);
    uint32_t b = BLU(colour);
    int i;

    build_halftone_table();
    r |= r << 8;
    g |= g << 8;
    b |= b << 8;
    if (ws.xeig != ws.yeig) {
        rows = planes(pattern16_masks, round_shift(r, 11), round_shift(g, 11), round_shift(b, 11));
        for (i = 0; i < 4; i++)
            rows.w[i] = remap_nibbles(rows.w[i]);
        return finish_rows(rows, flags, arg, ret);
    }
    if (ws.flags & 0x40000)
        return build_4bpp(r, g, b, flags, arg, ret);
    rows = planes(pattern_select_table, round_shift(r, 12), round_shift(g, 12), round_shift(b, 12));
    for (i = 0; i < 4; i++)
        rows.w[i] = rotate_pattern(rows.w[i]);
    return finish_rows(rows, flags, arg, ret);
}

/* One colour channel of BuildDepthPattern_1/_3: the two neighbouring levels,
   each a pair of colour bits, blended through a mask row. */
static void channel(uint32_t level, int square, uint32_t if_n, uint32_t if_c, uint32_t out[4])
{
    const uint32_t *tab = square ? pattern_row_xor_table : pattern_mask_table2;
    unsigned sh = square ? 27 : 28;
    uint32_t add = square ? 0x10 : 8;
    uint32_t lo;
    uint32_t hi;
    uint32_t v;
    int i;

    if (!square)
        level >>= 1;
    v = level;
    lo = (((v << sh) >> 31) ? if_n : 0) | (((v >> (32 - sh)) & 1) ? if_c : 0);
    v = level + add;
    hi = (((v << sh) >> 31) ? if_n : 0) | (((v >> (32 - sh)) & 1) ? if_c : 0);
    for (i = 0; i < 4; i++)
        out[i] = mix(rep8(lo), rep8(hi), tab[4 * (level & (square ? 0xF : 7)) + i]);
}

/* BuildDepthPattern_1 and _3: colour cube palette in 256 colour modes. */
static _kernel_oserror *depth_cube(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    int square = ws.xeig == ws.yeig;
    uint32_t cr[4];
    uint32_t cg[4];
    uint32_t cb[4];
    Rows rows;
    int i;

    channel(pattern_level_table[RED(colour)], square, 7, 0x13, cr);
    channel(pattern_level_table[GRN(colour)], square, 0x23, 0x43, cg);
    channel(pattern_level_table[BLU(colour)], square, 0xB, 0x83, cb);
    for (i = 0; i < 4; i++)
        rows.w[i] = cr[i] | cg[i] | cb[i];
    return finish_rows(rows, flags, arg, ret);
}

/* One channel of BuildDepthPattern_4 and _6: levels 0 to 5 scaled by weight. */
static void weighted(uint32_t level, int square, uint32_t weight, uint32_t out[4])
{
    const uint32_t *tab = square ? pattern_row_xor_table : pattern_mask_table2;
    unsigned sh = square ? 4 : 3;
    uint32_t lo = (level >> sh) * weight;
    uint32_t hi = ((level + (square ? 16 : 8)) >> sh) * weight;
    int i;

    for (i = 0; i < 4; i++)
        out[i] = mix(rep8(lo), rep8(hi), tab[4 * (level & (square ? 0xF : 7)) + i]);
}

static uint32_t level6(uint32_t v, int square)
{
    return round_shift((v | (v << 8)) * 5, square ? 12 : 13);
}

/* BuildDepthPattern_4 and _6: 6x6x6 colour numbers. */
static _kernel_oserror *depth_grey(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    int square = ws.xeig == ws.yeig;
    uint32_t cr[4];
    uint32_t cg[4];
    uint32_t cb[4];
    Rows rows;
    int i;

    weighted(level6(RED(colour), square), square, 1, cr);
    weighted(level6(GRN(colour), square), square, 6, cg);
    weighted(level6(BLU(colour), square), square, 36, cb);
    for (i = 0; i < 4; i++)
        rows.w[i] = cr[i] + cg[i] + cb[i];
    return finish_rows(rows, flags, arg, ret);
}

/* BuildDepthPattern */
static _kernel_oserror *build_depth_pattern(uint32_t colour, int32_t flags, uintptr_t arg,
                                            uint32_t *ret)
{
    ws.depth_scratch = ws.depth;
    switch (ws.palette_type) {
    case PALETTE_GREY:
        return select_depth3(colour, flags, arg, ret);
    case PALETTE_CUBE:
        return depth_grey(colour, flags, arg, ret);
    default:
        return depth_cube(colour, flags, arg, ret);
    }
}

/* Build16bpp */
static _kernel_oserror *build_16bpp(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t comp[3];
    uint32_t lo;
    uint32_t hi;
    uint32_t m[2];
    uint32_t acc[2];
    Rows rows;
    int shift[3] = {0, 5, 10};
    int i;
    int k;

    ws.depth_scratch = ws.depth;
    comp[0] = RED(colour);
    comp[1] = GRN(colour);
    comp[2] = BLU(colour);
    acc[0] = 0;
    acc[1] = 0;
    for (k = 0; k < 3; k++) {
        comp[k] |= comp[k] << 8;
        comp[k] = round_shift(comp[k] * 31, 14);
        lo = rep16((comp[k] >> 2) << shift[k]);
        hi = rep16(((comp[k] + 4) >> 2) << shift[k]);
        m[0] = pattern16bpp_masks[2 * (comp[k] & 3)];
        m[1] = pattern16bpp_masks[2 * (comp[k] & 3) + 1];
        for (i = 0; i < 2; i++)
            acc[i] |= mix(lo, hi, m[i]);
    }
    rows.w[0] = rows.w[2] = acc[0];
    rows.w[1] = rows.w[3] = acc[1];
    return finish_rows(rows, flags, arg, ret);
}

/* BuildFromPalette_14: the screen colour for CacheScreen is the grey level. */
static _kernel_oserror *halftone_key(uint32_t colour, int32_t flags, uint32_t *ret)
{
    uint32_t grey;

    *ret = colour;
    if (flags & FLAG_BUFFER_HALF)
        return NULL;
    grey = LUMA(colour);
    grey += grey >> 8;
    grey >>= 8;
    *ret = grey;
    if (ws.halftone[6] != grey) {
        ws.halftone[6] = grey;
        ws.halftone[7] = 0;
    }
    return NULL;
}

static _kernel_oserror *solid_gcol(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t rgb;

    return solid(return_gcol(colour, &rgb), flags, arg, ret);
}

_kernel_oserror *set_opp_gcol_core(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    return solid(return_opp_gcol(colour), flags, arg, ret);
}

_kernel_oserror *set_gcol_core(uint32_t colour, int32_t flags, uintptr_t arg, uint32_t *ret)
{
    uint32_t fl;
    int depth;
    int type;

    depth = ws.depth;
    if (ws.halftone[0] != 0)
        return halftone_key(colour, flags, ret);
    fl = ws.flags;
    if (fl & FLAGS_SOLID)
        return solid_gcol(colour, flags, arg, ret);
    if (depth == 5)
        return solid(colour >> 8, flags, arg, ret);
    if (depth == 4) {
        if (fl != 0)
            return build_16bpp(colour, flags, arg, ret);
        return solid_gcol(colour, flags, arg, ret);
    }
    type = ws.palette_type;
    if (type == PALETTE_GREY && depth == 3)
        return solid_gcol(colour, flags, arg, ret);
    if ((fl & (FLAGS_BUILDER_A | FLAGS_BUILDER_B)) || (fl != 0 && type == PALETTE_GREY))
        return select_pattern_builder(colour, flags, arg, ret);
    if (type == PALETTE_CUSTOM && depth == 3)
        return diffuse3(colour, flags, arg, ret);
    if (depth == 2 || depth == 3) {
        fl ^= 8;
        if (!(fl & 8))
            return depth == 2 ? build_halftone(colour, flags, arg, ret)
                             : build_depth_pattern(colour, flags, arg, ret);
    }
    if (!(fl & 3))
        return solid_gcol(colour, flags, arg, ret);
    if (fl & 2)
        return diffuse3(colour, flags, arg, ret);
    return diffuse2(colour, flags, arg, ret);
}

_kernel_oserror *swi_set_gcol(_kernel_swi_regs *r)
{
    uint32_t ret = r->r[0];
    _kernel_oserror *e = set_gcol_core(r->r[0], r->r[3] & FLAG_BUFFER_HALF, r->r[4], &ret);

    r->r[0] = ret;
    return e;
}

_kernel_oserror *swi_set_opp_gcol(_kernel_swi_regs *r)
{
    uint32_t ret = r->r[0];
    _kernel_oserror *e = set_opp_gcol_core(r->r[0], r->r[3] & FLAG_BUFFER_HALF, r->r[4], &ret);

    r->r[0] = ret;
    return e;
}
