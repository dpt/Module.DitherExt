#ifndef DITHER_H
#define DITHER_H

#include <stddef.h>
#include <stdint.h>
#include "kernel.h"

/* SWI offsets from the chunk base &44580 */
enum {
    SWI_SelectTable, SWI_SelectGCOLTable, SWI_ReturnGCOL, SWI_SetGCOL,
    SWI_ReturnColourNumber, SWI_ReturnGCOLForMode, SWI_ReturnColourNumberForMode,
    SWI_ReturnOppGCOL, SWI_SetOppGCOL, SWI_ReturnOppColourNumber,
    SWI_ReturnOppGCOLForMode, SWI_ReturnOppColourNumberForMode,
    SWI_GCOLToColourNumber, SWI_ColourNumberToGCOL, SWI_Info, SWI_Control,
    SWI_ReturnColourPattern, SWI_ReturnColourPatternTable,
    SWI_InvalidatePalette, SWI_Antialias, SWI_ReadPalette,
    SWI_ReturnColourPatternArray, SWI_SetHalftone, SWI_ReturnHalftone,
    SWI_SetHalftoneOrigin, SWI_ReturnHalftoneOrigin, SWI_SelectHalftoneTable,
    SWI_ReturnHalftoneIntensity, SWI_ReturnHalftoneTable, SWI_SetScreen,
    SWI_CacheScreen, SWI_SelectColourPatternTable,
    SWI_COUNT,                      /* 32 */
    SWI_ReadDitherState = 0x3C,     /* hidden */
    SWI_SuspendDither,
    SWI_EnableDither,
    SWI_DisableDither
};

/* Offsets below this go to ColourV (&22) while dithering is enabled */
#define SWI_COLOURV_LIMIT 0xE

#define STATE_ENABLED   1u
#define STATE_SUSPENDED 2u

/* Workspace.flags: b0-3 set by Dither_Control, b16-18 set by *Dither */
#define FLAGS_CONTROL_MASK 0xFu
#define FLAGS_OPTION_SHIFT 16
#define FLAGS_OPTION_MASK  0x70000u

/* Workspace.palette_type */
enum {
    PALETTE_INVALID = -1,
    PALETTE_DEFAULT,        /* default 8bpp */
    PALETTE_GREY,           /* grey ramp */
    PALETTE_CUBE,           /* 6x6x6 cube */
    PALETTE_CUSTOM
};

/* Workspace.depth: derived from Log2BPC, see read_mode_vars() */
#define DEPTH_COUNT 6

/* Mirrors the original private block (&984 bytes). Offsets in comments are
   the original ip-relative ones. The asm saved sp/lr at +4/+8 for its error
   long-jump. C returns errors normally so those words are unused. */
typedef struct {
    uint32_t  flags;            /* +&00 */
    uint32_t  unused_sp_lr[2];  /* +&04 */
    uint32_t  state;            /* +&0C STATE_* */
    uint32_t  pattern;          /* +&10 VDU variable &AB read at start-up */
    int       xeig;             /* +&14 these four are loaded in one go by */
    int       yeig;             /* +&18 OS_ReadVduVariables, keep the order */
    int       ncolour;          /* +&1C */
    int       depth;            /* +&20 0..5 */
    uint32_t  depth_scratch;    /* +&24 */
    /* +&28..+&44: SetHalftone stores R0-R7 here. The code also treats
       word 0 as "halftone active", words 4-5 (+&38 +&3C) as screen colours
       and words 6-7 (+&40 +&44) as the CacheScreen key and pointer. */
    uint32_t  halftone[8];
    uint32_t  cache_length;     /* +&48 */
    int       origin_x;         /* +&4C */
    int       origin_y;         /* +&50 */
    uint32_t  table_built;      /* +&54 */
    uint32_t  table[2];         /* +&58 */
    void     *antialias_table;  /* +&60 RMA block */
    int       palette_type;     /* +&64 PALETTE_* */
    void     *palette_block;    /* +&68 RMA block */
    uint32_t  reserved_6c[4];   /* +&6C */
    void     *screen_cache;     /* +&7C RMA block */
    const uint32_t *palette_table; /* +&80 starts at DefaultPaletteTable */
    uint32_t  palette_cache[256];  /* +&84 */
    uint32_t  thresholds[256];     /* +&484 */
    uint32_t  screen_bitmap[64];   /* +&884 CacheScreen bitmap */
    /* Not in the original. The blenders cannot reach static data, so they
       find these tables through the workspace. Set in the initialisation. */
    const uint8_t  *cube_class;    /* +&984 */
    const uint8_t  *grey_table;    /* +&988 */
    const uint32_t *cube_blend;    /* +&98C */
} Workspace;

#ifndef HOST_TEST
_Static_assert(offsetof(Workspace, xeig) == 0x14, "layout");
_Static_assert(offsetof(Workspace, halftone) == 0x28, "layout");
_Static_assert(offsetof(Workspace, origin_x) == 0x4C, "layout");
_Static_assert(offsetof(Workspace, antialias_table) == 0x60, "layout");
_Static_assert(offsetof(Workspace, palette_type) == 0x64, "layout");
_Static_assert(offsetof(Workspace, screen_cache) == 0x7C, "layout");
_Static_assert(offsetof(Workspace, palette_cache) == 0x84, "layout");
_Static_assert(sizeof(Workspace) == 0x990, "layout");
#endif

extern Workspace ws;

typedef _kernel_oserror *(*SwiFn)(_kernel_swi_regs *r);

/* main.c */
_kernel_oserror *make_error(int errnum, const char *message);
void             read_mode_vars(void);
void             free_caches(void);

/* stubs.c: not yet ported. See the asm label named in each comment. */
extern const SwiFn swi_table[SWI_COUNT];
_kernel_oserror *not_ported(const char *name);

#endif
