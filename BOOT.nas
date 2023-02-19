;程序入口 7c00
org 7c00h
call Start
mov cl,2
mov bx,0
call Load

mov dl,byte [es:bx]
and dl,00000111b
ll:
	cmp dl,0
	je lex
	inc cl
	add bx,200h
	call Load
	dec dl
	jmp ll
lex:
	call Fin
;输出函数
; 参数   含义
;  bl    前景
;es:bp 字符开始
;dh,dl   行列
Output:
	mov bh,0
	mov ah,2
	int 10h
ol:
	mov al,byte [es:bp]
	mov ah,0eh
	int 10h
	inc bp
	cmp al,0
	jne ol
	ret
;启动
Start:
	mov ax,cs
	mov es,ax
	mov bp,M_0
	mov bl,07h
	mov dx,0
	call Output
	ret
;读取软盘cl 扇区 -> >=2
Load:
	push bx
	push dx
	mov si,0
	
Retry:
	mov ah,0
	int 13h
	cmp si,3
	je Error
	inc si
	mov ax,7e00h
	mov es,ax
	mov ah,02h
	mov al,1
	mov ch,0
	mov dh,0
	mov dl,0
	int 13h
	jc Retry
	mov ax,cs
	mov es,ax
	mov bp,M_2
	mov bl,07h
	mov dx,0100h
	call Output
	pop dx
	pop bx
	ret
;读取错误
Error:
	mov ax,cs
	mov es,ax
	mov bp,M_1
	mov bl,07h
	mov dx,0100h
	call Output
el:
	hlt
	jmp el
;进入系统
Fin:
	mov ax,cs
	mov es,ax
	mov bp,M_3
	mov bl,07h
	mov dx,0200h
	call Output
	mov ah,0
	int 16h
	cmp al,0dh
	jne Fin
	mov ax,0600h
	mov cx,0
	mov dh,24
	mov dl,79
	int 10h
	jmp 7e00h:1h
;字符
M_0:
	db 'Boot from floppy...'
	db 0
M_1:
	db 'Error reading floppy disk.'
	db 0
M_2:
	db 'Read the floppy successfully.'
	db 0
M_3:
	db 'Press Enter key to run FOS'
	db 0
;填充
times 510-($-$$) db 0
db 55h, 0aah