%include "pm.inc"

	org 07c00h
	jmp label_begin
[section .gdt]
label_gdt:	   descriptor	0,	0,	0
label_desc_normal: descriptor	0,	0ffffh,	da_drw
label_desc_code32: descriptor	0,	segcode32len-1,	da_c+da_32
label_desc_code16: descriptor	0,	0ffffh,	da_c
label_desc_data:   descriptor	0,	datalen-1,	da_drw
label_desc_stack:  descriptor	0,	topofstack-1,	da_drwa+da_32
label_desc_test:   descriptor	0500000h,	0ffffh,	da_drw
label_desc_video:  descriptor	0b8000h,	0ffffh,	da_drw
	gdtlen	equ	$-label_gdt
	gdtptr	dw	gdtlen-1
		dd	0
	selectornormal	equ	label_desc_normal - label_gdt
	selectorcode32	equ	label_desc_code32 - label_gdt
	selectorcode16	equ	label_desc_code16 - label_gdt
	selectordata	equ	label_desc_data   - label_gdt
	selectorstack	equ	label_desc_stack  - label_gdt
	selectortest	equ	label_desc_test   - label_gdt
	selectorvideo	equ	label_desc_video  - label_gdt

[section .data1]
align 32
[bits 32]
label_data:
	spvalueinrealmode	dw	0
	pmmessage:	db	"in protected mode now!",0
	offsetpmmessage	equ	pmmessage - $$
	strtest:	db	"abcd string test abcd!",0
	offsetstrtest	equ	strtest - $$
	datalen		equ	$ - label_data

[section .gs]
align 32
[bits 32]
label_stack:
	times 10 db 0
	topofstack	equ	$ - label_stack

[section .s16]
[bits 16]
label_begin:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0100h

	;call dispstr
	;jmp $

	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,label_data
	mov word [label_desc_data+2],ax
	shr eax,16
	mov byte [label_desc_data+4],al
	mov byte [label_desc_data+7],ah

	xor eax,eax
	mov ax,ss
	shl eax,4
	add eax,label_stack
	mov word [label_desc_stack+2],ax
	shr eax,16
	mov byte [label_desc_stack+4],al
	mov byte [label_desc_stack+7],ah

	xor eax,eax
	mov ax,cs
	shl eax,4
	add eax,label_seg_code32
	mov word [label_desc_code32+2],ax
	shr eax,16
	mov byte [label_desc_code32+4],al
	mov byte [label_desc_code32+7],ah

	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,label_gdt
	mov dword [gdtptr+2],eax
	lgdt [gdtptr]

	cli

	in al,92h
	or al,00000010b
	out 92h,al

	mov eax,cr0
	or eax,1
	mov cr0,eax

	jmp dword selectorcode32:0

	dispstr:
	mov ax,bootmessage
	mov bp,ax
	mov cx,16
	mov ax,01301h
	mov bx,000ch
	mov dl,0
	int 10h
	ret
	bootmessage: db "hello,world!"

[section .s32]
[bits 32]
label_seg_code32:

	mov ax,selectordata
	mov ds,ax
	mov ax,selectortest
	mov es,ax
	mov ax,selectorvideo
	mov gs,ax
	mov ax,selectorstack
	mov ss,ax

	mov edi,(80*10+0)*2
	mov ah,0Ch
	xor esi,esi
	xor edi,edi
;	mov al,'p'
	mov esi,offsetpmmessage
	cld
.1:
	lodsb
	test al,al
	jz .2
	mov [gs:edi],ax
;	jmp $
;	jmp label_seg_code32
	add edi,2
	jmp .1
.2:
	jmp $

	segcode32len	equ	$-label_seg_code32

	times 510-($-$$) db 0
	dw 0xaa55
