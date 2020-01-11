model small
.stack 100h
.code
 JMP INIT       ;//to go to  initialization
 resi:
 push ax
 push bx
 push cx
 push dx
 push es        ;//to push all  registers
 push di
 mov ax,0b800h    ;//store address  of video ram area
 mov es,ax      ;//store VRAM to  extra segment
 mov di,0000    ; positon of clk to  display  
 mov ah,02h
 int 1ah        ;//for getting current time
 mov bx,cx    ;//copy current term to  bx
 mov ah,7ch   ;//decide background &  foreground 
 mov cx,0504h   ;//ch=05 five characters hr:min
 cld            ;//cl=04 for rotation  
 l2:cmp ch,03   
 jne l3
 mov al,':'
 jmp l4
 l3:
 rol bx,cl
 mov al,bl
 and al,0fh
 add al,30h
 l4:
 stosw     ;//store time to ES:DI  
 dec ch
 jnz l2
mov cx,0304h   ;//3 char for sec &cl for rotation 
cld            ;//clear of for stosw instruction
l5:mov al,':'
jmp l7
l6:rol dh,cl
mov al,dh
and al,0fh
add al,30h
l7:
stosw 
dec ch
jnz l6
pop di
pop es
pop dx
pop cx
pop bx
pop ax
jmp dword ptr cs:oldip
    
oldip dw 0
oldcs dw 0
init:
    mov ax,cs      ;//initialize data segment 
    mov ds,ax
   
    mov ah,35h
    mov al,08h   ;//to get address of type 8 
                      ;interrupt i.e.timer interrupt
    int 21h
    mov word ptr oldip,bx
    mov word ptr oldcs,es
    
    mov ah,25h      ;//repalce old ivt address with
                     ; new address which as in dx
    mov al,08h
    lea dx,resi
    int 21h
    
    mov ah,31h
    lea dx,init
    mov al,00
    int 21h
    end init
