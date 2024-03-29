        .cpu cortex-m4
        .fpu softvfp
        .syntax unified
        .thumb

        .text
        .section  .text, "ax", %progbits
        .globl handle_reset
        .type  handle_reset, %function
handle_reset:
        ldr sp, =stack_end

        /* copy .data into ram */
        ldr r1, =data_vma_start
        ldr r2, =data_lma_start
        ldr r3, =data_vma_end
0:
        cmp r1, r3
        bhs 1f
        ldr r0, [r2], #4
        str r0, [r1], #4
        b 0b
1:
        /* zero out .bss */
        mov r0, #0
        ldr r1, =bss_start
        ldr r2, =bss_end
2:
        cmp r1, r2
        bhs 3f
        str r0, [r1], #4
        b 2b
3:
        /* enable the fpu */
        ldr r0, =0xe000ed88
        ldr r1, [r0]
        orr r1, #(0xf << 20)
        str r1, [r0]
        dsb
        isb

        /* run C++ constructors */
        ldr r4, =__init_array_start
        ldr r5, =__init_array_end
0:
        cmp r4, r5
        bhs 1f
        ldr r7, [r4]
        blx r7
        add r4, #4
        b 0b

1:
        bl main
        /* if main ever returns, just loop */
0:
        b 0b
        .size  handle_reset, .-handle_reset
