# DitherExtend

A reverse engineering of the RISC OS module `DitherExtend` 0.60 (13 Nov 2002, Computer Concepts Ltd), together with a C port of it.

DitherExtend provides halftone and colour pattern dithering, antialias blending and related colour conversion SWIs. Its SWI chunk is `&44580`.

## Contents

| Path              | What it is                                                                                            |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| `Asm/DitherExt.s` | Annotated objasm disassembly with meaningful labels. Assembles byte-identical to the original module. |
| `C/`              | CMHG module in C, ported routine by routine from the disassembly.                                     |

The original module binary is not part of this repository, as it is copyrighted. To verify the disassembly, assemble `Asm/DitherExt.s` and compare the output with your own copy of `DitherExt,ffa` (`DitherExtend` 0.60, `&6F1C` bytes).

## SWIs

The module owns SWI chunk `&44580` (`DitherExtend_`). It reimplements the RISC OS ColourTrans SWIs that choose colours for a screen mode (`ColourTrans_SelectTable`, `ColourTrans_ReturnGCOL` and so on), adding dithering. SWI offsets `0` to `&D` have the same names and the same order as the matching ColourTrans SWIs. While dithering is enabled and not suspended, the module also takes these calls from ColourV and passes them on, so ColourTrans callers get dithered colours without change. The other SWIs are extensions.

The register lists below come from the disassembly and the C port. Colours are `&BBGGRR00` words. A mode argument is a mode number or a mode selector. A palette argument of `0` means the default palette for the mode and `-1` means the current palette.

| Offset | SWI                            | Entry                                                                                           | Exit                                        |
| ------ | ------------------------------ | ----------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `&00`  | `SelectTable`                  | R0 source mode, R1 source palette, R2 destination mode, R3 destination palette, R4 table buffer | Table written to R4                         |
| `&01`  | `SelectGCOLTable`              | As `SelectTable`                                                                                | Entries are GCOL values in 256 colour modes |
| `&02`  | `ReturnGCOL`                   | R0 colour                                                                                       | R0 GCOL value                               |
| `&03`  | `SetGCOL`                      | R0 colour, R3 flags (bit 7 picks the buffer half), R4 mask row (low 3 bits)                     | R0 GCOL value; pattern built                |
| `&04`  | `ReturnColourNumber`           | R0 colour                                                                                       | R0 colour number                            |
| `&05`  | `ReturnGCOLForMode`            | R0 colour, R1 mode, R2 palette                                                                  | R0 GCOL value                               |
| `&06`  | `ReturnColourNumberForMode`    | R0 colour, R1 mode, R2 palette                                                                  | R0 colour number                            |
| `&07`  | `ReturnOppGCOL`                | R0 colour                                                                                       | R0 GCOL value                               |
| `&08`  | `SetOppGCOL`                   | As `SetGCOL`                                                                                    | As `SetGCOL`                                |
| `&09`  | `ReturnOppColourNumber`        | R0 colour                                                                                       | R0 colour number                            |
| `&0A`  | `ReturnOppGCOLForMode`         | As `ReturnGCOLForMode`                                                                          | R0 GCOL value                               |
| `&0B`  | `ReturnOppColourNumberForMode` | As `ReturnColourNumberForMode`                                                                  | R0 colour number                            |
| `&0C`  | `GCOLToColourNumber`           | R0 GCOL value                                                                                   | R0 colour number                            |
| `&0D`  | `ColourNumberToGCOL`           | R0 colour number                                                                                | R0 GCOL value                               |
| `&0E`  | `Info`                         |                                                                                                 | R0 flags                                    |
| `&0F`  | `Control`                      | R0 EOR mask, R1 AND mask (control bits only)                                                    | R0 new flags                                |
| `&10`  | `ReturnColourPattern`          | R0 colour, R2 buffer (32 bytes)                                                                 | Pattern written                             |
| `&11`  | `ReturnColourPatternTable`     | R0 first colour, R1 last colour, R2 buffer (256 patterns of 32 bytes)                           | Patterns written                            |
| `&12`  | `InvalidatePalette`            |                                                                                                 | Palette caches freed                        |
| `&13`  | `Antialias`                    |                                                                                                 | R0 workspace, R1 blend routine (see below)  |
| `&14`  | `ReadPalette`                  | R0 mode, R1 palette, R2 buffer                                                                  | Palette words written                       |
| `&15`  | `ReturnColourPatternArray`     |                                                                                                 | R0 block of `&20000` bytes                  |
| `&16`  | `SetHalftone`                  | R0 to R7 halftone description                                                                   |                                             |
| `&17`  | `ReturnHalftone`               |                                                                                                 | R0 to R7 (R0 is 0 if none)                  |
| `&18`  | `SetHalftoneOrigin`            | R0 x, R1 y (graphics coordinates)                                                               |                                             |
| `&19`  | `ReturnHalftoneOrigin`         |                                                                                                 | R0 x, R1 y (pixels)                         |
| `&1A`  | `SelectHalftoneTable`          | R0 mode, R1 palette, R4 buffer                                                                  | Grey level of each entry                    |
| `&1B`  | `ReturnHalftoneIntensity`      | R0 colour                                                                                       | R0 grey level 0 to 255                      |
| `&1C`  | `ReturnHalftoneTable`          | R0 first colour, R1 last colour, R2 buffer (256 bytes)                                          | Grey levels of a ramp                       |
| `&1D`  | `SetScreen`                    | R0 spot function, R1 angle, R2 x size, R3 y size, R4 argument, R5 low colour, R6 high colour    | Threshold table built                       |
| `&1E`  | `CacheScreen`                  | R0 key                                                                                          | R0 bitmap, R1 length                        |
| `&1F`  | `SelectColourPatternTable`     | R0 mode, R1 palette, R4 buffer (32 bytes per palette entry)                                     | Patterns written                            |
| `&3C`  | `ReadDitherState` (hidden)     |                                                                                                 | R0 state                                    |
| `&3D`  | `SuspendDither` (hidden)       |                                                                                                 | Next call is not passed on to ColourV       |
| `&3E`  | `EnableDither` (hidden)        |                                                                                                 |                                             |
| `&3F`  | `DisableDither` (hidden)       |                                                                                                 |                                             |

