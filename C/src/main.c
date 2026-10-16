/* DitherExtend 0.60 - module entry points and the SWI dispatcher.
   Ported from DitherExt.s: Init, Final, Service, ReadModeVars, CmdDither,
   SWIHandler and the simple SWIs. */

#include <stdlib.h>
#include <string.h>
#include "kernel.h"
#include "swis.h"
#include "dither.h"
#include "colour.h"

#define SWI_UNKNOWN_41482 0x61482   /* unidentified X-form SWI, see read_mode_vars() */
#define COLOURV           0x22

Workspace ws;

_kernel_oserror *make_error(int errnum, const char *message)
{
    static struct {
        int  errnum;
        char message[64];
    } block;

    block.errnum = errnum;
    strncpy(block.message, message, sizeof block.message - 1);
    return (_kernel_oserror *)&block;
}

static void free_block(void **block)
{
    if (*block != NULL) {
        free(*block);
        *block = NULL;
    }
}

void free_caches(void)
{
    free_block(&ws.antialias_table);
    free_block(&ws.palette_block);
    free_block(&ws.screen_cache);
}

static int read_mode_var(int var, int *value)
{
    _kernel_swi_regs r;

    r.r[0] = var;
    if (_kernel_swi(SWI_UNKNOWN_41482, &r, &r) != NULL)
        return 0;
    *value = r.r[0];
    return 1;
}

void read_mode_vars(void)
{
    static const int vdu_vars[] = { 4, 5, 3, 0xA, -1 };
    _kernel_swi_regs r;
    int ok;

    /* Probe for the unidentified SWI first (R0 = &94 must return non-zero),
       then fall back to OS_ReadVduVariables. */
    r.r[0] = 0x94;
    ok = _kernel_swi(SWI_UNKNOWN_41482, &r, &r) == NULL && r.r[0] != 0;
    if (ok)
        ok = read_mode_var(4, &ws.xeig)
          && read_mode_var(5, &ws.yeig)
          && read_mode_var(0xA, &ws.depth);

    if (!ok) {
        r.r[0] = (int)vdu_vars;
        r.r[1] = (int)&ws.xeig;
        _kernel_swi(OS_ReadVduVariables, &r, &r);
        /* depth code 4 with NColour 15 is treated as code 5 */
        if (ws.depth == 4 && ws.ncolour == 0xF) {
            ws.depth = 5;
            ws.yeig -= 1;
        }
    }

    ws.table_built = 0;
    ws.halftone[0] = 0;
    ws.halftone[6] = 0;
    ws.origin_x = 0;
    ws.origin_y = 0;
    ws.palette_type = PALETTE_INVALID;
    free_caches();
}

_kernel_oserror *Dither_init(const char *cmd_tail, int podule_base, void *pw)
{
    static const int init_vars[] = { 0xAB, -1 };
    _kernel_swi_regs r;

    (void)cmd_tail;
    (void)podule_base;
    (void)pw;

    r.r[0] = 0x12;                  /* OS_Module 18: look up module name */
    r.r[1] = (int)"ColourTrans";
    if (_kernel_swi(OS_Module, &r, &r) != NULL)
        return make_error(0x803000, "ColourTrans needs to be installed before DitherExtend");

    memset(&ws, 0, sizeof ws);
    ws.palette_table = default_palette_table;
    ws.cube_class = cube_class_table;
    ws.grey_table = grey_palette_table;
    ws.cube_blend = cube_blend_table;

    r.r[0] = (int)init_vars;
    r.r[1] = (int)&ws.pattern;
    if (_kernel_swi(OS_ReadVduVariables, &r, &r) != NULL)
        return _kernel_last_oserror();

    read_mode_vars();
    return NULL;
}

_kernel_oserror *Dither_final(int fatal, int podule, void *pw)
{
    (void)fatal;
    (void)podule;
    (void)pw;

    free_caches();
    return NULL;
}

void Dither_service(int service_number, _kernel_swi_regs *r, void *pw)
{
    (void)r;
    (void)pw;

    if (service_number == 0x27)
        free_caches();              /* the original branches straight to Final */
    else
        read_mode_vars();
}

_kernel_oserror *Dither_command(const char *arg_string, int argc, int cmd_no, void *pw)
{
    _kernel_swi_regs r;
    uint32_t option = 0;

    (void)cmd_no;
    (void)pw;

    if (argc != 0) {
        r.r[0] = 0x20000000;        /* restrict to 0..R2 */
        r.r[1] = (int)arg_string;
        r.r[2] = 0xFF;
        if (_kernel_swi(OS_ReadUnsigned, &r, &r) != NULL)
            return _kernel_last_oserror();
        option = r.r[2] & 7;
    }
    ws.flags = (ws.flags & FLAGS_CONTROL_MASK) | option << FLAGS_OPTION_SHIFT;
    return NULL;
}

/* Hidden SWIs */

