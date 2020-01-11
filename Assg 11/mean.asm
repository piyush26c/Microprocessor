section .data
numbers 	db "The numbers are:102.59,198.21,100.67,230.78,67.93",10
		len equ $-numbers

meanmsg 	db 10,"CALCULATED MEAN IS:-"
		meanmsg_len equ $-meanmsg

sdmsg 	db 10,"CALCULATED STANDARD DEVIATION IS:-"
		sdmsg_len equ $-sdmsg

varmsg 	db 10,"CALCULATED VARIANCE IS:-"       
		varmsg_len equ $-varmsg

array 	dd 102.56,198.21,100.67,230.78,67.93
arraycnt 	dw 05
dpoint 	db '.'
hdec 	dq 100
;===================================================================
section .bss

dispbuff 	resb 1
resbuff 	rest 1
mean 		resd 1
variance 	resd 1
;====================================================================
%macro print 2
mov rax,1
mov rdi,1
mov rsi,%1
mov rdx,%2
syscall
%endmacro   

;==================================================================
section .text
global _start
_start:

print numbers,len
finit
fldz
mov 	rbx,array
mov 	rsi,00
xor 	rcx,rcx
mov 	cx,[arraycnt]
;=============================================================
up:

fadd dword[RBX+RSI*4]
inc rsi
loop up

fidiv word[arraycnt]
fst dword[mean]
print meanmsg,meanmsg_len
call dispres

mov rcx,00
mov cx,[arraycnt]
mov rbx,array
mov rsi,00
FLDZ
;==================================================================
up1:

FLDZ
FLD dword[RBX+RSI*4]
FSUB dword[mean]
FST ST1
FMUL
FADD
inc rsi
loop up1

FIDIV word[arraycnt]
FST dword[variance]
FSQRT
print sdmsg,sdmsg_len
CALL dispres

FLD dword[variance]
print varmsg,varmsg_len
CALL dispres

exit: 
mov rax,60
mov rdi,0
syscall

;=========================================================
disp8_proc:

mov rdi,dispbuff
mov rcx,02
;=====================================================
back:

rol bl,04
mov dl,bl
and dl,0FH
cmp dl,09
jbe next1
add dl,07H
;=============================
next1:  

add dl,30H
mov [rdi],dl
inc rdi
loop back
ret
;================================
dispres:
	fimul dword[hdec]
	fbstp tword[resbuff]
	xor rcx,rcx
	mov rcx,09H
	mov rsi,resbuff+9
;==================================
up2:

push rcx
push rsi
mov bl,[rsi]
call disp8_proc

print dispbuff,2
pop rsi
dec rsi
pop rcx
loop up2

print dpoint,1
mov bl,[resbuff]
call disp8_proc
print dispbuff,2
ret
