; DitherExtend 0.60 (13 Nov 2002) - Computer Concepts Ltd
; Disassembly of DitherExt,ffa for ObjAsm. Generated from the module image.
;
; Workspace (ip = [private word]):
;   +&00 flags            +&04/+&08 saved sp/lr    +&0C state (b0 enabled, b1 suspended)
;   +&10 pattern output   +&14/+&18 XEig/YEig      +&1C NColour   +&20 depth code 0..5
;   +&24 depth scratch    +&28..&44 halftone and cached GCOL data
;   +&38/+&3C screen colours   +&40/+&44/+&48 CacheScreen key/pointer/length
;   +&4C/+&50 halftone origin  +&54 table-built flag   +&58 8-byte table
;   +&60 RMA antialias table   +&64 palette type (-1 invalid)   +&68 palette cache block
;   +&7C RMA screen-cache block   +&84 palette cache (256 words), +&484 thresholds, +&884 CacheScreen bitmap
;
; Palette types: 0 default 8bpp, 1 grey ramp, 2 6x6x6 cube, 3 custom

r0 RN 0
r1 RN 1
r2 RN 2
r3 RN 3
r4 RN 4
r5 RN 5
r6 RN 6
r7 RN 7
r8 RN 8
r9 RN 9
r10 RN 10
r11 RN 11
r12 RN 12
sb RN 9
sl RN 10
fp RN 11
ip RN 12
sp RN 13
lr RN 14
pc RN 15

        MACRO
$l      EnterSWI $first, $last
$l      MRS     sl, CPSR
        BIC     sl, sl, #&80
        MSR     CPSR_c, sl
        STMFD   sp!, {$first-$last, lr}
        MEND

        ; Leave a SWI with V clear (ExitOK) or V set (ExitErr)
        ; Without arguments no registers are restored
        MACRO
$l      ExitOK  $first, $last
$l      TEQ     pc, pc
        IF "$first" <> ""
        LDMFDNE sp!, {$first-$last, lr}
        ENDIF
        BICNES  pc, lr, #&10000000
        MSR     CPSR_f, #0
        IF "$first" <> ""
        LDMFD   sp!, {$first-$last, pc}
        ELSE
        MOV     pc, lr
        ENDIF
        MEND

        MACRO
$l      ExitErr $first, $last
$l      TEQ     pc, pc
        IF "$first" <> ""
        LDMFDNE sp!, {$first-$last, lr}
        ENDIF
        ORRNES  pc, lr, #&10000000
        MSR     CPSR_f, #&10000000
        IF "$first" <> ""
        LDMFD   sp!, {$first-$last, pc}
        ELSE
        MOV     pc, lr
        ENDIF
        MEND

        AREA    |DitherExtend$$Code|, CODE, READONLY
        ENTRY

Module_Start
        DCD     0                       ; Start (none)
        DCD     Init - Module_Start
        DCD     Final - Module_Start
        DCD     Service - Module_Start
        DCD     Title - Module_Start
        DCD     Help - Module_Start
        DCD     Keywords - Module_Start
        DCD     &44580                  ; SWI chunk
        DCD     SWIHandler - Module_Start
        DCD     SWITable - Module_Start
        DCD     0                       ; SWI decoding code
        DCD     0                       ; Messages file
        DCD     ModuleFlags - Module_Start
ModuleFlags
        DCD     1                       ; 32-bit compatible
Title
        DCB     "DitherExtend"
        DCB     &00,&00,&00,&00
Help
        DCB     "DitherExtend"
        DCB     &09
        DCB     "0.60 (13 Nov 2002) "
        DCB     &A9
        DCB     " 1992-2002 Computer Concepts Ltd"
        DCB     &00,&0A,&20
Keywords
        DCB     "Dither"
        DCB     &00,&00
CmdTable
        DCD     CmdDither - Module_Start
        DCD     &00010000               ; min 0 max 1 args
        DCD     CmdSyntax - Module_Start
        DCD     CmdHelp - Module_Start
        DCD     0
CmdHelp
        DCB     "This command is used to control dithering."
        DCB     &0D
        DCB     "<dither option> can be any of the following :"
        DCB     &0D,&09
        DCB     "0 - Use default dither"
        DCB     &0D,&09
        DCB     "1 - Disable dithering"
        DCB     &0D,&09
        DCB     "2 - Use greyscale dither"
        DCB     &0D,&09
        DCB     "4 - Use alternative four colour dither"
        DCB     &0D
CmdSyntax
        DCB     "Syntax: *Dither [<dither option>]"
        DCB     &00