The module also provides the `*Dither [<option>]` command. Option `0` selects the default dither, `1` disables dithering, `2` selects greyscale dither and `4` selects the alternative four colour dither.

`SetScreen` takes either a built-in spot function (`-1` to `-6`) or the address of a user routine in R0. The user routine receives x in R0 and y in R1 and returns its result in R2.

## The disassembly

`Asm/DitherExt.s` is the source of truth for the port. Repeated entry and exit sequences are written with the `EnterSWI`, `ExitOK` and `ExitErr` macros. STM and LDM instructions use register ranges.

Build it with `asasm` and compare the output with the original module. The two files should be identical.

The Antialias entry code at `Antialias` is still raw `DCD` words. It is real code, not data.

## The C port

Every SWI is ported. The port needs the GCCSDK cross compiler (`arm-unknown-riscos-gcc`) and `cmunge`. From `C`:

```
make
```

This produces `DitherExt,ffa`. Run `make clean` to remove `build/` and the module.

### Layout

| File                | Contents                                                                  |
| ------------------- | ------------------------------------------------------------------------- |
| `cmhg/DitherExtHdr` | CMHG header: SWI chunk, names and handlers                                |
| `src/main.c`        | Initialisation, SWI dispatch, the simple SWIs and cache freeing           |
| `src/stubs.c`       | SWI dispatch table                                                        |
| `src/dither.h`      | `Workspace` layout (matches the original offsets), SWI numbers and errors |
| `src/colour.c`      | Colour number and GCOL SWIs, palette search, nearest-colour routines      |
| `src/select.c`      | `SelectTable` family                                                      |
| `src/misc.c`        | `ReadPalette`, halftone intensity and table, colour pattern array         |
| `src/pattern.c`     | `SetGCOL`, `SetOppGCOL` and the colour pattern SWIs                       |
| `src/screen.c`      | `CacheScreen`                                                             |
| `src/setscreen.c`   | `SetScreen`: spot functions, trigonometry and the 16 bit divide           |
| `src/antialias.c`   | `Antialias`: chooses a blender for the current depth                      |
| `src/blend.c`       | The eight blenders (2, 4, 8 and 16 and 32 bits per pixel)                 |
| `src/veneer.s`      | Register convention veneers for the blenders                              |
| `src/tables*.c`     | Constant tables extracted from the binary                                 |

### Antialias blenders

`Antialias` does not blend. It returns the workspace address in R0 and the address of a blend routine in R1. The caller then invokes that routine with IP = workspace, R1 = mask, R2 = source, R3 = destination and R4 = count. It returns with `LDMFD sp!, {r0-ip, pc}`.

The blenders are written in C. `veneer.s` adapts the register convention. The blenders are called from outside the module with an arbitrary static base, so they use no static data. They reach tables through extra trailing `Workspace` fields set at start-up. This is why every object is built with `-mno-apcs-stack-check`.

### Known differences and quirks

- The original allocates its caches from the RMA. The port uses `malloc` and `calloc`.
- The port keeps the original's behaviour for valid input. Some overruns are not reproduced as such: `blend_4bpp` can run past the buffers if an aligned shortcut word is met with only two pixels left, and unaligned word copies in the 8 bit blenders follow ARM `LDR` rotation, not `memcpy`.
- The error numbers `0x1E4` (no room) and `0x1E6` (SWI not known) are placeholders. The originals have not been checked.
- The port has not been run on RISC OS. Test at least one `Antialias` call per screen depth.

## Verification

Each ported routine was checked by a differential test against the original binary run in a Unicorn ARM emulator (SA1110 model), using random inputs. The tests are not part of this repository. The results at the last run:

- Colour number, GCOL, `SelectTable`, palette and pattern routines: 0 mismatches.
- `SetScreen`: 57 cases and 2000 inputs each for `Sine`, `ScreenSpot` and `Divide16`, 0 mismatches.
- Blenders: 3000 random cases across all eight, 0 mismatches.

Unicorn does not rotate unaligned `LDR` as an ARM610 or StrongARM does. The test harness patches that one instruction in `Blend16bpp`.
