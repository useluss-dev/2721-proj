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
    push    ebp
    mov     ebp, esp

    mov     ebx, [ebp+8]
    mov     eax, 5
    mov     ecx, 0
    mov     edx, 0
    int     80h

    cmp     eax, 0
    jl      .does_not_exist

    mov     ebx, eax
    mov     eax, 6
    int     80h

    mov     eax, 1
    jmp     .done

.does_not_exist:
    mov     eax, 0

.done:
    mov     esp,ebp
    pop     ebp
    ret 

handle_create:
	mov		edx, [esp]
	cmp		edx, 3	
	jne 	wrong_arg_count

    mov     esi, [ebx+4] ;filename = argv[2]

    push    esi
    call    file_exists
    add     esp,4

    cmp     eax, 1
    mov     eax, 8
    mov     ebx, esi
    mov     ecx, 0777o
    int     80h

	jmp		quit

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
