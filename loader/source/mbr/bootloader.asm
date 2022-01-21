org     0x7C00
bits    16


%include        "bootsector.asm"


stage2:
        jmp     $


; Fill the MBR gap.
times   32 * 512 - ($ - $$)     db      0x00
