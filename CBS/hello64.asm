;Assignment No.	: 1b
;Assignment Name	: Write an ALP to Display "Hello World" using 64-bit programming
;-----------------------------------------------------------------
section .data
	ano		db	10,"	Assignment No.	: 1B",10
	ano_len	equ	$-ano

	msg 		db 	10,"	Hello world using 64-bit programming!!!",10,10 	; linefeed character
	msg_len: 	equ 	$-msg		; Length of the 'Hello world!' string

;-----------------------------------------------------------------
section .text
	Global _start

_start:

	MOV RAX, 1		; system call 1 is write
	MOV RDI, 1		; file handle 1 is STDOUT
	MOV RSI, ano		; "	Assignment No.	: 1B"
	MOV RDX, ano_len	; number of bytes
	syscall			; invoke operating system to do the write

	MOV RAX, 1		; system call 1 is write
	MOV RDI, 1		; file handle 1 is STDOUT
	MOV RSI, msg		; address of string to output
	MOV RDX, msg_len	; number of bytes
	syscall			; invoke operating system to do the write

; exit(0)
	MOV RAX, 60		; system call 60 is exit
	MOV RDI, 00 		; we want return code 0
	syscall 			; invoke operating system to exit
