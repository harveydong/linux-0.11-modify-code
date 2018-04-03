
	bits 16
	org 0x7c00

start:
	cli
	
	in al,0x92
	or al,0x02
	out 0x92,al

	sti
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x7c00
	
	call clear_screen


	mov si,msg
	call print_message
	
	;load setup from sector 2 to 0x8000

	mov esi,1
	mov edi,0x8000-2
	call load_module
	

;	test al,1
;	jz do_read_error
	
	mov esi,30
	mov edi,0x8a00 - 2
	call load_module


	
	mov si,load_ok
	call print_message
	
	jmp 0x8000
		

do_read_error:
	mov si,read_error
	call print_message

	jmp $


;---------------------
;varable:
;---------------------
msg	db 'loading ... ... ',13,10,0
read_error	db 'load error',13,10,0
load_ok		db 'load ok',13,10,0



;---------------------------
;read_sector_ext:
;intput:
;	esi: sector, di: buf
;---------------------------

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




;---------------------
;check int3h
;---------------------
check_int13h_ext:
	push bx
	mov bx,0x55aa
	mov dl,0x80
	mov ah,0x41
	
	int 0x13
	setc al
	jc do_check_int13h_ext_done

	cmp bx,0xaa55
	setnz al
	jnz do_check_int13h_ext_done
	test cx,1
	setz al
do_check_int13h_ext_done:
	pop bx
	movzx ax,al
	ret	


;------------------------
;lba to chs
;------------------------
lba_to_chs:
	mov cl,20
	div cl
	mov ch,al
	shr ch,(16/2)
	mov dh,al
	and dh,1
	mov cl,ah
	inc cl
	ret



;----------------
; read_sector(); read one sector;
; input:
;	si-sector, di-buf
;----------------
read_sector:
	pusha
	push es
	push ds
	pop es

	;call check_int13h_ext
	;test ax,ax
	
	
;	jz do_read_sector_ext
;	mov bx,di
;	mov ax,di

;	call lba_to_chs
;	mov dl,0x80
;	mov ax,0x201
;	int 0x13
;	setc al

;	jmp do_read_sector_done
do_read_sector_ext:
	call read_sector_ext
	mov al,0

do_read_sector_done:

	pop es
	popa
	movzx ax,al
	ret


;---------------
;dot()
;
;---------------
dot:
	push ax
	push bx
	mov ah,0x0e
	xor bh,bh
	mov al,'.'
	int 0x10
	pop bx
	pop ax
	ret




;-------------------
; load_module()
;esi: start sector
; di　dest buf
;--------------------
load_module:
	call read_sector
	test ax,ax
	jnz do_load_module_done
	
	mov cx,[edi]	; this is module size
	test cx,cx
	setz al
	jz do_load_module_done

	add cx,512 - 1
	shr cx,9

do_load_module_loop:
	;call dot
	dec cx
	jz do_load_module_done
	inc esi
	add di,0x200
	call read_sector
	test ax,ax
	jz do_load_module_loop

do_load_module_done:
	ret





;-----------------
; clear screen
;-----------------
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

;-------------------
;print message()
; input:
; si: message
;-------------------

print_message:
	pusha
	mov ah,0x0e
	xor bh,bh
do_print_message_loop:
	lodsb
	test al,al
	jz do_print_message_done
	int 0x10
	jmp do_print_message_loop
do_print_message_done:
	popa
	ret


times 510 -  ($ - $$) db 0
	dw 0xaa55	
