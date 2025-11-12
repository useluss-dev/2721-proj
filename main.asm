%include		'functions.asm'

SECTION .data
msg     db      'test', 0Ah
 
SECTION .text
global  _start
 
_start:
	; print msg
    mov     eax, msg	; move memory address of our message into eax
	call	sprint		; call our string printing function
 
 	; end program
 	call	quit		; call our function to quit the program
