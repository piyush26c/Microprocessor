
section .data
        nline 		db	10,10
	nline_len	equ	$-nline

	ano		db	10,"	Assignment no	:1",
			db	10,"------------------------------------------------------------",
			db      10,"	Assignment Name:Multiplication of 16 bit number.",
			db	10,"		(using Succesive Addition and Shift and Add method)",
			db      10,"----------------------------------------------------------",10
	ano_len		equ	$-ano

	menu		db	10,"1.Multiplication By Successive Addition .",
			db	10,"2.Multiplication By Shift and Add method.",
			db	10,"3.Exit.",
			db	10,"Enter Your Choice::"
	menu_len	equ	$-menu

	n1msg		db	10,"Enter First Number(XXXX)::"
	n1msg_len	equ	$-n1msg

	n2msg		db	10,"Enter Second Number(XXXX)::"
	n2msg_len	equ	$-n2msg

	samsg		db	10,"Multiplication By Successive Addition::"
	samsg_len	equ	$-samsg

	shmsg		db	10,"Multiplication By Shift and Add method::"
	shmsg_len	equ	$-shmsg

	emsg		db	10,"INVALID NUMBER INPUT",10
	emsg_len	equ	$-emsg
;------------------------------------------------------------------------------
section .bss
	buf	resB	5
	buf_len	equ	$-buf

	n1	resW	1
	n2	resW	1

	ansl	resW	1
	ansh	resW	1
	
	ans	resD	1	

	char_ans resB	4
	
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

Menu:	Print 	menu,menu_len
	Read	buf,buf_len
	mov	al,[buf]
	
	
c1:	cmp	al,'1'
	jne	c2
	call	SA
	jmp	Menu

c2:	cmp	al,'2'
	jne	c3
	call	AD_SH
	jmp	Menu

c3:	cmp	al,'3'
	jne	invalid
	Exit

invalid:Print	emsg,emsg_len
	jmp	Menu
;-----------------------------------------------------------
SA:	
	mov	word[ansh],00	;for next time use
	mov	word[ansl],00

	Print	n1msg,n1msg_len
	call	Accept_16
	mov	[n1],bx
	
	Print	n2msg,n2msg_len
	call	Accept_16
	mov	[n2],bx
	
	mov	ax,[n1]
	mov	cx,[n2]

	cmp	cx,0		;if cx is 0 then multiplication is 0
	je	final	

back:	add	[ansl],ax	;add n1 to ansl
	jnc	next		;if not carry
	inc	word[ansh]
next:	dec	cx		
	jnz	back		;jmp for next time addition

final:
	Print 	samsg,samsg_len
	mov	ax,[ansh]
	call	Disp_16
	
	mov	ax,[ansl]
	call	Disp_16

RET
;-----------------------------------------------------------	
AD_SH:
	

	mov	dword[ans],00               ;dword bcz multiplication of two 16 bit no may be 32 bit
	
	Print	n1msg,n1msg_len
	call	Accept_16
	mov	[n1],bx

	Print	n2msg,n2msg_len
	call	Accept_16                 
	mov	[n2],bx

	XOR 	rax,rax                     ;clear registers- it will take as per requirement
	xor	rbx,rbx

	mov	ax,[n1]                     ;take no 1 in ax
	mov	bx,[n2]	                    ;take no 2 ib bx
	mov	cx,16                       ;initialize counter to 16

	mov	ebp,0                       ;initially take ans as 0

back1:
	shl	ebp,1                       ;multiply ans by 2
	shl	ax,1			    ;mov msb to carry flag
	jnc	next1
	add	ebp,ebx			    ;add answer with 2nd number
	
next1:
	
	loop	back1

	mov	[ans],ebp                  ;move the answer in ebp into "ans" variable
	Print	shmsg,shmsg_len
	mov	eax,[ans]
	call	Disp_32




	
RET			


;---------------------------------------------------------------
Disp_16:
	MOV	RSI,char_ans+3
	MOV	RCX,4           ;counter
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

	Print	char_ans,4
ret
;-------------------------------------------------------------------
Disp_32:
	MOV	RSI,char_ans+7
	MOV	RCX,8           ;counter
	MOV	RBX,16		;Hex no

next_digit1:
	XOR	RDX,RDX
	DIV	RBX

	CMP	DL,9	
	JBE	add301
	ADD	DL,07H

add301	:
	ADD	DL,30H
	MOV	[RSI],DL

	DEC	RSI
	DEC	RCX
	JNZ	next_digit1

	Print	char_ans,8
ret
;-------------------------------------------------------------------
Accept_16:
	Read	buf,buf_len

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
	jmp	Menu

sub57:	SUB	AL,20H
sub37:	SUB	AL,07H
sub30:	SUB	AL,30H
	
	ADD 	BX,AX

	INC	RSI
	DEC	RCX
	JNZ	next_byte
		
ret
;-----------------------------------------------------------------------------------------

