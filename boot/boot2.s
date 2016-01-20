[BITS 32]
[ORG 0x1000]

call _clear

mov eax, 'C'
push eax
push welcome
call _put_string
add esp, 4
call _put_char
push 0xABCDEF01
call _put_register

jmp $

_clear:
	push ebp
	mov ebp, esp
	mov ecx, 160 * 25
	xor ax, ax
	mov edi, 0xb8000
	rep stosw
	leave
	ret

_new_line:
	mov dword [xpos], 0
	mov eax, dword [ypos]
	inc eax
	mov dword [ypos], eax
	ret

_get_term_ptr:
	mov ebx, dword [xpos]
	shl ebx, 1
	mov edx, dword [ypos]
	mov eax, 160
	mul edx
	add eax, 0xb8000
	add eax, ebx
	ret

_put_string:
	push ebp
	mov ebp, esp
	call _get_term_ptr
	mov edi, eax
	mov esi, dword [ebp + 8]
	.loop:
		lodsb
		or al, al
		jz .end
		cmp al, 10
		je .new_line
		mov ah, 3
		stosw
		inc dword [xpos]
		jmp .loop
		.new_line:
			call _new_line
			jmp .loop
	.end:
		leave
		ret

_put_char:
	push ebp
	mov ebp, esp
	call _get_term_ptr
	mov edi, eax
	mov eax, dword [ebp + 8]
	mov ah, 3
	stosw
	inc dword [xpos]
	leave
	ret

_put_register:
	push ebp
	mov ebp, esp
	push register_begin
	call _put_string
	mov ecx, 8
	.continue:
		push ecx
		mov eax, dword [ebp + 8]
		shr eax, 28
		cmp al, 10
		jge .alpha
		add al, '0'
		push eax
		call _put_char
		add esp, 4
		jmp .next
		.alpha:
			sub al, 10
			add al, 'A'
			push eax
			call _put_char
			add esp, 4
		.next:
			shl dword [ebp + 8], 4
			pop ecx
			loop .continue
	leave
	ret

register_begin: db '0x', 0

xpos: dd 0
ypos: dd 0

welcome:
	db 'Bootloader stage 2, working draft ...', 10, 0

times 4096 - 512 - ($ - $$) db 0