section .bss
	buf resb 12

section .text
	global _start

_start:
	mov rbx, 76665343         ; Set number for checking
	mov rbp, 76575434         ; Set number to check against
	call check_greater_than   ; Run function

	call print_uint

	mov rax, 1
	xor ebx, ebx
	int 80h


check_greater_than:
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
	call setup_bitwise_operations

	mov rbp, 0xCCCCCCCCCCCCCCCC
	call setup_bitwise_operations

	mov rbp, 0xF0F0F0F0F0F0F0F0
	call setup_bitwise_operations
	
	mov rbp, 0xFF00FF00FF00FF00
	call setup_bitwise_operations

	mov rbp, 0xFFFF0000FFFF0000
	call setup_bitwise_operations
	
	mov rax, r12
	mov rbx, r13
	mov rbp, 0xFFFFFFFF00000000
	call bitwise_operations

	ret

setup_bitwise_operations:
	mov rax, r12
	mov rbx, r13
	call bitwise_operations
	mov rdx, rax

	mov rax, r13
	mov rbx, r12
	call bitwise_operations
	mov r13, rax

	mov r12, rdx
	shl rcx, 1

	ret

bitwise_operations:
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



; print_uint WAS WRITTEN BY CLAUDE
; prints the unsigned number in eax, followed by a newline
print_uint:
	mov rdi, buf+11         ; point at the last byte of the buffer
	mov byte [edi], 10      ; newline goes at the end
	mov rbx, 10             ; divisor

.next_digit:
	xor edx, edx            ; div uses edx:eax, so clear the top half
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
