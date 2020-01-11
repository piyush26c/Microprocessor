
section .data
        nline 		db	10,10
	nline_len	equ	$-nline

	space		db	" "

	ano		db	10,"	Assignment no	:2-C",
			db	10,"-------------------------------------------------------------------",
			db      10,"	Block Transfer- Overlapped without String instruction.",
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
	char_ans resB	2
	
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

	Print	bmsg,bmsg_len

	Print 	smsg,smsg_len
	mov	rsi,sblock
	call	disp_block

	Print	dmsg,dmsg_len
	mov	rsi,dblock-2	;dblock start at 4th position of sblock(overlapped)
	call	disp_block
	
	call	BT_O

	Print	amsg,amsg_len

	Print 	smsg,smsg_len
	mov	rsi,sblock
	call	disp_block

	Print	dmsg,dmsg_len
	mov	rsi,dblock-2
	call	disp_block

Exit
;-----------------------------------------------------------------
BT_O:
	mov	rsi,sblock+4	;rsi point at the end of sblock 0+4=4
	mov	rdi,dblock+2	;rdi point at th eend of dblock -2+4=2
	mov	rcx,5

back:	mov	al,[rsi]
	mov	[rdi],al

	dec	rsi
	dec	rdi

	dec	rcx
	jnz	back
RET
;-----------------------------------------------------------------
disp_block:
	mov	rbp,5

next_num:
	mov	al,[rsi]
	push	rsi

	call	Disp_8
	Print	space,1
	
	pop	rsi
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

