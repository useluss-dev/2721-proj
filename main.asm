%include	'functions.asm'		; include our functions file

SECTION .data
flag_create	db "--create", 0
flag_delete db "--delete", 0
flag_help	db "--help", 0

err_file_exists db "Specified file already exisits", 0
err_file_doesnt_exist db "No file with that name exists", 0
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
    push    flag_create		  ; put known flag on the stack
    push    esi				  ; put user inputed flag on the stack
    call    strcmp			  ; compare them
    add     esp, 8			  ; clean stack frame of the previously pushed strings
    test    eax, eax		  ; bitwise AND itself checks that strcmp returned 0 
    jz      handle_create

    ; compare current argument with the "--delete" flag
    push    flag_delete		  ; put known flag on the stack
    push    esi				  ; put user inputed flag on the stack
    call    strcmp			  ; compare them
    add     esp, 8			  ; clean stack frame of the previously pushed strings
    test    eax, eax		  ; bitwise AND itself checks that strcmp returned 0 
    jz      handle_delete

    ; compare current argument with the "--help" flag
    push    flag_help		  ; put known flag on the stack
    push    esi				  ; put user inputed flag on the stack
    call    strcmp			  ; compare them
    add     esp, 8			  ; clean stack frame of the previously pushed strings
    test    eax, eax          ; bitwise AND itself checks that strcmp returned 0
    jz      handle_help

    ; if we reach this point the argument did not match any known flag.
	jmp 	no_valid_flags

; flag handlers
handle_create:
    mov     edx, [esp]          ; fetch argc (still sitting at [esp] because jump didn't push anything)
    cmp     edx, 3              ; check if argc == 3 → program, flag, filename
    jne     wrong_arg_count     ; if not 3, reject the input

    mov     esi, [ebx+4]        ; go to next argv slot and fetch filename pointer → argv[2]

    push    esi                 ; push filename pointer to pass it as argument to file_exists
    call    file_exists         ; call our existence-checking function
    add     esp, 4              ; clean one argument (4 bytes) from the stack

    cmp     eax, 1              ; compare return value: is file already there?
	je		file_already_exists

    mov     eax, 8              ; syscall number 8 = sys_creat on 32-bit Linux
    mov     ebx, esi            ; ebx = pointer to filename string
    mov     ecx, 0777o          ; set file permissions (octal 0777)
    int     80h                 ; ask kernel to create the file

    call 	quit                ; leave the program

handle_delete:
	mov 	edx, [esp]          ; get how many arguments the user typed
	cmp		edx, 3              ; requires 3 arguments: program, flag, filename
	jne		wrong_arg_count     ; if not 3, jump to error handler

	mov     esi, [ebx+4]        ; get the filename user typed (argv[2])

    push    esi                 ; give the filename to file_exists
    call    file_exists         ; check if the file exists
    add     esp, 4              ; clean up the pushed argument from the stack

    cmp     eax, 1              ; did file_exists return 1 (file found)?
    jne     file_doesnt_exist   ; if file doesnt exist, show error and exit

    mov     eax, 10             ; choose the delete-file syscall(sys_unlink)
    mov     ebx, esi            ; give the syscall the filename to delete
    int     80h                 ; ask kernel to delete file

	call	quit                ; exit program successfully

handle_help:
	jmp		show_usage

; print how to use the program
show_usage:
	mov		eax, usage_msg
	call	sprintLF
	call	quit

; Error handling
no_valid_flags:
	mov		eax, err_no_flag
	call	sprintLF
	jmp 	show_usage

wrong_arg_count:
	mov		eax, err_wrong_args
	call	sprintLF
	jmp		show_usage

file_already_exists:
	mov 	eax, err_file_exists
	call	sprintLF
	call	quit

file_doesnt_exist:
	mov 	eax, err_file_doesnt_exist
	call	sprintLF
	call	quit
