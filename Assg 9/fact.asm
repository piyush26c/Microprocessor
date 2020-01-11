section .data

msg db 	10,'Enter the number',10
msg_len	equ $-msg

ebmsg db 10,"error:",10       
ebmsg_len equ $-ebmsg

section .bss
n resw 1
factorial resw 1
char_ans resb 4
buf resb 5

%macro print 2
mov rax,1
mov rdi,1
mov rsi,%1
mov rdx,%2
syscall
%endmacro

%macro read 2
 mov rax,0
mov rdi,0
mov rsi,%1
mov rdx,%2
syscall
%endmacro

%macro exit 0
mov rax,60
mov rdx,00
syscall
%endmacro

section .text
global _start
_start:

	print msg, msg_len
	call Accept_16
	mov [n], bx

	mov cx,[n]

	mov word[factorial],1
	call facto

	mov ax, word[factorial]
	call disp16_proc
exit

facto:
	push rcx
	cmp rcx, 1
	jne recursion
	jmp next

recursion:
	dec rcx
	call facto

next:
	pop rcx
	mov rax, rcx
	mul word[factorial]
	mov word[factorial], ax

ret

Accept_16:

    read buf,3
    mov rcx,2
    mov rsi,buf
    xor bx,bx

    next_byte:
    shl bx,4
    mov al,[rsi]

    cmp al,'0'
    jb error
    cmp al,'9'
    jbe sub30

    cmp al,'A'
    jb error
    cmp al,'F'
    jbe sub37

    cmp al,'a'
    jb error
    cmp al,'f'
    jbe sub57
    cmp al,'f'
    ja error


    sub57:sub al,20h
    sub37:sub al,30h
    sub30:sub al,30h

    add bx,ax
    inc rsi
    dec rcx
    jnz next_byte

ret

error:
    print ebmsg,ebmsg_len
    exit
    
disp16_proc:
	mov 		rbx,16			; divisor=16 for hex
	mov 		rcx,4			; number of digits 
	mov 		rsi,char_ans+3		; load last byte address of char_ans buffer in rsi

cnt:	mov 		rdx,0			; make rdx=0 (as in div instruction rdx:rax/rbx)
	div 		rbx

	cmp 		dl, 09h			; check for remainder in rdx
	jbe  	add30
	add  	dl, 07h 
add30:
	add 		dl,30h			; calculate ASCII code
	mov 		[rsi],dl			; store it in buffer
	dec 		rsi				; point to one byte back

	dec 		rcx				; decrement count
	jnz 		cnt				; if not zero repeat
	
	print 	char_ans,4		; display result on screen
ret
