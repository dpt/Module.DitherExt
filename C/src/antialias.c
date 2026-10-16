/* Antialias SWI. Ported from DitherExt.s (Antialias). It does not blend. It
   returns the workspace address in R0 and the address of a blend routine for
   the current screen depth in R1. veneer.s adapts the blend routines to the
   register convention the caller expects. */

#include <stdlib.h>
#include <string.h>
#include "colour.h"

#define BLEND4_TABLE_SIZE 4096

extern void veneer_blend_2bpp(void);
extern void veneer_blend_4bpp(void);
extern void veneer_blend_grey8(void);
extern void veneer_blend_default8(void);
extern void veneer_blend_cube8(void);
extern void veneer_blend_custom8(void);
extern void veneer_blend_16bpp(void);
extern void veneer_blend_32bpp(void);

_kernel_oserror *swi_antialias(_kernel_swi_regs *r)
{
    void (*blend)(void);

    switch (ws.depth) {
    case 0:
    case 1:
        blend = veneer_blend_2bpp;
        break;
    case 2:
        if (ws.antialias_table == NULL) {
            ws.antialias_table = malloc(BLEND4_TABLE_SIZE);
            if (ws.antialias_table == NULL)
                return make_error(0x1E4, "No room in the module area");
            memset(ws.antialias_table, 0xFF, BLEND4_TABLE_SIZE);
        }
        blend = veneer_blend_4bpp;
        break;
    case 3:
        switch (ws.palette_type) {
        case PALETTE_GREY:
            blend = veneer_blend_grey8;
            break;
        case PALETTE_CUBE:
            blend = veneer_blend_cube8;
            break;
        case PALETTE_CUSTOM:
            /* Allocate here: the blender cannot call the C library. */
            if (ws.palette_block == NULL)
                ws.palette_block = calloc(1, 0x9000);
            blend = veneer_blend_custom8;
            break;
        default:
            blend = veneer_blend_default8;
            break;
        }
        break;
    case 4:
        blend = veneer_blend_16bpp;
        break;
    case 5:
        blend = veneer_blend_32bpp;
        break;
    default:
        return make_error(0x803003, "Bad mode");
    }
    r->r[0] = (int)&ws;
    r->r[1] = (int)blend;
    return NULL;
}