static _kernel_oserror *set_state(uint32_t state)
{
    ws.state = state;
    ws.palette_type = PALETTE_INVALID;
    return NULL;
}

/* Simple SWIs */

static _kernel_oserror *swi_info(_kernel_swi_regs *r)
{
    r->r[0] = ws.flags;
    return NULL;
}

static _kernel_oserror *swi_control(_kernel_swi_regs *r)
{
    uint32_t eor = r->r[0] & FLAGS_CONTROL_MASK;
    uint32_t and = (r->r[1] & FLAGS_CONTROL_MASK) | FLAGS_OPTION_MASK;

    ws.flags = (ws.flags & and) ^ eor;
    r->r[0] = ws.flags;             /* returns the new flags */
    return NULL;
}

static _kernel_oserror *swi_invalidate_palette(_kernel_swi_regs *r)
{
    PaletteRange range;
    _kernel_oserror *e;
    int type = PALETTE_DEFAULT;

    (void)r;
    ws.table_built = 0;
    if (ws.depth < 4) {
        range = select_pattern_pointers(ws.depth);
        e = read_hardware_palette(range);
        if (e != NULL)
            return e;
        type = find_palette_type(range.start, range.end);
    }
    ws.palette_type = type;
    free_caches();
    return NULL;
}

static _kernel_oserror *swi_set_halftone(_kernel_swi_regs *r)
{
    memcpy(ws.halftone, r->r, sizeof ws.halftone);
    return NULL;
}

static _kernel_oserror *swi_return_halftone(_kernel_swi_regs *r)
{
    r->r[0] = ws.halftone[0];
    if (ws.halftone[0] != 0)
        memcpy(&r->r[1], &ws.halftone[1], 7 * sizeof(int));
    return NULL;
}

static _kernel_oserror *swi_set_halftone_origin(_kernel_swi_regs *r)
{
    static const int vars[] = { 0x88, 0x89, 4, 5, 0xC, -1 };  /* OrgX OrgY XEig YEig YWindLimit */
    _kernel_swi_regs v;
    int values[5];
    int x;
    int y;

    v.r[0] = (int)vars;
    v.r[1] = (int)values;
    if (_kernel_swi(OS_ReadVduVariables, &v, &v) != NULL)
        return _kernel_last_oserror();

    x = ((r->r[0] + values[0]) >> values[2]) << ws.depth;
    y = (values[4] + 1) - ((r->r[1] + values[1]) >> values[3]);
    ws.origin_x = x;
    ws.origin_y = y;
    return NULL;
}

static _kernel_oserror *swi_return_halftone_origin(_kernel_swi_regs *r)
{
    r->r[0] = ws.origin_x;
    r->r[1] = ws.origin_y;
    return NULL;
}

static _kernel_oserror *dispatch(int swi_offset, _kernel_swi_regs *r)
{
    switch (swi_offset) {
    case SWI_Info:                 return swi_info(r);
    case SWI_Control:              return swi_control(r);
    case SWI_InvalidatePalette:    return swi_invalidate_palette(r);
    case SWI_SetHalftone:          return swi_set_halftone(r);
    case SWI_ReturnHalftone:       return swi_return_halftone(r);
    case SWI_SetHalftoneOrigin:    return swi_set_halftone_origin(r);
    case SWI_ReturnHalftoneOrigin: return swi_return_halftone_origin(r);
    default:
        if (swi_table[swi_offset] == NULL)
            return not_ported("SWI");
        return swi_table[swi_offset](r);
    }
}

_kernel_oserror *Dither_swi(int swi_offset, _kernel_swi_regs *r, void *pw)
{
    _kernel_swi_regs forward;
    _kernel_oserror *e;

    (void)pw;

    switch (swi_offset) {
    case SWI_EnableDither:    return set_state(STATE_ENABLED);
    case SWI_DisableDither:   return set_state(0);
    case SWI_ReadDitherState: r->r[0] = ws.state; return NULL;
    case SWI_SuspendDither:
        if (ws.state & STATE_ENABLED)
            ws.state |= STATE_SUSPENDED;
        return NULL;
    }
    if (swi_offset >= SWI_COUNT)
        return make_error(0x1E6, "SWI not known");

    if (swi_offset < SWI_COLOURV_LIMIT && (ws.state & STATE_ENABLED)) {
        if (!(ws.state & STATE_SUSPENDED)) {
            /* Pass the call on to ColourV. R8 = SWI offset, R9 = vector. */
            memcpy(&forward, r, sizeof forward);
            forward.r[8] = swi_offset;
            forward.r[9] = COLOURV;
            e = _kernel_swi(OS_CallAVector, &forward, &forward);
            memcpy(r, &forward, sizeof forward);
            return e;
        }
        ws.state &= ~STATE_SUSPENDED;   /* suspension lasts one call */
    }

    if (ws.palette_type < 0) {
        _kernel_oserror *e = swi_invalidate_palette(r);

        if (e != NULL)
            return e;
    }

    return dispatch(swi_offset, r);
}
