%include		'functions.asm'

SECTION .data
msg     db      'test', 0Ah
 
SECTION .text
global  _start
 
_start:
; print msg
    mov     eax, msg	; copy msg to eax
	call	sprint		; call our string printing function
 
; end program
 	call	quit		; call our function to quit the program
