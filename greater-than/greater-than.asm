default rel

section .bss
	buf resb 21

section .data
	true_str:  db "TRUE", 10
	true_len:  equ $ - true_str
	false_str: db "FALSE", 10
	false_len: equ $ - false_str

section .text
	global	_start

_start:
	mov    rax, 76565343   ; x
	mov    rbx, 76575434   ; y
	movq   xmm0, rax       ; Copy rax into low lane
	pinsrq xmm0, rbx, 1    ; Copy rbx into high lane
	call   is_greater_than ; x > y

	call   print_result    ; Print the true or false

	mov    eax, 60         ; System call for exit
	xor    edi, edi        ; Clear edi
	syscall
	ret

; in:       xmm0 = [y, x]
; out:      rax = result
; clobbers: rcx, xmm1, xmm2, mm3, xmm4, xmm5
is_greater_than:
	mov        ecx, 1             ; Shift amount for bitwise operations

	movdqa     xmm1, xmm0         ; xmm1 = xmm0
	pshufd     xmm1, xmm1, 78     ; Swap lanes
	pandn      xmm1, xmm0         ; xmm1 = !xmm1 & xmm0

%macro round 1
	mov        rax, %1            ; Set rax to input for macro
	movq       xmm4, rax          ; Copy rax into low lane
	punpcklqdq xmm4, xmm4         ; Copy low lane into high lane
	call       bitwise_operations ; Run function
%endmacro

	round      0xAAAAAAAAAAAAAAAA ; (101010101010101010101010101010101...)
	round      0xCCCCCCCCCCCCCCCC ; (110011001100110011001100110011001...)
	round      0xF0F0F0F0F0F0F0F0 ; (111100001111000011110000111100001...)
	round      0xFF00FF00FF00FF00 ; (111111110000000011111111000000001...)
	round      0xFFFF0000FFFF0000 ; (111111111111111100000000000000001...)
	round      0xFFFFFFFF00000000 ; (111111111111111111111111111111110...)

	movq       rax, xmm1          ; Set rax to low lane of xmm1
	ret                           ; Return final result as rax

; in:       xmm1 = [x | y], xmm4 = [mask | mask], rcx = shift
; out:      xmm1 = result, xmm2 = result, rcx (doubled)
; clobbers: xmm0, xmm3, xmm5
bitwise_operations:
	movq    xmm3, rcx      ; Copy rcx into low lane

	movdqa  xmm2, xmm1     ; xmm2 = xmm1
	pshufd  xmm2, xmm2, 78 ; Swap lanes

	movdqa  xmm0, xmm1     ; xmm0 = xmm1
	pand    xmm1, xmm4     ; xmm1 = xmm1 & xmm4
	psrlq   xmm1, xmm3     ; xmm1 >> xmm3
	por     xmm0, xmm1     ; xmm0 = xmm0 | xmm1

	movdqa  xmm5, xmm4     ; xmm5 = xmm4
	pandn   xmm5, xmm0     ; xmm5 = !xmm5 & xmm0

	pand    xmm2, xmm4     ; xmm2 = xmm2 & xmm4
	psrlq   xmm2, xmm3     ; xmm2 >> xmm3
	pandn   xmm2, xmm5     ; xmm2 = !xmm2 & xmm5
	
	movdqa  xmm1, xmm2     ; xmm1 = xmm2

	shl     rcx, 1         ; Double the shift amount

	ret                    ; Returns nothing

; in:       eax = value to check
; clobbers: edx, edi, rsi
print_result:
	test    eax, eax         ; Set 0-flag if 0
	jz      .false           ; Jump to .false if 0

	lea     rsi, [true_str]  ; Load effective address into rsi
	mov     edx, true_len    ; Set edx to length of the string
	jmp     .write           ; Jump to .write

.false:
	lea     rsi, [false_str] ; Load effective address into rsi
	mov     edx, false_len   ; Set edx to length of the string
		
.write:
	mov     edi, 1           ; stdout
	mov     eax, 1           ; System-call for print
	syscall
	ret
