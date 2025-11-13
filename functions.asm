%define STDOUT 1
%define SYS_EXIT 1
%define SYS_WRITE 4
%define EXIT_OK 0

;------------------------------------------
; int slen(String message)
; String length calculation function
slen:
    push    ebx 			; put ebx on the stack
    mov     ebx, eax 		; copy eax into ebx

nextchar: 					; this is a label for the function to jump to
    cmp     byte [eax], 0 	; checks if byte pointed to by eax is the null terminator
    jz      finished		; jump if eax is 0 (jz stands for jump if 0)
    inc     eax				; increment eax by 1
    jmp     nextchar		; jumps back to the top of nextchar
 
finished:					; this is a label for the function to jump to
    sub     eax, ebx		; subtract start address from current address
    pop     ebx				; restore ebx to value at start
    ret						; return

;------------------------------------------
; void sprint(String message)
; String printing function
sprint:
    push    edx				; put edx on the stack
    push    ecx				; put ecx on the stack
    push    ebx				; put ebx on the stack
    push    eax				; put eax on the stack
    call    slen 			; call slen
 
    mov     edx, eax 		; move the string length from eax into edx 
    pop     eax				; restore eax start value
 
    mov     ecx, eax		; set ecx to eax which is the value of the string
    mov     ebx, STDOUT		; set ebx to 1 (stdout file)
    mov     eax, SYS_WRITE	; set eax to the write syscall opcode
    int     80h 			; software interrupt to move to kernal mode to execute syscall
 
    pop     ebx				; remove ebx from the stack
    pop     ecx				; remove ecx from the stack
    pop     edx				; remove edx from the stack
    ret						; return

;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, EXIT_OK	; set ebx to the exit ok status
    mov     eax, SYS_EXIT	; set eax to the exit syscall opcode
    int     80h				; software interrupt to move to kernal mode to execute syscall
    ret						; return
