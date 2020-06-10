;Assignment No.	: 7
;Assignment Name	: Write an ALP to find no. of positive / negative elements from 64-bit array 
;-------------------------------------------------------------------
section    .data
	nline	db	10,10
	nline_len	equ	$-nline

	ano		db	10,"	Assignment No.	: 7",10
			db	"Positive / Negative elements from 64-bit array", 10 
	ano_len	equ	$-ano
	
	arr64	dq	-11111111H, 22222222H, -33333333H, 44444444H, 55555555H
	n		equ	5

	pmsg		db	10,10,"The no. of Positive elements from 64-bit array :	"
	pmsg_len	equ	$-pmsg

	nmsg		db	10,10,"The no. of Negative elements from 64-bit array :	"
	nmsg_len	equ	$-nmsg

;---------------------------------------------------------------------
Section   .bss
	p_count	resq	1		
	n_count	resq	1	

	char_ans	resb	16
;---------------------------------------------------------------------
%macro  Print   2
	mov   rax, 1
	mov   rdi, 1
	mov   rsi, %1
	mov   rdx, %2
	syscall
%endmacro

%macro  Read   2
	mov   rax, 0
	mov   rdi, 0
	mov   rsi, %1
	mov   rdx, %2
	syscall
%endmacro

%macro	Exit	0
	mov  rax, 60
	mov  rdi, 0
	syscall
%endmacro

;---------------------------------------------------------------------
section    .text
	global   _start
_start:
	Print	ano, ano_len

	mov		rsi, arr64	
	mov		rcx, n

	mov		rbx,0;		; counter for 	+ve nos.
	mov		rdx,0;		; counter for	-ve nos.

next_num:
	mov		rax,[rsi]	; take no. in RAX
	Rol		rax,1		; rotate left 1 bit to check for sign bit 
	jc		negative

positive:
	inc		rbx		; no carry, so no. is +ve
	jmp		next

negative:
	inc		rdx		; carry, so no. is -ve

next:
	add 		rsi,8		; 64 bit nos i.e. 8 bytes
	dec 		rcx
	jnz  	next_num

	mov		[p_count], rbx		; store positive count
	mov		[n_count], rdx		; store negative count

	Print	pmsg, pmsg_len
	mov 		rax,[p_count]		; load value of p_count in rax
	call 	disp64_proc		        ; display p_count

	Print	nmsg, nmsg_len
	mov 		rax,[n_count]		; load value of n_count in rax
	call 	disp64_proc		        ; display n_count

	Print	nline, nline_len
	Exit
;--------------------------------------------------------------------	
disp64_proc:
	mov 		rbx,16			; divisor=16 for hex
	mov 		rcx,2			; number of digits 
	mov 		rsi,char_ans+1		; load last byte address of char_ans buffer in rsi

cnt:	mov 		rdx,0			; make rdx=0 (as in div instruction rdx:rax/rbx)
	div 		rbx

	cmp 		dl, 09h			; check for remainder in rdx
	jbe  	add30
	add  	dl, 07h 
add30:
	add 		dl,30h			; calculate ASCII code
	mov 		[rsi],dl		; store it in buffer
	dec 		rsi			; point to one byte back

	dec 		rcx			; decrement count
	jnz 		cnt			; if not zero repeat
	
	Print 	char_ans,2		        ; display result on screen
ret
;----------------------------------------------------------------
