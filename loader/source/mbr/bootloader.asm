org     0x7C00
bits    16


%include        "bootsector.asm"


stage2:
        ; Enable the 32-bit Protected Mode.

        ; Disable interrupts, including NMI.
        cli
        in      al, 0x70
        or      al, 0b10000000
        out     0x70, al

        lgdt    [gdt_descriptor]

        mov     eax, cr0
        or      eax, 1
        mov     cr0, eax

        jmp     0x0008:.enter_32bit_protected_mode

align   4
bits    32
.enter_32bit_protected_mode:
        jmp     $


%include        "gdt.asm"


; Fill the MBR gap.
times   32 * 512 - ($ - $$)     db      0x00
