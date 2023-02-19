;常量
Number_of_commands equ 5
Length_of_commands equ 8
Length_of_commands_data equ 7
;系统文件 首个扇区 再读扇区3 FOS BIN
db 00010011b,'FOS',0,0,0,0,0,'BIN',0,0,0,0
mov al,3
mov ah,0
int 10h
call Welcome
call Input
call f
;输出函数
; 参数   含义
;  bl    前景
;es:bp 字符开始
Output:
	push ax
	push bx
	push dx
	push bp
ol:
	mov al,byte [es:bp]
	cmp al,0
	je oex
	cmp al,0dh
	je onextline
	mov ah,0eh
	int 10h
	inc bp
	jmp ol
onextline:
	mov bh,0
	mov ah,3
	int 10h
	inc dh
	mov dl,0
	mov ah,2
	int 10h
	inc bp
	call Roll_Up
	jmp ol
oex:
	pop bp
	pop dx
	pop bx
	pop ax
	ret
;指令复位
Reset:
	push ax
	push bx
	push dx
	mov bh,0
	mov dx,[cs:bp]
	mov ah,2
	int 10h
	pop dx
	pop bx
	pop ax
	ret
;指令显示
Pshow:
	push ax
	push cx
	push bp
	mov cx,64
sl:
	mov al,byte [cs:bp]
	cmp al,0
	je sex
	mov ah,0eh
	int 10h
	inc bp
	loop sl
sex:
	pop bp
	pop cx
	pop ax
	ret
;判断相等
; 参数   含义
;es:di  字符串1
;es:si  字符串2
;返回值      含义
;  al   相等:1 不相等:0
Equal:
	push di
	push si
el:
	mov al,byte[es:di]
	mov ah,byte[es:si]
	cmp al,ah
	jne efe
	cmp al,0
	je ete
	inc di
	inc si
	jmp el
ete:
	mov al,1
	jmp eex
efe:
	mov al,0
	jmp eex
eex:
	pop si
	pop di
	ret
;转换为大写
;参数    含义
; al  待转换字符
;返回值  含义
; al  已转换字符
Upper:
	cmp al,97
	jb uex
	cmp al,122
	ja uex
	sub al,32
uex:
	ret
;寻零
;参数     含义
; si  待寻零寄存器
;返回值  含义
; si  已寻零寄存器
Find_Zero:
	cmp byte [cs:si],0
	je fex
	inc si
	jmp Find_Zero
fex:
	ret
;查看寄存器
;参数   含义
; ax  带查看值
Show_Data:
	push ds
	push bp
	push bx
	mov bx,0b800h
	mov ds,bx
	push ax
	shr ax,12
	mov bp,sm_0
	add bp,ax
	mov bl,byte [cs:bp]
	mov byte [ds:0],bl
	pop ax
	push ax
	shr ax,8
	and ax,00000000000001111b
	mov bp,sm_0
	add bp,ax
	mov bl,byte [cs:bp]
	mov byte [ds:2],bl
	pop ax
	push ax
	shr ax,4
	and ax,00000000000001111b
	mov bp,sm_0
	add bp,ax
	mov bl,byte [cs:bp]
	mov byte [ds:4],bl
	pop ax
	push ax
	and ax,00000000000001111b
	mov bp,sm_0
	add bp,ax
	mov bl,byte [cs:bp]
	mov byte [ds:6],bl
	pop ax
	pop bx
	pop bp
	pop ds
	ret
;上卷
Roll_Up:
	push ax
	push bx
	push cx
	push dx
	mov bh,0
	mov ah,3
	int 10h
	cmp dh,23
	ja rcls
	jmp rex
rcls:
	call CLS
rex:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
sm_0:
	db '0123456789ABCDEF'
;换行
Next_Line:
	push bp
	mov bp,nm_0
	call Output
	pop bp
	ret
nm_0:
	db 0dh
	db 0
;欢迎
Welcome:
	mov ax,cs
	mov es,ax
	mov bp,M_0
	mov bl,07h
	call Output
	ret
Input:
	mov ax,cs
	mov es,ax
	mov bp,D_3
	cmp byte [cs:bp],0
	je ist
	mov bp,P_0
	mov bl,07h
	call Output
ist:
	mov bp,D_0
	mov bh,0
	mov ah,3
	int 10h
	mov [cs:bp],dx
	mov ax,cs
	mov es,ax
	mov si,S_0
	mov di,S_0
