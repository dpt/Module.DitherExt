/* SWI dispatch table. Every SWI is ported. Entries left NULL (the simple SWIs
   that live in main.c) are handled by dispatch(). */

#include "dither.h"
#include "colour.h"

_kernel_oserror *not_ported(const char *name)
{
    return make_error(0x1E6, name);     /* TODO: pick a proper error number */
}

const SwiFn swi_table[SWI_COUNT] = {
    [SWI_SelectTable]                   = swi_select_table,
    [SWI_SelectGCOLTable]               = swi_select_gcol_table,
    [SWI_ReturnGCOL]                    = swi_return_gcol,
    [SWI_SetGCOL]                       = swi_set_gcol,
    [SWI_ReturnColourNumber]            = swi_return_colour_number,
    [SWI_ReturnGCOLForMode]             = swi_return_gcol_for_mode,
    [SWI_ReturnColourNumberForMode]     = swi_return_colour_number_for_mode,
    [SWI_ReturnOppGCOL]                 = swi_return_opp_gcol,
    [SWI_SetOppGCOL]                    = swi_set_opp_gcol,
    [SWI_ReturnOppColourNumber]         = swi_return_opp_colour_number,
    [SWI_ReturnOppGCOLForMode]          = swi_return_opp_gcol_for_mode,
    [SWI_ReturnOppColourNumberForMode]  = swi_return_opp_colour_number_for_mode,
    [SWI_GCOLToColourNumber]            = swi_gcol_to_colour_number,
    [SWI_ColourNumberToGCOL]            = swi_colour_number_to_gcol,
    [SWI_ReturnColourPattern]           = swi_return_colour_pattern,
    [SWI_ReturnColourPatternTable]      = swi_return_colour_pattern_table,
    [SWI_Antialias]                     = swi_antialias,
    [SWI_ReadPalette]                   = swi_read_palette,
    [SWI_ReturnColourPatternArray]      = swi_return_colour_pattern_array,
    [SWI_SelectHalftoneTable]           = swi_select_halftone_table,
    [SWI_ReturnHalftoneIntensity]       = swi_return_halftone_intensity,
    [SWI_ReturnHalftoneTable]           = swi_return_halftone_table,
    [SWI_SetScreen]                     = swi_set_screen,
    [SWI_CacheScreen]                   = swi_cache_screen,
    [SWI_SelectColourPatternTable]      = swi_select_colour_pattern_table,
};
