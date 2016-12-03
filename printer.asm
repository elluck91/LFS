; Applications linear-feedback shift register
; Author: Lukasz Juraszek
; Date November 2, 2016
; run application this way:
; nasm printer.asm -felf
; gcc printer.o -o printer

section .bss
section .data
	Msg db "Done.",0		; Message used for testing when code has completed
	format db "%i",0		; formatter to print out integers
	charFormat db "%c",10,0		; formatter to print out characters
	strFormat db "%s",0		; formatter to print out strings
	hexFormat db "%0x",0		; formatter to print out hexadecimal values
	counter db 8
section .text
	extern printf			; external glibc metod printff
	global main
main:
	xor ebx,ebx			; clear up register ebx, preparing for use
	add bl,1			; Operations will be on 8-bit register
					; This is my initial value 0000 0001b

	mov ecx,1			; number of linear shifts
function_loop:				; function_loop executes specified number of shifts
	push ebx			; passes argument
	call myFunction			; invokes shift function
	shr bl,1			; removes the LSB - least sginifant bit
	add ebx,eax			; adds the returning bit to MSB
	add esp,4			; fixing stack
	loop function_loop		; repeat # of times

;	push ebx			; test
;	push format			; test
;	call printf			; test
;	add esp,8			; test



	push ebx			; store the shifted value on the stack
bit_print:				; bit printer
	shl bl,1			; bits have to be printed in order beginning with first
	jc print_one			; if the MSB was 1, then the carry flag will be set to true, print 1
	mov eax,0			; else print 0
	push eax			; passing of the zero
	push format			; pass formatter
	call printf			; function invocation
	add esp,8			; fix stack
	
	dec byte [counter]		; decrement number of bits left to print
	cmp byte [counter],0		; are we done printing all 8 bits?
	je print_b			; if yes, print b and print in hexadecimal form
	jmp bit_print			; else print the next bit
print_one:				; function printing one
	mov eax,1			; passing the argument 1
	push eax			; pushing the argument onto the stack
	push format			; pushing the formatted
	call printf			; function invocation
	add esp,8			; fix stack
	
	dec byte [counter]		; are we done printing bits?
	cmp byte [counter],0		; are we?
	je print_b			; if yes, print b
	jmp bit_print			; else print next bit
	
print_b:				; values in binary are followed by character 'b'
	mov eax,'b'			; move the character 'b' to register eax
	push eax			; pass the argument
	push charFormat			; pass the character formatter
	call printf			; function invocation
	add esp,8			; fix the stack

hex_print:				; Now, we are printing the shifted value in Hexadecimal form
	pop ebx				; we get the value that we saved on stack
	push ebx			; we pass it as an argument
	push hexFormat			; pass the hexadecimal formatter
	call printf			; function invocation
	add esp,8			; fix the stack

	mov eax,'h'			; pass 'h' to indicate it's a hex number
	push eax			; pass the argument
	push charFormat			; push character formatter
	call printf			; function invocation
	add esp,8			; fix the stack
	jmp Done			; We are done

myFunction:
	push ebp			; save stack
	mov ebp, esp			; set the base pointer


; my function goes below

	mov esi,[ebp+8]		; accessing the argument 0000 00001b
	mov edi,[ebp+8]		; stoing argument for later use
	and edi,1		; edi holds the arguments bit 0
	
	shr esi, 2		; shifting right to access bit 2
	and esi,1		; clearing other bits
	
	xor edi, esi		; xor on the bits 0 and 2, storing result in edi

	xor esi,esi		; preparing esi for next xor
	mov esi,[ebp+8]
	and esi,8		; preserves bit 3
	shr esi,3		; accesses bit 3

	xor edi, esi		; xor on bit 3 and previous result

	xor esi, esi
	mov esi,[ebp+8]
	and esi,16		; preserves bit 4
	shr esi,4		; accesses bit 4
	xor edi, esi		; xor on bit 4 and previous result
Test:	
;	push edi
;	push format
;	call printf
;	add esp,8
Return:
	shl edi,7		; set up the return value for easier addition to MSB
	mov eax,edi		; pass the result to the return value

; my function goes above
	mov esp, ebp		; restore the stack
	pop ebp			; restore the stack
	ret			; return to the caller

Done:
;	mov ebx,Msg
;	push ebx
;	push format
;	call printf
;	add esp,8
