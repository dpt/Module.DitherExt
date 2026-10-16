/* DitherExtend CacheScreen. Ported from DitherExt.s. */

#include "colour.h"

#ifdef HOST_TEST
extern const uint8_t *host_thresholds;
#define THRESHOLDS() host_thresholds
#else
#define THRESHOLDS() ((const uint8_t *)(uintptr_t)ws.halftone[0])
#endif

#define BITMAP_WORDS 64u

/* Pack the threshold bytes for one row into words of 32/bpp pixels each.
   A pixel is set to colour 'low' when the key is at most its threshold and
   to colour 'high' otherwise. A narrow row is repeated to fill its last
   word. Returns the number of words written, or 0 on overflow. */
static uint32_t pack_row(int32_t key, const uint8_t *src, uint32_t width, unsigned bpp,
                         uint32_t low, uint32_t high, uint32_t *out, uint32_t room,
                         uint32_t *pos)
{
    uint32_t ppw = 32 / bpp;
    uint32_t words = 0;
    uint32_t first = 0;
    uint32_t w = 0;
    uint32_t n = width;
    uint32_t i;

    *pos = 0;
    while (n >= ppw) {
        for (i = 0; i < ppw; i++)
            w = (*src++ >= key ? low : high) | (w >> bpp);
        if (words >= room)
            return 0;
        if (words == 0)
            first = w;
        out[words++] = w;
        n -= ppw;
        if (n == 0)
            return words;
    }
    n = width & (ppw - 1);
    for (i = 0; i < n; i++)
        w = (*src++ >= key ? low : high) | (w >> bpp);
    w >>= 32 - n * bpp;
    if (words == 0)
        first = w;
    *pos = n * bpp;
    do {
        w |= first << *pos;
        *pos += width * bpp;
    } while (*pos < 32);
    if (words >= room)
        return 0;
    out[words++] = w;
    return words;
}

_kernel_oserror *cache_screen(uint32_t key, uint32_t *bitmap, uint32_t *length)
{
    const uint8_t *src;
    uint32_t width;
    uint32_t height;
    uint32_t low;
    uint32_t high;
    uint32_t pos;
    uint32_t used;
    uint32_t got;
    unsigned depth;
    unsigned bpp;
    uint32_t r1;
    uint32_t y;

    if (ws.halftone[7] != 0 && key == ws.halftone[6]) {
        *bitmap = ws.halftone[7];
        *length = ws.cache_length;
        return NULL;
    }
    ws.halftone[6] = key;
    ws.halftone[7] = (uint32_t)(uintptr_t)ws.screen_bitmap;
    *bitmap = 0;
    *length = 0;
    src = THRESHOLDS();
    width = ws.halftone[1];
    height = ws.halftone[2];
    depth = ws.depth;
    if (depth > 3 || width == 0 || height * (width >> (5 - depth)) > 0x40)
        return NULL;
    bpp = 1u << depth;
    low = ws.halftone[4] << (32 - bpp);
    high = ws.halftone[5] << (32 - bpp);
    used = 0;
    pos = 0;
    for (y = 0; y < height; y++) {
        got = pack_row((int32_t)key, src + y * width, width, bpp, low, high,
                       ws.screen_bitmap + used, BITMAP_WORDS - used, &pos);
        if (got == 0)
            return NULL;       /* the original would overrun its bitmap here */
        used += got;
    }
    r1 = pos;
    if (pos > 32)
        r1 = pos - width * bpp;
    else if (pos == 32)
        r1 = 32;
    if (width >= 32 / bpp)
        r1 = width * bpp;
    ws.cache_length = r1;
    *bitmap = (uint32_t)(uintptr_t)ws.screen_bitmap;
    *length = r1;
    return NULL;
}

_kernel_oserror *swi_cache_screen(_kernel_swi_regs *r)
{
    uint32_t bitmap;
    uint32_t length;
    _kernel_oserror *e = cache_screen(r->r[0], &bitmap, &length);

    r->r[0] = bitmap;
    r->r[1] = length;
    return e;
}
