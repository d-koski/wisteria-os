bits    16


;; The entry point of the bootloader.
stage1:
        jmp     0x0000:.ensure_cs_ip

.ensure_cs_ip:
        ; Make sure that all segment registers are set to zero.
        mov     ax, 0
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax

        ; Set up the stack.
        mov     ss, ax
        mov     sp, 0x7C00

        ; Clear the screen by setting the 80x25 video mode.
        mov     ah, 0x00
        mov     al, 0x03
        int     0x10

        mov     si, hello_msg
        call    print

        jmp     $


;; Prints the given byte string to the screen.
;;
;; Parameters:
;;      DS:SI   Pointer to the string.
;;
;; Clobbers:
;;      AX
print:
        push    si

        mov     ah, 0x0E

.loop:
        lodsb
        cmp     al, 0
        je      .exit
        int     0x10
        jmp     .loop

.exit:
        pop     si
        ret


hello_msg               db      "Wisteria Loader", 0x0D, 0x0A, 0x00


times   510 - ($ - $$)  db      0x00

;; Bootable signature. Marks the drive as bootable for BIOS.
db      0x55, 0xAA
