;Asg no. 	:	8
;Asg Name	: 	Write X86 menu driven Assembly Language Program (ALP) 
;			to implement OS (DOS) commands TYPE, COPY and DELETE 
;			using file operations. 
;---------------------------------------------------------
%include	"macro.asm"
;---------------------------------------------------------
section .data
	nline		db	10
	nline_len	equ	$-nline

	ano		db 	10,"ML-08 :- FILE : TYPE, COPY & DELETE"
			db	10,"---------------------------------------------------",10
	ano_len		equ	$-ano

	menu		db	10,"	1. Type 	: "
			db	10,"	2. Copy 	: "
			db	10,"	3. Delete 	: "
			db	10,"Enter your choice 	: "
	menu_len 	equ $-menu

	f1msg		db	10,"Enter filename : "
	f1msg_len	equ	$-f1msg

	f2msg		db	10,"Enter new filename : "
	f2msg_len	equ	$-f2msg		

	tmsg		db	10,"-----------File TYPED successfully...--------",10,10
	tmsg_len	equ	$-tmsg

	cmsg		db	10,"-----------File COPIED successfully...--------",10,10
	cmsg_len	equ	$-cmsg

	dmsg		db	10,"-----------File DELETED successfully...--------",10,10
	dmsg_len	equ	$-dmsg

	ecmsg		db	10,"Enter new filename : "
	ecmsg_len	equ	$-ecmsg

	ermsg		db	10,10,"Error in file operation!!!",10,10
	ermsg_len	equ	$-ermsg

	exmsg		db	10,10,"Exit from program...",10,10
	exmsg_len	equ	$-exmsg
	
;---------------------------------------------------------
section .bss
	char		resb	2	
	SIZE		equ	10

	buf		resb	SIZE
	buf_len	equ	$-buf		; buffer initial length

	fname1	resb	50	
	fname2	resb	50	

	fh1		resq	1
	fh2		resq	1

	abuf_len	resq	1
	char_ans	resb	16
;---------------------------------------------------------
section .text
	global _start
	
_start:
	Print	ano,ano_len	

MENU:	Print	menu,menu_len
	Read 	char,2
	mov 	al,[char]
	sub	al,30h

C1:	cmp	al,1
	jne	C2
	call 	TYPE_CMD
	jmp 	MENU

C2:	cmp	al,2
	jne	C3
	call 	COPY_CMD
	jmp 	MENU

C3: 	cmp	al,3
	jne	C4
	call 	DEL_CMD
	jmp 	MENU

C4:	Print	exmsg,exmsg_len
	Exit	
;---------------------------------------------------------

TYPE_CMD:	

					; Accept Filename
	Print	f1msg,f1msg_len	
	Read 	fname1,50
	dec	rax
	mov	byte[fname1 + rax],0	; blank char/null char

					; Open File
	Fopen	fname1			; on succes returns handle in rax
	cmp	rax,-1H			; on failure returns -1
	js	ferr
	mov	[fh1],rax	

					; Read file
back:	Fread	[fh1],buf, buf_len	
	mov	[abuf_len],rax

	Print	buf, [abuf_len]	
	cmp	rax,SIZE		; is file lengthy???
	je	back			; more contents availble in file

	Fclose	[fh1]

	Print 	tmsg,tmsg_len

	ret

ferr:	Print 	ermsg,ermsg_len
	ret

;---------------------------------------------------------
COPY_CMD:	

					; Accept Filename1
	Print	f1msg,f1msg_len	
	Read 	fname1,50
	dec	rax
	mov	byte[fname1 + rax],0	; blank char/null char

					; Open File
	Fopen	fname1			; on succes returns handle in rax
	cmp	rax,-1H			; on failure returns -1
	js	ferr1
	mov	[fh1],rax	

					; Accept Filename2
	Print	f2msg,f2msg_len	
	Read 	fname2,50
	dec	rax
	mov	byte[fname2 + rax],0	; blank char/null char

					; Create  File
	Fcreate	fname2			; on succes returns handle in rax
	cmp	rax,-1H			; on failure returns -1
	js	ferr2
	mov	[fh2],rax	
					; Read file
back1:	Fread	[fh1],buf, buf_len	
	mov	[abuf_len],rax

	Fwrite	[fh2],buf, [abuf_len]	
	cmp	rax,SIZE		; is file lengthy???
	JE	back1			; more contents availble in file

	Fclose	[fh1]
	Fclose	[fh2]

	Print 	cmsg,cmsg_len

	ret

ferr2:	Fclose	[fh1]
ferr1:	Print 	ermsg,ermsg_len
	ret

;---------------------------------------------------------
DEL_CMD:	

					; Accept Filename1
	Print	f1msg,f1msg_len	
	Read 	fname1,50
	dec	rax
	mov	byte[fname1 + rax],0	; blank char/null char

	Fdelete	fname1

	cmp	rax,0
	JNE	ferr3

	Print 	dmsg,dmsg_len
	ret

ferr3:	Print 	ermsg,ermsg_len
	ret

;---------------------------------------------------------
