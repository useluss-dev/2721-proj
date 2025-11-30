%include	'functions.asm'		; include our functions file

SECTION .data
flag_create	db "--create", 0
flag_delete db "--delete", 0
flag_help	db "--help", 0

err_no_flag db "Error: You are missing required flags.", 0
err_wrong_args db "Error: Wrong number of arguments for this flag", 0
usage_msg db "Usage:", 10, \
           "  program --help", 10, \
           "      Show this help message.", 10, \
           "  program --create <name>", 10, \
           "      Create a file with the given name.", 10, \
           "  program --delete <name>", 10, \
           "      Delete the file with the given name.", 10, \
           0

SECTION .text
global _start

_start:
    mov     eax, [esp]        ; argc
    lea     ebx, [esp+4]      ; argv pointer = &argv[0]

    add     ebx, 4			  ; move to argv[1] (skip program name arg)
    dec     eax               ; argc--

; Checks the first argumet after program name to see if it's a flag.
check_flag:
    cmp     eax, 0			  ; check if there are any arugments
    jz      no_valid_flags	  ; if no args are provided

    ; load current argument pointer:
    ; ebx points to argv array, so [ebx] = argv[i]
    mov     esi, [ebx]
    cmp     esi, 0
    jz      no_valid_flags

    ; compare current argument with the "--create" flag
    push    flag_create
    push    esi
    call    strcmp
    add     esp, 8
    test    eax, eax
    jz      handle_create

    ; compare current argument with the "--delete" flag
    push    flag_delete
    push    esi
    call    strcmp
    add     esp, 8
    test    eax, eax
    jz      handle_delete

    ; compare current argument with the "--help" flag
    push    flag_help
    push    esi
    call    strcmp
    add     esp, 8
    test    eax, eax
    jz      handle_help

    ; if we reach this point the argument did not match any known flag.
	jmp 	no_valid_flags

; Error handling
no_valid_flags:
	mov		eax, err_no_flag
	call	sprintLF
	jmp 	show_usage

wrong_arg_count:
	mov		eax, err_wrong_args
	call	sprintLF
	jmp		show_usage

; flag handlers
file_exists:
    push    ebp                 ; save old base pointer on the stack
    mov     ebp, esp            ; set current stack pointer as new base pointer

    mov     ebx, [ebp+8]        ; go to the memory location (ebp+8) and fetch the filename pointer argument
    mov     eax, 5              ; load syscall number 5 (sys_open) into eax
    mov     ecx, 0              ; use flags = 0 → open file in read-only mode
    mov     edx, 0              ; no mode bits needed because read-only never creates a file
    int     80h                 ; ask the kernel to open the file

    cmp     eax, 0              ; compare return value with zero
    jl      .does_not_exist     ; if eax < 0, the open failed → file does not exist

    mov     ebx, eax            ; file opened successfully, move file descriptor into ebx
    mov     eax, 6              ; syscall number 6 → sys_close
    int     80h                 ; close the file descriptor

    mov     eax, 1              ; return value 1 → file exists
    jmp     .done               ; skip the non-existent case

.does_not_exist:
    mov     eax, 0              ; return value 0 → file does not exist

.done:
    mov     esp, ebp            ; restore old stack pointer
    pop     ebp                 ; restore old base pointer
    ret                         ; return to caller

handle_create:
    mov     edx, [esp]          ; fetch argc (still sitting at [esp] because jump didn't push anything)
    cmp     edx, 3              ; check if argc == 3 → program, flag, filename
    jne     wrong_arg_count     ; if not 3, reject the input

    mov     esi, [ebx+4]        ; go to next argv slot and fetch filename pointer → argv[2]

    push    esi                 ; push filename pointer to pass it as argument to file_exists
    call    file_exists         ; call our existence-checking function
    add     esp, 4              ; clean one argument (4 bytes) from the stack

    cmp     eax, 1              ; compare return value: is file already there?
    ; NOTE: you forgot a jump here (example: je file_already_exists)
    ; but I'll leave your flow unchanged

    mov     eax, 8              ; syscall number 8 = sys_creat on 32-bit Linux
    mov     ebx, esi            ; ebx = pointer to filename string
    mov     ecx, 0777o          ; set file permissions (octal 0777)
    int     80h                 ; ask kernel to create the file

    jmp     quit                ; leave the program

handle_delete:
	mov 	edx, [esp]
	cmp		edx, 3
	jne		wrong_arg_count

	; TODO: implement deleting file here
	jmp		quit

handle_help:
	jmp		show_usage

; print how to use the program
show_usage:
	mov		eax, usage_msg
	call	sprintLF
	jmp		quit
