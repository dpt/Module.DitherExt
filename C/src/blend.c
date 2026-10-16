/* DitherExtend antialias blenders. Ported from DitherExt.s.
   The original entry points use a register convention (IP = workspace,
   R1 = mask, R2 = source, R3 = destination, R4 = count) and return by popping
   the caller's R0-IP and PC. veneer.s adapts that to these C functions. A mask
   byte is a source weight from 0 to 16. These functions use no static data,
   as external code calls them with an arbitrary static base register. */

#include <string.h>
#include "colour.h"

#define MASK_FULL 0x10101010u

/* (w * s + (16 - w) * d) / 16 rounded half up. */
static uint32_t mix(uint32_t w, uint32_t s, uint32_t d)
{
    uint32_t t = w * s + (16 - w) * d;

    return (t >> 4) + ((t >> 3) & 1);
}

static uint32_t pixel(uint32_t w, uint32_t s, uint32_t d)
{
    if (w == 0)
        return d;
    if (w == 0x10)
        return s;
    return mix(w, s, d);
}

void blend_2bpp(const uint32_t *mask, const uint8_t *src, uint8_t *dst, uint32_t count)
{
    uint32_t m;
    uint32_t s;
    uint32_t d;
    uint32_t out;
    unsigned i;

    do {
        m = *mask++;
        if (m == 0) {
            src++;
            dst++;
        } else if (m == MASK_FULL) {
            *dst++ = *src++;
        } else {
            s = *src++;
            d = *dst;
            out = 0;
            for (i = 0; i < 4; i++)
                out |= pixel((m >> (8 * i)) & 0xFF, (s >> (2 * i)) & 3, (d >> (2 * i)) & 3) << (2 * i);
            *dst++ = (uint8_t)out;
        }
        count -= 4;
    } while (count != 0);
}

/* Fill one entry of the 4bpp blend table. key = weight | source << 4 | dest << 8. */
static uint8_t fill_blend4(const Workspace *w, uint8_t *table, uint32_t key)
{
    PaletteRange range;
    uint32_t weight = key & 0xF;
    uint32_t s = w->palette_cache[(key >> 4) & 0xF];
    uint32_t d = w->palette_cache[(key >> 8) & 0xF];
    uint32_t c[3];
    Nearest n;
    unsigned i;

    range.start = w->palette_cache;
    range.end = w->palette_cache + 16;
    for (i = 0; i < 3; i++)
        c[i] = mix(weight, CHAN(s, i), CHAN(d, i));
    n = search_rgb(range, c[0], c[1], c[2]);
    table[key] = (uint8_t)n.index;
    return (uint8_t)n.index;
}

static uint32_t blend4_pixel(const Workspace *w, uint8_t *table, uint32_t weight, uint32_t s, uint32_t d)
{
    uint32_t key;
    uint32_t v;

    if (weight == 0)
        return d;
    if (weight == 0x10)
        return s;
    key = weight | s << 4 | d << 8;
    v = table[key];
    if (v == 0xFF)
        v = fill_blend4(w, table, key);
    return v;
}

void blend_4bpp(const uint8_t *mask, const uint8_t *src, uint8_t *dst, uint32_t count, const Workspace *w)
{
    uint8_t *table = w->antialias_table;
    uint32_t word;
    uint32_t s;
    uint32_t d;

    do {
        if (((uintptr_t)mask & 3) == 0) {
            memcpy(&word, mask, 4);
            if (word == 0) {
                mask += 4;
                src += 2;
                dst += 2;
                count -= 4;
                continue;
            }
            if (word == MASK_FULL) {
                mask += 4;
                *dst++ = *src++;
                *dst++ = *src++;
                count -= 4;
                continue;
            }
        }
        s = *src++;
        d = *dst;
        *dst++ = (uint8_t)(blend4_pixel(w, table, mask[0], s & 0xF, d & 0xF)
                           | blend4_pixel(w, table, mask[1], s >> 4, d >> 4) << 4);
        mask += 2;
        count -= 2;
    } while (count != 0);
}

