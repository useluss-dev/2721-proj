%include	'functions.asm'		; include our functions file

%define		INPUT_SIZE		255		; max size of user input
%define		STDIN			0		; stdin file descriptor
%define		READ			3		; read opcode

SECTION .data										; this section denotes where we create variables
msg		db		'Enter CREATE or DELETE: ', 0Ah		; this assigns the value in '' along with a null terminator `0Ah` into the msg1 variable

SECTION .bss						; this section denotes where we can reserver blocks of memory to store uninitialized variables
usrinput:		resb	INPUT_SIZE 	; this reservers of a block of 255 bytes for user input
 
SECTION .text		; this section denotes where actual executable code will go
global  _start		; this denotes that this is where our program starts
 
_start:
; print msg
    mov     eax, msg	; copy msg to eax
	call	sprint		; call our string printing function

; read user input
	mov		eax, usrinput
	mov		ebx, INPUT_SIZE
	call	sread

	mov		eax, usrinput
	call 	sprint

; end program
 	call	quit		; call our function to quit the program
