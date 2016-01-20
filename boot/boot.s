[BITS 16]

%define SEG_BOOT_START			0x7c0
%define SEG_BOOT_S2_START		0x100
%define MEMORY_MAP_START		0x500

mov ax, SEG_BOOT_START
mov ds, ax
mov es, ax
mov ax, 0x8000
mov ss, ax
mov sp, 0xf000

clc

_initialize_disk:
	xor ax, ax
	int 0x13
	jc _initialize_disk

_read_kernel:
	mov ax, SEG_BOOT_S2_START
	mov es, ax
	.loop:
		mov ax, (2 << 8) | 6
		mov cx, 2
		xor dh, dh
		xor bx, bx
		int 0x13
		jc .loop

_memory_map:
	xor ax, ax
	mov es, ax
	.loop:
		mov edx, 0x534D4150
		xor ebx, ebx
		mov di, 0x500
		mov ecx, 20
		.continue:
			mov eax, 0xE820
			int 0x15
			jc .loop
			cmp eax, 0x534D4150
			jne .loop
			or ebx, ebx
			jz .end
			add di, 20
			jmp .continue
	.end:

cli
_global_table_descriptor:
	lgdt [ds:gdt_ptr]

_protect_mode:
	mov eax, cr0
	or ax, 1
	mov cr0, eax
	jmp _run_stage_2

_run_stage_2:
	mov ax, 0x10
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x10000
	mov esp, 0x10000

	jmp dword 0x8:0x1000

gdt:
	db 0x00, 0x00, 0x00, 0x00, 0x00, 00000000b, 00000000b, 0x00
gdt_cs:
	db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10011011b, 11011111b, 0x00
gdt_ds:
	db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10010011b, 11011111b, 0x00
gdtend:

gdt_ptr:
	dw	gdtend - gdt
	dd	(SEG_BOOT_START << 4) + gdt

times 510 - ($ - $$) db 0
dw 0xAA55