io:
	mov ah,0
	int 16h
	cmp al,0
	je io
	cmp al,8
	je backspace
	cmp al,0dh
	je Crun
	push si
	sub si,di
	cmp si,64
	pop si
	je io
	mov byte [cs:si],al
	inc si
update:
	mov bp,D_0
	call Reset
	mov bl,07h
	mov bp,S_0
	call Pshow
	jmp io
backspace:
	push si
	sub si,di
	cmp si,0
	pop si
	je io
	dec si
	mov byte [cs:si],0
	mov bh,0
	mov ah,3
	int 10h
	sub dl,1
	mov ah,2
	int 10h
	mov bl,07h
	mov al,0
	mov ah,0eh
	int 10h
	jmp update
;执行指令
Crun:
	mov bh,0
	mov ah,3
	int 10h
	mov dl,0
	inc dh
	mov ah,2
	int 10h
	call Roll_Up
	call Run
	call Rrun
	jmp Input
;执行
Run:
	mov cx,64
	mov bp,S_0
	mov si,D_1
	mov di,D_2
;转移
pt:
	mov al,byte [cs:bp]
	cmp al,20h
	je pf
	cmp al,0
	je pf
	cmp al,97
	jb pm
	cmp al,122
	ja pm
	sub al,32
pm:
	mov byte [cs:si],al
	inc bp
	inc si
	loop pt
;停止转移
pf:
	mov byte [cs:si],0
	inc si
	loop pf
push bp
mov cx,16
mov bp,D_2
pca:
	mov dword [cs:bp],0
	add bp,4
	loop pca
pop bp
pal:
	inc bp
	cmp byte[cs:bp],0
	je pae
	cmp byte[cs:bp],20h
	jne palt
	jmp pal
palt:
	mov al,byte[cs:bp]
	cmp al,0
	je pae
	call Upper
	mov byte [cs:di],al
	inc bp
	inc di
	dec cx
	jz pae
	jmp palt
pae:
	mov bp,D_1
	mov al,byte [cs:bp]
	cmp al,0
	je pex
	mov cx,Number_of_commands
	mov si,P_1
;比较
pl:
	push cx
;比较字符
pcl:
	mov al,byte[cs:bp]
	mov ah,byte[cs:si]
	cmp al,ah
	jne pn
	cmp al,0
	je pr
	inc bp
	inc si
	jmp pcl
pn:
	inc si
	cmp byte [cs:si],0
	jne pn
	mov bp,D_1
	add si,Length_of_commands_data
	pop cx
	loop pl
mov bp,M_1
call Output
mov bp,D_1
call Output
call Next_Line
;返回
pex:
	ret
;运行
pr:
	pop cx
	inc si
	mov bp,[cs:si]
	call cs:bp
	jmp pex
Rrun:
	push cx
	push bp
	mov cx,16
	mov bp,S_0
clo:
	mov dword [cs:bp],0
	add bp,4
	loop clo
	mov bp,D_0
	mov bh,0
	mov ah,3
	int 10h
	mov dl,0
	mov [cs:bp],dx
	call Reset
	pop bp
	pop cx
	ret
f:
	hlt
	jmp f
P_0:
	db '>>>'
	db 0
P_1:
	db 'CLS'
	db 0
	dw CLS
	dw fcm_0
	dw ffm_0
	db 'ECHO'
	db 0
	dw ECHO
	dw fcm_1
	dw ffm_1
	db 'FASTHELP'
	db 0
	dw FASTHELP
	dw fcm_2
	dw ffm_2
	db 'HELP'
	db 0
	dw HELP
	dw fcm_3
	dw ffm_3
	db 'VER'
	db 0
	dw VER
	dw fcm_4
	dw ffm_4
M_0:
	db 'Welcome to FOS 1.0 Beta.'
	db 0dh
	db 'Type "HELP" for help.'
	db 0dh
	db 0
M_1:
	db 'Bad command: '
	db 0
S_0:
	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
D_0:
	dw 0
D_1:
	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
D_2:
	dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
D_3:
	db 1
CLS:
	mov al,0
	mov bh,0
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	mov ah,6
	int 10h
	mov dx,0
	mov al,2
	int 10h
	ret
