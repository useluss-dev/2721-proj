%define STDIN 0
%define STDOUT 1
%define SYS_EXIT 1
%define SYS_READ 3
%define SYS_WRITE 4
%define SYS_OPEN 5
%define SYS_CLOSE 6
%define EXIT_OK 0

;------------------------------------------
; int slen(char *message)
; string length calculation function
slen:
    push    ebx 			; put ebx on the stack
    mov     ebx, eax 		; copy eax into ebx

.nextchar:
    cmp     byte [eax], 0 	; checks if byte pointed to by eax is the null terminator
    jz      .finished		; jump if eax is 0 (jz stands for jump if 0)
    inc     eax				; increment eax by 1
    jmp     .nextchar		; jumps back to the top of nextchar
 
.finished:
    sub     eax, ebx		; subtract start address from current address
    pop     ebx				; restore ebx to value at start
    ret						; return

;------------------------------------------
; void sprint(char *str)
; string printing function
sprint:
    push    edx				; put edx on the stack
    push    ecx				; put ecx on the stack
    push    ebx				; put ebx on the stack
    push    eax				; put eax on the stack
    call    slen 			; call slen
 
    mov     edx, eax 		; move the string length from eax into edx 
    pop     eax				; restore eax start value
 
 	; execute syscall write(int fd(ebx), char *buf(ecx), size_t count(edx))
    mov     ecx, eax		; set ecx to eax which is the value of the string
    mov     ebx, STDOUT		; set ebx to 1 (stdout file)
    mov     eax, SYS_WRITE	; set eax to the write syscall opcode
    int     80h 			; software interrupt to move to kernal mode to execute syscall
 
    pop     ebx				; remove ebx from the stack
    pop     ecx				; remove ecx from the stack
    pop     edx				; remove edx from the stack
    ret						; return

;------------------------------------------
; void sprintLF(char *str)
; string printing with line feed function
sprintLF:
	call    sprint 		; print original string
    push    eax			; push eax to use string to use later
    mov     eax, 0Ah	; set eax to a '\n'

    push    eax			; pushes '\n' which is a single byte storing it as a full 32 bit value
                        ; will be stored in reverse order so 0Ah 00 00 00 00 00
    mov     eax, esp	; move the new 32 bit version of '\n' into eax
    call    sprint 		; print the '\n'
    pop     eax			; removes '\n' from stack
    pop     eax			; restores original eax string
    ret                 ; return

;------------------------------------------
; void strcmp(char *s1, char *s2)
; string comparison function
strcmp:
    push    ebp             ; save old base pointer
    mov     ebp, esp        ; move start stack frame into base pointer
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
    test    al, al          ; check if al == '\0'
    je      .equal          ; if al == '\0', then dl == '\0' so string are equal

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
; void file_exists(char *filename)
; check if a file exists
file_exists:
    push    ebp                 ; save old base pointer on the stack
    mov     ebp, esp            ; set current stack pointer as new base pointer

 	; execute syscall open(char *filename(ebx), int flags(ecx), umode_t mode(edx))
    mov     ebx, [ebp+8]        ; go to the memory location (ebp+8) and fetch the filename pointer argument
    mov     eax, SYS_OPEN       ; load sys open syscall
    mov     ecx, 0              ; set flags = 0 open file in read-only mode
    mov     edx, 0              ; no mode bits needed because read-only never creates a file
    int     80h                 ; ask the kernel to open the file

    cmp     eax, 0              ; compare return value with zero
    jl      .does_not_exist     ; if eax < 0, the open failed then file does not exist

 	; execute syscall open(int fd(ebx))
    mov     ebx, eax            ; file opened successfully, move file descriptor into ebx
    mov     eax, SYS_CLOSE      ; sys_close
    int     80h                 ; close the file descriptor

    mov     eax, 1              ; return value 1; file exists
    jmp     .done               ; skip the non-existent case

.does_not_exist:
    mov     eax, 0              ; return value 0; file does not exist

.done:
    mov     esp, ebp            ; restore old stack pointer
    pop     ebp                 ; restore old base pointer
    ret                         ; return to caller

;------------------------------------------
; void quit()
; exit program and restore resources
quit:
    mov     ebx, EXIT_OK	; set ebx to the exit ok status
    mov     eax, SYS_EXIT	; set eax to the exit syscall opcode
    int     80h				; software interrupt to move to kernal mode to execute syscall
