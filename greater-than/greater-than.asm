section .bss
	buf resb 12

section .text
	global _start

_start:
	mov rbx, 76665343
	mov rbp, 76575434
	call f

	call print_uint

	mov rax, 1
	xor rbx, rbx
	int 80h

; prints the unsigned number in eax, followed by a newline
print_uint:
	mov rdi, buf+11         ; point at the last byte of the buffer
	mov byte [edi], 10      ; newline goes at the end
	mov rbx, 10             ; divisor

.next_digit:
	xor rdx, rdx            ; div uses edx:eax, so clear the top half
	div rbx                 ; eax = eax / 10, edx = eax % 10
	add dl, '0'             ; digit -> ASCII character
	dec rdi
	mov [rdi], dl           ; store it, moving backwards
	test rax, rax           ; quotient zero yet?
	jnz .next_digit

	mov rax, 4              ; sys_write
	mov rbx, 1              ; stdout
	mov rcx, rdi            ; start of the digits
	mov rdx, buf+12
	sub rdx, rcx            ; length = end - start
	int 80h
	ret

f:
	mov r12, rbx
	not rbp
	and r12, rbx
	not rbp

	not rbx
	and rbp, rbx
	not rbx
	mov r13, rbp

	mov rcx, 1

	mov rbp, 0xAAAAAAAAAAAAAAAA
	call h

	mov rbp, 0xCCCCCCCCCCCCCCCC
	call h

	mov rbp, 0xF0F0F0F0F0F0F0F0
	call h
	
	mov rbp, 0xFF00FF00FF00FF00
	call h

	mov rbp, 0xFFFF0000FFFF0000
	call h
	
	mov rax, r12
	mov rbx, r13
	mov rbp, 0xFFFFFFFF00000000
	call g

	ret

h:
	mov rax, r12
	mov rbx, r13
	call g
	mov rdx, rax

	mov rax, r13
	mov rbx, r12
	call g
	mov r13, rax

	mov r12, rdx
	shl rcx, 1

	ret

g:
	mov rsi, rax
	and rsi, rbp
	shr rsi, rcx
	or rax, rsi

	ror rbp, rcx
	and rax, rbp
	rol rbp, rcx

	and rbx, rbp
	shr rbx, rcx
	not rbx
	and rax, rbx

	ret
