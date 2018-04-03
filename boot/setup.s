
	bits 16
	org 0x90200
 
	


entry:
	mov ax,0x9000
	mov ds,ax
	mov ah,0x03
	xor bh,bh
	int 0x10
	mov [0],dx

	mov ah,0x88
	int 0x15
	mov [2],ax
	
	mov ah,0x0f
	int 0x10
	mov [4],bx
	mov [6],ax
	
	mov ah,0x12
	mov bl,0x10	
	int 0x10
	mov [8],ax
	mov [10],bx
	mov [12],cx
	

	mov ax,0x0000
	mov ds,ax
	lds si,[4*0x41]
	mov ax,0x9000
	mov es,ax
	mov di,0x0080
	mov cx,0x10
	rep
	movsb


	mov ax,0x0000
	mov ds,ax
	lds si,[4*0x46]
	mov ax,0x9000
	mov es,ax
	mov di,0x0090
	mov cx,0x10
	rep
	movsb

	mov ax,0x1500
	mov dl,0x81
	int 0x13
	jc no_disk1
	cmp ah,0x3
	je is_disk1

no_disk1:
	mov ax,0x9000
	mov es,ax
	mov di,0x0090
	mov cx,0x10
	mov ax,0x00
	rep
	stosb

is_disk1:
	cli
	mov ax,0x0000
	cld
	
do_move:
	mov es,ax
	add ax,0x1000
	cmp ax,0x9000
	jz end_move
	mov ds,ax
	sub di,di
	sub si,si
	mov cx,0x8000
	rep
	movsw
	jmp do_move

end_move:
	mov ax,0x9020
	mov ds,ax


	lidt [idt_48]
	;call empty_8042
	
;	mov al,0xd1
;	out 0x64,al
;	call empty_8042
;	mov al,0xdf
;	out 0x60,al
;	call empty_8042

	mov al,0x11
	out 0x20,al
	dw 0x00eb,0x00eb
	

	out 0xa0,al
	dw 0x00eb,0x00eb
	
	mov al,0x20
	out 0x21,al
	dw 0x00eb,0x00eb

	mov al,0x28
	out 0xa1,al
	dw 0x00eb,0x00eb
	
	mov al,0x04
	out 0x21,al
	dw 0x00eb,0x00eb

	mov al,0x02
	out 0xa1,al
	dw 0x00eb,0x00eb
	

	mov al,0x01
	out 0x21,al
	dw 0x00eb,0x00eb
	
	out 0xa1,al
	dw 0x00eb,0x00eb
	
	mov al,0xff
	out 0x21,al

	out 0xa1,al

	lgdt [gdt_48]
	
	cli

	mov eax,cr0
	or eax,0x01
	mov cr0,eax

	jmp 0x08:go


	bits 32
go:
	
	jmp $
	
;---------------
;empty_8042
;---------------
empty_8042:
	dw 0x00eb,0x00eb
	in al,0x64
	test al,0x02
	jnz empty_8042
	ret


;-------------
;idt_48
;-------------
idt_48	dw 0
	dd 0


;-------------------
;gdt desc
;-------------------
gdt_base 	dq 0x0000000000000000
		dq 0x00cf9a090000ffff ; kernel code
		dq 0x00cf92090000ffff ;kernel data

gdt_len	equ ($ - gdt_base)

gdt_48 	dw (gdt_len - 1)
	dd 0x12345678 



