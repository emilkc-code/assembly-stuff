section .bss
	buf resb 12

section .text
	global _start

_start:
	movabs rax, 76665343    ; Set number for checking
	movabs rbx, 76575434    ; Set number to check against
	call check_greater_than ; Run function

	call print_uint         ; Print rax from unsigned integer

	mov rax, 1              ; System call for exit
	xor ebx, ebx            ; Clear ebx
	int 80h


; in:       rax = x, rbx = y
; out:      rax = result
; clobbers: rcx, rbp, r12, r13, + rdx, rsi, r15 
check_greater_than:
	mov r12, rax                  ; Need rax later
	andn r12, rbx, r12            ; Flip rbx and mask r12 with it

	andn r13, rax, r13            ; Flip saved rax and mask r13 with it

	mov rcx, 1                    ; Shift amount for bitwise operations

	mov rbp, 0xAAAAAAAAAAAAAAAA   ; Set mask (101010101010101010101010101010101...)
	call setup_bitwise_operations ; Bitwise operations across r12 and r13

	mov rbp, 0xCCCCCCCCCCCCCCCC   ; (110011001100110011001100110011001...)
	call setup_bitwise_operations

	mov rbp, 0xF0F0F0F0F0F0F0F0   ; (111100001111000011110000111100001...)
	call setup_bitwise_operations
	
	mov rbp, 0xFF00FF00FF00FF00   ; (111111110000000011111111000000001...)
	call setup_bitwise_operations

	mov rbp, 0xFFFF0000FFFF0000   ; (111111111111111100000000000000001...)
	call setup_bitwise_operations
	
	mov rax, r12                  ; Set rax for next call
	mov rbx, r13                  ; Set rbx for next call
	mov rbp, 0xFFFFFFFF00000000   ; Mask (111111111111111111111111111111110...)
	call bitwise_operations

	ret                           ; Return final result as rax

; in:       r12 = x, r13 = y, rcx = shift, rbp = mask
; clobbers: rax, rbx, rdx, r15, + rsi
setup_bitwise_operations:
	mov r15, rbp            ; Copy the mask
	ror r15, rcx            ; Shift with wrapping

	mov rax, r12            ; Set rax for next call
	mov rbx, r13            ; Set rbx for next call
	call bitwise_operations ; Bitwise operations
	mov rdx, rax            ; Save the value for later

	                        ; Same operations but swap r12 and r13
	mov rax, r13
	mov rbx, r12
	call bitwise_operations ; Reuses the shifted mask in r15
	mov r13, rax

	mov r12, rdx            ; Grab the saved value
	shl rcx, 1              ; Double the shift amount for next time

	ret                     ; Returns nothing

; in:       rax = x, rbx = y, rcx = shift, rbp = mask, r15 = inv mask
; out:      rax = result
; clobbers: rsi
bitwise_operations:
	mov rsi, rax ; Save rax for later
	and rsi, rbp ; & mask
	shr rsi, rcx ; Shift without wrap
	or rax, rsi  ; | mask with the saved rax

	and rax, r15 ; & mask with the shifted mask

	and rbx, rbp ; & mask
	shr rbx, rcx ; Shift without wrap
	not rbx      ; Flip bits
	and rax, rbx ; & mask

	ret          ; Return rax



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
