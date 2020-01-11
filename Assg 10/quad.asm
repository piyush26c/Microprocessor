section .data

msg1 db 10,"Roots are Complex",10
msglen1 equ $-msg1

msg2 db 10,"Root1: "
msglen2 equ $-msg2

msg3 db 10,"Root2: "
msglen3 equ $-msg3

a dd 5.00
b dd 3.00
c dd 3.00

four dd 4.00
two dd 2.00

hdec dq 100
dpoint db "."
;--------------------------------------------------------------- 	
section .bss
	
	root1 resd 1
	root2 resd 1
	resbuff rest 1
	temp resb 2
	disc resd 1
	char_ans resb 2
;--------------------------------------------------------------- 
%macro print 2			;macro for display
	mov rax,1 
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro read 2			;macro for input
	mov rax,0
	mov rdi,0
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

%macro exit 0			;macro for exit	
	mov rax,60
	xor rdi,rdi
	syscall
%endmacro
;--------------------------------------------------------------- 
section .text
  global _start
  _start:
  
  finit				; initialise 80387 co-processor
  fld dword[b]			; stack: b
     
  fmul dword[b] 		; stack: b*b
 
  fld dword[a]			; stack: a, b*b

  fmul dword[c] 		; stack: a*c, b*b

  fmul dword[four]		; stack: 4*a*c,b*b
  
  fsub	 			; stack: b*b - 4*a*c

  ftst 				; compares ST0 and 0
   
   
  fstsw ax			; Stores the coprocessor status word ;into either a word in memory or the AX register
  sahf				; Stores the AH register into the FLAGS register. Loads the SF, ZF, AF, PF, and CF flags of the EFLAGS register 				with values from the corresponding bits in the AH register (bits 7, 6, 4, 2, and 0, respectively).

  jb no_real_solutions 		; if disc < 0, no real solutions
  fsqrt 			; stack: sqrt(b*b - 4*a*c)

  fst dword[disc] 		; store disc= sqrt(b*b - 4*a*c)

  fsub dword[b] 		; stack: disc-b

  fdiv dword[a] 		; stack: disc-b/2*a or (-b+disc)/2a


  fdiv dword[two]

  print msg2,msglen2  
  call display_result 

  fldz				;stack:0

  fsub dword[disc]		;stack:-disc

  fsub dword[b] 		; stack: -disc - b

  fdiv dword[a]			; stack: (-b - disc)/(2*a)

  fdiv dword[two]
  
  print msg3,msglen3
  call display_result
  jmp End

no_real_solutions:
	print msg1,msglen1

End:
exit
  
;--------------------------------------------------------------- 
display_8:
	mov 	rsi,char_ans+1	
	mov 	rcx,2		; number of digits 

cnt:	mov 	rdx,0		
	mov 	rbx,16	
	div 	rbx
	cmp 	dl, 09h		; check for remainder in RDX
	jbe  	add30
	add  	dl, 07h 
add30:
	add 	dl,30h		; calculate ASCII code
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
