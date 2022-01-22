org     0x7C00
bits    16


%include        "bootsector.asm"


stage2:
        mov     si, stage2_hello_msg
        call    print

        ; Infinite loop.
        jmp     $


stage2_hello_msg        db      "status: stage2", 0x0D, 0x0A, 0x00

; Fill the MBR gap.
times   32 * 512 - ($ - $$)     db      0x00
