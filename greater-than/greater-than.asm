default rel

section .bss
	buf resb 21

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
; in:       rax = unsigned number
; out:      nothing (prints number and newline)
; clobbers: rax, rbx, rcx, rdx, rsi, rdi, r8, r11
print_uint:
    lea rdi, [buf+20]
    mov byte [rdi], 10
    mov r8, 0xCCCCCCCCCCCCCCCD   ; magic constant, loaded once outside the loop
    mov rsi, rax                 ; rsi = current value

.next_digit:
    mov rax, rsi
    mul r8                       ; rdx:rax = rsi * magic
    shr rdx, 3                   ; rdx = rsi / 10
    lea rax, [rdx + rdx*4]
    add rax, rax                 ; rax = (rsi / 10) * 10
    sub rsi, rax                 ; rsi = remainder (the digit)
    add sil, '0'
    dec rdi
    mov [rdi], sil               ; store the digit character
    mov rsi, rdx                 ; value = quotient
    test rsi, rsi
    jnz .next_digit
    
    mov rsi, rdi            ; address of the first digit
    lea rdx, [buf+21]
    sub rdx, rsi            ; length including the newline
    mov edi, 1              ; stdout (rdi is free now that rsi has the address)
    mov eax, 1              ; sys_write (64-bit number)
    syscall                 ; clobbers rcx and r11
    ret
