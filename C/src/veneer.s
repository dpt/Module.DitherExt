@ Entry veneers for the antialias blenders. The caller of an original blender
@ has pushed R0-IP and PC and expects the blender to return with
@ LDMFD sp!, {r0-ip, pc}. It passes IP = workspace, R1 = mask, R2 = source,
@ R3 = destination and R4 = count. Each veneer moves R1-R4 to R0-R3 for the
@ C function. The ones that need the workspace pass IP as a fifth argument.

        .text
        .align  2

        .macro  veneer name, cfn
        .global \name
\name:
        mov     r0, r1
        mov     r1, r2
        mov     r2, r3
        mov     r3, r4
        bl      \cfn
        ldmfd   sp!, {r0-ip, pc}
        .endm

        .macro  veneer_ws name, cfn
        .global \name
\name:
        sub     sp, sp, #8
        str     ip, [sp]
        mov     r0, r1
        mov     r1, r2
        mov     r2, r3
        mov     r3, r4
        bl      \cfn
        add     sp, sp, #8
        ldmfd   sp!, {r0-ip, pc}
        .endm

        veneer      veneer_blend_2bpp, blend_2bpp
        veneer_ws   veneer_blend_4bpp, blend_4bpp
        veneer      veneer_blend_grey8, blend_grey8
        veneer_ws   veneer_blend_default8, blend_default8
        veneer_ws   veneer_blend_cube8, blend_cube8
        veneer_ws   veneer_blend_custom8, blend_custom8
        veneer      veneer_blend_16bpp, blend_16bpp
        veneer      veneer_blend_32bpp, blend_32bpp
