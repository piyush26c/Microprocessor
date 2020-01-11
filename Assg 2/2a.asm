
section .data
        nline 		db	10,10
	nline_len	equ	$-nline

	space		db	" "

	ano		db	10,"	Assignment no	:2-A",
			db	10,"-------------------------------------------------------------------",
			db      10,"	Block Transfer-Non overlapped without String instruction.",
			db      10,"-------------------------------------------------------------------",10
	ano_len		equ	$-ano

	bmsg		db	10,"Before Transfer::"
	bmsg_len	equ	$-bmsg

	amsg		db	10,"After Transfer::"
	amsg_len	equ	$-amsg
	
	smsg		db	10,"	Source Block		:"
	smsg_len	equ	$-smsg

	dmsg		db	10,"	Destination Block	:"
	dmsg_len	equ	$-dmsg

	sblock		db	11h,22h,33h,44h,55h
	dblock		times	5	db	0
	
;------------------------------------------------------------------------------
section .bss
	char_ans resB	2	;char_ans is of 2 byte because we have 2 byte nos
	
;-----------------------------------------------------------------------------

%macro	Print	2
	 MOV	RAX,1
	 MOV	RDI,1
         MOV	RSI,%1
         MOV	RDX,%2
    syscall
%endmacro

%macro	Read	2
	 MOV	RAX,0
	 MOV	RDI,0
         MOV	RSI,%1
         MOV	RDX,%2
    syscall
%endmacro


%macro Exit 0
	Print	nline,nline_len
	MOV	RAX,60
        MOV	RDI,0
    syscall
%endmacro
;---------------------------------------------------------------       

section .text
	global _start

_start:
       	Print	ano,ano_len

	Print	bmsg,bmsg_len	;Block values before transfer

	Print 	smsg,smsg_len
	mov	rsi,sblock	;As rsi is used to point source as well as destination block
	call	disp_block	;assign source and destination block separately before call

	Print	dmsg,dmsg_len
	mov	rsi,dblock
	call	disp_block
	
	call	BT_NO		;call for actual block transfer

	Print	amsg,amsg_len	;Block values after transfer 

	Print 	smsg,smsg_len
	mov	rsi,sblock
	call	disp_block

	Print	dmsg,dmsg_len
	mov	rsi,dblock
	call	disp_block

Exit
;-----------------------------------------------------------------
BT_NO:
	mov	rsi,sblock
	mov	rdi,dblock
	mov	rcx,5

back:	mov	al,[rsi]	;moves 1 value from rsi to rdi 
	mov	[rdi],al	;(memory-memory transfer is not allowed)

	inc	rsi
	inc	rdi

	dec	rcx
	jnz	back
RET
;-----------------------------------------------------------------
disp_block:
	mov	rbp,5		;counter as 5 values

next_num:
	mov	al,[rsi]	;moves 1 value to rsi
	push	rsi		;push rsi on stack as it get modified in Disp_8

	call	Disp_8
	Print	space,1
	
	pop	rsi		;again pop rsi that pushed on stack
	inc	rsi
	
	dec	rbp
	jnz	next_num
RET
;---------------------------------------------------------------
Disp_8:
	MOV	RSI,char_ans+1
	MOV	RCX,2           ;counter
	MOV	RBX,16		;Hex no

next_digit:
	XOR	RDX,RDX
	DIV	RBX

	CMP	DL,9	
	JBE	add30
	ADD	DL,07H

add30	:
	ADD	DL,30H
	MOV	[RSI],DL

	DEC	RSI
	DEC	RCX
	JNZ	next_digit

	Print	char_ans,2
ret
;-------------------------------------------------------------------