enum { GREY8, DEFAULT8, CUBE8, CUSTOM8, RGB16, RGB32 };

/* Mix one channel the way the 16 and 32 bit blenders do, with rounding. */
static uint32_t mix_channels(uint32_t w, uint32_t s, uint32_t d, unsigned bits, unsigned count)
{
    const uint32_t mask = (1u << bits) - 1;
    uint32_t out = 0;
    unsigned i;

    for (i = 0; i < count; i++)
        out |= mix(w, (s >> (bits * i)) & mask, (d >> (bits * i)) & mask) << (bits * i);
    return out;
}

/* Blend one pixel with weight 1..15. s and d are the pixel values read from
   the source and the destination. */
static uint32_t blend_one(const Workspace *ws, int kind, uint32_t w, uint32_t s, uint32_t d)
{
    const uint32_t keep = 0x0F0F0F00;
    uint32_t c[3];
    uint32_t sc;
    uint32_t dc;
    int grey;
    unsigned i;

    /* No switch: the compiler may turn it into a jump table in static data. */
    if (kind == GREY8)
        return mix(w, s, d);
    if (kind == DEFAULT8) {
        sc = keep & (ws->palette_cache[s] >> 4);
        dc = keep & (ws->palette_cache[d] >> 4);
        return nearest_default_in(ws->palette_table, w * sc + (16 - w) * dc).index;
    }
    if (kind == CUBE8) {
        sc = ws->cube_blend[s];
        dc = ws->cube_blend[d];
        for (i = 0; i < 3; i++)
            c[i] = (w * CHAN(sc, i) + (16 - w) * CHAN(dc, i)) * 1285;
        return cube_pick(ws->cube_class, ws->grey_table, c, &grey);
    }
    if (kind == CUSTOM8) {
        sc = ws->palette_cache[s];
        dc = ws->palette_cache[d];
        for (i = 0; i < 3; i++)
            c[i] = ((w * CHAN(sc, i) + (16 - w) * CHAN(dc, i)) >> 4) << (8 + 8 * i);
        return nearest_custom_in(ws, c[0] | c[1] | c[2]).index;
    }
    if (kind == RGB16)
        return mix_channels(w, s, d, 5, 3);
    return mix_channels(w, s, d, 8, 3);
}

/* Shared loop of the 8, 16 and 32 bit blenders. The count is one less than
   the number of pixels. */
static inline __attribute__((always_inline)) void blendn(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count,
                          const Workspace *ws, int kind)
{
    const unsigned size = kind == RGB32 ? 4 : kind == RGB16 ? 2 : 1;
    uint32_t word;
    uint32_t w;
    uint32_t s;
    uint32_t d;

    do {
        if (((uintptr_t)mask & 3) == 0) {
            memcpy(&word, mask, 4);
            if (word == 0 || word == MASK_FULL) {
                if (word != 0)
                    memcpy(dst, src, 4 * size);
                mask += 4;
                src += 4 * size;
                dst += 4 * size;
                count -= 4;
                continue;
            }
        }
        w = *mask++;
        if (w != 0) {
            s = 0;
            d = 0;
            memcpy(&s, src, size);
            memcpy(&d, dst, size);
            if (w != 0x10)
                s = blend_one(ws, kind, w, s, d);
            memcpy(dst, &s, size);
        }
        src += size;
        dst += size;
        count--;
    } while (count >= 0);
}

#define BLENDER(name, kind) \
    void name(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count) \
    { blendn(mask, src, dst, count, NULL, kind); }
#define BLENDER_WS(name, kind) \
    void name(const uint8_t *mask, const uint8_t *src, uint8_t *dst, int32_t count, const Workspace *w) \
    { blendn(mask, src, dst, count, w, kind); }

BLENDER(blend_grey8, GREY8)
BLENDER_WS(blend_default8, DEFAULT8)
BLENDER_WS(blend_cube8, CUBE8)
BLENDER_WS(blend_custom8, CUSTOM8)
BLENDER(blend_16bpp, RGB16)
BLENDER(blend_32bpp, RGB32)
