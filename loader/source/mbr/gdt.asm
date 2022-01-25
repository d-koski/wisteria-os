align   8,      db      0x00
gdt_descriptor:
        dw      global_descriptor_table.end - global_descriptor_table - 1
        dq      global_descriptor_table


align   8,      db      0x00
global_descriptor_table:
        dq      0                       ; Null segment.
        dq      0x00CF9A000000FFFF      ; 32-bit code segment.
        dq      0x00CF92000000FFFF      ; 32-bit data segment.
.end:
