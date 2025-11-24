%define STDIN 0
%define STDOUT 1
%define SYS_EXIT 1
%define SYS_WRITE 4
%define SYS_READ 3
%define EXIT_OK 0

;------------------------------------------
; int slen(String message)
; string length calculation function
slen:
    push    ebx 			; put ebx on the stack
    mov     ebx, eax 		; copy eax into ebx

.nextchar: 					; this is a label for the function to jump to
    cmp     byte [eax], 0 	; checks if byte pointed to by eax is the null terminator
    jz      .finished		; jump if eax is 0 (jz stands for jump if 0)
    inc     eax				; increment eax by 1
    jmp     .nextchar		; jumps back to the top of nextchar
 
.finished:					; this is a label for the function to jump to
    sub     eax, ebx		; subtract start address from current address
    pop     ebx				; restore ebx to value at start
    ret						; return

;------------------------------------------
; void sprint(String message)
; string printing function
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
; void sprintLF(String message)
; string printing with line feed function
sprintLF:
	call    sprint
 
    push    eax         ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah    ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
                        ; as eax is 4 bytes wide, it now contains 0000000Ah
    push    eax         ; push the linefeed onto the stack so we can get the address
                        ; given that we have a little-endian architecture, eax register bytes are stored in reverse order,
                        ; this corresponds to stack memory contents of 0Ah, 0h, 0h, 0h,
                        ; giving us a linefeed followed by a NULL terminating byte
    mov     eax, esp    ; move the address of the current stack pointer into eax for sprint
    call    sprint      ; call our sprint function
    pop     eax         ; remove our linefeed character from the stack
    pop     eax         ; restore the original value of eax before our function was called
    ret                 

;------------------------------------------
; void sread(String input, int input_size)
; string reading function
sread:
	push	eax
	push	ebx
	push	ecx
	push	edx

	mov		ecx, eax
	mov		edx, ebx
	mov		ebx, STDIN
	mov		eax, SYS_READ
	int 	80h

	pop		eax
	pop		ebx
	pop		ecx
	pop		edx
	ret

;------------------------------------------
; void strcmp(string s1, string s2)
; string comparison function
strcmp:
    push    ebp             ; save old base pointer
    mov     ebp, esp        ; establish new stack frame
    push    esi             ; save esi (we'll use it for s1)
    push    edi             ; save edi (we'll use it for s2)

    mov     esi, [ebp + 8]  ; esi = s1 pointer
    mov     edi, [ebp + 12] ; edi = s2 pointer

.compare_loop:
    ; load current chars from both strings
    mov     al, [esi]       ; al = *s1
    mov     dl, [edi]       ; dl = *s2

    ; compare the two characters
    cmp     al, dl          ; compare *s1 and *s2
    jne     .different      ; if they differ, jump to .different

    ; if characters are equal, check for end of string
    test    al, al          ; set flags based on al (is al == 0?)
    je      .equal          ; if al == 0, both chars are '\0' → strings equal

    ; advance both pointers and continue
    inc     esi             ; s1++
    inc     edi             ; s2++
    jmp     .compare_loop   ; Repeat loop

.different:
    ; characters are different, compute (unsigned) difference
    movzx   eax, al         ; zero-extend al to eax (unsigned char)
    movzx   edx, dl         ; zero-extend dl to edx (unsigned char)
    sub     eax, edx        ; eax = (unsigned)*s1 - (unsigned)*s2
    jmp     .done           ; Done, eax holds the result

.equal:
    ; strings matched all the way to the null terminator
    xor     eax, eax        ; eax = 0

.done:
    pop     edi             ; restore edi 
    pop     esi             ; restore esi
    mov     esp, ebp        ; restore stack pointer
    pop     ebp             ; restore base pointer
    ret		                ; return to caller

;------------------------------------------
; void quit()
; exit program and restore resources
quit:
    mov     ebx, EXIT_OK	; set ebx to the exit ok status
    mov     eax, SYS_EXIT	; set eax to the exit syscall opcode
    int     80h				; software interrupt to move to kernal mode to execute syscall
