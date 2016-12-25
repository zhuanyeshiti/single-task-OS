%include "pm.inc"

	org 07c00h
	jmp label_begin
[section .gdt]
label_gdt:	descriptor	0,	0,	0
label_desc_code32: descriptor	0,	segcode32len-1,	da_c+da_32
label_desc_video: descriptor	0b8000h,	0ffffh,	da_drw
	gdtlen	equ	$-label_gdt
	gdtptr	dw	gdtlen-1
		dd	0
	selectorcode32	equ	label_desc_code32-label_gdt
	selectorvideo	equ	label_desc_video-label_gdt
[section .s16]
[bits 16]
label_begin:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0100h
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

	call dispstr
	jmp $
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

	mov ax,selectorvideo
	mov gs,ax
	mov edi,(80*10+0)*2
	mov ah,0Ch
	mov al,'p'
	mov [gs:edi],ax
	jmp $
	;jmp label_seg_code32

	segcode32len	equ	$-label_seg_code32

	times 510-($-$$) db 0
	dw 0xaa55