FASTHELP:
	mov di,D_2
	cmp byte [cs:di],0
	je fc
	mov ax,cs
	mov es,ax
	mov si,P_1
	mov cx,Number_of_commands
fcl:
	call Equal
	cmp al,1
	je fct
fcf:
	inc si
	cmp byte [cs:si],0
	jne fcf
	add si,Length_of_commands_data
	loop fcl
mov bp,fem_0
call Output
ret
fct:
	call Find_Zero
	add si,3
	mov bp,[cs:si]
	call Output
	add si,2
	mov bp,[cs:si]
	call Output
	ret
fc:
	mov ax,cs
	mov es,ax
	mov bp,fm_0
	mov bl,07h
	call Output
	mov cx,Number_of_commands
	mov bp,P_1
	mov si,fcm_0
fl:
	push cx
	call Output
	mov cx,Length_of_commands
	inc cx
ftl:
	mov al,byte [es:bp]
	cmp al,0
	je ft
	inc bp
	loop ftl
ft:
	push cx
	mov bh,0
	mov ah,3
	int 10h
	pop cx
	add dl,cl
	mov ah,2
	int 10h
	add bp,Length_of_commands_data
	push bp
	mov bp,si
	call Output
ftl_2:
	inc si
	cmp byte[cs:si],0
	je ft_2
	jmp ftl_2
ft_2:
	inc si
	pop bp
	pop cx
	loop fl
	ret
fem_0:
	db 'Help not available for this command.'
	db 0dh
	db 0
fm_0:
	db 'For more information on a specific command, type FASTHELP Command-name.'
	db 0dh
	db 0
fcm_0:
	db 'Clears the screen.'
	db 0dh
	db 0
fcm_1:
	db 'Displays messages, or turns command-echoing on or off.'
	db 0dh
	db 0
fcm_2:
	db 'Provides summary help information for FOS commands.'
	db 0dh
	db 0
fcm_3:
	db 'Provides general help information for FOS commands.'
	db 0dh
	db 0
fcm_4:
	db 'Displays the FOS version.'
	db 0dh
	db 0
ffm_0:
	db 'CLS'
	db 0dh
	db 0
ffm_1:
	db 'ECHO [ON | OFF]'
	db 0dh
	db 'ECHO [message]'
	db 0dh
	db 'Type ECHO without parameters to display the current echo setting.'
	db 0dh
	db 0
ffm_2:
	db 'FASTHELP [command]'
	db 0dh
	db 20h,20h,20h,20h
	db 'command - displays help information on that command.'
	db 0dh
	db 0
ffm_3:
	db 'HELP'
	db 0dh
	db 0
ffm_4:
	db 'VER'
	db 0dh
	db 0
ECHO:
	mov bp,D_2
	cmp byte [cs:bp],0
	jne e_1
	mov bp,D_3
	cmp byte [cs:bp],1
	jne e_0_0
	mov bp,em_0
	jmp e_0_ex
e_0_0:
	mov bp,em_1
e_0_ex:
	call Output
	ret
e_1:
	mov si,bp
	mov di,esm_0
	call Equal
	cmp al,1
	je eoff
	mov di,esm_1
	call Equal
	cmp al,1
	je eon
	jmp eecho
eoff:
	mov bp,D_3
	mov byte[cs:bp],0
	jmp ecex
eon:
	mov bp,D_3
	mov byte[cs:bp],1
	jmp ecex
eecho:
	mov bp,D_2
	call Output
	call Next_Line
ecex:
	ret
em_0:
	db 'Echo is on.'
	db 0dh
	db 0
em_1:
	db 'Echo is off.'
	db 0dh
	db 0
esm_0:
	db 'OFF'
	db 0
esm_1:
	db 'ON'
	db 0
HELP:
	mov ax,cs
	mov es,ax
	mov bp,hm_0
	mov bl,07h
	call Output
	ret
hm_0:
	db 'Welcome to use FOS 1.0 Beta.'
	db 0dh
	db 'For a list of FOS commands, please type "FASTHELP".'
	db 0dh
	db 'For more information, please see the technotes.'
	db 0dh
	db 0
VER:
	mov ax,cs
	mov es,ax
	mov bp,vm_0
	mov bl,07h
	call Output
	ret
vm_0:
	db 'FOS 1.0 Beta [Version 2.19.2023]'
	db 0dh
	db 0