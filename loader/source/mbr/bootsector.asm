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

        ; Preserve the boot drive number.
        mov     [boot_drive], dl

        ; Clear the screen by setting the 80x25 video mode.
        mov     ah, 0x00
        mov     al, 0x03
        int     0x10

        mov     si, hello_msg
        call    print

        call    enable_a20_line

        ; TODO: Check if Int13h extensions are supported.
        mov     ah, 0x41
        mov     bx, 0x55AA
        mov     dl, [boot_drive]
        int     0x13
        jc      .int13_exts_unsupported

        ; Load the stage2 of the bootloader.
        mov     ah, 0x42
        mov     dl, [boot_drive]
        mov     si, disk_address_packet
        int     0x13
        jc      .stage2_not_loaded

        jmp     stage2

.int13_exts_unsupported:
        mov     si, int13_exts_unsupported_msg
        call    print
        jmp     $

.stage2_not_loaded:
        mov     si, int13_exts_unsupported_msg
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


;; Enables the A20 address line.
;;
;; Note:
;;      It's virtually impossible that someone will try to run the system without
;;      BIOS A20 support. Ignore other methods of enabling it.
;;
;; Clobbers:
;;      AX
align   4,      db      0x00
enable_a20_line:
        call    .test_a20_line
        jc      .enable_using_bios
        ret

.enable_using_bios:
        ; Query BIOS A20 gate support.
        mov     ax, 0x2403
        int     0x15
        jb      .enable_failure

        ; Try enabling the A20 address line using BIOS.
        mov     ax, 0x2401
        int     0x15

        ; Check if the A20 line was enabled.
        call    .test_a20_line
        jc      .enable_failure

.test_a20_line:
        push    ds

        mov     ax, 0xFFFF
        mov     ds, ax
        mov     byte [ds:0x0510], 0xFF

        xor     ax, ax
        mov     ds, ax
        cmp     byte [ds:0x0500], 0xFF

        clc
        jne     .test_a20_line_enabled
        stc

.test_a20_line_enabled:
        pop     ds
        ret

.enable_failure:
        mov     si, a20_not_enabled_msg
        call    print
        jmp     $


boot_drive              db      0x00


disk_address_packet:
.size                   db      0x10    ; Size of the packet.
.padding                db      0x00
.block_count            dw      31      ; Number of blocks (sectors) to transfer.
.buffer_offset          dw      0x7E00
.buffer_segment         dw      0x0000
.first_block_index      dq      0x01    ; Index of the first block (sector).


hello_msg               db      "Wisteria Loader", 0x0D, 0x0A, 0x00
a20_not_enabled_msg     db      "error: couldn't enable the A20 address line", 0x0D, 0x0A, 0x00
int13_exts_unsupported_msg db   "error: int13h extensions are not supported", 0x0D, 0x0A, 0x00
stage2_not_loaded_msg   db      "error: couldn't load the stage 2 of the bootloader", 0x0D, 0x0A, 0x00


times   510 - ($ - $$)  db      0x00

;; Bootable signature. Marks the drive as bootable for BIOS.
db      0x55, 0xAA
