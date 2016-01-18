[BITS 16]

[ORG 0x7c00]
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov sp, 0x9c00

	mov ax, 0xb800
	mov es, ax

	mov si, msg
	call sprint

sprint:
	lodsb
	or al, al
	jz .end
	call .print_char
	jmp sprint
	.end:
		add byte [ypos], 1
		mov byte [xpos], 0
		ret
	.print_char:
		mov ah, 0x0F
		mov cx, ax
		movzx ax, byte [ypos]
		mov dx, 160
		mul dx
		movzx bx, byte [xpos]
		shl bx, 1

		mov di, 0
		add di, ax
		add di, bx

		mov ax, cx
		stosw
		add byte [xpos], 1
		ret

cli
hang:
	nop
	nop
	jmp hang

msg:
	db 'Hello world', 0

xpos db 0
ypos db 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA