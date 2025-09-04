; Boot sector program to dump as many BIOS provided interrupt vectors as fit on the screen.

MAX_IVT_FITS_ON_SCREEN = 200 ; how many vectors can fit on the screen
MAX_ENTRIES_PER_ROW = 7 ; how many seg:off strings can fit on one row of the screen

use16
org 7C00h

start:
	cli
	xor ax, ax
	mov ss, ax
	mov sp, 7C00h
	sti

	push cs
	pop ds

	xor ax, ax
	mov es, ax ; 0000h segment in es

	mov ax, 0003h ; video mode 3 (80x25 color text)
	int 10h

	mov ax, 1112h ; load 8x8 font (optional, BIOS-dependent)
	xor bx, bx
	int 10h
	
	mov ax, 1201h ; set cursor height / text rows
	mov bl, 20h ; 32 rows (0x20 = 32 decimal)
	mov bh, 00h
	int 10h
	
	; reset cursor to top left
	xor dx, dx ; dh=row=0, dl=col=0
	mov bh, 0 ; page 0
	mov ah, 02h ; set cursor position
	int 10h

	; hide cursor
	mov ah, 03h ; read current cursor shape
	mov bh, 0
	int 10h
	or ch, 00100000b ; set cursor to invisible mode (bit 5)
	mov ah, 01h ; set cursor shape
	int 10h

	xor di, di ; di = 0 (IVT starts at 0000:0000)
	mov cx, MAX_IVT_FITS_ON_SCREEN - 1 ; we can't fit the last crnl, handeled separately
	xor bl, bl ; bl = entry counter for newline control

.next:
	mov ax, [es:di] ; offset of current entry
	mov dx, [es:di+2] ; segment of current entry

	push ax ; save offset
	mov ax, dx
	call print_word ; print segment
	mov al, ':'
	call putc
	pop ax ; restore offset
	call print_word ; print offset
	mov al, ' '
	call putc

	add di, 4 ; next IVT entry (in memory)
	inc bl ; next IVT entry (counter)
	
	test bl, MAX_ENTRIES_PER_ROW ; out of space on row? 
	jnz .no_nl ; Nah
	; Yes

	mov al, 13 ; carrige return
	call putc
	mov al, 10 ; line feed
	call putc

.no_nl:
	loop .next ; repeat until cx=0

.print_one_last: ; fill in the last entry WITHOUT the crnl
	mov ax, [es:di]
	mov dx, [es:di+2]

	push ax
	mov ax, dx
	call print_word
	mov al, ':'
	call putc
	pop ax
	call print_word

.halt: ; halt the cpu, we are done
	cli
	hlt
	jmp .halt

putc:
	push ax
	push bx
	
	mov ah, 0Eh ; BIOS teletype output function
	mov bh, 0 ; page 0
	mov bl, 7 ; white-on-black attribute
	int 10h

	pop bx
	pop ax
	ret

print_word:
	push ax
	
	mov al, ah ; print high byte first
	call print_byte

	pop ax ; then print low byte
	call print_byte

	ret

print_byte:
	push ax

	mov ah, al ; save al in ah
	shr ah, 1 ; move high nibble into ah
	shr ah, 1
	shr ah, 1
	shr ah, 1
	mov al, ah ; restore al
	call print_hex_digit ; print high nibble

	pop ax
	and al, 0Fh ; mask low nibble

; fall-through into print_hex_digit as tail call
print_hex_digit:
	cmp al, 10
	jb .d09
	add al, 7 ; adjust for 'A'-'F'
.d09:
	add al, '0' ; convert to ascii
	jmp putc ; tail call putc

times 510-($-$$) db 0
dw 0AA55h
