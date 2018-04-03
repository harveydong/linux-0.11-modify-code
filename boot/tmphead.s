
	bits 16
	
	org 0x8000-2

setup_begin:
	
	setup_len	dw	(setup_end - setup_begin)

entry:
	
	mov si,setup_message

	call puts

	
	xor eax,eax
	mov ax,cs
	shl eax,4
	add eax,0x00000000
	mov word [label_desc_code32+2],ax
	shr eax,16
	mov byte [label_desc_code32 +4],al
	mov byte [label_desc_code32 +7],ah
	mov ax,0xffff
	mov word [label_desc_code32],ax
	
	mov ax,0xcf98
	mov [label_desc_code32 +5],ax

	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,label_gdt_null
	mov dword [gdt_ptr+2],eax	
	lgdt [gdt_ptr]
	mov eax,cr0
	or eax,1
	mov cr0,eax

	cli
		
	jmp  selcode32:label_seg_code32


	bits 32
label_seg_code32:
	
	mov ax,selvideo
	mov gs,ax
	mov edi,(80*11+30)*2
	mov ah,0x0c
	mov al,'P'
	mov [gs:edi],ax

	jmp $	
;	jmp 0x9000	




;--------------------
;gdt
;--------------------

label_gdt_null dq	0x0000000000000000
label_desc_code32	dq 0x0000000000000000
label_desc_video	dq 0x00cf920b8000ffff

kernel_code32_desc              dq 0x00cf9a000000ffff   ; non-conforming, DPL=0, P=1
kernel_data32_desc              dq 0x00cf92000000ffff   ; DPL=0, P=1, writeable, expand-up

user_code32_desc                dq 0x00cff8000000ffff   ; non-conforming, DPL=3, P=1
user_data32_desc                dq 0x00cff2000000ffff   ; DPL=3, P=1, writeable, expand-up

tss32_desc                      dq 0
call_gate_desc                  dq 0

conforming_code32_desc          dq 0x00cf9e000000ffff   ; conforming, DPL=0, P=1
tss_test_desc                   dq 0
task_gate_desc                  dq 0
ldt_desc                        dq 0

gdt_len	equ	($ - label_gdt_null)

gdt_ptr	dw	(gdt_len - 1)
	dd	label_gdt_null

selcode32	equ 0x08
selvideo	equ 0x10




;----------------
;varible
;----------------
setup_message	db 'this is from setup module',13,10,0


;--------------------------------------
; this is  bits 16, library function
;--------------------------------------
puts:	jmp 0x8a00 + 0*3

setup_end:
