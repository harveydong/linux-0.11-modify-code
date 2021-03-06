
	bits 16
	org 0x7c00
start:
	cli
	in al,0x92
	or al,0x02
	out 0x92,al
	sti

	
	mov ax,0x7c0
	mov ds,ax
	
	mov ax,0x9000
	mov es,ax

	sub si,si
	sub di,di
	mov di,0x7c00
	mov cx,256
	
	rep
	movsw

	mov ax,0x9000
	push ax
	push go
	retf

	
go:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0xffff

	call clear_screen
	
	mov esi,1
	mov di,0x0200
	mov ecx,4
	call load_module



	mov  si,msg1
	call print_message

	mov esi,10
	mov ax,0x1000
	mov es,ax
	mov di,0
	mov ecx,7
	call load_module

	mov ax,cs
	mov es,ax
	
	mov ax,ROOT_DEV
	cmp ax,0
	jne root_defined
	
	mov si,root_error
	call print_message
	jmp $
	
root_defined:
	
	mov si,load_ok
	call print_message
	
next:
	

	
	jmp 0x9020:0



;-------------------------
;varaible
;-------------------------
load_ok db 'Load ok ...',13,10,0
msg1	db 'Loading system ...',13,10,0
root_error db 'Not defined root',13,10,0

;-------------------------
;print_message
;-------------------------
print_message:
	pusha
	mov ah,0x0e
	xor bh,bh
	
do_print_loop:
	lodsb
	test al,al
	jz do_print_done
	int 0x10
	jmp do_print_loop
do_print_done:
	popa
	ret



;--------------------------------
;clear_screen
;--------------------------------
clear_screen:
	pusha
	mov ax,0x0600
	xor cx,cx
	xor bh,0x0f
	mov dh,24
	mov dl,79
	int 0x10
set_cursor_position:
	mov ah,0x02
	mov bh,0
	mov dx,0
	int 0x10
	popa
	ret





;----------------------------
;read_sector_ext:
;input:
;	esi:start sector
;	edi:  dst buf
;----------------------------
read_sector_ext:
	xor eax,eax
	push eax
	push esi

	push es
	push di
	push word 0x01
	push word 0x10
	mov ah,0x42
	mov dl,0x80
	mov si,sp
	int 0x13
	add sp,0x10
	ret




;---------------------------------
;read_sector()
;
;----------------------------------	
read_sector:
	pusha
	push es
	push ds
	
do_read_sector_ext:
	call read_sector_ext
	mov al,0
do_read_sector_done:
	pop ds
	pop es
	popa
	movzx ax,al
	ret

;---------------------------------
;load_module()
;input:
; esi: start vector; 
; edi: dst buf; 
; ecx: total number of vector
;---------------------------------
load_module:

	call read_sector
	test ax,ax
	jnz do_load_module_done

do_load_module_loop:

	dec cx
	jz do_load_module_done
	
	inc esi
	add di,0x200
	call read_sector
	test ax,ax
	jz do_load_module_loop

do_load_module_done:
	ret









;--------
;ROOTDEV
;--------
ROOT_DEV dw 0x301




times 510 - ($-$$) db 0
	dw 0xaa55	
