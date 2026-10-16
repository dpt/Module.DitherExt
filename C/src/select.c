/* DitherExtend SelectTable, SelectGCOLTable and SelectHalftoneTable.
   Ported from DitherExt.s. Each converts every colour of a source palette
   to a colour number in the destination mode. */

#include "kernel.h"
#include "colour.h"

_kernel_oserror *select_table(int src_mode, const uint32_t *src_palette,
                              int dst_mode, const uint32_t *dst_palette, uint8_t *out)
{
    PaletteRange src;
    PaletteRange dst;
    const uint32_t *p;
    _kernel_oserror *e;
    Nearest n;
    int src_depth;
    int dst_depth;
    int type;

    e = mode_to_depth(src_mode, &src_depth);
    if (e != NULL)
        return e;
    /* The original indexes its palette tables with depth 4 and 5 here, which
       reads past them. Refuse instead. */
    if (src_depth > 3)
        return make_error(0x803003, "Bad mode");
    src = pointers_for_mode(src_depth, src_palette);
    e = mode_to_depth(dst_mode, &dst_depth);
    if (e != NULL)
        return e;

    type = -1;
    if (dst_depth < 3) {
        dst = pointers_for_mode(dst_depth, dst_palette);
        type = PALETTE_CUSTOM;
    } else if (dst_depth == 3) {
        type = PALETTE_DEFAULT;
        if (dst_palette != NULL) {
            dst = pointers_for_mode(dst_depth, dst_palette);
            type = find_palette_type(dst.start, dst.end);
        }
    }

    for (p = src.start; p != src.end; p++) {
        if (dst_depth == 5) {
            *(uint32_t *)out = *p >> 8;
            out += 4;
        } else if (dst_depth == 4) {
            n = colour_to_15(*p);
            *out++ = n.index;
            *out++ = n.index >> 8;
        } else if (type == PALETTE_CUSTOM) {
            *out++ = search_palette(dst, *p).index;
        } else {
            *out++ = nearest_by_type(type, *p).index;
        }
    }
    return NULL;
}

_kernel_oserror *select_gcol_table(int src_mode, const uint32_t *src_palette,
                                   int dst_mode, const uint32_t *dst_palette, uint8_t *out)
{
    _kernel_oserror *e = select_table(src_mode, src_palette, dst_mode, dst_palette, out);
    int i;

    if (e != NULL || ws.depth_scratch != 3)
        return e;
    for (i = 0; i < 256; i++)
        out[i] = colour_number_to_gcol(out[i]);
    return NULL;
}

_kernel_oserror *select_halftone_table(int mode, const uint32_t *palette, uint8_t *out)
{
    PaletteRange range;
    const uint32_t *p;
    _kernel_oserror *e;
    int depth;

    e = mode_to_depth(mode, &depth);
    if (e != NULL)
        return e;
    if (depth > 3)
        return make_error(0x803003, "Bad mode");     /* as in select_table */
    range = pointers_for_mode(depth, palette);
    for (p = range.start; p != range.end; p++)
        *out++ = nearest_grey(*p).index;
    return NULL;
}

_kernel_oserror *swi_select_table(_kernel_swi_regs *r)
{
    return select_table(r->r[0], (const uint32_t *)r->r[1], r->r[2],
                        (const uint32_t *)r->r[3], (uint8_t *)r->r[4]);
}

_kernel_oserror *swi_select_gcol_table(_kernel_swi_regs *r)
{
    return select_gcol_table(r->r[0], (const uint32_t *)r->r[1], r->r[2],
                             (const uint32_t *)r->r[3], (uint8_t *)r->r[4]);
}

_kernel_oserror *swi_select_halftone_table(_kernel_swi_regs *r)
{
    return select_halftone_table(r->r[0], (const uint32_t *)r->r[1], (uint8_t *)r->r[4]);
}
