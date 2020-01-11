;Write 8087ALP to obtain: i) Mean ii) Variance  iii) Standard Deviation  
;for a given set of data elements defined in data segment. Also display result.	
;---------------------------------------------------------------------------------------
section .data
	nline		db	10,10
	nline_len:	equ	$-nline
     
	msg 		db 	10,"MIL assignment 13 : 8087 program for mean, SD, & Variance"
			db	10,"---------------------------------------------",10
	msg_len:	equ 	$-msg
    	
	mmsg 	db 	10,"CALCULATED MEAN 		: "
    	mmsg_len 	equ 	$-mmsg
    
    	sdmsg 	db 	10,"CALCULATED STANDARD DEVIATION	: "
    	sdmsg_len 	equ 	$-sdmsg
    
    	vmsg 	db 	10,"CALCULATED VARIANCE 		: "
    	vmsg_len 	equ 	$-vmsg
     
   
    	array 	dd 	102.56, 198.21, 100.67, 230.78, 67.93
    	count		dw 	05

    	dpoint	db 	'.'
    	hdec 	dq 	100
;--------------------------------------------------------------- 
section .bss
	char_ans 	resB 2
    	resbuff 	resT 1

	mean 		resD 1
	variance 	resD 1
;--------------------------------------------------------------- 
;macros as per 64-bit convensions

%macro  	print   2
	mov 	rax,1		; Function 1 - write
  	mov 	rdi,1		; To stdout
   	mov 	rsi,%1	       ; String address
   	mov 	rdx,%2	       ; String size
   	syscall		; invoke operating system to WRITE
%endmacro

%macro  read   2
	mov 	rax,0		; Function 0 - Read
  	mov 	rdi,0		; from stdin
   	mov 	rsi,%1	       ; buffer address
   	mov 	rdx,%2	       ; buffer size
   	syscall		; invoke operating system to READ
%endmacro

%macro	exit	0
	print	nline, nline_len
	mov 	rax, 60	; system call 60 is exit
	xor 	rdi, rdi 	; we want return code 0
	syscall 		; invoke operating system to exit
%endmacro
;--------------------------------------------------------------- 

section .text
   global _start
_start:

	print	msg, msg_len

	finit			       		; initialize coprocessor
	fldz			       			; loads zero on top of stack st(0)=0

	mov 	rbx,array
	mov 	rsi,00		       		; index of array initalized to 0
	xor 	rcx,rcx	
	mov 	cx,[count]	       		; load count in cx reg

back:	fadd 	dword[RBX+RSI*4]	; st(0)+[array+(index*4)]=st(0)
								; each element in array is of type Double word = 4 bytes
	inc 	rsi						; increment array index
	loop 	back					; repeat addition untill all elements are added

	fidiv	word[count]		; st(0)=sum of array elements / count = mean
	fst 	dword[mean]		; store the st(0) in mean

	print  mmsg,mmsg_len	
	call 	display_result

	mov 	rbx,array
	mov 	rsi,00		       ; index of array initalized to 0
	xor 	rcx,rcx	
	mov 	cx,[count]		; load count in cx reg

	fldz				; loads zero on top of stack st(0)=0
back1:fldz
	FLD 	DWORD[RBX+RSI*4]     ;st(0)=array[rsi]
	FSUB 	DWORD[mean]          ;st(0)=st(0)-mean
	FST 	ST1
	FMUL                        ;st(0)=st(0)*st(1)                 
	FADD                        ;add squared value to st(1) i.e. st(0)=st(0)+st(1)
	INC 	RSI
	LOOP 	back1

	FIDIV	word[count]          ;divide result by count to get variance
	FST 	dWORD[variance]
	FSQRT                       ;st(0)=sqrt(st(0))= value of standard deviation

	print  sdmsg,sdmsg_len
	CALL 	display_result

	FLD 	dWORD[variance]
	print vmsg,vmsg_len
	CALL 	display_result
	
	exit
;--------------------------------------------------------------- 
display_8:
	mov 	rsi,char_ans+1	
	mov 	rcx,2		; number of digits 

cnt:	mov 	rdx,0		
	mov 	rbx,16	
	div 	rbx
	cmp 	dl, 09h	; check for remainder in RDX
	jbe  	add30
	add  	dl, 07h 
add30:
	add 	dl,30h	; calculate ASCII code
	mov 	[rsi],dl	; store it in buffer
	dec 	rsi		; point to one byte back

	dec 	rcx		; decrement count
	jnz 	cnt		
	
	print char_ans,2	; display result on screen
	ret
;--------------------------------------------------------------- 
display_result:

	fimul	dword[hdec]
	fbstp	tword[resbuff]
	xor 	rcx,rcx
	mov 	rcx,09H
	mov 	rsi,resbuff+9

nextdigit:	
	push 	rcx
	push 	rsi

	xor	rax,rax
	mov 	al,[rsi]
	call 	display_8

	pop 	rsi
	dec 	rsi
	pop 	rcx
	loop 	nextdigit

	print dpoint,1

	xor	rax,rax
	mov al,[resbuff]
	call display_8

	ret
;--------------------------------------------------------------- 
