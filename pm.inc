%macro descriptor 3
	dw %2 & 0ffffh
	dw %1 & 0ffffh
	db (%1 >> 16) & 0ffh
	dw ((%2 >> 8) & 0f00h) | (%3 & 0f0ffh)
	db (%1 >> 24) & 0ffh
%endmacro

da_32	equ	4000h
da_dpl0	equ	00h
da_dpl1	equ	20h
da_dpl2	equ	40h
da_dpl3	equ	60h
da_dr	equ	90h
da_drw	equ	92h
da_drwa	equ	93h
da_c	equ	98h
da_cr	equ	9ah
da_cco	equ	9ch
da_ccor	equ	9eh
da_ldt	equ	82h
da_taskgate	equ	85h
da_386tss	equ	89h
da_386cgate	equ	8ch
da_386igate	equ	8eh
da_386tgate	equ	8fh