CmdDither
        STR     lr, [sp, #-4]!
        LDR     ip, [ip]
        MOVS    r2, r1
        BEQ     CmdDither_1
        MOV     r2, #&FF
        MOV     r1, r0
        MOV     r0, #&20000000
        SWI     &20021 ; XOS_ReadUnsigned
        LDRVS   pc, [sp], #4
        AND     r2, r2, #7
CmdDither_1
        LDR     r0, [ip]
        AND     r0, r0, #&F
        ORR     r0, r0, r2, lsl #16
        STR     r0, [ip]
        MSR     CPSR_f, #0
        LDMFD   sp!, {pc}
SWITable
        DCB     "DitherExtend"
        DCB     &00
        DCB     "SelectTable"
        DCB     &00
        DCB     "SelectGCOLTable"
        DCB     &00
        DCB     "ReturnGCOL"
        DCB     &00
        DCB     "SetGCOL"
        DCB     &00
        DCB     "ReturnColourNumber"
        DCB     &00
        DCB     "ReturnGCOLForMode"
        DCB     &00
        DCB     "ReturnColourNumberForMode"
        DCB     &00
        DCB     "ReturnOppGCOL"
        DCB     &00
        DCB     "SetOppGCOL"
        DCB     &00
        DCB     "ReturnOppColourNumber"
        DCB     &00
        DCB     "ReturnOppGCOLForMode"
        DCB     &00
        DCB     "ReturnOppColourNumberForMode"
        DCB     &00
        DCB     "GCOLToColourNumber"
        DCB     &00
        DCB     "ColourNumberToGCOL"
        DCB     &00
        DCB     "Info"
        DCB     &00
        DCB     "Control"
        DCB     &00
        DCB     "ReturnColourPattern"
        DCB     &00
        DCB     "ReturnColourPatternTable"
        DCB     &00
        DCB     "InvalidatePalette"
        DCB     &00
        DCB     "Antialias"
        DCB     &00
        DCB     "ReadPalette"
        DCB     &00
        DCB     "ReturnColourPatternArray"
        DCB     &00
        DCB     "SetHalftone"
        DCB     &00
        DCB     "ReturnHalftone"
        DCB     &00
        DCB     "SetHalftoneOrigin"
        DCB     &00
        DCB     "ReturnHalftoneOrigin"
        DCB     &00
        DCB     "SelectHalftoneTable"
        DCB     &00
        DCB     "ReturnHalftoneIntensity"
        DCB     &00
        DCB     "ReturnHalftoneTable"
        DCB     &00
        DCB     "SetScreen"
        DCB     &00
        DCB     "CacheScreen"
        DCB     &00
        DCB     "SelectColourPatternTable"
        DCB     &00,&00,&00

Init
        STR     lr, [sp, #-4]!
        MOV     r0, #&12
        ADR     r1, ColourTransName
        SWI     &2001E ; XOS_Module
        ADRVS   r0, ErrColourTrans
        BVS     Init_2
        LDR     r2, [ip]
        TEQ     r2, #0
        BNE     Init_1
        MOV     r0, #6
        MOV     r3, #&184
        ORR     r3, r3, #&800
        SWI     &2001E ; XOS_Module
        BVS     Init_2
        STR     r2, [ip]
Init_1
        MOV     ip, r2
        MOV     lr, #0
        STR     lr, [ip]
        STR     lr, [ip, #&54]
        STR     lr, [ip, #&C]
        STR     lr, [ip, #&28]
        STR     lr, [ip, #&40]
        STR     lr, [ip, #&44]
        STR     lr, [ip, #&4C]
        STR     lr, [ip, #&50]
        STR     lr, [ip, #&60]
        STR     lr, [ip, #&68]
        ADD     lr, pc, #&A4 ; with next instruction: DefaultPaletteTable
        ADD     lr, lr, #&3700
        STR     lr, [ip, #&80]
        STR     lr, [ip, #&7C]
        ADR     r0, InitVduVarList
        ADD     r1, ip, #&10
        SWI     &20031 ; XOS_ReadVduVariables
        BVS     Init_2
        BL      ReadModeVars
        TEQ     pc, pc
        LDRNE   lr, [sp], #4
        BICNES  pc, lr, #&10000000
        MSR     CPSR_f, #0
        LDR     pc, [sp], #4
Init_2
        MSR     CPSR_f, #&10000000
        LDMFD   sp!, {pc}

ColourTransName
        DCB     "ColourTrans"
        DCB     &00

ErrColourTrans
        DCD     &00803000
        DCB     "ColourTrans needs to be installed before DitherExtend"
        DCB     &00,&00,&00

InitVduVarList
        DCD     &000000AB
        DCD     &FFFFFFFF

Final
        STMFD   sp!, {r0-r2, lr}
        LDR     ip, [ip]
        LDR     r2, [ip, #&60]
        TEQ     r2, #0
        BEQ     Final_1
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&60]
Final_1
        LDR     r2, [ip, #&68]
        TEQ     r2, #0
        BEQ     Final_2
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&68]
Final_2
        LDR     r2, [ip, #&7C]
        TEQ     r2, #0
        BEQ     Final_3
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&7C]
Final_3
        LDMFD   sp!, {r0-r2, pc}

Service
        TEQ     r1, #&27
        BEQ     Final
        EOR     r1, r1, #&80000
        TEQ     r1, #&50
        EOR     r1, r1, #&80000
        TEQNE   r1, #&46
        TEQNE   r1, #&72
        MOVNE   pc, lr
        LDR     ip, [ip]

ReadModeVars
        STMFD   sp!, {r0-r3, lr}
        MOV     r0, #&94
        SWI     &61482 ; X_Unknown_41482
        BVS     ReadModeVars_1
        TEQ     r0, #0
        BEQ     ReadModeVars_1
        MOV     r0, #4
        SWI     &61482 ; X_Unknown_41482
        STRVC   r0, [ip, #&14]
        MOVVC   r0, #5
        SWIVC   &61482 ; X_Unknown_41482
        STRVC   r0, [ip, #&18]
        MOVVC   r0, #&A
        SWIVC   &61482 ; X_Unknown_41482
        STRVC   r0, [ip, #&20]
        BVC     ReadModeVars_2
ReadModeVars_1
        ADR     r0, ModeVduVarList
        ADD     r1, ip, #&14
        SWI     &20031 ; XOS_ReadVduVariables
        LDR     lr, [ip, #&20]
        TEQ     lr, #4
        LDREQ   lr, [ip, #&1C]
        TEQEQ   lr, #&F
        MOVEQ   lr, #5
        STREQ   lr, [ip, #&20]
        LDREQ   lr, [ip, #&18]
        SUBEQ   lr, lr, #1
        STREQ   lr, [ip, #&18]
ReadModeVars_2
        MOV     lr, #0
        STR     lr, [ip, #&54]
        STR     lr, [ip, #&28]
        STR     lr, [ip, #&40]
        STR     lr, [ip, #&4C]
        STR     lr, [ip, #&50]
        MVN     lr, #0
        STR     lr, [ip, #&64]
        LDR     r2, [ip, #&60]
        TEQ     r2, #0
        BEQ     ReadModeVars_3
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&60]
ReadModeVars_3
        LDR     r2, [ip, #&68]
        TEQ     r2, #0
        BEQ     ReadModeVars_4
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&68]
ReadModeVars_4
        LDR     r2, [ip, #&7C]
        TEQ     r2, #0
        BEQ     ReadModeVars_5
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&7C]
ReadModeVars_5
        LDMFD   sp!, {r0-r3, pc}

ModeVduVarList
        DCD     &00000004
        DCD     &00000005
        DCD     &00000003
        DCD     &0000000A
        DCD     &FFFFFFFF

SWIHandler
        LDR     ip, [ip]
        TEQ     fp, #&3E
        BEQ     EnableDither
        TEQ     fp, #&3F
        BEQ     DisableDither
        TEQ     fp, #&3C
        BEQ     ReadDitherState
        TEQ     fp, #&3D
        BEQ     SuspendDither
        CMP     fp, #&20
        BHS     SWINotKnown
        CMP     fp, #&E
        BHS     SWIHandler_2
        LDR     sl, [ip, #&C]
        TST     sl, #1
        BEQ     SWIHandler_2
        TST     sl, #2
        BNE     SWIHandler_1
        STMFD   sp!, {r8, sb, lr}
        MOV     r8, fp
        MOV     sb, #&22
        SWI     &20034 ; XOS_CallAVector
        LDMFD   sp!, {r8, sb, pc}
SWIHandler_1
        BIC     sl, sl, #2
        STR     sl, [ip, #&C]
SWIHandler_2
        STR     sp, [ip, #4]
        STR     lr, [ip, #8]
        MRS     sl, CPSR
        BIC     sl, sl, #&80
        MSR     CPSR_c, sl
        LDR     sl, [ip, #&64]
        TEQ     sl, #0
        BPL     SWIHandler_3
        BL      InvalidatePalette
        LDR     lr, [ip, #8]
SWIHandler_3
        CMP     fp, #&20
        ADDLO   pc, pc, fp, lsl #2
        B       SWINotKnown
        B       SelectTable
        B       SelectGCOLTable
        B       ReturnGCOL
        B       SetGCOL
        B       ReturnColourNumber
        B       ReturnGCOLForMode
        B       ReturnColourNumberForMode
        B       ReturnOppGCOL
        B       SetOppGCOL
        B       ReturnOppColourNumber
        B       ReturnOppGCOLForMode
        B       ReturnOppColourNumberForMode
        B       GCOLToColourNumber
        B       ColourNumberToGCOL
        B       Info
        B       Control
        B       ReturnColourPattern
        B       ReturnColourPatternTable
        B       InvalidatePalette
        B       Antialias
        B       ReadPalette
        B       ReturnColourPatternArray
        B       SetHalftone
        B       ReturnHalftone
        B       SetHalftoneOrigin
        B       ReturnHalftoneOrigin
        B       SelectHalftoneTable
        B       ReturnHalftoneIntensity
        B       ReturnHalftoneTable
        B       SetScreen
        B       CacheScreen
        B       SelectColourPatternTable

SWINotKnown
        ADD     r0, pc, #4
        MSR     CPSR_f, #&10000000
        MOV     pc, lr

ErrSWIUnknown
        DCD     &000001E6
        DCB     "SWI not known"
        DCB     &00,&00,&00

EnableDither
        MOV     fp, #1
        STR     fp, [ip, #&C]
        MVN     fp, #0
        STR     fp, [ip, #&64]
        ExitOK

DisableDither
        MOV     fp, #0
        STR     fp, [ip, #&C]
        MVN     fp, #0
        STR     fp, [ip, #&64]
        ExitOK

ReadDitherState
        LDR     r0, [ip, #&C]
        ExitOK

SuspendDither
        LDR     fp, [ip, #&C]
        TST     fp, #1
        ORRNE   fp, fp, #2
        STRNE   fp, [ip, #&C]
        ExitOK

Info
        LDR     r0, [ip]
        ExitOK

Control
        AND     sl, r0, #&F
        AND     fp, r1, #&F
        ORR     fp, fp, #&70000
        LDR     r0, [ip]
        AND     r0, r0, fp
        EOR     r0, r0, sl
        STR     r0, [ip]
        ExitOK

InvalidatePalette
        STMFD   sp!, {r0-r4, lr}
        MOV     lr, #0
        STR     lr, [ip, #&54]
        LDR     r0, [ip, #&20]
        CMP     r0, #4
        MOVHS   r0, #0
        BHS     InvalidatePalette_1
        BL      SelectPatternPointers
        BL      ReadHardwarePalette
        BL      FindPaletteType
InvalidatePalette_1
        STR     lr, [ip, #&64]
        LDR     r2, [ip, #&60]
        TEQ     r2, #0
        BEQ     InvalidatePalette_2
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&60]
InvalidatePalette_2
        LDR     r2, [ip, #&68]
        TEQ     r2, #0
        BEQ     InvalidatePalette_3
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&68]
InvalidatePalette_3
        LDR     r2, [ip, #&7C]
        TEQ     r2, #0
        BEQ     InvalidatePalette_4
        MOV     r0, #7
        SWI     &2001E ; XOS_Module
        MOV     lr, #0
        STR     lr, [ip, #&7C]
InvalidatePalette_4
        ExitOK r0, r4

SetHalftone
        ADD     sl, ip, #&28
        STMIA   sl, {r0-r7}
        ExitOK

ReturnHalftone
        LDR     r0, [ip, #&28]
        TEQ     r0, #0
        ADDNE   sl, ip, #&2C
        LDMNEIA sl, {r1-r7}
        ExitOK

SetHalftoneOrigin
        STMFD   sp!, {r0-r7, lr}
        SUB     sp, sp, #&14
        ADR     r0, PaletteVduVarList
        MOV     r1, sp
        SWI     &20031 ; XOS_ReadVduVariables
        LDMIA   sp, {r0-r4, r6, r7}
        ADD     sp, sp, #&14
        LDR     r5, [ip, #&20]
        ADD     r4, r4, #1
        ADD     r0, r6, r0
        ADD     r1, r7, r1
        MOV     r0, r0, ASR r2
        MOV     r0, r0, LSL r5
        SUB     r1, r4, r1, asr r3
        ADD     lr, ip, #&4C
        STMIA   lr, {r0, r1}
        ExitOK r0, r7

PaletteVduVarList
        DCD     &00000088
        DCD     &00000089
        DCD     &00000004
        DCD     &00000005
        DCD     &0000000C
        DCD     &FFFFFFFF

ReturnHalftoneOrigin
        ADD     sl, ip, #&4C
        LDMIA   sl, {r0, r1}
        ExitOK

ReadPalette
        STMFD   sp!, {r0-sb, lr}
        BL      ModeToDepth
        BL      SelectPatternPointersForMode
        SUB     r1, r1, r0
        TEQ     r1, #8
        LDMEQIA r0, {r3, r4}
        STMEQIA r2, {r3, r4}
        BEQ     ReadPalette_2
        TEQ     r1, #&10
        LDMEQIA r0, {r3-r6}
        STMEQIA r2, {r3-r6}
        BEQ     ReadPalette_2
ReadPalette_1
        LDMIA   r0!, {r3-sl}
        STMIA   r2!, {r3-sl}
        LDMIA   r0!, {r3-sl}
        STMIA   r2!, {r3-sl}
        SUBS    r1, r1, #&40
        BNE     ReadPalette_1
ReadPalette_2
        ExitOK r0, sb

ErrBadMode
        DCD     &00803003
        DCB     "Bad mode"
        DCB     &00,&00,&00,&00
ReadPalette_3
        ADR     r0, ErrBadMode

ReturnError
        LDR     sp, [ip, #4]
        LDR     lr, [ip, #8]
        ExitErr

SetOppGCOL
        LDR     r2, [ip, #&20]
        AND     r3, r3, #&80
        STMFD   sp!, {r1-sb, lr}
        BL      ReturnOppGCOL
SetOppGCOL_1
        STMFD   sp!, {r0}
SetOppGCOL_2
        LDR     r2, [ip, #&20]
        TEQ     r2, #5
        MOVEQ   r6, r0
        MOVEQ   r8, r0
        BEQ     SetGCOLCore_8
        TEQ     r2, #3
        BLEQ    GCOLToColourNumber
        CMP     r2, #1
        ORRLT   r0, r0, r0, lsl #1
        ORRLE   r0, r0, r0, lsl #2
        CMP     r2, #3
        ORRLT   r0, r0, r0, lsl #4
        ORRLE   r0, r0, r0, lsl #8
        ORR     r6, r0, r0, lsl #16
        ORR     r8, r0, r0, lsl #16
        B       SetGCOLCore_8

SetGCOL
        AND     r3, r3, #&80

SetGCOLCore
        LDR     r2, [ip, #&20]
        STMFD   sp!, {r1-sb, lr}
        LDR     lr, [ip, #&28]
        TEQ     lr, #0
        BNE     BuildFromPalette_14
        LDR     lr, [ip]
        TST     lr, #&10000
        BEQ     SetGCOLCore_1
        BL      ReturnGCOL
        B       SetOppGCOL_1
SetGCOLCore_1
        TEQ     r2, #5
        MOVEQ   r0, r0, LSR #8
        BEQ     SetOppGCOL_1
        TEQ     r2, #4
        BNE     SetGCOLCore_2
        TEQ     lr, #0
        BNE     Build16bpp
        BL      ReturnGCOL
        B       SetOppGCOL_1
SetGCOLCore_2
        LDR     sb, [ip, #&64]
        TEQ     sb, #1
        TEQEQ   r2, #3
        BNE     SetGCOLCore_3
        BL      ReturnGCOL
        B       SetOppGCOL_1
SetGCOLCore_3
        TST     lr, #4
        TSTEQ   lr, #&20000
        BNE     SelectPatternBuilder
        TEQ     lr, #0
        BEQ     SetGCOLCore_4
        TEQ     sb, #1
        BEQ     SelectPatternBuilder
SetGCOLCore_4
        TEQ     sb, #3
        TEQEQ   r2, #3
        BEQ     SetGCOLCore_10
        TEQ     r2, #2
        EOREQ   lr, lr, #8
        TSTEQ   lr, #8
        BEQ     SetGCOLCore_14
        TEQ     r2, #3
        EOREQ   lr, lr, #8
        TSTEQ   lr, #8
        BEQ     BuildDepthPattern
        TST     lr, #3
        BNE     SetGCOLCore_5
        BL      ReturnGCOL
        B       SetOppGCOL_1
SetGCOLCore_5
        TST     lr, #2
        BNE     SetGCOLCore_10
        MOV     lr, #&FF
        AND     r7, lr, r0, lsr #8
        AND     r8, lr, r0, lsr #16
        AND     sb, lr, r0, lsr #24
        BL      ReturnGCOL
        STMFD   sp!, {r0}
        MOV     r2, r0
        MOV     lr, #&FF
        AND     r4, lr, fp, lsr #8
        AND     r5, lr, fp, lsr #16
        AND     r6, lr, fp, lsr #24
        RSB     r4, r4, r7, lsl #1
        RSB     r5, r5, r8, lsl #1
        RSB     r6, r6, sb, lsl #1
        BL      ConvertColourForDepth
SetGCOLCore_6
        TEQ     r0, r2
        BEQ     SetOppGCOL_2
        MOV     r1, r2
        LDR     fp, [ip, #&20]
        TEQ     fp, #3
        BNE     SetGCOLCore_7
        BL      GCOLToColourNumber
        MOV     r1, r0
        MOV     r0, r2
        BL      GCOLToColourNumber
SetGCOLCore_7
        CMP     r0, r1
        EORHI   r0, r1, r0
        EORHI   r1, r0, r1
        EORHI   r0, r1, r0
        CMP     fp, #1
        ORRLT   r0, r0, r1, lsl #1
        ORRLT   r0, r0, r0, lsl #2
        ORREQ   r0, r0, r1, lsl #2
        CMP     fp, #2
        ORRLT   r0, r0, r0, lsl #4
        ORREQ   r0, r0, r1, lsl #4
        ORRLE   r0, r0, r0, lsl #8
        ORRGT   r0, r0, r1, lsl #8
        ORR     r6, r0, r0, lsl #16
        CMP     fp, #1
        MOVLT   r8, r6, ROR #1
        MOVEQ   r8, r6, ROR #2
        CMP     fp, #2
        MOVEQ   r8, r6, ROR #4
        MOVGT   r8, r6, ROR #8
SetGCOLCore_8
        ADD     lr, ip, #&4C
        LDMIA   lr, {r0, r1}
        AND     r0, r0, #&1F
        RSB     r0, r0, #&20
        TST     r1, #1
        EORNE   r6, r8, r6
        EORNE   r8, r6, r8
        EORNE   r6, r8, r6
        ADD     lr, sp, #&C
        LDMIA   lr, {r3, r4}
        TEQ     r3, #0
        BMI     SetGCOLCore_9
        AND     r4, r4, #7
        ADR     sb, DitherMaskTable
        ADD     sb, sb, r4, lsl #4
        LDMIA   sb, {sb-fp, lr}
        ORR     r5, sb, r6, ror r0
        EOR     r5, sl, r5
        ORR     r6, fp, r6, ror r0
        EOR     r6, lr, r6
        ORR     r7, sb, r8, ror r0
        EOR     r7, sl, r7
        ORR     r8, fp, r8, ror r0
        EOR     r8, lr, r8
        LDR     r1, [ip, #&10]
        TST     r3, #&80
        ADDNE   r1, r1, #&40
        STMIA   r1!, {r5-r8}
        STMIA   r1!, {r5-r8}
        STMIA   r1!, {r5-r8}
        STMIA   r1!, {r5-r8}
        ExitOK r0, sb
SetGCOLCore_9
        MOV     r5, r6, ROR r0
        MOV     r7, r6, ROR r0
        MOV     r6, r8, ROR r0
        MOV     r8, r8, ROR r0
        STMIA   r4!, {r5-r8}
        STMIA   r4!, {r5-r8}
        ExitOK r0, sb

DitherMaskTable
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
SetGCOLCore_10
        MOV     r3, r0
        MOV     lr, #&FF
        AND     r7, lr, r0, lsr #8
        AND     r8, lr, r0, lsr #16
        AND     sb, lr, r0, lsr #24
        BL      ReturnGCOL
        STMFD   sp!, {r0}
        MOV     r2, r0
        MOV     lr, #&FF
        AND     r4, lr, fp, lsr #8
        AND     r5, lr, fp, lsr #16
        AND     r6, lr, fp, lsr #24
        ADD     r7, r7, r7, lsl #1
        ADD     r8, r8, r8, lsl #1
        ADD     sb, sb, sb, lsl #1
        SUB     r7, r7, r4, lsl #1
        SUB     r8, r8, r5, lsl #1
        SUB     sb, sb, r6, lsl #1
        MOV     r4, r7
        MOV     r5, r8
        MOV     r6, sb
        BL      ConvertColourForDepth
        MOV     sl, r3
        MOV     r3, r0
        MOV     lr, #&FF
        AND     r4, lr, fp, lsr #8
        AND     r5, lr, fp, lsr #16
        SUB     r4, r7, r4
        SUB     r5, r8, r5
        SUB     r6, sb, fp, lsr #24
        AND     r7, lr, sl, lsr #8
        AND     r8, lr, sl, lsr #16
        ADD     r4, r4, r7
        ADD     r5, r5, r8
        ADD     r6, r6, sl, lsr #24
        BL      ConvertColourForDepth
        TEQ     r0, r3
        BEQ     SetGCOLCore_6
        LDR     lr, [ip, #&20]
        CMP     lr, #1
        BLT     SetGCOLCore_11
        BEQ     SetGCOLCore_12
        TEQ     lr, #2
        BEQ     SetGCOLCore_13
        BL      GCOLToColourNumber
        MOV     r1, r0
        MOV     r0, r2
        BL      GCOLToColourNumber
        MOV     r2, r0
        MOV     r0, r3
        BL      GCOLToColourNumber
        CMP     r0, r1
        EORHI   r0, r1, r0
        EORHI   r1, r0, r1
        EORHI   r0, r1, r0
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        ORR     r6, r2, r0, lsl #8
        ORR     r8, r1, r2, lsl #8
        ORREQ   r6, r6, r6, lsl #16
        ORREQ   r8, r8, r8, lsl #16
        ORRNE   r6, r6, r8, lsl #16
        MOVNE   r8, r6, ROR #&10
        B       SetGCOLCore_8
SetGCOLCore_11
        CMP     r3, r0
        EORHI   r3, r0, r3
        EORHI   r0, r3, r0
        EORHI   r3, r0, r3
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        ORR     r6, r2, r3, lsl #1
        ORR     r8, r0, r2, lsl #1
        ORREQ   r6, r6, r6, lsl #2
        ORREQ   r8, r8, r8, lsl #2
        ORRNE   r6, r6, r8, lsl #2
        MOVNE   r8, r6, ROR #2
        ORR     r6, r6, r6, ror #4
        ORR     r8, r8, r8, ror #4
        ORR     r6, r6, r6, ror #8
        ORR     r8, r8, r8, ror #8
        ORR     r6, r6, r6, ror #16
        ORR     r8, r8, r8, ror #16
        B       SetGCOLCore_8
SetGCOLCore_12
        CMP     r3, r0
        EORHI   r3, r0, r3
        EORHI   r0, r3, r0
        EORHI   r3, r0, r3
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        ORR     r6, r2, r3, lsl #2
        ORR     r8, r0, r2, lsl #2
        ORREQ   r6, r6, r6, lsl #4
        ORREQ   r8, r8, r8, lsl #4
        ORRNE   r6, r6, r8, lsl #4
        MOVNE   r8, r6, ROR #4
        ORR     r6, r6, r6, ror #8
        ORR     r8, r8, r8, ror #8
        ORR     r6, r6, r6, ror #16
        ORR     r8, r8, r8, ror #16
        B       SetGCOLCore_8
SetGCOLCore_13
        CMP     r3, r0
        EORHI   r3, r0, r3
        EORHI   r0, r3, r0
        EORHI   r3, r0, r3
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        ORR     r6, r2, r3, lsl #4
        ORR     r8, r0, r2, lsl #4
        ORREQ   r6, r6, r6, lsl #8
        ORREQ   r8, r8, r8, lsl #8
        ORRNE   r6, r6, r8, lsl #8
        MOVNE   r8, r6, ROR #8
        ORR     r6, r6, r6, ror #16
        ORR     r8, r8, r8, ror #16
        B       SetGCOLCore_8

PatternMaskTable
        DCD     &00000000
        DCD     &0000FF00
        DCD     &00FF0000
        DCD     &00FFFF00
        DCD     &FF000000
        DCD     &FF00FF00
        DCD     &FFFF0000
        DCD     &FFFFFF00
SetGCOLCore_14
        LDR     lr, [ip, #&54]
        TEQ     lr, #0
        BNE     SetGCOLCore_16
        STMFD   sp!, {r0}
        LDR     r0, [ip, #&20]
        BL      SelectPatternPointers
        ADR     r3, PatternMaskTable
        ADD     r4, ip, #&58
        MOV     r5, #8
SetGCOLCore_15
        LDR     r2, [r3], #4
        BL      SearchPalette
        STRB    r2, [r4], #1
        SUBS    r5, r5, #1
        BNE     SetGCOLCore_15
        MVN     lr, #0
        STR     lr, [ip, #&54]
        LDMFD   sp!, {r0}
SetGCOLCore_16
        MOV     lr, #&FF
        STR     lr, [sp, #-4]!
        AND     r7, lr, r0, lsr #8
        AND     r8, lr, r0, lsr #16
        AND     sb, lr, r0, lsr #24
        ORR     r7, r7, r7, lsl #8
        ORR     r8, r8, r8, lsl #8
        ORR     sb, sb, sb, lsl #8
        ADD     lr, ip, #&14
        LDMIA   lr, {sl, fp}
        TEQ     sl, fp
        BNE     RotatePattern_1
        LDR     lr, [ip]
        TST     lr, #&40000
        BNE     Build4bpp
        ADR     lr, PatternSelectTable
        MOVS    r7, r7, LSR #&C
        ADDHS   r7, r7, #1
        MOVS    r8, r8, LSR #&C
        ADDHS   r8, r8, #1
        MOVS    sb, sb, LSR #&C
        ADDHS   sb, sb, #1
        ADD     r0, lr, r7, lsl #4
        LDMIA   r0, {r0-r3}
        ADD     r4, lr, r8, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r0, r0, r4, lsl #1
        ORR     r1, r1, r5, lsl #1
        ORR     r2, r2, r6, lsl #1
        ORR     r3, r3, r7, lsl #1
        ADD     r4, lr, sb, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r8, r0, r4, lsl #2
        ORR     sb, r1, r5, lsl #2
        ORR     sl, r2, r6, lsl #2
        ORR     fp, r3, r7, lsl #2
        ADD     r0, ip, #&58
        MOV     r1, #7
        MOV     r2, r8
        BL      RotatePattern
        MOV     r8, r2
        MOV     r2, sb
        BL      RotatePattern
        MOV     sb, r2
        MOV     r2, sl
        BL      RotatePattern
        MOV     sl, r2
        MOV     r2, fp
        BL      RotatePattern
        MOV     fp, r2
        B       FinishPattern

RotatePattern
        AND     r4, r1, r2
        AND     r5, r1, r2, lsr #8
        AND     r6, r1, r2, lsr #16
        AND     r7, r1, r2, lsr #24
        LDRB    r4, [r0, r4]
        LDRB    r5, [r0, r5]
        LDRB    r6, [r0, r6]
        LDRB    r7, [r0, r7]
        ORR     r2, r4, r5, lsl #4
        ORR     r2, r2, r6, lsl #8
        ORR     r2, r2, r7, lsl #12
        ORR     r2, r2, r2, lsl #16
        MOV     pc, lr

PatternSelectTable
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00010000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &01000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000101
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000101
        DCD     &00010001
        DCD     &01010100
        DCD     &00010001
        DCD     &01000101
        DCD     &00010001
        DCD     &01010101
        DCD     &00010001
        DCD     &01010101
        DCD     &00010001
        DCD     &01010101
        DCD     &00010101
        DCD     &01010101
        DCD     &00010001
        DCD     &01010101
        DCD     &00010101
        DCD     &01010101
        DCD     &01010001
        DCD     &01010101
        DCD     &00010101
        DCD     &01010101
        DCD     &01010101
        DCD     &01010101
        DCD     &01010101
        DCD     &01010101
        DCD     &01010101
        DCD     &01010101
RotatePattern_1
        ADR     lr, Pattern16Masks
        MOVS    r7, r7, LSR #&B
        ADDHS   r7, r7, #1
        MOVS    r8, r8, LSR #&B
        ADDHS   r8, r8, #1
        MOVS    sb, sb, LSR #&B
        ADDHS   sb, sb, #1
        ADD     r0, lr, r7, lsl #4
        LDMIA   r0, {r0-r3}
        ADD     r4, lr, r8, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r0, r0, r4, lsl #1
        ORR     r1, r1, r5, lsl #1
        ORR     r2, r2, r6, lsl #1
        ORR     r3, r3, r7, lsl #1
        ADD     r4, lr, sb, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r8, r0, r4, lsl #2
        ORR     sb, r1, r5, lsl #2
        ORR     sl, r2, r6, lsl #2
        ORR     fp, r3, r7, lsl #2
        ADD     r0, ip, #&58
        MOV     r1, r8
        BL      RemapNibbles
        MOV     r8, r2
        MOV     r1, sb
        BL      RemapNibbles
        MOV     sb, r2
        MOV     r1, sl
        BL      RemapNibbles
        MOV     sl, r2
        MOV     r1, fp
        BL      RemapNibbles
        MOV     fp, r2
        B       FinishPattern

RemapNibbles
        MOV     r1, r1, ROR #4
        LDRB    r2, [r0, r1, lsr #28]
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #4
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #8
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #12
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #16
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #20
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #24
        MOV     r1, r1, ROR #4
        LDRB    r3, [r0, r1, lsr #28]
        ORR     r2, r2, r3, lsl #28
        MOV     pc, lr

Pattern16Masks
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00010000
        DCD     &00000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &00000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &01000000
        DCD     &00010001
        DCD     &00000100
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000100
        DCD     &00010001
        DCD     &01000100
        DCD     &10010010
        DCD     &01000100
        DCD     &00010001
        DCD     &01000100
        DCD     &10010010
        DCD     &01000100
        DCD     &00101001
        DCD     &01000100
        DCD     &10101010
        DCD     &01000100
        DCD     &00101001
        DCD     &01000100
        DCD     &10101010
        DCD     &01000100
        DCD     &10101010
        DCD     &01000100
        DCD     &10101010
        DCD     &01000101
        DCD     &10101010
        DCD     &01000100
        DCD     &10101010
        DCD     &01000101
        DCD     &10101010
        DCD     &01010100
        DCD     &10101010
        DCD     &01000101
        DCD     &10101010
        DCD     &01010101
        DCD     &10101010
        DCD     &01010101
        DCD     &10101010
        DCD     &01010101
        DCD     &10101010
        DCD     &01011101
        DCD     &10101010
        DCD     &01010101
        DCD     &10101010
        DCD     &01011101
        DCD     &10101010
        DCD     &11010101
        DCD     &10101010
        DCD     &11011101
        DCD     &10101010
        DCD     &11010101
        DCD     &10101010
        DCD     &11011101
        DCD     &10101010
        DCD     &11011101
        DCD     &10110110
        DCD     &11011101
        DCD     &10101010
        DCD     &11011101
        DCD     &10110110
        DCD     &11011101
        DCD     &01101011
        DCD     &11011101
        DCD     &10110110
        DCD     &11011101
        DCD     &01110111
        DCD     &11011101
        DCD     &01110111
        DCD     &11011101
        DCD     &01110111
        DCD     &11011101
        DCD     &01110111
        DCD     &11011111
        DCD     &01110111
        DCD     &11011101
        DCD     &01110111
        DCD     &11011111
        DCD     &01110111
        DCD     &11111101
        DCD     &01110111
        DCD     &11011111
        DCD     &01110111
        DCD     &11111111
        DCD     &01110111
        DCD     &11111111
        DCD     &01110111
        DCD     &11111111
        DCD     &01111111
        DCD     &11111111
        DCD     &01110111
        DCD     &11111111
        DCD     &01111111
        DCD     &11111111
        DCD     &11110111
        DCD     &11111111
        DCD     &01111111
        DCD     &11111111
        DCD     &11111111
        DCD     &11111111
        DCD     &11111111
        DCD     &11111111
        DCD     &11111111
        DCD     &11111111

Build4bpp
        MOV     r5, r7
        CMP     r5, r8
        MOVHI   r5, r8
        CMP     r5, sb
        MOVHI   r5, sb
        SUB     r7, r7, r5
        SUB     r8, r8, r5
        SUB     sb, sb, r5
        MOVS    r0, r7, LSR #&C
        ADDHS   r0, r0, #1
        MOVS    r1, r8, LSR #&C
        ADDHS   r1, r1, #1
        MOVS    r2, sb, LSR #&C
        ADDHS   r2, r2, #1
        SUB     r7, r7, r0, lsl #12
        SUB     r8, r8, r1, lsl #12
        SUB     sb, sb, r2, lsl #12
        ADD     r3, r8, r8, lsl #1
        ADD     r3, r3, r7, lsl #1
        ADD     r3, r3, sb
        ADD     r3, r3, r3, asr #2
        ADD     r3, r3, r3, asr #4
        ADD     r3, r3, r3, asr #8
        MOVS    r3, r3, ASR #3
        ADCS    r3, r3, r5
        MOVMI   r3, #0
        MOV     r6, r0
        CMP     r6, r1
        MOVLO   r6, r1
        CMP     r6, r2
        MOVLO   r6, r2
        CMP     r6, #&F
        MOVHI   r3, #&100000
        MOVEQ   r3, r3, LSL #4
        BHS     Build4bpp_1
        ADD     lr, pc, #&60 ; with next instruction: PatternPaletteTable2
        ADD     lr, lr, #&1500
        LDR     r4, [lr, -r6, lsl #1]
        MOV     r4, r4, LSL #&10
        MOV     r4, r4, LSR #&10
        MUL     r3, r4, r3
        MOVS    r3, r3, LSR #&C
        ADDHS   r3, r3, #1
Build4bpp_1
        STMFD   sp!, {r0-r2, r6}
        MOVS    r2, r3, LSR #8
        ADDHS   r2, r2, #1
        CMP     r2, #&FF
        MOVHI   r2, #&FF
        ADD     r0, ip, #&84
        ADD     r1, r0, #&40
        MOV     fp, r1
        MVN     r3, #0
        MVN     r4, #0
        MOV     r5, #&80000000
        MVN     r6, #&80000000
        MOV     sl, #&FF
Build4bpp_2
        LDMDB   fp!, {sb}
        AND     r7, sl, sb, lsr #8
        AND     r8, sl, sb, lsr #16
        AND     sb, sl, sb, lsr #24
        TEQ     r7, r8
        TEQEQ   r7, sb
        BNE     Build4bpp_3
        CMP     r7, r2
        CMPLE   r5, r7
        MOVLE   r5, r7
        SUBLE   r3, fp, r0
        CMP     r7, r2
        CMPGE   r6, r7
        MOVGE   r6, r7
        SUBGE   r4, fp, r0
Build4bpp_3
        TEQ     r0, fp
        BNE     Build4bpp_2
        ORRS    lr, r3, r4
        BPL     Build4bpp_5
        MOV     fp, r1
        STMFD   sp!, {r3-r6}
        MVN     r5, #&80000000
        MOV     r6, #&80000000
Build4bpp_4
        LDMDB   fp!, {sb}
        AND     r7, sl, sb, lsr #8
        AND     r8, sl, sb, lsr #16
        AND     sb, sl, sb, lsr #24
        ADD     r8, r8, r8, lsl #1
        ADD     r7, r8, r7, lsl #1
        ADD     r7, r7, sb
        CMP     r5, r7
        MOVGT   r5, r7
        SUBGT   r3, fp, r0
        CMP     r6, r7
        MOVLT   r6, r7
        SUBLT   r4, fp, r0
        TEQ     r0, fp
        BNE     Build4bpp_4
        LDMFD   sp!, {r7, r8, sl, fp}
        TEQ     r7, #0
        MOVPL   r3, r7
        MOVPL   r5, sl
        MOVMI   r5, #0
        TEQ     r8, #0
        MOVPL   r4, r8
        MOVPL   r6, fp
        MOVMI   r6, #&FF
Build4bpp_5
        MOV     r8, r3, LSR #2
        MOV     sb, r4, LSR #2
        SUB     r6, r6, r5
        SUB     r2, r2, r5
        ADD     lr, pc, #&20 ; with next instruction: PatternPaletteTable
        ADD     lr, lr, #&1400
        LDR     r6, [lr, r6, lsl #1]
        MOV     r6, r6, LSL #&10
        MOV     r6, r6, LSR #&10
        MUL     r2, r6, r2
        LDR     r0, [sp, #&C]
        RSB     r1, r0, #&10
        MUL     r2, r1, r2
        MOVS    r2, r2, LSR #4
        ADC     r2, r2, r0, lsl #12
        ORR     r8, r8, r8, lsl #4
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        ORR     sb, sb, sb, lsl #4
        ORR     sb, sb, sb, lsl #8
        ORR     sb, sb, sb, lsl #16
        MOV     r2, r2, LSR #&C
        CMP     r2, #&10
        MOVHI   r2, #&10
        ADD     lr, pc, #&74 ; with next instruction: Pattern8bppMasks
        ADD     lr, lr, #&F00
        ADD     lr, lr, r2, lsl #3
        LDMIA   lr, {r0, r2}
        MOV     r1, r0, LSR #&10
        MOV     r3, r2, LSR #&10
        BIC     r0, r0, r1, lsl #16
        BIC     r2, r2, r3, lsl #16
        ORR     r0, r0, r0, lsl #16
        ORR     r1, r1, r1, lsl #16
        ORR     r2, r2, r2, lsl #16
        ORR     r3, r3, r3, lsl #16
        BIC     r4, r8, r0
        BIC     r5, r8, r1
        BIC     r6, r8, r2
        BIC     r7, r8, r3
        AND     r0, sb, r0
        AND     r1, sb, r1
        AND     r2, sb, r2
        AND     r3, sb, r3
        ORR     r8, r0, r4
        ORR     sb, r1, r5
        ORR     sl, r2, r6
        ORR     fp, r3, r7
        ADD     lr, ip, #&6C
        STMIA   lr, {r8-fp}
        LDMFD   sp!, {r7-sb}
        SUB     lr, pc, #&7C ; with next instruction: PatternSelectTable
        SUB     lr, lr, #&600
        ADD     r0, lr, r7, lsl #4
        LDMIA   r0, {r0-r3}
        ADD     r4, lr, r8, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r0, r0, r4, lsl #1
        ORR     r1, r1, r5, lsl #1
        ORR     r2, r2, r6, lsl #1
        ORR     r3, r3, r7, lsl #1
        ADD     r4, lr, sb, lsl #4
        LDMIA   r4, {r4-r7}
        ORR     r8, r0, r4, lsl #2
        ORR     sb, r1, r5, lsl #2
        ORR     sl, r2, r6, lsl #2
        ORR     fp, r3, r7, lsl #2
        ADD     r0, ip, #&58
        MOV     r1, #7
        MOV     r2, r8
        BL      RotatePattern
        MOV     r8, r2
        MOV     r2, sb
        BL      RotatePattern
        MOV     sb, r2
        MOV     r2, sl
        BL      RotatePattern
        MOV     sl, r2
        MOV     r2, fp
        BL      RotatePattern
        MOV     fp, r2
        LDMFD   sp!, {r6}
        ADD     lr, pc, #&8C ; with next instruction: Pattern8bppMasks
        ADD     lr, lr, #&E00
        ADD     lr, lr, r6, lsl #3
        LDMIA   lr, {r0, r2}
        MOV     r1, r0, LSR #&10
        MOV     r3, r2, LSR #&10
        BIC     r0, r0, r1, lsl #16
        BIC     r2, r2, r3, lsl #16
        ORR     r0, r0, r0, lsl #16
        ORR     r1, r1, r1, lsl #16
        ORR     r2, r2, r2, lsl #16
        ORR     r3, r3, r3, lsl #16
        ADD     lr, ip, #&6C
        LDMIA   lr, {r4-r7}
        BIC     r4, r4, r0
        BIC     r5, r5, r1
        BIC     r6, r6, r2
        BIC     r7, r7, r3
        AND     r8, r8, r0
        AND     sb, sb, r1
        AND     sl, sl, r2
        AND     fp, fp, r3
        ORR     r8, r8, r4
        ORR     sb, sb, r5
        ORR     sl, sl, r6
        ORR     fp, fp, r7
        B       FinishPattern

PatternLevelTable
        DCD     &00000000
        DCD     &00000000
        DCD     &01010101
        DCD     &02010101
        DCD     &02020202
        DCD     &03030202
        DCD     &03030303
        DCD     &04040303
        DCD     &04040404
        DCD     &05050504
        DCD     &05050505
        DCD     &06060606
        DCD     &06060606
        DCD     &07070707
        DCD     &08070707
        DCD     &08080808
        DCD     &09090808
        DCD     &09090909
        DCD     &0A0A0A09
        DCD     &0A0A0A0A
        DCD     &0B0B0B0A
        DCD     &0B0B0B0B
        DCD     &0C0C0C0C
        DCD     &0D0C0C0C
        DCD     &0D0D0D0D
        DCD     &0E0D0D0D
        DCD     &0E0E0E0E
        DCD     &0F0F0E0E
        DCD     &0F0F0F0F
        DCD     &1010100F
        DCD     &11111010
        DCD     &12121111
        DCD     &13121212
        DCD     &14131313
        DCD     &15141414
        DCD     &16151515
        DCD     &17161616
        DCD     &18171717
        DCD     &18181818
        DCD     &19191919
        DCD     &1A1A1A1A
        DCD     &1B1B1B1B
        DCD     &1C1C1C1C
        DCD     &1D1D1D1D
        DCD     &1E1E1E1E
        DCD     &1F1F1F1E
        DCD     &2020201F
        DCD     &21212120
        DCD     &22222221
        DCD     &23232322
        DCD     &24242423
        DCD     &25252424
        DCD     &26262525
        DCD     &27272626
        DCD     &28282727
        DCD     &29292828
        DCD     &2A2A2929
        DCD     &2B2A2A2A
        DCD     &2C2B2B2B
        DCD     &2D2C2C2C
        DCD     &2E2D2D2D
        DCD     &2F2E2E2E
        DCD     &302F2F2F
        DCD     &30303030

BuildDepthPattern
        STR     r2, [ip, #&24]
        MOV     lr, #&FF
        STR     lr, [sp, #-4]!
        AND     r7, lr, r0, lsr #8
        AND     r8, lr, r0, lsr #16
        AND     sb, lr, r0, lsr #24
        LDR     r0, [ip, #&64]
        ADD     pc, pc, r0, lsl #2
        DCD     &E1A00000
        B       BuildDepthPattern_1
        B       SelectPatternBuilder_1
        B       BuildDepthPattern_4
BuildDepthPattern_1
        ADR     lr, PatternLevelTable
        LDRB    r7, [lr, r7]
        LDRB    r8, [lr, r8]
        LDRB    sb, [lr, sb]
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildDepthPattern_3
        ADD     lr, pc, #&44 ; with next instruction: PatternRowXorTable
        ADD     lr, lr, #&900
        STMFD   sp!, {r8, sb, ip}
        ADD     ip, r7, #&10
        MOVS    fp, r7, LSL #&1B
        MOV     fp, #0
        ORRMI   fp, fp, #7
        ORRHS   fp, fp, #&13
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1B
        MOV     ip, #0
        ORRMI   ip, ip, #7
        ORRHS   ip, ip, #&13
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r7, #&F
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r0, r4, r8
        ORR     r1, r5, sb
        ORR     r2, r6, sl
        ORR     r3, r7, fp
        LDMFD   sp!, {r8}
        ADD     ip, r8, #&10
        MOVS    fp, r8, LSL #&1B
        MOV     fp, #0
        ORRMI   fp, fp, #&23
        ORRHS   fp, fp, #&43
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1B
        MOV     ip, #0
        ORRMI   ip, ip, #&23
        ORRHS   ip, ip, #&43
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r8, #&F
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ORR     r0, r0, r4
        ORR     r1, r1, r5
        ORR     r2, r2, r6
        ORR     r3, r3, r7
        LDMFD   sp!, {sb}
        ADD     ip, sb, #&10
        MOVS    fp, sb, LSL #&1B
        MOV     fp, #0
        ORRMI   fp, fp, #&B
        ORRHS   fp, fp, #&83
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1B
        MOV     ip, #0
        ORRMI   ip, ip, #&B
        ORRHS   ip, ip, #&83
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, sb, #&F
BuildDepthPattern_2
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ORR     r8, r0, r4
        ORR     sb, r1, r5
        ORR     sl, r2, r6
        ORR     fp, r3, r7
        LDMFD   sp!, {ip}
        B       FinishPattern
BuildDepthPattern_3
        ADD     lr, pc, #&C8 ; with next instruction: PatternMaskTable2
        ADD     lr, lr, #&800
        MOV     r7, r7, LSR #1
        MOV     r8, r8, LSR #1
        MOV     sb, sb, LSR #1
        STMFD   sp!, {r8, sb, ip}
        ADD     ip, r7, #8
        MOVS    fp, r7, LSL #&1C
        MOV     fp, #0
        ORRMI   fp, fp, #7
        ORRHS   fp, fp, #&13
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1C
        MOV     ip, #0
        ORRMI   ip, ip, #7
        ORRHS   ip, ip, #&13
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r7, #7
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r0, r4, r8
        ORR     r1, r5, sb
        ORR     r2, r6, sl
        ORR     r3, r7, fp
        LDMFD   sp!, {r8}
        ADD     ip, r8, #8
        MOVS    fp, r8, LSL #&1C
        MOV     fp, #0
        ORRMI   fp, fp, #&23
        ORRHS   fp, fp, #&43
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1C
        MOV     ip, #0
        ORRMI   ip, ip, #&23
        ORRHS   ip, ip, #&43
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r8, #7
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ORR     r0, r0, r4
        ORR     r1, r1, r5
        ORR     r2, r2, r6
        ORR     r3, r3, r7
        LDMFD   sp!, {sb}
        ADD     ip, sb, #8
        MOVS    fp, sb, LSL #&1C
        MOV     fp, #0
        ORRMI   fp, fp, #&B
        ORRHS   fp, fp, #&83
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        MOVS    ip, ip, LSL #&1C
        MOV     ip, #0
        ORRMI   ip, ip, #&B
        ORRHS   ip, ip, #&83
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, sb, #7
        B       BuildDepthPattern_2
BuildDepthPattern_4
        ORR     r7, r7, r7, lsl #8
        ORR     r8, r8, r8, lsl #8
        ORR     sb, sb, sb, lsl #8
        ADD     r7, r7, r7, lsl #2
        ADD     r8, r8, r8, lsl #2
        ADD     sb, sb, sb, lsl #2
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildDepthPattern_6
        ADD     lr, pc, #&44 ; with next instruction: PatternRowXorTable
        ADD     lr, lr, #&600
        MOVS    r7, r7, LSR #&C
        ADDHS   r7, r7, #1
        MOVS    r8, r8, LSR #&C
        ADDHS   r8, r8, #1
        MOVS    sb, sb, LSR #&C
        ADDHS   sb, sb, #1
        STMFD   sp!, {r8, sb, ip}
        MOV     fp, r7, LSR #4
        ADD     ip, r7, #&10
        MOV     ip, ip, LSR #4
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r7, #&F
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r0, r4, r8
        ORR     r1, r5, sb
        ORR     r2, r6, sl
        ORR     r3, r7, fp
        LDMFD   sp!, {r8}
        MOV     fp, r8, LSR #4
        ADD     ip, r8, #&10
        MOV     ip, ip, LSR #4
        ADD     fp, fp, fp, lsl #1
        ADD     ip, ip, ip, lsl #1
        MOV     fp, fp, LSL #1
        MOV     ip, ip, LSL #1
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r8, #&F
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ADD     r0, r0, r4
        ADD     r1, r1, r5
        ADD     r2, r2, r6
        ADD     r3, r3, r7
        LDMFD   sp!, {sb}
        MOV     fp, sb, LSR #4
        ADD     ip, sb, #&10
        MOV     ip, ip, LSR #4
        ADD     fp, fp, fp, lsl #3
        ADD     ip, ip, ip, lsl #3
        MOV     fp, fp, LSL #2
        MOV     ip, ip, LSL #2
        AND     r4, sb, #&F
BuildDepthPattern_5
        ADD     r4, lr, r4, lsl #4
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ADD     r8, r0, r4
        ADD     sb, r1, r5
        ADD     sl, r2, r6
        ADD     fp, r3, r7
        LDMFD   sp!, {ip}
        B       FinishPattern
BuildDepthPattern_6
        ADD     lr, pc, #&D8 ; with next instruction: PatternMaskTable2
        ADD     lr, lr, #&500
        MOVS    r7, r7, LSR #&D
        ADDHS   r7, r7, #1
        MOVS    r8, r8, LSR #&D
        ADDHS   r8, r8, #1
        MOVS    sb, sb, LSR #&D
        ADDHS   sb, sb, #1
        STMFD   sp!, {r8, sb, ip}
        MOV     fp, r7, LSR #3
        ADD     ip, r7, #8
        MOV     ip, ip, LSR #3
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r7, #7
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r0, r4, r8
        ORR     r1, r5, sb
        ORR     r2, r6, sl
        ORR     r3, r7, fp
        LDMFD   sp!, {r8}
        MOV     fp, r8, LSR #3
        ADD     ip, r8, #8
        MOV     ip, ip, LSR #3
        ADD     fp, fp, fp, lsl #1
        ADD     ip, ip, ip, lsl #1
        MOV     fp, fp, LSL #1
        MOV     ip, ip, LSL #1
        ORR     fp, fp, fp, lsl #8
        ORR     fp, fp, fp, lsl #16
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        AND     r4, r8, #7
        ADD     r4, lr, r4, lsl #4
        LDMIA   r4, {r4-r7}
        BIC     r8, fp, r4
        BIC     sb, fp, r5
        BIC     sl, fp, r6
        BIC     fp, fp, r7
        AND     r4, ip, r4
        AND     r5, ip, r5
        AND     r6, ip, r6
        AND     r7, ip, r7
        ORR     r4, r4, r8
        ORR     r5, r5, sb
        ORR     r6, r6, sl
        ORR     r7, r7, fp
        ADD     r0, r0, r4
        ADD     r1, r1, r5
        ADD     r2, r2, r6
        ADD     r3, r3, r7
        LDMFD   sp!, {sb}
        MOV     fp, sb, LSR #3
        ADD     ip, sb, #8
        MOV     ip, ip, LSR #3
        ADD     fp, fp, fp, lsl #3
        ADD     ip, ip, ip, lsl #3
        MOV     fp, fp, LSL #2
        MOV     ip, ip, LSL #2
        AND     r4, sb, #7
        B       BuildDepthPattern_5

Build16bpp
        STR     r2, [ip, #&24]
        MOV     lr, #&FF
        STR     lr, [sp, #-4]!
        AND     r7, lr, r0, lsr #8
        AND     r8, lr, r0, lsr #16
        AND     sb, lr, r0, lsr #24
        ORR     r7, r7, r7, lsl #8
        ORR     r8, r8, r8, lsl #8
        ORR     sb, sb, sb, lsl #8
        RSB     r7, r7, r7, lsl #5
        RSB     r8, r8, r8, lsl #5
        RSB     sb, sb, sb, lsl #5
        ADD     lr, pc, #&EC ; with next instruction: Pattern16bppMasks
        ADD     lr, lr, #0
        MOVS    r7, r7, LSR #&E
        ADDHS   r7, r7, #1
        MOVS    r8, r8, LSR #&E
        ADDHS   r8, r8, #1
        MOVS    sb, sb, LSR #&E
        ADDHS   sb, sb, #1
        MOV     sl, r7, LSR #2
        ADD     fp, r7, #4
        MOV     fp, fp, LSR #2
        ORR     sl, sl, sl, lsl #16
        ORR     fp, fp, fp, lsl #16
        AND     r2, r7, #3
        ADD     r2, lr, r2, lsl #3
        LDMIA   r2, {r2, r3}
        BIC     r4, sl, r2
        BIC     r5, sl, r3
        AND     r2, fp, r2
        AND     r3, fp, r3
        ORR     r0, r2, r4
        ORR     r1, r3, r5
        MOV     sl, r8, LSR #2
        ADD     fp, r8, #4
        MOV     fp, fp, LSR #2
        MOV     sl, sl, LSL #5
        ORR     sl, sl, sl, lsl #16
        MOV     fp, fp, LSL #5
        ORR     fp, fp, fp, lsl #16
        AND     r2, r8, #3
        ADD     r2, lr, r2, lsl #3
        LDMIA   r2, {r2, r3}
        BIC     r4, sl, r2
        BIC     r5, sl, r3
        AND     r2, fp, r2
        AND     r3, fp, r3
        ORR     r2, r2, r4
        ORR     r3, r3, r5
        ORR     r0, r0, r2
        ORR     r1, r1, r3
        MOV     sl, sb, LSR #2
        ADD     fp, sb, #4
        MOV     fp, fp, LSR #2
        MOV     sl, sl, LSL #&A
        ORR     sl, sl, sl, lsl #16
        MOV     fp, fp, LSL #&A
        ORR     fp, fp, fp, lsl #16
        AND     r2, sb, #3
        ADD     r2, lr, r2, lsl #3
        LDMIA   r2, {r2, r3}
        BIC     r4, sl, r2
        BIC     r5, sl, r3
        AND     r2, fp, r2
        AND     r3, fp, r3
        ORR     r2, r2, r4
        ORR     r3, r3, r5
        ORR     r8, r0, r2
        ORR     sb, r1, r3
        ORR     sl, r0, r2
        ORR     fp, r1, r3
        B       FinishPattern

Pattern16bppMasks
        DCD     &00000000
        DCD     &00000000
        DCD     &0000FFFF
        DCD     &00000000
        DCD     &0000FFFF
        DCD     &FFFF0000
        DCD     &FFFFFFFF
        DCD     &FFFF0000
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF

SelectPatternBuilder
        MOV     r2, r0
        LDR     r0, [ip, #&20]
        STR     r0, [ip, #&24]
        TEQ     r0, #3
        BLNE    SelectPatternPointers
        MOV     lr, #&FF
        STMFD   sp!, {lr}
        AND     r7, lr, r2, lsr #8
        AND     r8, lr, r2, lsr #16
        AND     sb, lr, r2, lsr #24
        BNE     BuildFromPalette
SelectPatternBuilder_1
        MOV     r4, #&4D
        MOV     r5, #&97
        MOV     r6, #&1C
        MUL     r2, r7, r4
        MLA     r2, r8, r5, r2
        MLA     r2, sb, r6, r2
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        LDR     r0, [ip, #&64]
        ADD     pc, pc, r0, lsl #2
        DCD     &F1A00000
        B       SelectPatternBuilder_2
        B       SelectPatternBuilder_3
        B       SelectPatternBuilder_5
        LDR     r0, [ip, #&20]
        BL      SelectPatternPointers
        B       BuildFromPalette_1
SelectPatternBuilder_2
        ADD     r2, r2, r2, lsr #8
        RSB     r2, r2, r2, lsl #4
        ADD     lr, pc, #8
        TEQ     r5, r6
        BNE     SelectPatternBuilder_7
        B       SelectPatternBuilder_6
        DCD     &03020100
        DCD     &2F2E2D2C
        DCD     &D3D2D1D0
        DCD     &FFFEFDFC
SelectPatternBuilder_3
        ADD     r2, r2, r2, lsr #8
        RSB     r2, r2, r2, lsl #8
        TEQ     r5, r6
        BNE     SelectPatternBuilder_4
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        MOV     r8, r2, LSR #4
        ADD     sb, r8, #1
        AND     r2, r2, #&F
        ADR     lr, PatternRowXorTable
        B       SelectPatternBuilder_8
SelectPatternBuilder_4
        MOVS    r2, r2, LSR #&D
        ADDHS   r2, r2, #1
        MOV     r8, r2, LSR #3
        ADD     sb, r8, #1
        AND     r2, r2, #7
        ADR     lr, PatternMaskTable2
        B       SelectPatternBuilder_8
SelectPatternBuilder_5
        ADD     r2, r2, r2, lsr #8
        ADD     r2, r2, r2, lsl #2
        ADD     r2, r2, r2, lsl #3
        ADD     lr, pc, #&60 ; with next instruction: GreyPaletteTable
        ADD     lr, lr, #&2D00
        TEQ     r5, r6
        BNE     SelectPatternBuilder_7
SelectPatternBuilder_6
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        LDRB    r8, [lr, r2, lsr #4]!
        LDRB    sb, [lr, #1]
        AND     r2, r2, #&F
        ADR     lr, PatternRowXorTable
        B       SelectPatternBuilder_8
SelectPatternBuilder_7
        MOVS    r2, r2, LSR #&D
        ADDHS   r2, r2, #1
        LDRB    r8, [lr, r2, lsr #3]!
        LDRB    sb, [lr, #1]
        AND     r2, r2, #7
        ADR     lr, PatternMaskTable2
SelectPatternBuilder_8
        ADD     lr, lr, r2, lsl #4
        LDMIA   lr, {r0-r3}
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        ORR     sb, sb, sb, lsl #8
        ORR     sb, sb, sb, lsl #16
SelectPatternBuilder_9
        BIC     r4, r8, r0
        BIC     r5, r8, r1
        BIC     r6, r8, r2
        BIC     r7, r8, r3
        AND     r0, sb, r0
        AND     r1, sb, r1
        AND     r2, sb, r2
        AND     r3, sb, r3
        ORR     r8, r0, r4
        ORR     sb, r1, r5
        ORR     sl, r2, r6
        ORR     fp, r3, r7

FinishPattern
        ADD     lr, ip, #&4C
        LDMIA   lr, {r0, r1}
        AND     r0, r0, #&1F
        RSB     r0, r0, #&20
        MOV     r8, r8, ROR r0
        MOV     sb, sb, ROR r0
        MOV     sl, sl, ROR r0
        MOV     fp, fp, ROR r0
        ANDS    r1, r1, #3
        BEQ     FinishPattern_2
        TST     r1, #2
        BEQ     FinishPattern_1
        EOR     r8, sl, r8
        EOR     sl, r8, sl
        EOR     r8, sl, r8
        EOR     sb, fp, sb
        EOR     fp, sb, fp
        EOR     sb, fp, sb
        TST     r1, #1
        BEQ     FinishPattern_2
FinishPattern_1
        MOV     lr, fp
        MOV     fp, sl
        MOV     sl, sb
        MOV     sb, r8
        MOV     r8, lr
FinishPattern_2
        ADD     lr, sp, #&C
        LDMIA   lr, {r3, r4}
        TEQ     r3, #0
        BMI     FinishPattern_3
        LDR     lr, [ip, #&10]
        TST     r3, #&80
        ADDNE   lr, lr, #&40
        AND     r4, r4, #7
        SUB     r1, pc, #&58 ; with next instruction: DitherMaskTable
        SUB     r1, r1, #&1500
        ADD     r1, r1, r4, lsl #4
        LDMIA   r1, {r4-r7}
        ORR     r0, r4, r8
        EOR     r0, r5, r0
        ORR     r1, r6, r8
        EOR     r1, r7, r1
        ORR     r2, r4, sb
        EOR     r2, r5, r2
        ORR     r3, r6, sb
        EOR     r3, r7, r3
        ORR     r8, r4, sl
        EOR     r8, r5, r8
        ORR     sb, r6, sl
        EOR     sb, r7, sb
        ORR     sl, r4, fp
        EOR     sl, r5, sl
        ORR     fp, r6, fp
        EOR     fp, r7, fp
        STMIA   lr!, {r0-r3, r8-fp}
        STMIA   lr!, {r0-r3, r8-fp}
        LDMFD   sp!, {r0-sb, pc}
FinishPattern_3
        STMIA   r4!, {r8-fp}
        STMIA   r4!, {r8-fp}
        LDMFD   sp!, {r0-sb, pc}

PatternRowXorTable
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &000000FF
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &000000FF
        DCD     &00000000
        DCD     &00FF0000
        DCD     &00000000
        DCD     &000000FF
        DCD     &00000000
        DCD     &00FF00FF
        DCD     &00000000
        DCD     &00FF00FF
        DCD     &00000000
        DCD     &00FF00FF
        DCD     &00000000
        DCD     &00FF00FF
        DCD     &0000FF00
        DCD     &00FF00FF
        DCD     &00000000
        DCD     &00FF00FF
        DCD     &0000FF00
        DCD     &00FF00FF
        DCD     &FF000000
        DCD     &00FF00FF
        DCD     &0000FF00
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FFFF
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FFFF
        DCD     &00FF00FF
        DCD     &FFFFFF00
        DCD     &00FF00FF
        DCD     &FF00FFFF
        DCD     &00FF00FF
        DCD     &FFFFFFFF
        DCD     &00FF00FF
        DCD     &FFFFFFFF
        DCD     &00FF00FF
        DCD     &FFFFFFFF
        DCD     &00FFFFFF
        DCD     &FFFFFFFF
        DCD     &00FF00FF
        DCD     &FFFFFFFF
        DCD     &00FFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFF00FF
        DCD     &FFFFFFFF
        DCD     &00FFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF

PatternMaskTable2
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &000000FF
        DCD     &00000000
        DCD     &00FF0000
        DCD     &00000000
        DCD     &000000FF
        DCD     &00FF0000
        DCD     &000000FF
        DCD     &00FF0000
        DCD     &00FF00FF
        DCD     &0000FF00
        DCD     &00FF00FF
        DCD     &FF000000
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FF00
        DCD     &00FF00FF
        DCD     &FF00FFFF
        DCD     &00FF00FF
        DCD     &FFFFFF00
        DCD     &00FFFFFF
        DCD     &FFFF00FF
        DCD     &00FFFFFF
        DCD     &FFFF00FF
        DCD     &00FFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFF00FF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF

BuildFromPalette
        MOV     r4, #&4D
        MOV     r5, #&97
        MOV     r6, #&1C
        MUL     r2, r7, r4
        MLA     r2, r8, r5, r2
        MLA     r2, sb, r6, r2
BuildFromPalette_1
        MOV     r2, r2, LSR #8
        MOV     fp, r1
        MVN     r3, #0
        MVN     r4, #0
        MOV     r5, #&80000000
        MVN     r6, #&80000000
        MOV     sl, #&FF
BuildFromPalette_2
        LDMDB   fp!, {sb}
        AND     r7, sl, sb, lsr #8
        AND     r8, sl, sb, lsr #16
        AND     sb, sl, sb, lsr #24
        TEQ     r7, r8
        TEQEQ   r7, sb
        BNE     BuildFromPalette_3
        CMP     r7, r2
        CMPLE   r5, r7
        MOVLE   r5, r7
        SUBLE   r3, fp, r0
        CMP     r7, r2
        CMPGE   r6, r7
        MOVGE   r6, r7
        SUBGE   r4, fp, r0
BuildFromPalette_3
        TEQ     r0, fp
        BNE     BuildFromPalette_2
        ORRS    lr, r3, r4
        BPL     BuildFromPalette_5
        MOV     fp, r1
        STMFD   sp!, {r3-r6}
        MVN     r5, #&80000000
        MOV     r6, #&80000000
BuildFromPalette_4
        LDMDB   fp!, {sb}
        AND     r7, sl, sb, lsr #8
        AND     r8, sl, sb, lsr #16
        AND     sb, sl, sb, lsr #24
        ADD     r8, r8, r8, lsl #1
        ADD     r7, r8, r7, lsl #1
        ADD     r7, r7, sb
        CMP     r5, r7
        MOVGT   r5, r7
        SUBGT   r3, fp, r0
        CMP     r6, r7
        MOVLT   r6, r7
        SUBLT   r4, fp, r0
        TEQ     r0, fp
        BNE     BuildFromPalette_4
        LDMFD   sp!, {r7, r8, sl, fp}
        TEQ     r7, #0
        MOVPL   r3, r7
        MOVPL   r5, sl
        MOVMI   r5, #0
        TEQ     r8, #0
        MOVPL   r4, r8
        MOVPL   r6, fp
        MOVMI   r6, #&FF
BuildFromPalette_5
        MOV     r8, r3, LSR #2
        MOV     sb, r4, LSR #2
        SUB     r6, r6, r5
        SUB     r2, r2, r5
        ADD     lr, pc, #&40 ; with next instruction: PatternPaletteTable
        ADD     lr, lr, #&500
        TEQ     r6, #1
        LDRNE   r6, [lr, r6, lsl #1]
        MOVNE   r6, r6, LSL #&10
        MOVNE   r6, r6, LSR #&10
        MULNE   r2, r6, r2
        LDR     lr, [ip, #&24]
        ADD     pc, pc, lr, lsl #2
        DCD     &00000000
        B       BuildFromPalette_12
        B       BuildFromPalette_9
        B       BuildFromPalette_7
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        ORR     sb, sb, sb, lsl #8
        ORR     sb, sb, sb, lsl #16
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildFromPalette_6
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        ADR     lr, PatternRowXorTable
        B       SelectPatternBuilder_8
BuildFromPalette_6
        MOVS    r2, r2, LSR #&D
        ADDHS   r2, r2, #1
        ADR     lr, PatternMaskTable2
        B       SelectPatternBuilder_8
BuildFromPalette_7
        ORR     r8, r8, r8, lsl #4
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        ORR     sb, sb, sb, lsl #4
        ORR     sb, sb, sb, lsl #8
        ORR     sb, sb, sb, lsl #16
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildFromPalette_8
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        ADR     lr, Pattern8bppMasks
        ADD     lr, lr, r2, lsl #3
        LDMIA   lr, {r0, r2}
        MOV     r1, r0, LSR #&10
        MOV     r3, r2, LSR #&10
        BIC     r0, r0, r1, lsl #16
        BIC     r2, r2, r3, lsl #16
        ORR     r0, r0, r0, lsl #16
        ORR     r1, r1, r1, lsl #16
        ORR     r2, r2, r2, lsl #16
        ORR     r3, r3, r3, lsl #16
        B       SelectPatternBuilder_9
BuildFromPalette_8
        MOVS    r2, r2, LSR #&B
        ADDHS   r2, r2, #1
        ADR     lr, Pattern8bppMasks2
        ADD     lr, lr, r2, lsl #4
        LDMIA   lr, {r0-r3}
        B       SelectPatternBuilder_9

Pattern8bppMasks
        DCD     &00000000
        DCD     &00000000
        DCD     &0000000F
        DCD     &00000000
        DCD     &0000000F
        DCD     &00000F00
        DCD     &0000000F
        DCD     &00000F0F
        DCD     &00000F0F
        DCD     &00000F0F
        DCD     &00F00F0F
        DCD     &00000F0F
        DCD     &00F00F0F
        DCD     &F0000F0F
        DCD     &00F00F0F
        DCD     &F0F00F0F
        DCD     &F0F00F0F
        DCD     &F0F00F0F
        DCD     &F0FF0F0F
        DCD     &F0F00F0F
        DCD     &F0FF0F0F
        DCD     &FFF00F0F
        DCD     &F0FF0F0F
        DCD     &FFFF0F0F
        DCD     &FFFF0F0F
        DCD     &FFFF0F0F
        DCD     &FFFF0FFF
        DCD     &FFFF0F0F
        DCD     &FFFF0FFF
        DCD     &FFFFFF0F
        DCD     &FFFF0FFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF

Pattern8bppMasks2
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &0000000F
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &0000000F
        DCD     &00000000
        DCD     &000F0000
        DCD     &00000000
        DCD     &0000000F
        DCD     &00000000
        DCD     &000F000F
        DCD     &00000000
        DCD     &000F000F
        DCD     &00000000
        DCD     &000F000F
        DCD     &00000000
        DCD     &000F000F
        DCD     &00000F00
        DCD     &000F000F
        DCD     &00000000
        DCD     &000F000F
        DCD     &00000F00
        DCD     &000F000F
        DCD     &0F000000
        DCD     &000F000F
        DCD     &00000F00
        DCD     &000F000F
        DCD     &0F000F00
        DCD     &000F000F
        DCD     &0F000F00
        DCD     &000F000F
        DCD     &0F000F00
        DCD     &F00F00F0
        DCD     &0F000F00
        DCD     &000F000F
        DCD     &0F000F00
        DCD     &F00F00F0
        DCD     &0F000F00
        DCD     &00F0F00F
        DCD     &0F000F00
        DCD     &F0F0F0F0
        DCD     &0F000F00
        DCD     &00F0F00F
        DCD     &0F000F00
        DCD     &F0F0F0F0
        DCD     &0F000F00
        DCD     &F0F0F0F0
        DCD     &0F000F00
        DCD     &F0F0F0F0
        DCD     &0F000F0F
        DCD     &F0F0F0F0
        DCD     &0F000F00
        DCD     &F0F0F0F0
        DCD     &0F000F0F
        DCD     &F0F0F0F0
        DCD     &0F0F0F00
        DCD     &F0F0F0F0
        DCD     &0F000F0F
        DCD     &F0F0F0F0
        DCD     &0F0F0F0F
        DCD     &F0F0F0F0
        DCD     &0F0F0F0F
        DCD     &F0F0F0F0
        DCD     &0F0F0F0F
        DCD     &F0F0F0F0
        DCD     &0F0FFF0F
        DCD     &F0F0F0F0
        DCD     &0F0F0F0F
        DCD     &F0F0F0F0
        DCD     &0F0FFF0F
        DCD     &F0F0F0F0
        DCD     &FF0F0F0F
        DCD     &F0F0F0F0
        DCD     &FF0FFF0F
        DCD     &F0F0F0F0
        DCD     &FF0F0F0F
        DCD     &F0F0F0F0
        DCD     &FF0FFF0F
        DCD     &F0F0F0F0
        DCD     &FF0FFF0F
        DCD     &F0FF0FF0
        DCD     &FF0FFF0F
        DCD     &F0F0F0F0
        DCD     &FF0FFF0F
        DCD     &F0FF0FF0
        DCD     &FF0FFF0F
        DCD     &0FF0F0FF
        DCD     &FF0FFF0F
        DCD     &F0FF0FF0
        DCD     &FF0FFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFFFF
        DCD     &0FFF0FFF
        DCD     &FF0FFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFFFF
        DCD     &0FFF0FFF
        DCD     &FFFFFF0F
        DCD     &0FFF0FFF
        DCD     &FF0FFFFF
        DCD     &0FFF0FFF
        DCD     &FFFFFFFF
        DCD     &0FFF0FFF
        DCD     &FFFFFFFF
        DCD     &0FFF0FFF
        DCD     &FFFFFFFF
        DCD     &0FFFFFFF
        DCD     &FFFFFFFF
        DCD     &0FFF0FFF
        DCD     &FFFFFFFF
        DCD     &0FFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFF0FFF
        DCD     &FFFFFFFF
        DCD     &0FFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
        DCD     &FFFFFFFF
BuildFromPalette_9
        ORR     r8, r8, r8, lsl #2
        ORR     r8, r8, r8, lsl #4
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        ORR     sb, sb, sb, lsl #2
        ORR     sb, sb, sb, lsl #4
        ORR     sb, sb, sb, lsl #8
        ORR     sb, sb, sb, lsl #16
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildFromPalette_10
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        ADR     lr, PatternBitTable
        B       BuildFromPalette_11
BuildFromPalette_10
        MOVS    r2, r2, LSR #&D
        ADDHS   r2, r2, #1
        ADR     lr, PatternBitTable2
BuildFromPalette_11
        LDR     lr, [lr, r2, lsl #2]
        MOV     r3, #&FF
        AND     r0, r3, lr
        AND     r1, r3, lr, lsr #8
        AND     r2, r3, lr, lsr #16
        AND     r3, r3, lr, lsr #24
        ORR     r0, r0, r0, lsl #8
        ORR     r0, r0, r0, lsl #16
        ORR     r1, r1, r1, lsl #8
        ORR     r1, r1, r1, lsl #16
        ORR     r2, r2, r2, lsl #8
        ORR     r2, r2, r2, lsl #16
        ORR     r3, r3, r3, lsl #8
        ORR     r3, r3, r3, lsl #16
        B       SelectPatternBuilder_9

PatternBitTable
        DCD     &00000000
        DCD     &00000003
        DCD     &00300003
        DCD     &00330003
        DCD     &00330033
        DCD     &00330C33
        DCD     &C0330C33
        DCD     &CC330C33
        DCD     &CC33CC33
        DCD     &CC33CF33
        DCD     &FC33CF33
        DCD     &FF33CF33
        DCD     &FF33FF33
        DCD     &FF33FF3F
        DCD     &FFF3FF3F
        DCD     &FFFFFF3F
        DCD     &FFFFFFFF

PatternBitTable2
        DCD     &00000000
        DCD     &00300003
        DCD     &30033003
        DCD     &C0330C33
        DCD     &CC33CC33
        DCD     &FC33CF33
        DCD     &F33FF33F
        DCD     &FFF3FF3F
        DCD     &FFFFFFFF
BuildFromPalette_12
        TEQ     r8, #0
        MVNNE   r8, #0
        TEQ     sb, #0
        MVNNE   sb, #0
        ADD     lr, ip, #&14
        LDMIA   lr, {r5, r6}
        TEQ     r5, r6
        BNE     BuildFromPalette_13
        MOVS    r2, r2, LSR #&C
        ADDHS   r2, r2, #1
        ADR     lr, PatternWordTable
        B       BuildFromPalette_11
BuildFromPalette_13
        MOVS    r2, r2, LSR #&D
        ADDHS   r2, r2, #1
        ADR     lr, PatternWordTable2
        B       BuildFromPalette_11

PatternWordTable
        DCD     &00000000
        DCD     &00000011
        DCD     &00440011
        DCD     &00550011
        DCD     &00550055
        DCD     &00552255
        DCD     &88552255
        DCD     &AA552255
        DCD     &AA55AA55
        DCD     &AA55BB55
        DCD     &EE55BB55
        DCD     &FF55BB55
        DCD     &FF55FF55
        DCD     &FF55FF77
        DCD     &FFDDFF77
        DCD     &FFFFFF77
        DCD     &FFFFFFFF

PatternWordTable2
        DCD     &00000000
        DCD     &00440011
        DCD     &44114411
        DCD     &88552255
        DCD     &AA55AA55
        DCD     &EE55BB55
        DCD     &DD77DD77
        DCD     &FFDDFF77
        DCD     &FFFFFFFF
BuildFromPalette_14
        TST     r3, #&80
        LDMFDNE sp!, {r1-sb, pc}

SetCacheKey
        MOV     r2, r0
        BL      GreyOfColour
        MOV     r0, r2
        LDR     lr, [ip, #&40]
        TEQ     r0, lr
        STRNE   r0, [ip, #&40]
        MOVNE   lr, #0
        STRNE   lr, [ip, #&44]
        LDMFD   sp!, {r1-sb, pc}

PatternPaletteTable
        DCD     &FFFFFFFF
        DCD     &55558000
        DCD     &33334000
        DCD     &24922AAB
        DCD     &1C722000
        DCD     &1746199A
        DCD     &13B11555
        DCD     &11111249

PatternPaletteTable2
        DCD     &0F0F1000
        DCD     &0D790E39
        DCD     &0C310CCD
        DCD     &0B210BA3
        DCD     &0A3D0AAB
        DCD     &097B09D9
        DCD     &08D40925
        DCD     &08420889
        DCD     &07C20800
        DCD     &07500788
        DCD     &06EB071C
        DCD     &069006BD
        DCD     &063E0666
        DCD     &05F40618
        DCD     &05B005D1
        DCD     &05720591
        DCD     &05390555
        DCD     &0505051F
        DCD     &04D504EC
        DCD     &04A804BE
        DCD     &047E0492
        DCD     &0457046A
        DCD     &04320444
        DCD     &04100421
        DCD     &03F00400
        DCD     &03D203E1
        DCD     &03B603C4
        DCD     &039B03A8
        DCD     &0382038E
        DCD     &036A0376
        DCD     &0353035E
        DCD     &033E0348
        DCD     &03290333
        DCD     &0316031F
        DCD     &0303030C
        DCD     &02F102FA
        DCD     &02E002E9
        DCD     &02D002D8
        DCD     &02C102C8
        DCD     &02B202B9
        DCD     &02A402AB
        DCD     &0296029D
        DCD     &0289028F
        DCD     &027C0283
        DCD     &02700276
        DCD     &0264026A
        DCD     &0259025F
        DCD     &024E0254
        DCD     &02440249
        DCD     &023A023F
        DCD     &02300235
        DCD     &0227022B
        DCD     &021E0222
        DCD     &02150219
        DCD     &020C0211
        DCD     &02040208
        DCD     &01FC0200
        DCD     &01F401F8
        DCD     &01ED01F0
        DCD     &01E501E9
        DCD     &01DE01E2
        DCD     &01D701DB
        DCD     &01D101D4
        DCD     &01CA01CE
        DCD     &01C401C7
        DCD     &01BE01C1
        DCD     &01B801BB
        DCD     &01B201B5
        DCD     &01AC01AF
        DCD     &01A701AA
        DCD     &01A101A4
        DCD     &019C019F
        DCD     &0197019A
        DCD     &01920195
        DCD     &018D0190
        DCD     &0188018B
        DCD     &01840186
        DCD     &017F0182
        DCD     &017B017D
        DCD     &01760179
        DCD     &01720174
        DCD     &016E0170
        DCD     &016A016C
        DCD     &01660168
        DCD     &01620164
        DCD     &015E0160
        DCD     &015B015D
        DCD     &01570159
        DCD     &01540155
        DCD     &01500152
        DCD     &014D014E
        DCD     &0149014B
        DCD     &01460148
        DCD     &01430144
        DCD     &01400141
        DCD     &013D013E
        DCD     &013A013B
        DCD     &01370138
        DCD     &01340135
        DCD     &01310132
        DCD     &012E012F
        DCD     &012B012D
        DCD     &0129012A
        DCD     &01260127
        DCD     &01230125
        DCD     &01210122
        DCD     &011E011F
        DCD     &011C011D
        DCD     &0119011A
        DCD     &01170118
        DCD     &01150116
        DCD     &01120113
        DCD     &01100111
        DCD     &010E010F
        DCD     &010B010D
        DCD     &0109010A
        DCD     &01070108
        DCD     &01050106
        DCD     &01030104
        DCD     &01010102

ReturnOppGCOL
        STMFD   sp!, {r1, r2, lr}
        MVN     r1, #0
        MVN     r2, #0
        BL      ReturnOppColourNumberForMode
        BL      ToRGBIfDepth3
        ExitOK r1, r2

ReturnOppGCOLForMode
        STMFD   sp!, {r1, r2, lr}
        BL      ReturnOppColourNumberForMode
        BL      ToRGBIfDepth3
        ExitOK r1, r2

ReturnOppColourNumber
        STMFD   sp!, {r1-sb, lr}
        MVN     r1, #0
        MVN     r2, #0
        B       ReturnOppColourNumberForMode_1

ReturnOppColourNumberForMode
        STMFD   sp!, {r1-sb, lr}
ReturnOppColourNumberForMode_1
        MOV     lr, r0
        MOV     r0, r1
        MOV     r1, r2
        MOV     r2, lr
        BL      ModeToDepth
        CMP     r0, #4
        BHS     ReturnOppColourNumberForMode_2
        BL      SelectPatternPointersForMode
        BL      SearchPaletteAlt
ReturnOppColourNumberForMode_2
        MOV     r0, r2
        ExitOK r1, sb

ReturnGCOL
        STMFD   sp!, {r1-sb, lr}
        MOV     r2, r0
        LDR     r0, [ip, #&20]
        STR     r0, [ip, #&24]
        TEQ     r0, #5
        MOVEQ   r0, r2, LSR #8
        BEQ     ReturnGCOL_4
        CMP     r0, #3
        BHI     ReturnGCOL_1
        BLO     ReturnGCOL_2
        BL      NearestColourFromType
        MOV     r0, r2
        BL      ColourNumberToGCOL
        B       ReturnGCOL_4
ReturnGCOL_1
        BL      Colour24To15
        B       ReturnGCOL_3
ReturnGCOL_2
        BL      SetSearchPointers
ReturnGCOL_3
        MOV     r0, r2
ReturnGCOL_4
        ExitOK r1, sb

ReturnColourNumber
        STMFD   sp!, {r1-sb, lr}
        MOV     r2, r0
        LDR     r0, [ip, #&20]
        STR     r0, [ip, #&24]
        TEQ     r0, #5
        MOVEQ   r0, r2, LSR #8
        BEQ     ReturnColourNumber_4
        CMP     r0, #3
        BHI     ReturnColourNumber_1
        BLO     ReturnColourNumber_2
        BL      NearestColourFromType
        B       ReturnColourNumber_3
ReturnColourNumber_1
        BL      Colour24To15
        B       ReturnColourNumber_3
ReturnColourNumber_2
        BL      SetSearchPointers
ReturnColourNumber_3
        MOV     r0, r2
ReturnColourNumber_4
        ExitOK r1, sb

ReturnGCOLForMode
        STMFD   sp!, {r1, r2, lr}
        BL      ReturnColourNumberForMode
        BL      ToRGBIfDepth3
        ExitOK r1, r2

ReturnColourNumberForMode
        STMFD   sp!, {r1-sb, lr}
        MOV     lr, r0
        MOV     r0, r1
        MOV     r1, r2
        MOV     r2, lr
        BL      ModeToDepth
        TEQ     r0, #5
        MOVEQ   r0, r2, LSR #8
        BEQ     ReturnColourNumberForMode_1
        CMP     r0, #3
        BLHI    Colour24To15
        MOVHI   r0, r2
        BHI     ReturnColourNumberForMode_1
        BL      SelectPatternPointersForMode
        BLLO    SearchPalette
        MOVLO   r0, r2
        BLO     ReturnColourNumberForMode_1
        BL      FindPaletteType
        TEQ     lr, #3
        BLEQ    SearchPalette
        MOVNE   r0, lr
        BLNE    NearestColour
        MOV     r0, r2
ReturnColourNumberForMode_1
        ExitOK r1, sb

SelectTable
        EnterSWI r0, sb
        BL      ModeToDepth
        BL      SelectPatternPointersForMode
        MOV     r5, r1
        MOV     r1, r3
        MOV     r3, r0
        MOV     r0, r2
        BL      ModeToDepth
        TEQ     r0, #5
        BEQ     SelectTable_7
        CMP     r0, #3
        BEQ     SelectTable_2
        BHI     SelectTable_6
        BL      SelectPatternPointersForMode
SelectTable_1
        LDR     r2, [r3], #4
        BL      SearchPalette
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectTable_1
        ExitOK r0, sb
SelectTable_2
        TEQ     r1, #0
        BEQ     SelectTable_5
        BL      SelectPatternPointersForMode
        BL      FindPaletteType
        ADD     pc, pc, lr, lsl #2
        DCD     &F1A00000
        B       SelectTable_5
        B       SelectTable_4
        B       SelectTable_3
        B       SelectTable_1
SelectTable_3
        LDR     r2, [r3], #4
        BL      NearestCube
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectTable_3
        ExitOK r0, sb
SelectTable_4
        LDR     r2, [r3], #4
        BL      NearestGrey
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectTable_4
        ExitOK r0, sb
SelectTable_5
        LDR     r2, [r3], #4
        BL      NearestDefault
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectTable_5
        ExitOK r0, sb
SelectTable_6
        LDR     r2, [r3], #4
        BL      Colour24To15
        STRB    r2, [r4], #1
        MOV     r2, r2, LSR #8
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectTable_6
        ExitOK r0, sb
SelectTable_7
        LDR     r2, [r3], #4
        MOV     r2, r2, LSR #8
        STR     r2, [r4], #4
        TEQ     r3, r5
        LDRNE   r2, [r3], #4
        MOVNE   r2, r2, LSR #8
        STRNE   r2, [r4], #4
        TEQNE   r3, r5
        BNE     SelectTable_7
        ExitOK r0, sb

SelectGCOLTable
        STMFD   sp!, {r0-r2, lr}
        BL      SelectTable
        LDR     lr, [ip, #&24]
        TEQ     lr, #3
        BNE     SelectGCOLTable_2
        MOV     r1, #&FF
SelectGCOLTable_1
        LDRB    r0, [r4, r1]
        BL      ColourNumberToGCOL
        STRB    r0, [r4, r1]
        SUBS    r1, r1, #1
        BPL     SelectGCOLTable_1
SelectGCOLTable_2
        ExitOK r0, r2

SelectHalftoneTable
        EnterSWI r0, sb
        BL      ModeToDepth
        BL      SelectPatternPointersForMode
        MOV     r5, r1
        MOV     r3, r0
SelectHalftoneTable_1
        LDR     r2, [r3], #4
        BL      GreyOfColour
        STRB    r2, [r4], #1
        TEQ     r3, r5
        BNE     SelectHalftoneTable_1
        ExitOK r0, sb

SelectColourPatternTable
        EnterSWI r0, sb
        BL      ModeToDepth
        BL      SelectPatternPointersForMode
        MOV     r5, r1
        MOV     r3, r0
SelectColourPatternTable_1
        LDR     r2, [r3], #4
        BL      PatternToBufferHalf
        TEQ     r3, r5
        BNE     SelectColourPatternTable_1
        ExitOK r0, sb

ToRGBIfDepth3
        LDR     sl, [ip, #&24]
        TEQ     sl, #3
        MOVNE   pc, lr

ColourNumberToGCOL
        AND     sl, r0, #&87
        TST     r0, #8
        AND     r0, r0, #&70
        ORR     r0, sl, r0, lsr #1
        ORRNE   r0, r0, #&40
        ExitOK

GCOLToColourNumber
        AND     sl, r0, #&87
        TST     r0, #&40
        AND     r0, r0, #&38
        ORR     r0, sl, r0, lsl #1
        ORRNE   r0, r0, #8
        ExitOK

ReturnColourPattern
        STMFD   sp!, {r0-r4, sl, fp, lr}
        BL      PatternToBuffer
        TEQ     pc, pc
        LDMFDNE sp!, {r0-r4, sl, fp, lr}
        BICNES  pc, lr, #&10000000
        MSR     CPSR_f, #0
        LDMFD   sp!, {r0-r4, sl, fp, pc}

ReturnColourPatternTable
        EnterSWI r0, fp
        MOV     sb, #&FF
        AND     r3, sb, r0, lsr #8
        AND     r4, sb, r0, lsr #16
        AND     r5, sb, r0, lsr #24
        AND     r6, sb, r1, lsr #8
        AND     r7, sb, r1, lsr #16
        AND     r8, sb, r1, lsr #24
        SUB     r6, r6, r3
        SUB     r7, r7, r4
        SUB     r8, r8, r5
        RSB     r3, r3, r3, lsl #8
        RSB     r4, r4, r4, lsl #8
        RSB     r5, r5, r5, lsl #8
ReturnColourPatternTable_1
        ADD     r1, r3, r3, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        MOV     r0, r1, LSL #8
        ADD     r1, r4, r4, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        ORR     r0, r0, r1, lsl #16
        ADD     r1, r5, r5, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        ORR     r0, r0, r1, lsl #24
        STMFD   sp!, {r2-r4}
        BL      PatternToBuffer
        LDMFD   sp!, {r2-r4}
        SUBS    sb, sb, #1
        ADDPL   r2, r2, #&20
        ADDPL   r3, r3, r6
        ADDPL   r4, r4, r7
        ADDPL   r5, r5, r8
        BPL     ReturnColourPatternTable_1
        ExitOK r0, fp

PatternToBuffer
        MOV     r4, r2
        MVN     r3, #0
        B       SetGCOLCore

PatternToBufferHalf
        ADD     r4, r4, #&20
        STMFD   sp!, {r0-r4, sl, fp, lr}
        MOV     r0, r2
        MVN     r3, #0
        SUB     r4, r4, #&20
        BL      SetGCOLCore
        LDMFD   sp!, {r0-r4, sl, fp, pc}

ReturnColourPatternArray
        LDR     r0, [ip, #&7C]
        TEQ     r0, #0
        BEQ     ReturnColourPatternArray_1
        ExitOK
ReturnColourPatternArray_1
        STMFD   sp!, {r1-fp, lr}
        MOV     r0, #6
        MOV     r3, #&20000
        SWI     &2001E ; XOS_Module
        BVC     ReturnColourPatternArray_2
        ExitErr r1, fp
ReturnColourPatternArray_2
        STR     r2, [ip, #&7C]
        STMFD   sp!, {r2}
        MOV     sl, r2
        MOV     fp, r3
        MOV     r0, #&A2
        ORR     r0, r0, #&DA00
        ORR     r0, r0, #&F0000
        ORR     r0, r0, #&C9000000
        MOV     r1, r0
        MOV     r2, r0
        MOV     r3, r0
        MOV     r4, r0
        MOV     r5, r0
        MOV     r6, r0
        MOV     r7, r0
        MOV     r8, r0
        MOV     sb, r0
        MOV     ip, r0
        MOV     lr, r0
ReturnColourPatternArray_3
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-sb, ip, lr}
        STMIA   sl!, {r0-r7}
        SUBS    fp, fp, #&200
        BNE     ReturnColourPatternArray_3
        ExitOK r0, fp

ReturnHalftoneIntensity
        STMFD   sp!, {r2, lr}
        MOV     r2, r0
        BL      GreyOfColour
        MOV     r0, r2
        TEQ     pc, pc
        LDMFDNE sp!, {r2, lr}
        BICNES  pc, lr, #&10000000
        MSR     CPSR_f, #0
        LDMFD   sp!, {r2, pc}

ReturnHalftoneTable
        EnterSWI r0, fp
        MOV     sb, #&FF
        AND     r3, sb, r0, lsr #8
        AND     r4, sb, r0, lsr #16
        AND     r5, sb, r0, lsr #24
        AND     r6, sb, r1, lsr #8
        AND     r7, sb, r1, lsr #16
        AND     r8, sb, r1, lsr #24
        SUB     r6, r6, r3
        SUB     r7, r7, r4
        SUB     r8, r8, r5
        RSB     r3, r3, r3, lsl #8
        RSB     r4, r4, r4, lsl #8
        RSB     r5, r5, r5, lsl #8
ReturnHalftoneTable_1
        ADD     r1, r3, r3, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        MOV     r0, r1, LSL #8
        ADD     r1, r4, r4, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        ORR     r0, r0, r1, lsl #16
        ADD     r1, r5, r5, lsl #8
        MOVS    r1, r1, LSR #&10
        ADDHS   r1, r1, #1
        ORR     r0, r0, r1, lsl #24
        STMFD   sp!, {r2-r4}
        MOV     r2, r0
        BL      GreyOfColour
        MOV     r0, r2
        LDMFD   sp!, {r2-r4}
        STRB    r0, [r2], #1
        SUBS    sb, sb, #1
        ADDPL   r3, r3, r6
        ADDPL   r4, r4, r7
        ADDPL   r5, r5, r8
        BPL     ReturnHalftoneTable_1
        ExitOK r0, fp

GreyOfColour
        STMFD   sp!, {r0, r1, lr}
        MOV     lr, #&FF
        AND     r0, lr, r2, lsr #8
        AND     r1, lr, r2, lsr #16
        AND     r2, lr, r2, lsr #24
        MOV     lr, #&1C
        MUL     r2, lr, r2
        MOV     lr, #&97
        MLA     r2, lr, r1, r2
        MOV     lr, #&4D
        MLA     r2, lr, r0, r2
        ADD     r2, r2, r2, lsr #8
        MOV     r2, r2, LSR #8
        LDMFD   sp!, {r0, r1, pc}

ModeToDepth
        CMN     r0, #1
        LDREQ   r0, [ip, #&20]
        STREQ   r0, [ip, #&24]
        MOVEQ   pc, lr
        STMFD   sp!, {r1, r2, lr}
        MOV     r1, #9
        SWI     &20035
        BHS     ReadPalette_3
        BVS     ReturnError
        TEQ     r2, #4
        MOVNE   r0, r2
        STRNE   r0, [ip, #&24]
        LDMFDNE sp!, {r1, r2, pc}
        MOV     r1, #3
        SWI     &20035
        BHS     ReadPalette_3
        BVS     ReturnError
        TEQ     r2, #&F
        MOVEQ   r0, #5
        MOVNE   r0, #4
        STR     r0, [ip, #&24]
        LDMFD   sp!, {r1, r2, pc}

ReadHardwarePalette
        STMFD   sp!, {r0-r6, sb, lr}
        MOV     r5, r0
        MOV     r6, r1
        MOV     r0, #0
        MOV     r1, #&10
        MOV     r4, #1
        MOV     sb, #&23
        SWI     &20034 ; XOS_CallAVector
        BVS     ReturnError
        TEQ     r4, #0
        BNE     ReadHardwarePalette_2
        STR     r2, [r5], #4
ReadHardwarePalette_1
        ADD     r0, r0, #1
        MOV     r4, #1
        SWI     &20034 ; XOS_CallAVector
        BVS     ReturnError
        STR     r2, [r5], #4
        TEQ     r5, r6
        BNE     ReadHardwarePalette_1
        MSR     CPSR_f, #0
        LDMFD   sp!, {r0-r6, sb, pc}
ReadHardwarePalette_2
        MOV     r4, #&F000
        ORR     r4, r4, #&F00000
        ORR     r4, r4, #&F0000000
ReadHardwarePalette_3
        SWI     &2002F
        BVS     ReturnError
        AND     r2, r2, r4
        ORR     r2, r2, r2, lsr #4
        STR     r2, [r5], #4
        TEQ     r5, r6
        ADDNE   r0, r0, #1
        BNE     ReadHardwarePalette_3
        MSR     CPSR_f, #0
        LDMFD   sp!, {r0-r6, sb, pc}

FindPaletteType
        STMFD   sp!, {r0-sb, lr}
        MOV     r8, r0
        MOV     sb, r1
        SUB     lr, r1, r0
        TEQ     lr, #&400
        BNE     FindPaletteType_6
        MOV     r2, #&FF
FindPaletteType_1
        LDMIA   r0!, {r3}
        AND     r4, r2, r3, lsr #8
        AND     r5, r2, r3, lsr #16
        AND     r6, r2, r3, lsr #24
        TEQ     r4, r5
        TEQEQ   r4, r6
        BNE     FindPaletteType_2
        TEQ     r0, r1
        BNE     FindPaletteType_1
        MOV     lr, #1
        LDMFD   sp!, {r0-sb, pc}
FindPaletteType_2
        MOV     r0, r8
        MOV     r1, sb
        ADR     r2, PatternOffsetTable2
FindPaletteType_3
        LDMIA   r0!, {r3, r4}
        LDMIA   r2!, {r5, r6}
        TEQ     r3, r5
        TEQEQ   r4, r6
        BNE     FindPaletteType_4
        TEQ     r0, r1
        BNE     FindPaletteType_3
        MOV     lr, #0
        LDMFD   sp!, {r0-sb, pc}
FindPaletteType_4
        MOV     r0, r8
        MOV     r1, sb
        MVN     r2, #&80000000
        MOV     r3, #0
        MOV     r4, #&FF
FindPaletteType_5
        LDR     lr, [r1, #-4]!
        AND     r5, r4, lr, lsr #8
        AND     r6, r4, lr, lsr #16
        AND     r7, r4, lr, lsr #24
        ADD     r6, r6, r6, lsl #1
        ADD     r5, r6, r5, lsl #1
        ADD     r5, r5, r7
        CMP     r2, r5
        MOVHI   r2, r5
        SUBHI   r8, r1, r0
        CMP     r3, r5
        MOVLO   r3, r5
        SUBLO   sb, r1, r0
        TEQ     r0, r1
        BNE     FindPaletteType_5
        TEQ     r8, #0
        TEQEQ   sb, #&35C
        MOVEQ   lr, #2
        MOVNE   lr, #3
        LDMFD   sp!, {r0-sb, pc}
FindPaletteType_6
        LDR     r2, [r8], #4
        MOV     lr, r2, LSR #&18
        EOR     r2, r2, lr, lsl #8
        EOR     r2, r2, lr, lsl #16
        EORS    r2, r2, lr, lsl #24
        BNE     FindPaletteType_7
        TEQ     r8, sb
        BNE     FindPaletteType_6
        MOV     lr, #1
        LDMFD   sp!, {r0-sb, pc}
FindPaletteType_7
        MOV     lr, #3
        LDMFD   sp!, {r0-sb, pc}

SelectPatternPointers
        ADR     r1, PatternOffsetTable
        LDR     r1, [r1, r0, lsl #2]
        ADD     r0, ip, #&84
        ADD     r1, r0, r1, lsl #2
        MOV     pc, lr

SelectPatternPointersForMode
        STR     lr, [sp, #-4]!
        TEQ     r1, #0
        ADREQ   lr, PatternOffsetBytes
        LDREQB  r1, [lr, r0]
        ADDEQ   r1, r1, lr
        ADR     lr, PatternOffsetTable
        LDR     lr, [lr, r0, lsl #2]
        CMN     r1, #1
        ADDEQ   r0, ip, #&84
        MOVNE   r0, r1
        ADD     r1, r0, lr, lsl #2
        LDR     pc, [sp], #4

PatternOffsetTable
        DCD     &00000002
        DCD     &00000004
        DCD     &00000010
        DCD     &00000100

PatternOffsetBytes
        DCD     &5C1C0C04
        DCD     &00000000
        DCD     &FFFFFF00
        DCD     &00000000
        DCD     &0000FF00
        DCD     &00FFFF00
        DCD     &FFFFFF00
        DCD     &00000000
        DCD     &0000FF00
        DCD     &00FF0000
        DCD     &00FFFF00
        DCD     &FF000000
        DCD     &FF00FF00
        DCD     &FFFF0000
        DCD     &FFFFFF00
        DCD     &00000000
        DCD     &0000FF00
        DCD     &00FF0000
        DCD     &00FFFF00
        DCD     &FF000000
        DCD     &FF00FF00
        DCD     &FFFF0000
        DCD     &FFFFFF00

PatternOffsetTable2
        DCD     &00000000
        DCD     &11111100
        DCD     &22222200
        DCD     &33333300
        DCD     &00004400
        DCD     &11115500
        DCD     &22226600
        DCD     &33337700
        DCD     &44000000
        DCD     &55111100
        DCD     &66222200
        DCD     &77333300
        DCD     &44004400
        DCD     &55115500
        DCD     &66226600
        DCD     &77337700
        DCD     &00008800
        DCD     &11119900
        DCD     &2222AA00
        DCD     &3333BB00
        DCD     &0000CC00
        DCD     &1111DD00
        DCD     &2222EE00
        DCD     &3333FF00
        DCD     &44008800
        DCD     &55119900
        DCD     &6622AA00
        DCD     &7733BB00
        DCD     &4400CC00
        DCD     &5511DD00
        DCD     &6622EE00
        DCD     &7733FF00
        DCD     &00440000
        DCD     &11551100
        DCD     &22662200
        DCD     &33773300
        DCD     &00444400
        DCD     &11555500
        DCD     &22666600
        DCD     &33777700
        DCD     &44440000
        DCD     &55551100
        DCD     &66662200
        DCD     &77773300
        DCD     &44444400
        DCD     &55555500
        DCD     &66666600
        DCD     &77777700
        DCD     &00448800
        DCD     &11559900
        DCD     &2266AA00
        DCD     &3377BB00
        DCD     &0044CC00
        DCD     &1155DD00
        DCD     &2266EE00
        DCD     &3377FF00
        DCD     &44448800
        DCD     &55559900
        DCD     &6666AA00
        DCD     &7777BB00
        DCD     &4444CC00
        DCD     &5555DD00
        DCD     &6666EE00
        DCD     &7777FF00
        DCD     &00880000
        DCD     &11991100
        DCD     &22AA2200
        DCD     &33BB3300
        DCD     &00884400
        DCD     &11995500
        DCD     &22AA6600
        DCD     &33BB7700
        DCD     &44880000
        DCD     &55991100
        DCD     &66AA2200
        DCD     &77BB3300
        DCD     &44884400
        DCD     &55995500
        DCD     &66AA6600
        DCD     &77BB7700
        DCD     &00888800
        DCD     &11999900
        DCD     &22AAAA00
        DCD     &33BBBB00
        DCD     &0088CC00
        DCD     &1199DD00
        DCD     &22AAEE00
        DCD     &33BBFF00
        DCD     &44888800
        DCD     &55999900
        DCD     &66AAAA00
        DCD     &77BBBB00
        DCD     &4488CC00
        DCD     &5599DD00
        DCD     &66AAEE00
        DCD     &77BBFF00
        DCD     &00CC0000
        DCD     &11DD1100
        DCD     &22EE2200
        DCD     &33FF3300
        DCD     &00CC4400
        DCD     &11DD5500
        DCD     &22EE6600
        DCD     &33FF7700
        DCD     &44CC0000
        DCD     &55DD1100
        DCD     &66EE2200
        DCD     &77FF3300
        DCD     &44CC4400
        DCD     &55DD5500
        DCD     &66EE6600
        DCD     &77FF7700
        DCD     &00CC8800
        DCD     &11DD9900
        DCD     &22EEAA00
        DCD     &33FFBB00
        DCD     &00CCCC00
        DCD     &11DDDD00
        DCD     &22EEEE00
        DCD     &33FFFF00
        DCD     &44CC8800
        DCD     &55DD9900
        DCD     &66EEAA00
        DCD     &77FFBB00
        DCD     &44CCCC00
        DCD     &55DDDD00
        DCD     &66EEEE00
        DCD     &77FFFF00
        DCD     &88000000
        DCD     &99111100
        DCD     &AA222200
        DCD     &BB333300
        DCD     &88004400
        DCD     &99115500
        DCD     &AA226600
        DCD     &BB337700
        DCD     &CC000000
        DCD     &DD111100
        DCD     &EE222200
        DCD     &FF333300
        DCD     &CC004400
        DCD     &DD115500
        DCD     &EE226600
        DCD     &FF337700
        DCD     &88008800
        DCD     &99119900
        DCD     &AA22AA00
        DCD     &BB33BB00
        DCD     &8800CC00
        DCD     &9911DD00
        DCD     &AA22EE00
        DCD     &BB33FF00
        DCD     &CC008800
        DCD     &DD119900
        DCD     &EE22AA00
        DCD     &FF33BB00
        DCD     &CC00CC00
        DCD     &DD11DD00
        DCD     &EE22EE00
        DCD     &FF33FF00
        DCD     &88440000
        DCD     &99551100
        DCD     &AA662200
        DCD     &BB773300
        DCD     &88444400
        DCD     &99555500
        DCD     &AA666600
        DCD     &BB777700
        DCD     &CC440000
        DCD     &DD551100
        DCD     &EE662200
        DCD     &FF773300
        DCD     &CC444400
        DCD     &DD555500
        DCD     &EE666600
        DCD     &FF777700
        DCD     &88448800
        DCD     &99559900
        DCD     &AA66AA00
        DCD     &BB77BB00
        DCD     &8844CC00
        DCD     &9955DD00
        DCD     &AA66EE00
        DCD     &BB77FF00
        DCD     &CC448800
        DCD     &DD559900
        DCD     &EE66AA00
        DCD     &FF77BB00
        DCD     &CC44CC00
        DCD     &DD55DD00
        DCD     &EE66EE00
        DCD     &FF77FF00
        DCD     &88880000
        DCD     &99991100
        DCD     &AAAA2200
        DCD     &BBBB3300
        DCD     &88884400
        DCD     &99995500
        DCD     &AAAA6600
        DCD     &BBBB7700
        DCD     &CC880000
        DCD     &DD991100
        DCD     &EEAA2200
        DCD     &FFBB3300
        DCD     &CC884400
        DCD     &DD995500
        DCD     &EEAA6600
        DCD     &FFBB7700
        DCD     &88888800
        DCD     &99999900
        DCD     &AAAAAA00
        DCD     &BBBBBB00
        DCD     &8888CC00
        DCD     &9999DD00
        DCD     &AAAAEE00
        DCD     &BBBBFF00
        DCD     &CC888800
        DCD     &DD999900
        DCD     &EEAAAA00
        DCD     &FFBBBB00
        DCD     &CC88CC00
        DCD     &DD99DD00
        DCD     &EEAAEE00
        DCD     &FFBBFF00
        DCD     &88CC0000
        DCD     &99DD1100
        DCD     &AAEE2200
        DCD     &BBFF3300
        DCD     &88CC4400
        DCD     &99DD5500
        DCD     &AAEE6600
        DCD     &BBFF7700
        DCD     &CCCC0000
        DCD     &DDDD1100
        DCD     &EEEE2200
        DCD     &FFFF3300
        DCD     &CCCC4400
        DCD     &DDDD5500
        DCD     &EEEE6600
        DCD     &FFFF7700
        DCD     &88CC8800
        DCD     &99DD9900
        DCD     &AAEEAA00
        DCD     &BBFFBB00
        DCD     &88CCCC00
        DCD     &99DDDD00
        DCD     &AAEEEE00
        DCD     &BBFFFF00
        DCD     &CCCC8800
        DCD     &DDDD9900
        DCD     &EEEEAA00
        DCD     &FFFFBB00
        DCD     &CCCCCC00
        DCD     &DDDDDD00
        DCD     &EEEEEE00
        DCD     &FFFFFF00

ConvertColourForDepth
        STMFD   sp!, {r1-sl, lr}
        LDR     r0, [ip, #&20]
        STR     r0, [ip, #&24]
        CMP     r0, #3
        BLO     ConvertColourForDepth_3
        TEQ     r4, #0
        MOVMI   r4, #0
        TEQ     r5, #0
        MOVMI   r5, #0
        TEQ     r6, #0
        MOVMI   r6, #0
        CMP     r4, #&FF
        MOVHI   r4, #&FF
        CMP     r5, #&FF
        MOVHI   r5, #&FF
        CMP     r6, #&FF
        MOVHI   r6, #&FF
        MOV     r2, r4, LSL #8
        ORR     r2, r2, r5, lsl #16
        ORR     r2, r2, r6, lsl #24
        TEQ     r0, #4
        BNE     ConvertColourForDepth_1
        BL      Colour24To15
        MOV     r0, r2
        B       ConvertColourForDepth_2
ConvertColourForDepth_1
        BL      NearestColourFromType
        MOV     r0, r2
        BL      ColourNumberToGCOL
ConvertColourForDepth_2
        LDMFD   sp!, {r1-sl, pc}
ConvertColourForDepth_3
        BL      SelectPatternPointers
        BL      SearchPaletteFull
        MOV     r0, r2
        LDMFD   sp!, {r1-sl, pc}

Colour24To15
        MOV     sl, #&FF
        AND     r7, sl, r2, lsr #8
        AND     r8, sl, r2, lsr #16
        AND     sb, sl, r2, lsr #24
        ADD     r7, r7, r7, lsl #8
        ADD     r8, r8, r8, lsl #8
        ADD     sb, sb, sb, lsl #8
        ADD     r7, r7, #&400
        ADD     r8, r8, #&400
        ADD     sb, sb, #&400
        RSB     r7, r7, r7, lsl #5
        RSB     r8, r8, r8, lsl #5
        RSB     sb, sb, sb, lsl #5
        MOV     r7, r7, LSR #&10
        MOV     r8, r8, LSR #&10
        MOV     sb, sb, LSR #&10
        ORR     r2, r7, r8, lsl #5
        ORR     r2, r2, sb, lsl #10
        ORR     r7, r7, r7, lsl #5
        ORR     r8, r8, r8, lsl #5
        ORR     sb, sb, sb, lsl #5
        MOV     r7, r7, LSR #3
        MOV     r8, r8, LSR #3
        MOV     sb, sb, LSR #3
        MOV     fp, r7, LSL #8
        ORR     fp, fp, r8, lsl #16
        ORR     fp, fp, sb, lsl #24
        MOV     pc, lr

NearestColourFromType
        LDR     r0, [ip, #&64]

NearestColour
        ADD     pc, pc, r0, lsl #2
        DCD     &F1A00000
        B       NearestDefault
        B       NearestGrey
        B       NearestCube
        B       NearestCustom

NearestDefault
        MOV     r8, #&400
        ORR     r8, r8, #&40000
        ORR     r8, r8, #&4000000
        ORR     sb, r8, r8, lsl #1
        AND     r7, sb, r2, lsr #4
        AND     r0, r2, #&3800
        AND     r1, r2, #&3C0000
        AND     r2, r2, #&38000000
        ORR     r0, r0, r1, lsr #11
        ORR     r0, r0, r2, lsr #23
        ADR     fp, DefaultPaletteTable
        LDR     sl, [fp, r0, lsr #2]
        AND     r0, sb, sl
        BIC     r1, r0, r8
        ORR     r0, r0, r1, lsl #1
        ADD     r0, r0, r7
        TST     r0, r8, lsl #2
        BEQ     NearestDefault_1
        MOV     sl, sl, LSR #2
        AND     r0, sb, sl
        BIC     r1, r0, r8
        ORR     r0, r0, r1, lsl #1
        ADD     r0, r0, r7
        TST     r0, r8, lsl #2
        BEQ     NearestDefault_1
        MOV     sl, sl, LSR #2
        AND     r0, sb, sl
        BIC     r1, r0, r8
        ORR     r0, r0, r1, lsl #1
        ADD     r0, r0, r7
        TST     r0, r8, lsl #2
        MOVNE   sl, sl, LSR #2
        MOVNE   r0, r7
NearestDefault_1
        AND     r2, sl, #3
        ORR     r0, r0, r2, lsl #8
        ORR     r0, r0, r2, lsl #16
        ORR     r0, r0, r2, lsl #24
        ORR     fp, r0, r0, lsl #4
        MOVS    r0, fp, LSL #&11
        ORRHS   r2, r2, #&10
        ORRMI   r2, r2, #4
        AND     r0, fp, #&C00000
        ORR     r2, r2, r0, lsr #17
        MOVS    r0, fp, LSL #1
        ORRHS   r2, r2, #&80
        ORRMI   r2, r2, #8
        MOV     pc, lr

DefaultPaletteTable
        DCD     &3030301C
        DCD     &C0C0C034
        DCD     &00C0C034
        DCD     &40000004
        DCD     &04C0C030
        DCD     &0430300C
        DCD     &4430305C
        DCD     &4430305C
        DCD     &C0C0C034
        DCD     &C0C0C034
        DCD     &40000004
        DCD     &40000004
        DCD     &04000010
        DCD     &04000044
        DCD     &4430305C
        DCD     &14C0C074
        DCD     &C0C0C034
        DCD     &C0C0C034
        DCD     &40000004
        DCD     &40000041
        DCD     &10000041
        DCD     &04000044
        DCD     &14000054
        DCD     &14C0C074
        DCD     &C0000014
        DCD     &C0C0C034
        DCD     &40000041
        DCD     &40000041
        DCD     &10000041
        DCD     &04000044
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000014
        DCD     &00000061
        DCD     &00000061
        DCD     &40000041
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000061
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000051
        DCD     &C000C071
        DCD     &C000C071
        DCD     &00000061
        DCD     &0000C069
        DCD     &0000C069
        DCD     &0000306D
        DCD     &44000045
        DCD     &1400C071
        DCD     &3000304D
        DCD     &3000304D
        DCD     &0000C069
        DCD     &0000C069
        DCD     &0000306D
        DCD     &0000306D
        DCD     &10000C57
        DCD     &4400304D
        DCD     &0C400C47
        DCD     &3000306D
        DCD     &0000C069
        DCD     &0000306D
        DCD     &00000C67
        DCD     &00000C67
        DCD     &0000CCAB
        DCD     &10000CA7
        DCD     &0C400C47
        DCD     &0C400C47
        DCD     &C000F07D
        DCD     &00000C67
        DCD     &00000C67
        DCD     &0000CCAB
        DCD     &0000CCAB
        DCD     &50400C87
        DCD     &0C100C53
        DCD     &0C100C53
        DCD     &30403C4F
        DCD     &00000C67
        DCD     &0000CCAB
        DCD     &0000CCAB
        DCD     &10100CA3
        DCD     &50100C93
        DCD     &0C10CC73
        DCD     &0C10CC73
        DCD     &C004F0BC
        DCD     &C010CCB3
        DCD     &10500C83
        DCD     &10100CA3
        DCD     &10100CA3
        DCD     &10100CA3
        DCD     &3004F07C
        DCD     &3004F0BC
        DCD     &C004F0BC
        DCD     &C010CCB3
        DCD     &10500C83
        DCD     &10500C83
        DCD     &10100CA3
        DCD     &10100CA3
        DCD     &3004F0BC
        DCD     &3004F0BC
        DCD     &C004F0BC
        DCD     &4044308C
        DCD     &10500C83
        DCD     &10500C83
        DCD     &10500C83
        DCD     &4444309C
        DCD     &3044309C
        DCD     &3044309C
        DCD     &C004F0BC
        DCD     &4044308C
        DCD     &10500C83
        DCD     &10500C83
        DCD     &0444308C
        DCD     &4444309C
        DCD     &3044309C
        DCD     &3044309C
        DCD     &0014C0B4
        DCD     &4044308C
        DCD     &0414C0B0
        DCD     &0444308C
        DCD     &0444308C
        DCD     &4444309C
        DCD     &C0C0C034
        DCD     &C0C0C034
        DCD     &40000004
        DCD     &40000004
        DCD     &10000041
        DCD     &04000044
        DCD     &4430305C
        DCD     &14C0C074
        DCD     &C0C0C034
        DCD     &C0C0C034
        DCD     &40000004
        DCD     &40000041
        DCD     &10000041
        DCD     &04000044
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000014
        DCD     &C0C0C071
        DCD     &40000041
        DCD     &40000041
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &40000041
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000061
        DCD     &40000049
        DCD     &50000051
        DCD     &14000054
        DCD     &14000051
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000049
        DCD     &40000049
        DCD     &40000059
        DCD     &44000045
        DCD     &14000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000059
        DCD     &04000065
        DCD     &140000A1
        DCD     &C0000069
        DCD     &00000049
        DCD     &00000049
        DCD     &0000C079
        DCD     &0000C079
        DCD     &40000059
        DCD     &10000096
        DCD     &04000099
        DCD     &3000306D
        DCD     &C000C079
        DCD     &0000C079
        DCD     &0000C079
        DCD     &0000C0B6
        DCD     &0000C0B6
        DCD     &4000309E
        DCD     &0400C0B9
        DCD     &3000306D
        DCD     &C000C079
        DCD     &0000C079
        DCD     &0000C0B6
        DCD     &0000C0B6
        DCD     &0000309E
        DCD     &4000309E
        DCD     &40000C9B
        DCD     &0C100C53
        DCD     &C010C071
        DCD     &00400086
        DCD     &0000C0B6
        DCD     &0000309E
        DCD     &00000C9B
        DCD     &40400C8B
        DCD     &10100CA3
        DCD     &300430AC
        DCD     &300430AC
        DCD     &0004C0B8
        DCD     &0040308E
        DCD     &40400C8B
        DCD     &40400C8B
        DCD     &10100CA3
        DCD     &10100CA3
        DCD     &300430AC
        DCD     &300430AC
        DCD     &0004C0B8
        DCD     &000430AC
        DCD     &40400C8B
        DCD     &10100CA3
        DCD     &10100CA3
        DCD     &040430AC
        DCD     &3044309C
        DCD     &3044309C
        DCD     &C004F0BC
        DCD     &4044308C
        DCD     &10500C83
        DCD     &0444308C
        DCD     &040430AC
        DCD     &040430AC
        DCD     &3044309C
        DCD     &C014C0B4
        DCD     &0014C0B4
        DCD     &0014C0B4
        DCD     &0414C0B0
        DCD     &0444308C
        DCD     &0444308C
        DCD     &444430DC
        DCD     &C014C0B4
        DCD     &C014C0B4
        DCD     &40540084
        DCD     &40540084
        DCD     &04540090
        DCD     &0444308C
        DCD     &444430DC
        DCD     &444430DC
        DCD     &C0C00034
        DCD     &C0C00034
        DCD     &40000041
        DCD     &40000041
        DCD     &10000041
        DCD     &04000044
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000014
        DCD     &00000061
        DCD     &40000041
        DCD     &40000041
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000061
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000054
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000061
        DCD     &40000049
        DCD     &50000051
        DCD     &44000045
        DCD     &14000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000049
        DCD     &00000049
        DCD     &40000049
        DCD     &40000059
        DCD     &04000065
        DCD     &14000051
        DCD     &00000061
        DCD     &00000049
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000059
        DCD     &04000065
        DCD     &04000099
        DCD     &C0000069
        DCD     &00000049
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000096
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C0000069
        DCD     &00000049
        DCD     &40000096
        DCD     &40000096
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C0000069
        DCD     &000000B6
        DCD     &000000B6
        DCD     &40000096
        DCD     &10000096
        DCD     &500000A6
        DCD     &C0000069
        DCD     &C00000A6
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &10000096
        DCD     &500000A6
        DCD     &3000009A
        DCD     &00400086
        DCD     &00400086
        DCD     &00400086
        DCD     &000000B6
        DCD     &0000C0BE
        DCD     &0000C0BE
        DCD     &101000B2
        DCD     &C00400A8
        DCD     &00100092
        DCD     &00100092
        DCD     &00100092
        DCD     &0000C0BE
        DCD     &0000C0BE
        DCD     &101000B2
        DCD     &101000B2
        DCD     &F004C0BC
        DCD     &C00400B8
        DCD     &00500092
        DCD     &001000B2
        DCD     &0000C0BE
        DCD     &101000B2
        DCD     &101000B2
        DCD     &040400B8
        DCD     &F004C0BC
        DCD     &00440098
        DCD     &00440098
        DCD     &00440098
        DCD     &10500082
        DCD     &040400B8
        DCD     &040400B8
        DCD     &0404C0FC
        DCD     &C01400B4
        DCD     &001400A4
        DCD     &001400A4
        DCD     &001400A4
        DCD     &04540090
        DCD     &040400B8
        DCD     &0404C0FC
        DCD     &0404C0FC
        DCD     &C01400B4
        DCD     &C01400B4
        DCD     &40540084
        DCD     &40540084
        DCD     &105400C1
        DCD     &045400C4
        DCD     &145400D4
        DCD     &141400F4
        DCD     &C0C00071
        DCD     &C0C00071
        DCD     &00C00071
        DCD     &00C00071
        DCD     &4030004D
        DCD     &10C00071
        DCD     &4430005C
        DCD     &14C00074
        DCD     &C0C00071
        DCD     &C0C00071
        DCD     &00000061
        DCD     &00000061
        DCD     &10000041
        DCD     &50000051
        DCD     &14000054
        DCD     &14000051
        DCD     &C0000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000049
        DCD     &40000049
        DCD     &40000049
        DCD     &44000045
        DCD     &14000051
        DCD     &00000061
        DCD     &00000061
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000059
        DCD     &04000065
        DCD     &14000051
        DCD     &00000061
        DCD     &00000049
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000059
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &00000049
        DCD     &00000049
        DCD     &40000059
        DCD     &40000096
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C0000069
        DCD     &000000B6
        DCD     &40000096
        DCD     &40000096
        DCD     &10000096
        DCD     &500000A6
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &40000096
        DCD     &10000096
        DCD     &500000A6
        DCD     &C0000069
        DCD     &C00000A6
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &4000009E
        DCD     &500000A6
        DCD     &3000009A
        DCD     &C00000A6
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &0000009E
        DCD     &4000009E
        DCD     &400000AE
        DCD     &F00000BA
        DCD     &C00000B6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000AE
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &0000009E
        DCD     &0000009E
        DCD     &4040008E
        DCD     &4040008E
        DCD     &400000AE
        DCD     &0C1000A3
        DCD     &3040008E
        DCD     &001000B2
        DCD     &0040008E
        DCD     &4040008E
        DCD     &4040008E
        DCD     &404000CB
        DCD     &404000CB
        DCD     &0C1000A3
        DCD     &300400AC
        DCD     &001000B2
        DCD     &0040008E
        DCD     &4040008E
        DCD     &404000CB
        DCD     &404000CB
        DCD     &101000E3
        DCD     &3044009C
        DCD     &C01400B4
        DCD     &001400A4
        DCD     &001000B6
        DCD     &004000DB
        DCD     &404000CB
        DCD     &101000E3
        DCD     &101000E3
        DCD     &C01400B4
        DCD     &C01400B4
        DCD     &001400F1
        DCD     &001400F1
        DCD     &404400CD
        DCD     &105000D3
        DCD     &444400DC
        DCD     &444400DC
        DCD     &0C0C4047
        DCD     &3030404D
        DCD     &00001041
        DCD     &0030404D
        DCD     &000C0067
        DCD     &400C4047
        DCD     &500C1043
        DCD     &500C4047
        DCD     &3030404D
        DCD     &00001041
        DCD     &00001041
        DCD     &0030006D
        DCD     &0030006D
        DCD     &0030006D
        DCD     &100C0057
        DCD     &4430404D
        DCD     &00001041
        DCD     &00004049
        DCD     &00004049
        DCD     &00C00079
        DCD     &00C00079
        DCD     &00C00079
        DCD     &04000065
        DCD     &043000AD
        DCD     &C0000069
        DCD     &00004049
        DCD     &00004049
        DCD     &00004049
        DCD     &40000059
        DCD     &40000059
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &00004049
        DCD     &00004049
        DCD     &40000096
        DCD     &40000096
        DCD     &10000096
        DCD     &04000099
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C0000069
        DCD     &000000B6
        DCD     &40000096
        DCD     &40000096
        DCD     &10000096
        DCD     &500000A6
        DCD     &C0000069
        DCD     &C0000069
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &10000096
        DCD     &500000A6
        DCD     &3000009A
        DCD     &C00000A6
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &4000009E
        DCD     &500000A6
        DCD     &F00000BA
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &0000009E
        DCD     &0000009E
        DCD     &4000009E
        DCD     &400000AE
        DCD     &F00000BA
        DCD     &F00000AE
        DCD     &000000B6
        DCD     &0000009E
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000AE
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &0000009E
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &0000009E
        DCD     &400000EB
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &404040CB
        DCD     &404040CB
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000FB
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C501083
        DCD     &0C1000A7
        DCD     &300000EF
        DCD     &004000DB
        DCD     &004000DB
        DCD     &004000DB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C5040C7
        DCD     &0C5040C7
        DCD     &C00400FD
        DCD     &001000E7
        DCD     &001000E7
        DCD     &001000E7
        DCD     &505010C3
        DCD     &505010C3
        DCD     &0C0C1053
        DCD     &3030045C
        DCD     &00C00474
        DCD     &000C1053
        DCD     &400C4047
        DCD     &100C1053
        DCD     &500C1053
        DCD     &500C1053
        DCD     &3030045C
        DCD     &C0C00474
        DCD     &00C00474
        DCD     &00C01071
        DCD     &400C4047
        DCD     &100C1053
        DCD     &500C1053
        DCD     &4430049C
        DCD     &C0C00474
        DCD     &C0C01071
        DCD     &00001061
        DCD     &00004049
        DCD     &00C00079
        DCD     &000C009B
        DCD     &043004AC
        DCD     &4430049C
        DCD     &00001061
        DCD     &00001061
        DCD     &00004049
        DCD     &00004049
        DCD     &40004086
        DCD     &40004086
        DCD     &50001092
        DCD     &140004A4
        DCD     &00001061
        DCD     &00004049
        DCD     &00004086
        DCD     &00004086
        DCD     &40004086
        DCD     &40004086
        DCD     &50001092
        DCD     &50004086
        DCD     &C0000069
        DCD     &C00000A6
        DCD     &00004086
        DCD     &00004086
        DCD     &000000B6
        DCD     &000000B6
        DCD     &10000096
        DCD     &500000A6
        DCD     &3000009A
        DCD     &C00000A6
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &0000009E
        DCD     &4000009E
        DCD     &4000009E
        DCD     &F00000BA
        DCD     &C00000A6
        DCD     &000000B6
        DCD     &000000B6
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000AE
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &000000B6
        DCD     &0000009E
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000AE
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &0000009E
        DCD     &0000009E
        DCD     &400000AE
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &000000DB
        DCD     &400000EB
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &400000EB
        DCD     &0C1010A3
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000FB
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C1010A3
        DCD     &0C1010F3
        DCD     &300000EF
        DCD     &C00000FB
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &0C1010F3
        DCD     &304040CF
        DCD     &004040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &101010E3
        DCD     &101010E3
        DCD     &0C5010D3
        DCD     &0C1010F3
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &105050C3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &505010D3
        DCD     &3030445C
        DCD     &30F0047C
        DCD     &C0F0047C
        DCD     &4030444C
        DCD     &100C5043
        DCD     &100C5043
        DCD     &100C5083
        DCD     &4430449C
        DCD     &3030445C
        DCD     &3030445C
        DCD     &C0F0047C
        DCD     &4030444C
        DCD     &100C5043
        DCD     &0430448C
        DCD     &0430448C
        DCD     &4430449C
        DCD     &3030445C
        DCD     &3030445C
        DCD     &00001454
        DCD     &00C004B8
        DCD     &04C014B0
        DCD     &043004AC
        DCD     &043004AC
        DCD     &043004AC
        DCD     &00001454
        DCD     &00001454
        DCD     &00004498
        DCD     &00004498
        DCD     &10005082
        DCD     &04C004B8
        DCD     &04C004B8
        DCD     &04C004B8
        DCD     &00001454
        DCD     &00004498
        DCD     &00005092
        DCD     &00005092
        DCD     &00001096
        DCD     &10005092
        DCD     &100010B2
        DCD     &44004498
        DCD     &C00004A8
        DCD     &00005092
        DCD     &00005092
        DCD     &00001096
        DCD     &00001096
        DCD     &100010B2
        DCD     &100010B2
        DCD     &100010B2
        DCD     &F00000BA
        DCD     &C00010B2
        DCD     &00001096
        DCD     &0000409E
        DCD     &0000409E
        DCD     &4000408E
        DCD     &4000408E
        DCD     &4000408E
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &0000409E
        DCD     &0000409E
        DCD     &0000409E
        DCD     &400000AE
        DCD     &400000AE
        DCD     &CC0000AB
        DCD     &F00000AE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &0000409E
        DCD     &0000409E
        DCD     &400000EB
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &404040CB
        DCD     &400000EB
        DCD     &400000EB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000BE
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C1010A3
        DCD     &0C0000BB
        DCD     &300000EF
        DCD     &C00000FB
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C1010A3
        DCD     &0C1010F3
        DCD     &300000EF
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &0C1010F3
        DCD     &304040CF
        DCD     &C01010F3
        DCD     &404040CB
        DCD     &101010E3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &300404FC
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &105050C3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &300404FC
        DCD     &300404FC
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &105050C3
        DCD     &105050C3
        DCD     &105050C3
        DCD     &101010E3
        DCD     &3030445C
        DCD     &3030445C
        DCD     &00C01474
        DCD     &4030444C
        DCD     &100C5083
        DCD     &0430448C
        DCD     &0430448C
        DCD     &4430449C
        DCD     &3030445C
        DCD     &C0C01474
        DCD     &00C01474
        DCD     &40005484
        DCD     &04C014B0
        DCD     &0430448C
        DCD     &0430448C
        DCD     &4430449C
        DCD     &C0C01474
        DCD     &C0C014B4
        DCD     &40005484
        DCD     &40005484
        DCD     &04005490
        DCD     &0430449C
        DCD     &4430449C
        DCD     &4430449C
        DCD     &C0C014B4
        DCD     &000014A4
        DCD     &000014A4
        DCD     &40005484
        DCD     &10005481
        DCD     &04005484
        DCD     &14005494
        DCD     &14C014B4
        DCD     &000014A4
        DCD     &000014A4
        DCD     &000014A1
        DCD     &000014A1
        DCD     &40004489
        DCD     &040014A4
        DCD     &44004498
        DCD     &140014A4
        DCD     &000014A4
        DCD     &000014A1
        DCD     &000014A1
        DCD     &00004489
        DCD     &40004489
        DCD     &40005086
        DCD     &44004498
        DCD     &140014A4
        DCD     &C00014B1
        DCD     &000014A1
        DCD     &00004489
        DCD     &000010B6
        DCD     &000010B6
        DCD     &0000409E
        DCD     &4000408E
        DCD     &100010E3
        DCD     &0C0010A7
        DCD     &C00004B9
        DCD     &000010B6
        DCD     &000010B6
        DCD     &0000409E
        DCD     &0000409E
        DCD     &400040DB
        DCD     &400040DB
        DCD     &0C0010A7
        DCD     &0C00409B
        DCD     &000010B6
        DCD     &0000409E
        DCD     &000040DB
        DCD     &000040DB
        DCD     &400040DB
        DCD     &400040DB
        DCD     &CC0000AB
        DCD     &0C0000BB
        DCD     &C00000BE
        DCD     &C00000FB
        DCD     &000040DB
        DCD     &000040DB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &0C1010A3
        DCD     &0C1010A3
        DCD     &300000EF
        DCD     &C00000FB
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &0C1010F3
        DCD     &304040CF
        DCD     &C00000FB
        DCD     &404040CB
        DCD     &404040CB
        DCD     &101010E3
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &0C1010F3
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &404040CB
        DCD     &101010E3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &0C1010F3
        DCD     &300404FC
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &105050C3
        DCD     &105050C3
        DCD     &101010E3
        DCD     &101010E3
        DCD     &300404FC
        DCD     &300404FC
        DCD     &C00404FC
        DCD     &C01010F3
        DCD     &105050C3
        DCD     &105050C3
        DCD     &105050C3
        DCD     &101010E3
        DCD     &304444DC
        DCD     &300404FC
        DCD     &C00404FC
        DCD     &404444CC
        DCD     &105050C3
        DCD     &105050C3
        DCD     &044444CC
        DCD     &444444DC

NearestGrey
        MOV     sl, #&FF
        AND     r7, sl, r2, lsr #8
        AND     r8, sl, r2, lsr #16
        AND     sb, sl, r2, lsr #24
        MOV     sl, #&1C
        MUL     r2, sl, sb
        MOV     sl, #&97
        MLA     r2, sl, r8, r2
        MOV     sl, #&4D
        MLA     r2, sl, r7, r2
        ADD     r2, r2, r2, lsr #8
        MOV     r2, r2, LSR #8
        MOV     fp, r2, LSL #8
        ORR     fp, fp, r2, lsl #16
        ORR     fp, fp, r2, lsl #24
        MOV     pc, lr

NearestCube
        MOV     sl, #&FF
        AND     r7, sl, r2, lsr #8
        AND     r8, sl, r2, lsr #16
        AND     sb, sl, r2, lsr #24
        ADD     r7, r7, r7, lsl #8
        ADD     r8, r8, r8, lsl #8
        ADD     sb, sb, sb, lsl #8
        ADD     r7, r7, r7, lsl #2
        ADD     r8, r8, r8, lsl #2
        ADD     sb, sb, sb, lsl #2
        MOVS    r0, r7, LSR #&10
        ADDHS   r0, r0, #1
        MOVS    r1, r8, LSR #&10
        ADDHS   r1, r1, #1
        MOVS    r2, sb, LSR #&10
        ADDHS   r2, r2, #1
        MOV     fp, r0, LSL #8
        ORR     fp, fp, r1, lsl #16
        ORR     fp, fp, r2, lsl #24
        ADD     fp, fp, fp, lsl #1
        ADD     fp, fp, fp, lsl #4
        ADD     r0, r0, r1, lsl #1
        ADD     r0, r0, r1, lsl #2
        ADD     r0, r0, r2, lsl #2
        ADD     r2, r0, r2, lsl #5
        ADR     sl, CubeClassTable
        LDRB    sl, [sl, r2]
        TEQ     sl, #0
        MOVEQ   pc, lr
        STMFD   sp!, {r2, lr}
        MOVS    r0, r7, LSR #4
        ADDHS   r0, r0, #1
        MOVS    r1, r8, LSR #4
        ADDHS   r1, r1, #1
        MOVS    r2, sb, LSR #4
        ADDHS   r2, r2, #1
        MUL     lr, r0, r0
        MLA     lr, r1, r1, lr
        MLA     lr, r2, r2, lr
        ADD     lr, lr, lr, lsl #1
        ADD     r0, r0, r1
        ADD     r0, r0, r2
        MUL     r1, r0, r0
        SUB     lr, lr, r1
        CMP     lr, #&2400000
        LDMFDHS sp!, {r2, pc}
        CMP     lr, #&800000
        BLS     NearestCube_1
        MOV     r0, r7, LSL #&10
        MOVS    r0, r0, ASR #&14
        ADDHSS  r0, r0, #1
        RSBMI   r0, r0, #0
        MOV     r1, r8, LSL #&10
        MOVS    r1, r1, ASR #&14
        ADDHSS  r1, r1, #1
        RSBMI   r1, r1, #0
        MOV     r2, sb, LSL #&10
        MOVS    r2, r2, ASR #&14
        ADDHSS  r2, r2, #1
        RSBMI   r2, r2, #0
        MUL     sl, r0, r0
        MLA     sl, r1, r1, sl
        MLA     sl, r2, r2, sl
        ADD     sl, sl, sl, lsl #1
        CMP     lr, sl
        LDMFDHS sp!, {r2, pc}
NearestCube_1
        MOV     sl, #&4D
        MUL     r2, sl, r7
        MOV     sl, #&97
        MLA     r2, sl, r8, r2
        MOV     sl, #&1C
        MLA     r2, sl, sb, r2
        ADD     r2, r2, r2, lsl #3
        MOVS    r2, r2, LSR #&18
        ADDHS   r2, r2, #1
        ADR     lr, GreyPaletteTable
        LDRB    r2, [lr, r2]
        ADD     lr, ip, #&84
        LDR     fp, [lr, r2, lsl #2]
        ADD     sp, sp, #4
        LDR     pc, [sp], #4

CubeClassTable
        DCD     &00000101
        DCD     &01010000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000101
        DCD     &01010000
        DCD     &00000001
        DCD     &00010100
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &01000000
        DCD     &00000001
        DCD     &01010100
        DCD     &00000000
        DCD     &00000101
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &01010000
        DCD     &00000000
        DCD     &00010101
        DCD     &01000000
        DCD     &00000001
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00010100
        DCD     &01000000
        DCD     &00000101
        DCD     &01010000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000000
        DCD     &00000101
        DCD     &01010000

GreyPaletteTable
        DCD     &DAD9D800
        DCD     &DEDDDCDB
        DCD     &E1E02BDF
        DCD     &E5E4E3E2
        DCD     &E856E7E6
        DCD     &ECEBEAE9
        DCD     &81EFEEED
        DCD     &F3F2F1F0
        DCD     &F7F6F5F4
        DCD     &FAF9F8AC
        DCD     &FEFDFCFB
        DCD     &524FD7FF

NearestCustom
        STMFD   sp!, {r4-r6, lr}
        MOV     lr, #&FF
        AND     r4, lr, r2, lsr #8
        AND     r5, lr, r2, lsr #16
        AND     r6, lr, r2, lsr #24
        RSB     r4, r4, r4, lsl #5
        ADD     r4, r4, r4, lsl #8
        MOVS    r4, r4, LSR #&10
        ADDHS   r4, r4, #1
        RSB     r5, r5, r5, lsl #5
        ADD     r5, r5, r5, lsl #8
        MOVS    r5, r5, LSR #&10
        ADDHS   r5, r5, #1
        RSB     r6, r6, r6, lsl #5
        ADD     r6, r6, r6, lsl #8
        MOVS    r6, r6, LSR #&10
        ADDHS   r6, r6, #1
        LDR     r8, [ip, #&68]
        TEQ     r8, #0
        BEQ     NearestCustom_2
NearestCustom_1
        ADD     r0, ip, #&84
        ORR     r7, r4, r5, lsl #5
        ORR     r7, r7, r6, lsl #10
        LDRB    r2, [r8, r7]
        TEQ     r2, #0
        LDRNE   fp, [r0, r2, lsl #2]
        LDMFDNE sp!, {r4-r6, pc}
        ADD     lr, r8, #&8000
        LDRB    sb, [lr, r7, lsr #3]
        AND     sl, r7, #7
        MOV     fp, #1
        TST     sb, fp, lsl sl
        LDRNE   fp, [r0]
        LDMFDNE sp!, {r4-r6, pc}
        ORR     sb, sb, fp, lsl sl
        STRB    sb, [lr, r7, lsr #3]
        ADD     r1, r0, #&400
        ORR     r4, r4, r4, lsl #5
        MOV     r4, r4, LSR #2
        ORR     r5, r5, r5, lsl #5
        MOV     r5, r5, LSR #2
        ORR     r6, r6, r6, lsl #5
        MOV     r6, r6, LSR #2
        BL      SearchPaletteFull
        STRB    r2, [r8, r7]
        LDMFD   sp!, {r4-r6, pc}
NearestCustom_2
        BL      AllocPaletteCache
        LDRVC   r8, [ip, #&68]
        BVC     NearestCustom_1
        ADD     r0, ip, #&84
        ADD     r1, r0, #&400
        BL      SearchPaletteFull
        LDMFD   sp!, {r4-r6, pc}

AllocPaletteCache
        STMFD   sp!, {r0-sb, lr}
        MOV     r0, #6
        MOV     r3, #&9000
        SWI     &2001E ; XOS_Module
        LDMFDVS sp!, {r0-sb, pc}
        STR     r2, [ip, #&68]
        MOV     r0, r2
        MOV     r1, r3
        MOV     r2, #0
        MOV     r3, #0
        MOV     r4, #0
        MOV     r5, #0
        MOV     r6, #0
        MOV     r7, #0
        MOV     r8, #0
        MOV     sb, #0
AllocPaletteCache_1
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        STMIA   r0!, {r2-sb}
        SUBS    r1, r1, #&100
        BNE     AllocPaletteCache_1
        MSR     CPSR_f, #0
        LDMFD   sp!, {r0-sb, pc}

SearchPaletteFull
        STMFD   sp!, {r1, r3-r8, lr}
        MOV     r3, #&FF
        B       SearchPalette_1

SearchOffsetTable
        DCD     &00000002
        DCD     &00000004
        DCD     &00000010
        DCD     &00000100

SetSearchPointers
        ADR     r1, SearchOffsetTable
        LDR     r1, [r1, r0, lsl #2]
        ADD     r0, ip, #&84
        ADD     r1, r0, r1, lsl #2

SearchPalette
        STMFD   sp!, {r1, r3-r8, lr}
        MOV     r3, #&FF
        AND     r4, r3, r2, lsr #8
        AND     r5, r3, r2, lsr #16
        AND     r6, r3, r2, lsr #24
SearchPalette_1
        MVN     fp, #0
SearchPalette_2
        TEQ     r0, r1
        BEQ     SearchPalette_5
SearchPalette_3
        LDMDB   r1!, {sb, sl}
        AND     r7, r3, sb, lsr #16
        SUBS    r7, r5, r7
        RSBMI   r7, r7, #0
        ADD     lr, r7, r7, lsl #1
        MUL     r7, lr, r7
        CMP     fp, r7
        BLS     SearchPalette_4
        AND     r8, r3, sb, lsr #8
        SUBS    r8, r4, r8
        RSBMI   r8, r8, #0
        MOV     lr, r8, LSL #1
        MLA     r7, lr, r8, r7
        CMP     fp, r7
        BLS     SearchPalette_4
        SUBS    sb, r6, sb, lsr #24
        RSBMI   sb, sb, #0
        MLA     r7, sb, sb, r7
        CMP     fp, r7
        MOVHI   fp, r7
        SUBHI   r2, r1, r0
SearchPalette_4
        AND     r7, r3, sl, lsr #16
        SUBS    r7, r5, r7
        RSBMI   r7, r7, #0
        ADD     lr, r7, r7, lsl #1
        MUL     r7, lr, r7
        CMP     fp, r7
        BLS     SearchPalette_2
        AND     r8, r3, sl, lsr #8
        SUBS    r8, r4, r8
        RSBMI   r8, r8, #0
        MOV     lr, r8, LSL #1
        MLA     r7, lr, r8, r7
        CMP     fp, r7
        BLS     SearchPalette_2
        SUBS    sb, r6, sl, lsr #24
        RSBMI   sb, sb, #0
        MLA     r7, sb, sb, r7
        CMP     fp, r7
        BLS     SearchPalette_2
        MOV     fp, r7
        SUB     r2, r1, r0
        ADD     r2, r2, #4
        TEQ     r0, r1
        BNE     SearchPalette_3
SearchPalette_5
        LDR     fp, [r0, r2]
        MOV     r2, r2, LSR #2
        LDMFD   sp!, {r1, r3-r8, pc}

SearchPaletteAlt
        STMFD   sp!, {r3-r6, lr}
        MOV     r3, #&FF
        AND     r4, r3, r2, lsr #8
        AND     r5, r3, r2, lsr #16
        AND     r6, r3, r2, lsr #24
        MOV     fp, #0
        MOV     sl, r1
SearchPaletteAlt_1
        LDMDB   sl!, {sb}
        AND     r7, r3, sb, lsr #8
        SUBS    r7, r4, r7
        RSBMI   r7, r7, #0
        AND     r8, r3, sb, lsr #16
        SUBS    r8, r5, r8
        RSBMI   r8, r8, #0
        SUBS    sb, r6, sb, lsr #24
        RSBMI   sb, sb, #0
        MOV     lr, r7, LSL #1
        MUL     r7, lr, r7
        ADD     lr, r8, r8, lsl #1
        MLA     r7, lr, r8, r7
        MLA     r7, sb, sb, r7
        CMP     fp, r7
        MOVLO   fp, r7
        SUBLO   r2, sl, r0
        TEQ     r0, sl
        BNE     SearchPaletteAlt_1
        MOV     r2, r2, LSR #2
        LDMFD   sp!, {r3-r6, pc}

SpotRound
        STMFD   sp!, {r0, r1, lr}
        TEQ     r0, #0
        RSBMI   r0, r0, #0
        TEQ     r1, #0
        RSBMI   r1, r1, #0
        ADD     lr, r0, r1
        CMP     lr, #&10000
        RSBGT   r0, r0, #&10000
        RSBGT   r1, r1, #&10000
        MOV     lr, r0, ASR #1
        MUL     r0, lr, r0
        MOV     lr, r1, ASR #1
        MLA     r2, lr, r1, r0
        MOV     r2, r2, LSR #7
        SUBGT   r2, r2, #&1000000
        RSBLE   r2, r2, #&1000000
        LDMFD   sp!, {r0, r1, pc}
SpotRound_1
        STMFD   sp!, {r0, r1, lr}
        MOV     lr, r0, ASR #1
        MUL     r0, lr, r0
        MOV     lr, r1, ASR #1
        MLA     r2, lr, r1, r0
        MOVS    r2, r2, LSR #7
        ADDHS   r2, r2, #1
        RSB     r2, r2, #&1000000
        LDMFD   sp!, {r0, r1, pc}
SpotRound_2
        STMFD   sp!, {r0, r1, lr}
        MOV     lr, r0, ASR #1
        MUL     r0, lr, r0
        MOV     lr, r1, ASR #1
        MLA     r2, lr, r1, r0
        MOVS    r2, r2, LSR #7
        ADDHS   r2, r2, #1
        LDMFD   sp!, {r0, r1, pc}
SpotRound_3
        MOVS    r2, r1
        RSBMI   r2, r2, #0
        MOV     pc, lr
SpotRound_4
        STMFD   sp!, {r0, r1, lr}
        TEQ     r0, #0
        RSBMI   r0, r0, #0
        TEQ     r1, #0
        RSBMI   r1, r1, #0
        CMP     r0, r1
        MOVLE   r2, r0
        MOVGT   r2, r1
        LDMFD   sp!, {r0, r1, pc}
SpotRound_5
        STMFD   sp!, {r0, r1, lr}
        MOVS    r0, r0, LSL #1
        RSBMI   r0, r0, #0
        MOVS    r1, r1, LSL #1
        RSBMI   r1, r1, #0
        SUBS    r0, r0, #&10000
        RSBMI   r0, r0, #0
        SUBS    r1, r1, #&10000
        RSBMI   r1, r1, #0
        ADD     lr, r0, r1
        CMP     lr, #&10000
        RSBGT   r0, r0, #&10000
        RSBGT   r1, r1, #&10000
        MOV     lr, r0, ASR #1
        MUL     r0, lr, r0
        MOV     lr, r1, ASR #1
        MLA     r2, lr, r1, r0
        MOV     r2, r2, LSR #7
        SUBGT   r2, r2, #&1000000
        RSBLE   r2, r2, #&1000000
        LDMFD   sp!, {r0, r1, pc}

SetScreen
        STMFD   sp!, {r0-fp, lr}
        SUB     sp, sp, #&10
        CMN     r0, #1
        ADREQ   r0, SpotRound
        CMN     r0, #2
        ADREQ   r0, SpotRound_1
        CMN     r0, #3
        ADREQ   r0, SpotRound_2
        CMN     r0, #4
        ADREQ   r0, SpotRound_3
        CMN     r0, #5
        ADREQ   r0, SpotRound_4
        CMN     r0, #6
        ADREQ   r0, SpotRound_5
        STR     r0, [sp, #&C]
        MOV     r0, r1
        BL      Sine
        MOVS    sl, r0, ASR #&E
        ADDHS   sl, sl, #1
        MOV     r0, r1
        BL      ScreenSpot
        MOVS    fp, r0, ASR #&E
        ADDHS   fp, fp, #1
SetScreen_1
        MOV     r0, r4
        MUL     r6, sl, r3
        MUL     r7, fp, r3
        RSB     r7, r7, #0
        MUL     r8, fp, r2
        MUL     sb, sl, r2
        MOV     r1, r6
        BL      Divide16
        MOVS    r6, r1, ASR #&10
        ADDHS   r6, r6, #1
        MOV     r1, r7
        BL      Divide16
        MOVS    r7, r1, ASR #&10
        ADDHS   r7, r7, #1
        MOV     r1, r8
        BL      Divide16
        MOVS    r8, r1, ASR #&10
        ADDHS   r8, r8, #1
        MOV     r1, sb
        BL      Divide16
        MOVS    sb, r1, ASR #&10
        ADDHS   sb, sb, #1
        MULS    sl, r6, sb
        RSBMI   sl, sl, #0
        MULS    fp, r7, r8
        RSBMI   fp, fp, #0
        ADDS    r5, sl, fp
        MOVEQ   r2, r2, LSL #1
        MOVEQ   r3, r3, LSL #1
        BEQ     SetScreen_1
        CMP     r5, #&400
        BHI     SetScreen_14
        MOVS    r0, r6
        RSBMI   r0, r0, #0
        MOVS    r1, r7
        RSBMI   r1, r1, #0
        MOV     r2, #0
        MOV     r3, #0
        MOV     r4, #0
SetScreen_2
        ADD     r4, r4, #1
        SUBS    r2, r2, r0
        ADDMI   r2, r2, r5
        SUBS    r3, r3, r1
        ADDMI   r3, r3, r5
        ORRS    lr, r2, r3
        BNE     SetScreen_2
        STR     r4, [sp, #4]
        MOV     r0, r5
        MOV     r1, #0
SetScreen_3
        ADD     r1, r1, #1
        SUBS    r0, r0, r4
        ADDNE   r1, r1, #1
        SUBNES  r0, r0, r4
        ADDNE   r1, r1, #1
        SUBNES  r0, r0, r4
        BNE     SetScreen_3
        STR     r1, [sp]
        RSB     sl, r1, #0
        MOVS    r0, r6
        MOV     r2, r8
        RSBMI   r0, r0, #0
        RSBMI   r2, r2, #0
        MOVS    r1, r7
        MOV     r3, sb
        RSBMI   r1, r1, #0
        RSBMI   r3, r3, #0
        MULS    r2, sl, r2
SetScreen_4
        SUBPLS  r2, r2, r5
        BPL     SetScreen_4
SetScreen_5
        ADDS    r2, r2, r5
        BMI     SetScreen_5
        MULS    r3, sl, r3
SetScreen_6
        SUBPLS  r3, r3, r5
        BPL     SetScreen_6
SetScreen_7
        ADDS    r3, r3, r5
        BMI     SetScreen_7
        MOV     sl, #0
        MOV     fp, #0
        MOV     r4, #0
        TEQ     sl, r2
        TEQEQ   fp, r3
        BEQ     SetScreen_9
SetScreen_8
        ADD     r4, r4, #1
        SUBS    sl, sl, r0
        ADDMI   sl, sl, r5
        SUBS    fp, fp, r1
        ADDMI   fp, fp, r5
        TEQ     sl, r2
        TEQEQ   fp, r3
        BNE     SetScreen_8
SetScreen_9
        STR     r4, [sp, #8]
        MOV     r0, r5
        MOV     r1, r6
        BL      Divide16
        MOV     r6, r1
        MOV     r1, r7
        BL      Divide16
        MOV     r7, r1
        MOV     r1, r8
        BL      Divide16
        MOV     r8, r1
        MOV     r1, sb
        BL      Divide16
        MOV     sb, r1
        TST     r5, #1
        MOVNE   r0, #0
        MOVNE   r1, #0
        ADDEQ   r0, r6, r7
        ADDEQ   r1, r8, sb
        ADD     r0, r0, #&11
        ADD     r1, r1, #&21
        MOV     sl, #0
        MOV     fp, #0
        LDR     r4, [sp, #4]
SetScreen_10
        MOV     lr, pc
        LDR     pc, [sp, #&C]
        ADD     r2, r2, #&1000000
        MOV     lr, #&4000
        STR     r2, [lr, sl, lsl #2]
        ADD     sl, sl, #1
        TEQ     sl, r5
        BEQ     SetScreen_11
        ADD     fp, fp, #1
        TEQ     r4, fp
        MOVEQ   fp, #0
        ADDEQ   r0, r0, r8, lsl #1
        ADDEQ   r1, r1, sb, lsl #1
        ADD     r0, r0, r6, lsl #1
        ADD     r1, r1, r7, lsl #1
        MOV     r0, r0, LSL #&F
        MOV     r0, r0, ASR #&F
        MOV     r1, r1, LSL #&F
        MOV     r1, r1, ASR #&F
        B       SetScreen_10
SetScreen_11
        MOV     r1, #&FF0
        MOV     r0, r5
        BL      Divide16
        MOV     r8, r1
        MUL     lr, r1, r5
        SUB     lr, lr, r1
        CMP     lr, #&FF00
        SUBHS   r8, r8, #1
        MOV     r0, #&4000
        ADD     r1, ip, #&84
        ADD     r1, r1, #&400
        MOV     r2, r5
        MOV     r7, r8, LSR #1
SetScreen_12
        MVN     r4, #0
        MOV     r3, #0
SetScreen_13
        LDR     lr, [r0, r3, lsl #2]
        CMP     r4, lr
        MOVHI   r4, lr
        MOVHI   r6, r3
        ADD     r3, r3, #1
        TEQ     r3, r2
        BNE     SetScreen_13
        MVN     lr, #0
        STR     lr, [r0, r6, lsl #2]
        MOV     lr, r7, LSR #&14
        STRB    lr, [r1, r6]
        ADD     r7, r7, r8
        SUBS    r5, r5, #1
        BNE     SetScreen_12
        MOV     r0, r1
        LDR     r1, [sp, #4]
        LDR     r2, [sp]
        LDR     r3, [sp, #8]
        LDR     r4, [sp, #&24]
        LDR     r5, [sp, #&28]
        MOV     r6, #0
        MOV     r7, #0
        BL      SetHalftone
        ADD     sp, sp, #&10
        ExitOK r0, fp
SetScreen_14
        ADD     r0, pc, #0
        B       ReturnError

ErrScreenSize
        DCD     &00803004
        DCB     "Screen size too large"
        DCB     &00,&00,&00

CacheScreen
        STMFD   sp!, {r2-fp, lr}
        LDR     r1, [ip, #&44]
        TEQ     r1, #0
        BEQ     CacheScreen_2
        LDR     lr, [ip, #&40]
        TEQ     r0, lr
        MOVEQ   r0, r1
        LDREQ   r1, [ip, #&48]
        BNE     CacheScreen_2
CacheScreen_1
        ExitOK r2, fp
CacheScreen_2
        ADD     r1, ip, #&84
        ADD     r1, r1, #&800
        STR     r0, [ip, #&40]
        STR     r1, [ip, #&44]
        LDR     r2, [ip, #&28]
        LDR     r3, [ip, #&30]
        LDR     r6, [ip, #&2C]
        LDR     sb, [ip, #&20]
        RSB     lr, sb, #5
        MOV     lr, r6, LSR lr
        MUL     lr, r3, lr
        CMP     lr, #&40
CacheScreen_3
        MOVHI   r0, #0
        MOVHI   r1, #0
        BHI     CacheScreen_1
        ADD     lr, ip, #&38
        LDMIA   lr, {sl, fp}
        CMP     sb, #3
        ADDLS   pc, pc, sb, lsl #2
        B       CacheScreen_3
        B       CacheScreen_4
        B       CacheScreen_13
        B       CacheScreen_22
        B       CacheScreen_31
CacheScreen_4
        MOV     sl, sl, LSL #&1F
        MOV     fp, fp, LSL #&1F
CacheScreen_5
        MOV     r8, r1
        CMP     r6, #&20
        BLO     CacheScreen_8
        MOV     r4, r6
CacheScreen_6
        MOV     r7, #&20
CacheScreen_7
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
        SUBS    r7, r7, #4
        BNE     CacheScreen_7
        TEQ     r1, r8
        MOVEQ   sb, r5
        STR     r5, [r1], #4
        SUBS    r4, r4, #&20
        BEQ     CacheScreen_12
        CMP     r4, #&20
        BHS     CacheScreen_6
CacheScreen_8
        AND     r4, r6, #&1F
        MOVS    r4, r4, LSR #1
        ADDHS   r4, r4, #1
        BHS     CacheScreen_10
CacheScreen_9
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
CacheScreen_10
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #1
        ORRGT   r5, fp, r5, lsr #1
        SUBS    r4, r4, #1
        BNE     CacheScreen_9
        AND     r4, r6, #&1F
        RSB     lr, r4, #&20
        MOV     r5, r5, LSR lr
        TEQ     r1, r8
        MOVEQ   sb, r5
CacheScreen_11
        ORR     r5, r5, sb, lsl r4
        ADD     r4, r4, r6
        CMP     r4, #&20
        BLO     CacheScreen_11
        STR     r5, [r1], #4
CacheScreen_12
        SUBS    r3, r3, #1
        BNE     CacheScreen_5
        ADD     r0, ip, #&84
        ADD     r0, r0, #&800
        CMP     r4, #&20
        MOVEQ   r1, r4
        SUBHI   r1, r4, r6
        CMP     r6, #&20
        MOVHS   r1, r6
        STR     r1, [ip, #&48]
        ExitOK r2, fp
CacheScreen_13
        MOV     sl, sl, LSL #&1E
        MOV     fp, fp, LSL #&1E
CacheScreen_14
        MOV     r8, r1
        CMP     r6, #&10
        BLO     CacheScreen_17
        MOV     r4, r6
CacheScreen_15
        MOV     r7, #&10
CacheScreen_16
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
        SUBS    r7, r7, #4
        BNE     CacheScreen_16
        TEQ     r1, r8
        MOVEQ   sb, r5
        STR     r5, [r1], #4
        SUBS    r4, r4, #&10
        BEQ     CacheScreen_21
        CMP     r4, #&10
        BHS     CacheScreen_15
CacheScreen_17
        AND     r4, r6, #&F
        MOVS    r4, r4, LSR #1
        ADDHS   r4, r4, #1
        BHS     CacheScreen_19
CacheScreen_18
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
CacheScreen_19
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #2
        ORRGT   r5, fp, r5, lsr #2
        SUBS    r4, r4, #1
        BNE     CacheScreen_18
        AND     r4, r6, #&F
        MOV     r4, r4, LSL #1
        RSB     lr, r4, #&20
        MOV     r5, r5, LSR lr
        TEQ     r1, r8
        MOVEQ   sb, r5
CacheScreen_20
        ORR     r5, r5, sb, lsl r4
        ADD     r4, r4, r6, lsl #1
        CMP     r4, #&20
        BLO     CacheScreen_20
        STR     r5, [r1], #4
CacheScreen_21
        SUBS    r3, r3, #1
        BNE     CacheScreen_14
        ADD     r0, ip, #&84
        ADD     r0, r0, #&800
        CMP     r4, #&20
        MOVEQ   r1, r4
        SUBHI   r1, r4, r6, lsl #1
        CMP     r6, #&10
        MOVHS   r1, r6, LSL #1
        STR     r1, [ip, #&48]
        ExitOK r2, fp
CacheScreen_22
        MOV     sl, sl, LSL #&1C
        MOV     fp, fp, LSL #&1C
CacheScreen_23
        MOV     r8, r1
        CMP     r6, #8
        BLO     CacheScreen_26
        MOV     r4, r6
CacheScreen_24
        MOV     r7, #8
CacheScreen_25
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
        SUBS    r7, r7, #4
        BNE     CacheScreen_25
        TEQ     r1, r8
        MOVEQ   sb, r5
        STR     r5, [r1], #4
        SUBS    r4, r4, #8
        BEQ     CacheScreen_30
        CMP     r4, #8
        BHS     CacheScreen_24
CacheScreen_26
        AND     r4, r6, #7
        MOVS    r4, r4, LSR #1
        ADDHS   r4, r4, #1
        BHS     CacheScreen_28
CacheScreen_27
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
CacheScreen_28
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #4
        ORRGT   r5, fp, r5, lsr #4
        SUBS    r4, r4, #1
        BNE     CacheScreen_27
        AND     r4, r6, #7
        MOV     r4, r4, LSL #2
        RSB     lr, r4, #&20
        MOV     r5, r5, LSR lr
        TEQ     r1, r8
        MOVEQ   sb, r5
CacheScreen_29
        ORR     r5, r5, sb, lsl r4
        ADD     r4, r4, r6, lsl #2
        CMP     r4, #&20
        BLO     CacheScreen_29
        STR     r5, [r1], #4
CacheScreen_30
        SUBS    r3, r3, #1
        BNE     CacheScreen_23
        ADD     r0, ip, #&84
        ADD     r0, r0, #&800
        CMP     r4, #&20
        MOVEQ   r1, r4
        SUBHI   r1, r4, r6, lsl #2
        CMP     r6, #8
        MOVHS   r1, r6, LSL #2
        STR     r1, [ip, #&48]
        ExitOK r2, fp
CacheScreen_31
        MOV     sl, sl, LSL #&18
        MOV     fp, fp, LSL #&18
CacheScreen_32
        MOV     r8, r1
        CMP     r6, #4
        BLO     CacheScreen_34
        MOV     r4, r6
CacheScreen_33
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
        TEQ     r1, r8
        MOVEQ   sb, r5
        STR     r5, [r1], #4
        SUBS    r4, r4, #4
        BEQ     CacheScreen_38
        CMP     r4, #4
        BHS     CacheScreen_33
CacheScreen_34
        AND     r4, r6, #3
        MOVS    r4, r4, LSR #1
        ADDHS   r4, r4, #1
        BHS     CacheScreen_36
CacheScreen_35
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
CacheScreen_36
        LDRB    lr, [r2], #1
        CMP     r0, lr
        ORRLE   r5, sl, r5, lsr #8
        ORRGT   r5, fp, r5, lsr #8
        SUBS    r4, r4, #1
        BNE     CacheScreen_35
        AND     r4, r6, #3
        MOV     r4, r4, LSL #3
        RSB     lr, r4, #&20
        MOV     r5, r5, LSR lr
        TEQ     r1, r8
        MOVEQ   sb, r5
CacheScreen_37
        ORR     r5, r5, sb, lsl r4
        ADD     r4, r4, r6, lsl #3
        CMP     r4, #&20
        BLO     CacheScreen_37
        STR     r5, [r1], #4
CacheScreen_38
        SUBS    r3, r3, #1
        BNE     CacheScreen_32
        ADD     r0, ip, #&84
        ADD     r0, r0, #&800
        CMP     r4, #&20
        MOVEQ   r1, r4
        SUBHI   r1, r4, r6, lsl #3
        CMP     r6, #4
        MOVHS   r1, r6, LSL #3
        STR     r1, [ip, #&48]
        ExitOK r2, fp

Sine
        STMFD   sp!, {r1-sl, lr}
        BL      ReduceAngle
        ADD     r2, r2, #1
        MOVS    r6, r0
        RSBMI   r0, r0, #0
        MOVS    lr, r2, LSL #&1F
        BPL     ScreenSpot_1
Sine_1
        BHS     Sine_2
        MOV     r0, r0, LSL #&A
        BL      Square16
        MOV     r5, r0
        ADR     lr, SineTable
        LDMIA   lr!, {r1, r7-sl}
        BL      Multiply16
        RSB     r0, r7, r0, lsr #7
        BL      MultiplySigned16
        ADD     r0, r8, r0, asr #5
        BL      MultiplySigned16
        RSB     r0, sb, r0, asr #3
        BL      MultiplySigned16
        ADD     r0, sl, r0, asr #1
        LDMFD   sp!, {r1-sl, pc}
Sine_2
        MOV     r0, r0, LSL #&A
        BL      Square16
        MOV     r5, r0
        ADR     lr, SineTable
        LDMIA   lr!, {r1, r7-sl}
        BL      Multiply16
        RSB     r0, r7, r0, lsr #7
        BL      MultiplySigned16
        ADD     r0, r8, r0, asr #5
        BL      MultiplySigned16
        RSB     r0, sb, r0, asr #3
        BL      MultiplySigned16
        ADD     r0, sl, r0, asr #1
        RSB     r0, r0, #0
        LDMFD   sp!, {r1-sl, pc}

SineTable
        DCD     &F7C13513
        DCD     &5863091F
        DCD     &426C4015
        DCD     &4FDA8761
        DCD     &40000000

ScreenSpot
        STMFD   sp!, {r1-sl, lr}
        BL      ReduceAngle
        MOVS    r6, r0
        RSBMI   r0, r0, #0
        MOVS    lr, r2, LSL #&1F
        BMI     Sine_1
ScreenSpot_1
        BHS     ScreenSpot_2
        MOV     r0, r0, LSL #&A
        BL      Square16
        MOV     r5, r0
        ADR     lr, SpotTable
        LDMIA   lr!, {r1, r7-sl}
        BL      Multiply16
        RSB     r0, r7, r0, lsr #7
        BL      MultiplySigned16
        ADD     r0, r8, r0, asr #5
        BL      MultiplySigned16
        RSB     r0, sb, r0, asr #4
        BL      MultiplySigned16
        ADD     r0, sl, r0, asr #3
        MOV     r5, r6, LSL #&A
        TEQ     r6, #0
        RSBMI   r5, r5, #0
        BL      MultiplySigned16
        RSBMI   r0, r0, #0
        LDMFD   sp!, {r1-sl, pc}
ScreenSpot_2
        MOV     r0, r0, LSL #&A
        BL      Square16
        MOV     r5, r0
        ADR     lr, SpotTable
        LDMIA   lr!, {r1, r7-sl}
        BL      Multiply16
        RSB     r0, r7, r0, lsr #7
        BL      MultiplySigned16
        ADD     r0, r8, r0, asr #5
        BL      MultiplySigned16
        RSB     r0, sb, r0, asr #4
        BL      MultiplySigned16
        ADD     r0, sl, r0, asr #3
        RSB     r0, r0, #0
        MOV     r5, r6, LSL #&A
        TEQ     r6, #0
        RSBMI   r5, r5, #0
        BL      MultiplySigned16
        RSBMI   r0, r0, #0
        LDMFD   sp!, {r1-sl, pc}

SpotTable
        DCD     &F6D1DFA9
        DCD     &70D72AE3
        DCD     &76B64F55
        DCD     &76EE0831
        DCD     &477D1A89

Square16
        MOV     r1, r0, LSR #&10
        BIC     r0, r0, r1, lsl #16
        MUL     r0, r1, r0
        MOV     r2, r1
        MUL     r1, r2, r1
        MOVS    r0, r0, LSR #&F
        ADC     r0, r1, r0
        MOV     pc, lr

Multiply16
        MOV     r2, r0, LSR #&10
        MOV     r3, r1, LSR #&10
        BIC     r0, r0, r2, lsl #16
        BIC     r1, r1, r3, lsl #16
        MUL     r0, r3, r0
        MUL     r3, r2, r3
        MUL     r1, r2, r1
        ADDS    r0, r0, r1
        ADDHS   r3, r3, #&10000
        MOVS    r0, r0, LSR #&10
        ADC     r0, r3, r0
        MOV     pc, lr

MultiplySigned16
        MOVS    r4, r0
        RSBMI   r0, r0, #0
        MOV     r2, r0, LSR #&10
        MOV     r3, r5, LSR #&10
        BIC     r0, r0, r2, lsl #16
        BIC     r1, r5, r3, lsl #16
        MUL     r0, r3, r0
        MUL     r3, r2, r3
        MUL     r1, r2, r1
        ADDS    r0, r0, r1
        ADDHS   r3, r3, #&10000
        MOVS    r0, r0, LSR #&10
        ADC     r0, r3, r0
        TEQ     r4, #0
        RSBMI   r0, r0, #0
        MOV     pc, lr

ReduceAngle
        MOVS    r1, r0
        RSBMI   r0, r0, #0
        MOV     r3, #&2D0000
ReduceAngle_1
        CMP     r0, r3, lsl #3
        SUBHSS  r0, r0, r3, lsl #3
        BHI     ReduceAngle_1
        CMP     r0, r3, lsl #2
        SUBHS   r0, r0, r3, lsl #2
        ADC     r2, r2, r2
        CMP     r0, r3, lsl #1
        SUBHS   r0, r0, r3, lsl #1
        ADC     r2, r2, r2
        CMP     r0, r3
        SUBHS   r0, r0, r3, lsl #1
        ADDHS   r2, r2, #1
        TEQ     r1, #0
        RSBMI   r0, r0, #0
        RSBMI   r2, r2, #0
        MOV     pc, lr

Divide16
        TEQ     r1, #0
        MOVEQ   pc, lr
        STMFD   sp!, {r0, r2-r4, lr}
        MOV     r2, r1
        MOVS    r3, r2
        RSBMI   r2, r2, #0
        MOV     r4, #&E
        CMP     r0, r2
        BHS     Divide16_1
        CMP     r0, r2, lsr #16
        MOVLS   r0, r0, LSL #&10
        SUBLS   r4, r4, #&10
        CMP     r0, r2, lsr #8
        MOVLS   r0, r0, LSL #8
        SUBLS   r4, r4, #8
        CMP     r0, r2, lsr #4
        MOVLS   r0, r0, LSL #4
        SUBLS   r4, r4, #4
        CMP     r0, r2, lsr #2
        MOVLS   r0, r0, LSL #2
        SUBLS   r4, r4, #2
        CMP     r0, r2, lsr #1
        MOVLS   r0, r0, LSL #1
        SUBLS   r4, r4, #1
Divide16_1
        MOV     lr, #0
        RSBS    r2, r0, r2
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        ADDS    r4, r4, r4, lsl #1
        ADDPL   pc, pc, r4, lsl #2
        B       Divide16_2
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADDLO   r2, r2, r0
        ADC     lr, lr, lr
        RSBS    r2, r0, r2, lsl #1
        ADC     r1, lr, #0
        TEQ     r3, #0
        RSBMI   r1, r1, #0
        LDMFD   sp!, {r0, r2-r4, pc}
Divide16_2
        TEQ     r3, #0
        MVNPL   r1, #&80000000
        MOVMI   r1, #&80000000
        LDMFD   sp!, {r0, r2-r4, pc}

Antialias
        MOV     r0, ip
        LDR     sl, [ip, #&20]
        ADD     pc, pc, sl, lsl #2
        DCD     &F1A00000
        DCD     &F1A00000
        DCD     &EA000003
        DCD     &EA000007
        DCD     &EA00002F
        DCD     &EA000038
        DCD     &EA00003A
        DCD     &E28F10F0
        DCD     &E13F000F
        DCD     &13DEF201
        DCD     &E328F000
        DCD     &E1A0F00E
        DCD     &E59C1060
        DCD     &E3310000
        DCD     &E28F1038
        DCD     &E2811C02
        DCD     &0A000003
        DCD     &E13F000F
        DCD     &13DEF201
        DCD     &E328F000
        DCD     &E1A0F00E
        DCD     &E92D41FF
        DCD     &E3A00006
        DCD     &E3A03A01
        DCD     &EF02001E
        DCD     &7A000004
        DCD     &E13F000F
        DCD     &18BD41FF
        DCD     &139EF201
        DCD     &E328F201
        DCD     &E8BD81FF
        DCD     &E58C2060
        DCD     &E1A00002
        DCD     &E1A01003
        DCD     &E3E02000
        DCD     &E3E03000
        DCD     &E3E04000
        DCD     &E3E05000
        DCD     &E3E06000
        DCD     &E3E07000
        DCD     &E3E08000
        DCD     &E3E0E000
        DCD     &E8A041FC
        DCD     &E8A041FC
        DCD     &E8A041FC
        DCD     &E8A041FC
        DCD     &E2511080
        DCD     &1AFFFFF9
        DCD     &E13F000F
        DCD     &18BD41FF
        DCD     &13DEF201
        DCD     &E328F000
        DCD     &E8BD81FF
        DCD     &E59C1064
        DCD     &E28FA00C
        DCD     &E7BA1101
        DCD     &E081100A
        DCD     &E328F000
        DCD     &E1A0F00E
        DCD     &00000324
        DCD     &0000049C
        DCD     &00000564
        DCD     &00000B94
        DCD     &E28F10AC
        DCD     &E2811B03
        DCD     &E1A0F00E
        DCD     &E28F10D4
        DCD     &E2811C0D
        DCD     &E1A0F00E

Blend2bpp
        MOV     r0, #&FF
        MOV     sb, #3
        MOV     ip, #&10
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
Blend2bpp_1
        LDR     r5, [r1], #4
        TEQ     r5, #0
        BEQ     Blend2bpp_9
Blend2bpp_2
        TEQ     r5, ip
        BEQ     Blend2bpp_11
Blend2bpp_3
        LDRB    r6, [r2], #1
        LDRB    r7, [r3]
        AND     fp, sb, r7
        ANDS    lr, r0, r5
        MOVEQ   r8, fp
        BEQ     Blend2bpp_4
        AND     sl, sb, r6
        TEQ     lr, #&10
        MOVEQ   r8, sl
        BEQ     Blend2bpp_4
        MUL     sl, lr, sl
        RSB     lr, lr, #&10
        MLA     sl, lr, fp, sl
        MOVS    sl, sl, LSR #4
        ADC     r8, sl, #0
Blend2bpp_4
        AND     fp, sb, r7, lsr #2
        ANDS    lr, r0, r5, lsr #8
        ORREQ   r8, r8, fp, lsl #2
        BEQ     Blend2bpp_5
        AND     sl, sb, r6, lsr #2
        TEQ     lr, #&10
        ORREQ   r8, r8, sl, lsl #2
        BEQ     Blend2bpp_5
        MUL     sl, lr, sl
        RSB     lr, lr, #&10
        MLA     sl, lr, fp, sl
        MOVS    sl, sl, LSR #4
        ADC     sl, sl, #0
        ORR     r8, r8, sl, lsl #2
Blend2bpp_5
        AND     fp, sb, r7, lsr #4
        ANDS    lr, r0, r5, lsr #16
        ORREQ   r8, r8, fp, lsl #4
        BEQ     Blend2bpp_6
        AND     sl, sb, r6, lsr #4
        TEQ     lr, #&10
        ORREQ   r8, r8, sl, lsl #4
        BEQ     Blend2bpp_6
        MUL     sl, lr, sl
        RSB     lr, lr, #&10
        MLA     sl, lr, fp, sl
        MOVS    sl, sl, LSR #4
        ADC     sl, sl, #0
        ORR     r8, r8, sl, lsl #4
Blend2bpp_6
        AND     fp, sb, r7, lsr #6
        ANDS    lr, r0, r5, lsr #24
        ORREQ   r8, r8, fp, lsl #6
        BEQ     Blend2bpp_7
        AND     sl, sb, r6, lsr #6
        TEQ     lr, #&10
        ORREQ   r8, r8, sl, lsl #6
        BEQ     Blend2bpp_7
        MUL     sl, lr, sl
        RSB     lr, lr, #&10
        MLA     sl, lr, fp, sl
        MOVS    sl, sl, LSR #4
        ADC     sl, sl, #0
        ORR     r8, r8, sl, lsl #6
Blend2bpp_7
        STRB    r8, [r3], #1
        SUBS    r4, r4, #4
        BNE     Blend2bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend2bpp_8
        LDR     r5, [r1], #4
        TEQ     r5, #0
        BNE     Blend2bpp_2
Blend2bpp_9
        ADD     r2, r2, #1
        ADD     r3, r3, #1
        SUBS    r4, r4, #4
        BNE     Blend2bpp_8
        LDMFD   sp!, {r0-ip, pc}
Blend2bpp_10
        LDR     r5, [r1], #4
        TEQ     r5, #0
        BEQ     Blend2bpp_9
        TEQ     r5, ip
        BNE     Blend2bpp_3
Blend2bpp_11
        LDRB    r6, [r2], #1
        STRB    r6, [r3], #1
        SUBS    r4, r4, #4
        BNE     Blend2bpp_10
        LDMFD   sp!, {r0-ip, pc}

Blend4bpp
        MOV     r0, #&10
        ORR     r0, r0, r0, lsl #8
        ORR     r0, r0, r0, lsl #16
        LDR     sb, [ip, #&60]
Blend4bpp_1
        TST     r1, #3
        BNE     Blend4bpp_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend4bpp_8
Blend4bpp_2
        TEQ     r5, r0
        BEQ     Blend4bpp_10
Blend4bpp_3
        LDRB    r5, [r1], #1
        LDRB    r6, [r2], #1
        LDRB    r7, [r3]
        TEQ     r5, #0
        ANDEQ   r8, r7, #&F
        BEQ     Blend4bpp_4
        TEQ     r5, #&10
        ANDEQ   r8, r6, #&F
        BEQ     Blend4bpp_4
        AND     sl, r6, #&F
        AND     fp, r7, #&F
        ORR     r5, r5, sl, lsl #4
        ORR     r5, r5, fp, lsl #8
        LDRB    fp, [sb, r5]
        TEQ     fp, #&FF
        BLEQ    FillBlend4Table
        MOV     r8, fp
Blend4bpp_4
        LDRB    r5, [r1], #1
        MOV     fp, r7, LSR #4
        TEQ     r5, #0
        BEQ     Blend4bpp_5
        MOV     sl, r6, LSR #4
        TEQ     r5, #&10
        ORREQ   r8, r8, sl, lsl #4
        BEQ     Blend4bpp_6
        ORR     r5, r5, sl, lsl #4
        ORR     r5, r5, fp, lsl #8
        LDRB    fp, [sb, r5]
        TEQ     fp, #&FF
        BLEQ    FillBlend4Table
Blend4bpp_5
        ORR     r8, r8, fp, lsl #4
Blend4bpp_6
        STRB    r8, [r3], #1
        SUBS    r4, r4, #2
        BNE     Blend4bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend4bpp_7
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     Blend4bpp_2
Blend4bpp_8
        ADD     r1, r1, #4
        ADD     r2, r2, #2
        ADD     r3, r3, #2
        SUBS    r4, r4, #4
        BNE     Blend4bpp_7
        LDMFD   sp!, {r0-ip, pc}
Blend4bpp_9
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend4bpp_8
        TEQ     r5, r0
        BNE     Blend4bpp_3
Blend4bpp_10
        ADD     r1, r1, #4
        LDR     r6, [r2], #2
        STRB    r6, [r3], #1
        MOV     r6, r6, LSR #8
        STRB    r6, [r3], #1
        SUBS    r4, r4, #4
        BNE     Blend4bpp_9
        LDMFD   sp!, {r0-ip, pc}

FillBlend4Table
        STMFD   sp!, {r0-sl, lr}
        ADD     r0, ip, #&84
        ADD     r1, r0, #&40
        MOV     lr, #&F
        AND     r6, lr, r5, lsr #4
        AND     r7, lr, r5, lsr #8
        AND     r8, lr, r5
        RSB     sb, r8, #&10
        LDR     r6, [r0, r6, lsl #2]
        LDR     r7, [r0, r7, lsl #2]
        MOV     lr, #&FF
        AND     sl, lr, r6, lsr #8
        AND     fp, lr, r7, lsr #8
        MUL     sl, r8, sl
        MLA     sl, sb, fp, sl
        MOVS    r4, sl, LSR #4
        ADDHS   r4, r4, #1
        AND     sl, lr, r6, lsr #16
        AND     fp, lr, r7, lsr #16
        MUL     sl, r8, sl
        MLA     sl, sb, fp, sl
        MOVS    r5, sl, LSR #4
        ADDHS   r5, r5, #1
        AND     sl, lr, r6, lsr #24
        AND     fp, lr, r7, lsr #24
        MUL     sl, r8, sl
        MLA     sl, sb, fp, sl
        MOVS    r6, sl, LSR #4
        ADDHS   r6, r6, #1
        BL      SearchPaletteFull
        MOV     fp, r2
        LDMFD   sp!, {r0-sl, lr}
        STRB    fp, [sb, r5]
        MOV     pc, lr

BlendDefault8
        LDR     r0, [ip, #&80]
        ADD     lr, ip, #&84
        MOV     ip, #&10
        ORR     ip, ip, ip, lsl #8
        ORR     ip, ip, ip, lsl #16
        MOV     sl, ip, LSL #6
        ORR     fp, sl, sl, lsl #1
        ORR     sb, fp, fp, lsr #2
BlendDefault8_1
        TST     r1, #3
        BNE     BlendDefault8_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendDefault8_8
BlendDefault8_2
        TEQ     r5, ip
        BEQ     BlendDefault8_10
BlendDefault8_3
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     BlendDefault8_6
        LDRB    r6, [r2], #1
        TEQ     r5, #&10
        BEQ     BlendDefault8_5
        LDRB    r7, [r3]
        LDR     r6, [lr, r6, lsl #2]
        LDR     r7, [lr, r7, lsl #2]
        AND     r6, sb, r6, lsr #4
        AND     r7, sb, r7, lsr #4
        MUL     r6, r5, r6
        RSB     r5, r5, #&10
        MLA     r5, r7, r5, r6
        AND     r6, fp, r5, lsr #4
        AND     r7, r5, #&3800
        AND     r8, r5, #&3C0000
        ORR     r7, r7, r8, lsr #11
        AND     r8, r5, #&38000000
        ORR     r7, r7, r8, lsr #23
        LDR     r5, [r0, r7, lsr #2]
        AND     r7, fp, r5
        BIC     r8, r7, sl
        ORR     r7, r7, r8, lsl #1
        ADD     r7, r7, r6
        TST     r7, sl, lsl #2
        BEQ     BlendDefault8_4
        MOV     r5, r5, LSR #2
        AND     r7, fp, r5
        BIC     r8, r7, sl
        ORR     r7, r7, r8, lsl #1
        ADD     r7, r7, r6
        TST     r7, sl, lsl #2
        BEQ     BlendDefault8_4
        MOV     r5, r5, LSR #2
        AND     r7, fp, r5
        BIC     r8, r7, sl
        ORR     r7, r7, r8, lsl #1
        ADD     r7, r7, r6
        TST     r7, sl, lsl #2
        MOVNE   r5, r5, LSR #2
        MOVNE   r7, r6
BlendDefault8_4
        AND     r6, r5, #3
        MOVS    r8, r7, LSL #&15
        ORRHS   r6, r6, #&10
        ORRMI   r6, r6, #4
        AND     r8, r7, #&C0000
        ORR     r6, r6, r8, lsr #13
        MOVS    r8, r7, LSL #5
        ORRHS   r6, r6, #&80
        ORRMI   r6, r6, #8
BlendDefault8_5
        STRB    r6, [r3], #1
        SUBS    r4, r4, #1
        BPL     BlendDefault8_1
        LDMFD   sp!, {r0-ip, pc}
BlendDefault8_6
        ADD     r2, r2, #1
        ADD     r3, r3, #1
        SUBS    r4, r4, #1
        BPL     BlendDefault8_1
        LDMFD   sp!, {r0-ip, pc}
BlendDefault8_7
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     BlendDefault8_2
BlendDefault8_8
        ADD     r1, r1, #4
        ADD     r2, r2, #4
        ADD     r3, r3, #4
        SUBS    r4, r4, #4
        BPL     BlendDefault8_7
        LDMFD   sp!, {r0-ip, pc}
BlendDefault8_9
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendDefault8_8
        TEQ     r5, ip
        BNE     BlendDefault8_3
BlendDefault8_10
        ADD     r1, r1, #4
        LDR     r6, [r2], #4
        STR     r6, [r3], #4
        SUBS    r4, r4, #4
        BPL     BlendDefault8_9
        LDMFD   sp!, {r0-ip, pc}

BlendGrey8
        MOV     r8, #&10
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
BlendGrey8_1
        TST     r1, #3
        BNE     BlendGrey8_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendGrey8_7
BlendGrey8_2
        TEQ     r5, r8
        BEQ     BlendGrey8_9
BlendGrey8_3
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     BlendGrey8_5
        LDRB    r6, [r2], #1
        TEQ     r5, #&10
        BEQ     BlendGrey8_4
        LDRB    r7, [r3]
        MUL     r6, r5, r6
        RSB     r5, r5, #&10
        MLA     r6, r5, r7, r6
        MOVS    r6, r6, LSR #4
        ADDHS   r6, r6, #1
BlendGrey8_4
        STRB    r6, [r3], #1
        SUBS    r4, r4, #1
        BPL     BlendGrey8_1
        LDMFD   sp!, {r0-ip, pc}
BlendGrey8_5
        ADD     r2, r2, #1
        ADD     r3, r3, #1
        SUBS    r4, r4, #1
        BPL     BlendGrey8_1
        LDMFD   sp!, {r0-ip, pc}
BlendGrey8_6
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     BlendGrey8_2
BlendGrey8_7
        ADD     r1, r1, #4
        ADD     r2, r2, #4
        ADD     r3, r3, #4
        SUBS    r4, r4, #4
        BPL     BlendGrey8_6
        LDMFD   sp!, {r0-ip, pc}
BlendGrey8_8
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendGrey8_7
        TEQ     r5, r8
        BNE     BlendGrey8_3
BlendGrey8_9
        ADD     r1, r1, #4
        LDR     r6, [r2], #4
        STR     r6, [r3], #4
        SUBS    r4, r4, #4
        BPL     BlendGrey8_8
        LDMFD   sp!, {r0-ip, pc}

BlendCube8
        MOV     r0, #&FF
        MOV     r8, #&10
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        LDR     sb, [pc, #4]
        ADD     sb, pc, sb
        B       BlendCube8_1
        DCD     &FFFFE804
BlendCube8_1
        ADR     lr, CubeBlendTable
BlendCube8_2
        TST     r1, #3
        BNE     BlendCube8_4
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendCube8_9
BlendCube8_3
        TEQ     r5, r8
        BEQ     BlendCube8_11
BlendCube8_4
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     BlendCube8_7
        LDRB    r6, [r2], #1
        TEQ     r5, #&10
        BEQ     BlendCube8_6
        LDRB    r7, [r3]
        STMFD   sp!, {r1-r4}
        LDR     r6, [lr, r6, lsl #2]
        LDR     r7, [lr, r7, lsl #2]
        RSB     r4, r5, #&10
        AND     sl, r0, r6, lsr #8
        MUL     r1, r5, sl
        AND     sl, r0, r7, lsr #8
        MLA     r1, r4, sl, r1
        AND     sl, r0, r6, lsr #16
        MUL     r2, r5, sl
        AND     sl, r0, r7, lsr #16
        MLA     r2, r4, sl, r2
        AND     sl, r0, r6, lsr #24
        MUL     r3, r5, sl
        AND     sl, r0, r7, lsr #24
        MLA     r3, r4, sl, r3
        ADD     r1, r1, r1, lsl #8
        ADD     r2, r2, r2, lsl #8
        ADD     r3, r3, r3, lsl #8
        ADD     r1, r1, r1, lsl #2
        ADD     r2, r2, r2, lsl #2
        ADD     r3, r3, r3, lsl #2
        MOVS    sl, r1, LSR #&14
        ADDHS   sl, sl, #1
        MOVS    fp, r2, LSR #&14
        ADDHS   fp, fp, #1
        MOVS    ip, r3, LSR #&14
        ADDHS   ip, ip, #1
        ADD     r6, sl, fp, lsl #1
        ADD     r6, r6, fp, lsl #2
        ADD     r6, r6, ip, lsl #2
        ADD     r6, r6, ip, lsl #5
        LDRB    r4, [sb, r6]
        TEQ     r4, #0
        LDMFDEQ sp!, {r1-r4}
        BEQ     BlendCube8_6
        MOVS    sl, r1, LSR #8
        ADDHS   sl, sl, #1
        MOVS    fp, r2, LSR #8
        ADDHS   fp, fp, #1
        MOVS    ip, r3, LSR #8
        ADDHS   ip, ip, #1
        MUL     r4, sl, sl
        MLA     r4, fp, fp, r4
        MLA     r4, ip, ip, r4
        ADD     r4, r4, r4, lsl #1
        ADD     sl, sl, fp
        ADD     sl, sl, ip
        MUL     fp, sl, sl
        SUB     r4, r4, fp
        CMP     r4, #&2400000
        LDMFDHS sp!, {r1-r4}
        BHS     BlendCube8_6
        CMP     r4, #&800000
        BLS     BlendCube8_5
        MOV     sl, r1, LSL #&C
        MOVS    sl, sl, ASR #&14
        ADDHSS  sl, sl, #1
        RSBMI   sl, sl, #0
        MOV     fp, r2, LSL #&C
        MOVS    fp, fp, ASR #&14
        ADDHSS  fp, fp, #1
        RSBMI   fp, fp, #0
        MOV     ip, r3, LSL #&C
        MOVS    ip, ip, ASR #&14
        ADDHSS  ip, ip, #1
        RSBMI   ip, ip, #0
        MUL     r5, sl, sl
        MLA     r5, fp, fp, r5
        MLA     r5, ip, ip, r5
        ADD     r5, r5, r5, lsl #1
        CMP     r4, r5
        LDMFDHS sp!, {r1-r4}
        BHS     BlendCube8_6
BlendCube8_5
        MOV     r1, r1, LSR #4
        MOV     r2, r2, LSR #4
        MOV     r3, r3, LSR #4
        MOV     r4, #&4D
        MUL     r6, r4, r1
        MOV     r4, #&97
        MLA     r6, r4, r2, r6
        MOV     r4, #&1C
        MLA     r6, r4, r3, r6
        ADD     r6, r6, r6, lsl #3
        MOVS    r6, r6, LSR #&18
        ADDHS   r6, r6, #1
        ADD     r5, sb, #&D8
        LDRB    r6, [r5, r6]
        LDMFD   sp!, {r1-r4}
BlendCube8_6
        STRB    r6, [r3], #1
        SUBS    r4, r4, #1
        BPL     BlendCube8_2
        LDMFD   sp!, {r0-ip, pc}
BlendCube8_7
        ADD     r2, r2, #1
        ADD     r3, r3, #1
        SUBS    r4, r4, #1
        BPL     BlendCube8_2
        LDMFD   sp!, {r0-ip, pc}
BlendCube8_8
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     BlendCube8_3
BlendCube8_9
        ADD     r1, r1, #4
        ADD     r2, r2, #4
        ADD     r3, r3, #4
        SUBS    r4, r4, #4
        BPL     BlendCube8_8
        LDMFD   sp!, {r0-ip, pc}
BlendCube8_10
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendCube8_9
        TEQ     r5, r8
        BNE     BlendCube8_4
BlendCube8_11
        ADD     r1, r1, #4
        LDR     r6, [r2], #4
        STR     r6, [r3], #4
        SUBS    r4, r4, #4
        BPL     BlendCube8_10
        LDMFD   sp!, {r0-ip, pc}

CubeBlendTable
        DCD     &00000000
        DCD     &00003300
        DCD     &00006600
        DCD     &00009900
        DCD     &0000CC00
        DCD     &0000FF00
        DCD     &00330000
        DCD     &00333300
        DCD     &00336600
        DCD     &00339900
        DCD     &0033CC00
        DCD     &0033FF00
        DCD     &00660000
        DCD     &00663300
        DCD     &00666600
        DCD     &00669900
        DCD     &0066CC00
        DCD     &0066FF00
        DCD     &00990000
        DCD     &00993300
        DCD     &00996600
        DCD     &00999900
        DCD     &0099CC00
        DCD     &0099FF00
        DCD     &00CC0000
        DCD     &00CC3300
        DCD     &00CC6600
        DCD     &00CC9900
        DCD     &00CCCC00
        DCD     &00CCFF00
        DCD     &00FF0000
        DCD     &00FF3300
        DCD     &00FF6600
        DCD     &00FF9900
        DCD     &00FFCC00
        DCD     &00FFFF00
        DCD     &33000000
        DCD     &33003300
        DCD     &33006600
        DCD     &33009900
        DCD     &3300CC00
        DCD     &3300FF00
        DCD     &33330000
        DCD     &33333300
        DCD     &33336600
        DCD     &33339900
        DCD     &3333CC00
        DCD     &3333FF00
        DCD     &33660000
        DCD     &33663300
        DCD     &33666600
        DCD     &33669900
        DCD     &3366CC00
        DCD     &3366FF00
        DCD     &33990000
        DCD     &33993300
        DCD     &33996600
        DCD     &33999900
        DCD     &3399CC00
        DCD     &3399FF00
        DCD     &33CC0000
        DCD     &33CC3300
        DCD     &33CC6600
        DCD     &33CC9900
        DCD     &33CCCC00
        DCD     &33CCFF00
        DCD     &33FF0000
        DCD     &33FF3300
        DCD     &33FF6600
        DCD     &33FF9900
        DCD     &33FFCC00
        DCD     &33FFFF00
        DCD     &66000000
        DCD     &66003300
        DCD     &66006600
        DCD     &66009900
        DCD     &6600CC00
        DCD     &6600FF00
        DCD     &66330000
        DCD     &66333300
        DCD     &66336600
        DCD     &66339900
        DCD     &6633CC00
        DCD     &6633FF00
        DCD     &66660000
        DCD     &66663300
        DCD     &66666600
        DCD     &66669900
        DCD     &6666CC00
        DCD     &6666FF00
        DCD     &66990000
        DCD     &66993300
        DCD     &66996600
        DCD     &66999900
        DCD     &6699CC00
        DCD     &6699FF00
        DCD     &66CC0000
        DCD     &66CC3300
        DCD     &66CC6600
        DCD     &66CC9900
        DCD     &66CCCC00
        DCD     &66CCFF00
        DCD     &66FF0000
        DCD     &66FF3300
        DCD     &66FF6600
        DCD     &66FF9900
        DCD     &66FFCC00
        DCD     &66FFFF00
        DCD     &99000000
        DCD     &99003300
        DCD     &99006600
        DCD     &99009900
        DCD     &9900CC00
        DCD     &9900FF00
        DCD     &99330000
        DCD     &99333300
        DCD     &99336600
        DCD     &99339900
        DCD     &9933CC00
        DCD     &9933FF00
        DCD     &99660000
        DCD     &99663300
        DCD     &99666600
        DCD     &99669900
        DCD     &9966CC00
        DCD     &9966FF00
        DCD     &99990000
        DCD     &99993300
        DCD     &99996600
        DCD     &99999900
        DCD     &9999CC00
        DCD     &9999FF00
        DCD     &99CC0000
        DCD     &99CC3300
        DCD     &99CC6600
        DCD     &99CC9900
        DCD     &99CCCC00
        DCD     &99CCFF00
        DCD     &99FF0000
        DCD     &99FF3300
        DCD     &99FF6600
        DCD     &99FF9900
        DCD     &99FFCC00
        DCD     &99FFFF00
        DCD     &CC000000
        DCD     &CC003300
        DCD     &CC006600
        DCD     &CC009900
        DCD     &CC00CC00
        DCD     &CC00FF00
        DCD     &CC330000
        DCD     &CC333300
        DCD     &CC336600
        DCD     &CC339900
        DCD     &CC33CC00
        DCD     &CC33FF00
        DCD     &CC660000
        DCD     &CC663300
        DCD     &CC666600
        DCD     &CC669900
        DCD     &CC66CC00
        DCD     &CC66FF00
        DCD     &CC990000
        DCD     &CC993300
        DCD     &CC996600
        DCD     &CC999900
        DCD     &CC99CC00
        DCD     &CC99FF00
        DCD     &CCCC0000
        DCD     &CCCC3300
        DCD     &CCCC6600
        DCD     &CCCC9900
        DCD     &CCCCCC00
        DCD     &CCCCFF00
        DCD     &CCFF0000
        DCD     &CCFF3300
        DCD     &CCFF6600
        DCD     &CCFF9900
        DCD     &CCFFCC00
        DCD     &CCFFFF00
        DCD     &FF000000
        DCD     &FF003300
        DCD     &FF006600
        DCD     &FF009900
        DCD     &FF00CC00
        DCD     &FF00FF00
        DCD     &FF330000
        DCD     &FF333300
        DCD     &FF336600
        DCD     &FF339900
        DCD     &FF33CC00
        DCD     &FF33FF00
        DCD     &FF660000
        DCD     &FF663300
        DCD     &FF666600
        DCD     &FF669900
        DCD     &FF66CC00
        DCD     &FF66FF00
        DCD     &FF990000
        DCD     &FF993300
        DCD     &FF996600
        DCD     &FF999900
        DCD     &FF99CC00
        DCD     &FF99FF00
        DCD     &FFCC0000
        DCD     &FFCC3300
        DCD     &FFCC6600
        DCD     &FFCC9900
        DCD     &FFCCCC00
        DCD     &FFCCFF00
        DCD     &FFFF0000
        DCD     &FFFF3300
        DCD     &FFFF6600
        DCD     &FFFF9900
        DCD     &FFFFCC00
        DCD     &FFFFFF00
        DCD     &06060600
        DCD     &0B0B0B00
        DCD     &11111100
        DCD     &17171700
        DCD     &1C1C1C00
        DCD     &22222200
        DCD     &28282800
        DCD     &2D2D2D00
        DCD     &39393900
        DCD     &3E3E3E00
        DCD     &44444400
        DCD     &4A4A4A00
        DCD     &4F4F4F00
        DCD     &55555500
        DCD     &5B5B5B00
        DCD     &60606000
        DCD     &6C6C6C00
        DCD     &71717100
        DCD     &77777700
        DCD     &7D7D7D00
        DCD     &82828200
        DCD     &88888800
        DCD     &8E8E8E00
        DCD     &93939300
        DCD     &9F9F9F00
        DCD     &A4A4A400
        DCD     &AAAAAA00
        DCD     &B0B0B000
        DCD     &B5B5B500
        DCD     &BBBBBB00
        DCD     &C1C1C100
        DCD     &C6C6C600
        DCD     &D2D2D200
        DCD     &D7D7D700
        DCD     &DDDDDD00
        DCD     &E3E3E300
        DCD     &E8E8E800
        DCD     &EEEEEE00
        DCD     &F4F4F400
        DCD     &F9F9F900

BlendCustom8
        ADD     r0, ip, #&84
        MOV     r8, #&10
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
        MOV     lr, #&FF
BlendCustom8_1
        TST     r1, #3
        BNE     BlendCustom8_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendCustom8_7
BlendCustom8_2
        TEQ     r5, r8
        BEQ     BlendCustom8_9
BlendCustom8_3
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     BlendCustom8_5
        LDRB    r6, [r2], #1
        TEQ     r5, #&10
        BEQ     BlendCustom8_4
        LDRB    r7, [r3]
        LDR     r6, [r0, r6, lsl #2]
        LDR     r7, [r0, r7, lsl #2]
        STMFD   sp!, {r0-r3, r8, lr}
        RSB     sb, r5, #&10
        AND     sl, lr, r6, lsr #8
        AND     fp, lr, r7, lsr #8
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOV     sl, sl, LSR #4
        MOV     r2, sl, LSL #8
        AND     sl, lr, r6, lsr #16
        AND     fp, lr, r7, lsr #16
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOV     sl, sl, LSR #4
        ORR     r2, r2, sl, lsl #16
        AND     sl, lr, r6, lsr #24
        AND     fp, lr, r7, lsr #24
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOV     sl, sl, LSR #4
        ORR     r2, r2, sl, lsl #24
        BL      NearestCustom
        MOV     r6, r2
        LDMFD   sp!, {r0-r3, r8, lr}
BlendCustom8_4
        STRB    r6, [r3], #1
        SUBS    r4, r4, #1
        BPL     BlendCustom8_1
        LDMFD   sp!, {r0-ip, pc}
BlendCustom8_5
        ADD     r2, r2, #1
        ADD     r3, r3, #1
        SUBS    r4, r4, #1
        BPL     BlendCustom8_1
        LDMFD   sp!, {r0-ip, pc}
BlendCustom8_6
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     BlendCustom8_2
BlendCustom8_7
        ADD     r1, r1, #4
        ADD     r2, r2, #4
        ADD     r3, r3, #4
        SUBS    r4, r4, #4
        BPL     BlendCustom8_6
        LDMFD   sp!, {r0-ip, pc}
BlendCustom8_8
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     BlendCustom8_7
        TEQ     r5, r8
        BNE     BlendCustom8_3
BlendCustom8_9
        ADD     r1, r1, #4
        LDR     r6, [r2], #4
        STR     r6, [r3], #4
        SUBS    r4, r4, #4
        BPL     BlendCustom8_8
        LDMFD   sp!, {r0-ip, pc}

Blend16bpp
        MOV     r0, #&1F
        MOV     r8, #&10
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
Blend16bpp_1
        TST     r1, #3
        BNE     Blend16bpp_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend16bpp_7
Blend16bpp_2
        TEQ     r5, r8
        BEQ     Blend16bpp_9
Blend16bpp_3
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     Blend16bpp_5
        LDR     r6, [r2], #2
        TEQ     r5, #&10
        LDR     r7, [r3]
        BEQ     Blend16bpp_4
        RSB     sb, r5, #&10
        AND     sl, r0, r6
        AND     fp, r0, r7
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    ip, sl, LSR #4
        ADDHS   ip, ip, #1
        AND     sl, r0, r6, lsr #5
        AND     fp, r0, r7, lsr #5
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    sl, sl, LSR #4
        ADDHS   sl, sl, #1
        ORR     ip, ip, sl, lsl #5
        AND     sl, r0, r6, lsr #10
        AND     fp, r0, r7, lsr #10
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    sl, sl, LSR #4
        ADDHS   sl, sl, #1
        ORR     r6, ip, sl, lsl #10
Blend16bpp_4
        TST     r3, #3
        MOVNE   r6, r6, LSL #&10
        ORRNE   r6, r6, r7, lsr #16
        MOVEQ   r6, r6, LSL #&10
        MOVEQ   r7, r7, LSR #&10
        MOVEQ   r6, r6, LSR #&10
        ORREQ   r6, r6, r7, lsl #16
        BIC     r7, r3, #3
        STR     r6, [r7]
        ADD     r3, r3, #2
        SUBS    r4, r4, #1
        BPL     Blend16bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend16bpp_5
        ADD     r2, r2, #2
        ADD     r3, r3, #2
        SUBS    r4, r4, #1
        BPL     Blend16bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend16bpp_6
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     Blend16bpp_2
Blend16bpp_7
        ADD     r1, r1, #4
        ADD     r2, r2, #8
        ADD     r3, r3, #8
        SUBS    r4, r4, #4
        BPL     Blend16bpp_6
        LDMFD   sp!, {r0-ip, pc}
Blend16bpp_8
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend16bpp_7
        TEQ     r5, r8
        BNE     Blend16bpp_3
Blend16bpp_9
        ADD     r1, r1, #4
        LDMIA   r2!, {r6, r7}
        STMIA   r3!, {r6, r7}
        SUBS    r4, r4, #4
        BPL     Blend16bpp_8
        LDMFD   sp!, {r0-ip, pc}

Blend32bpp
        MOV     r0, #&FF
        MOV     r8, #&10
        ORR     r8, r8, r8, lsl #8
        ORR     r8, r8, r8, lsl #16
Blend32bpp_1
        TST     r1, #3
        BNE     Blend32bpp_3
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend32bpp_7
Blend32bpp_2
        TEQ     r5, r8
        BEQ     Blend32bpp_9
Blend32bpp_3
        LDRB    r5, [r1], #1
        TEQ     r5, #0
        BEQ     Blend32bpp_5
        LDR     r6, [r2], #4
        TEQ     r5, #&10
        BEQ     Blend32bpp_4
        LDR     r7, [r3]
        RSB     sb, r5, #&10
        AND     sl, r0, r6
        AND     fp, r0, r7
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    ip, sl, LSR #4
        ADDHS   ip, ip, #1
        AND     sl, r0, r6, lsr #8
        AND     fp, r0, r7, lsr #8
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    sl, sl, LSR #4
        ADDHS   sl, sl, #1
        ORR     ip, ip, sl, lsl #8
        AND     sl, r0, r6, lsr #16
        AND     fp, r0, r7, lsr #16
        MUL     sl, r5, sl
        MLA     sl, sb, fp, sl
        MOVS    sl, sl, LSR #4
        ADDHS   sl, sl, #1
        ORR     r6, ip, sl, lsl #16
Blend32bpp_4
        STR     r6, [r3], #4
        SUBS    r4, r4, #1
        BPL     Blend32bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend32bpp_5
        ADD     r2, r2, #4
        ADD     r3, r3, #4
        SUBS    r4, r4, #1
        BPL     Blend32bpp_1
        LDMFD   sp!, {r0-ip, pc}
Blend32bpp_6
        LDR     r5, [r1]
        TEQ     r5, #0
        BNE     Blend32bpp_2
Blend32bpp_7
        ADD     r1, r1, #4
        ADD     r2, r2, #&10
        ADD     r3, r3, #&10
        SUBS    r4, r4, #4
        BPL     Blend32bpp_6
        LDMFD   sp!, {r0-ip, pc}
Blend32bpp_8
        LDR     r5, [r1]
        TEQ     r5, #0
        BEQ     Blend32bpp_7
        TEQ     r5, r8
        BNE     Blend32bpp_3
Blend32bpp_9
        ADD     r1, r1, #4
        LDMIA   r2!, {r6, r7, sl, fp}
        STMIA   r3!, {r6, r7, sl, fp}
        SUBS    r4, r4, #4
        BPL     Blend32bpp_8
        LDMFD   sp!, {r0-ip, pc}

        END
