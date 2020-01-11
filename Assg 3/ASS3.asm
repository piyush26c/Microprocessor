
section .data
        nline 		db	10,10
	nline_len	equ	$-nline

	ano		db	10,"	Assignment no	:3",
			db	10,"------------------------------------------------------------",
			db      10,"	Assignment Name:Conversion From HEX to BCD and BCD to HEX Number.",
			db      10,"----------------------------------------------------------",10
	ano_len		equ	$-ano

	menu		db	10,"1.Hex To BCD.",
			db	10,"2.BCD To Hex.",
			db	10,"3.Exit."
			db	10,"Enter Your Choice::"
	menu_len	equ	$-menu

	hmsg		db	10,"Enter 4 digit Hex Number::"
	hmsg_len	equ	$-hmsg

	bmsg		db	10,"Enter 5 digit BCD Number::"
	bmsg_len	equ	$-bmsg

	ebmsg		db	10,"The Equivalent BCD Number is::"
	ebmsg_len	equ	$-ebmsg

	ehmsg		db	10,"The Equivalent Hex Number is::"
	ehmsg_len	equ	$-ehmsg

	emsg		db	10,"INVALID NUMBER INPUT",10
	emsg_len	equ	$-emsg
;------------------------------------------------------------------------------
section .bss
	buf		resB	6
	char_ans 	resB	4
	ans		resW	1
	
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
	
MENU:	Print	menu,menu_len
	Read	buf,2		;accept choice i.e 1 digit+enter

	mov	al,[buf]	;contains only digit character

c1:	cmp	al,'1'
	jne	c2
	call	HEX_BCD
	jmp	MENU

c2:	cmp	al,'2'
	jne	c3
	call	BCD_HEX
	jmp	MENU

c3:	cmp	al,'3'
	jne	invalid
	Exit

invalid:
	Print	emsg,emsg_len
	jmp	MENU
;---------------------------------------------------------------

HEX_BCD:
	Print	hmsg,hmsg_len
	call	Accept_16		;accept 4 digit hex number
	mov	ax,bx			;mov hex number in ax

	mov	bx,10			;for divide hex number by 10
	xor	bp,bp			;counter
	
back:	xor	dx,dx			;as dx each time contains remainder
	div	bx			;divide ax by 10 ax=Q,dx=R
	push	dx			;push dx on stack as it is bcd
	inc	bp			;inc counter by 1
	
	cmp	ax,0			;compare whether Q is 0 if 0 means number get over
	jne	back			;mov to conversion of quotient

	Print	ebmsg,ebmsg_len

back1:	pop	dx			;pop last digit pushed on stack
	add	dl,30h			;add 30 to digit to make them decimal
	mov	[char_ans],dl		;print individual digit
	Print	char_ans,1

	dec	bp	
	jnz	back1			;mov to next digit

RET
;---------------------------------------------------------------

BCD_HEX:
	Print	bmsg,bmsg_len
	Read	buf,6		;5 digit + 1 enter

	mov	rsi,buf		;Points at the start of buffer 
	xor	ax,ax		;Previous digit =0
	mov	rbp,5		;counter
	mov	rbx,10		;multiplier
	
next:	xor	cx,cx		;contains next digit each time
	mul	bx		;(ax*bx)+cl
	mov	cl,[rsi]
	sub	cl,30h
	add	ax,cx

	inc	rsi		;Point at the next digit
	dec	rbp
	jnz	next

	mov	[ans],ax	;store ax in ans because ax get change in Print macro
	Print	ehmsg,ehmsg_len
	
	mov	ax,[ans]
	call	Disp_16		;Print hex number	
	
	
	
RET
;---------------------------------------------------------------
Disp_16:				;Hex to Ascii(character) display
	MOV	RSI,char_ans+3
	MOV	RCX,4           	;counter
	MOV	RBX,16			;Hex no

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

	Print	char_ans,4
ret
;-------------------------------------------------------------------
Accept_16:				;Ascii(character) to hex number input
	Read	buf,5

	MOV	RCX,4
	MOV	RSI,buf
	XOR	BX,BX

next_byte:
	SHL	BX,4
	MOV	AL,[RSI]
	
	CMP	AL,'0'
	JB	error
	CMP	AL,'9'
	JBE	sub30

	CMP	AL,'A'
	JB	error
	CMP	AL,'F'
	JBE	sub37
	
	CMP	AL,'a'
	JB	error
	CMP	AL,'f'
	JBE	sub57

error:
	Print 	emsg,emsg_len
	Exit

sub57:	SUB	AL,20H
sub37:	SUB	AL,07H
sub30:	SUB	AL,30H
	
	ADD 	BX,AX

	INC	RSI
	DEC	RCX
	JNZ	next_byte
		
RET
;-------------------------------------------------------------------------------------

