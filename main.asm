SECTION .data
msg     db      'Hello World!', 0Ah
 
SECTION .text
global  _start
 
_start:
    mov     edx, 13 	; number of bytes to write - one for each letter plus 0Ah
    mov     ecx, msg	; move memory address of our message into ecx
    mov     ebx, 1		; write to the stdout file
    mov     eax, 4		; invoke SYS_WRITE (kernel opcode 4)
    int     80h			; tells the kernel perform the syscall with values edx, ecx, ebx, and eax
 
    mov     ebx, 0      ; return 0 status on exit - 'No Errors'
    mov     eax, 1      ; invoke SYS_EXIT (kernel opcode 1)
    int     80h			; tells the kernel perform the syscall with values edx, ecx, ebx, and eax
