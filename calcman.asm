; CalcMan v1.2
; Keith Batten kbatten@gmail.com
; 7 January 1999
;
; Tab width set to 8

;*******************************************
;* 01 for the home screen
;* 02 for the polynomial solver
;* 03 for the simultaneous equation solver
;* 05 for the constant editor
;* 06 for the vector editor
;* 07 for the matrix editor
;* 08 for the program editor
;* 0c for the interpolate/extrapolate editor
;* 0e for the list/stat editor
;* 12 for tolerance
;* 19 for the table
;* 1a for table setup
;* 1b for link
;* 1d for reset mem prompt
;* 1e for reset defaults prompt
;* 1f for reset all prompt
;* 20 for RAM
;* 21 for mode/self test
;* 23 for delete variables
;* 49 for the function editor
;* 4a for the window editor
;* 4c for the graph
;* 53 initial conditions
;* 54 axes something
;* 62 for format
;* 96 for cat/var
;* 98 for an error message
;*******************************************

#include "asm86.h"
#include "rom86.h"
#include "ram86.h"


;------BEGIN (SQRT)KEY LOADER------

NameLength	equ 16 + 11
#DEFINE		NAME	.db "CalcMan v1.2 KWB"

.org _asm_exec_ram

	nop
	jp	Start
	.dw	0000h
	.dw	Description

Start:
	call	_flushallmenus
	call	_clrLCD
	call	_homeUp

	set	textInverse, (IY + textflags)
	ld	hl, Title_str
	call	_puts
	call	_newline
	res	textInverse, (IY + textflags)

	ld	hl, Install_str
	call	_puts
	call	_newline
	ld	hl, UnInstall_str
	call	_puts
	ld	hl, Change_Password_str
	call	_puts
	call	_newline
	ld		hl, Quit_str
	call	_puts

	ld	hl, $0900
	ld	(_penCol), hl
	ld	hl, key_str
	call	_vputs

	call	check_disp_install

check_link_locked:
	call	Load_Password
	ld	hl, $3A00
	ld	(_penCol), hl
	ld	hl, link_str
	set	textInverse, (IY + textflags)
	call	_vputs
	ld	a, (blank_pass)
	and	%00000001	; check if link is locked
	cp	0
	call	nz, disp_menu_locked
	call	z, disp_menu_unlocked
	call	_vputs
check_mem_locked:
	ld	hl, $3A2D
	ld	(_penCol), hl
	ld	hl, mem_str
	call	_vputs
	ld	a, (blank_pass)
	and	%00000010	; check if mem is locked
	cp	0
	call	nz, disp_menu_locked
	call	z, disp_menu_unlocked
	call	_vputs
check_delete_locked:
	ld	hl, $3A5C
	ld	(_penCol), hl
	ld	hl, deletemenu_str
	call	_vputs
	ld	a, (blank_pass)
	and	%00000100	; check if delete is locked
	cp	0
	call	nz, disp_menu_locked
	call	z, disp_menu_unlocked
	call	_vputs
	res	textInverse, (IY + textflags)
	jr	check_done

disp_menu_locked:
	ld	hl, locked_str
	ret
disp_menu_unlocked:
	ld	hl, unlocked_str
	ret

check_done:
Main_Menu:
	call	_getkey
	cp	k1
	jp	z, Install
	cp	k2
	jp	z, Uninstall
	cp	k3
	jp	z, Change_Password
	cp	k4
	jr	z, Quit_Main
	cp	kExit
	jr	z, Quit_Main
	cp	kF1
	jr	z, lockunlock_link
	cp	kF3
	jr	z, lockunlock_mem
	cp	kF5
	jp	z, lockunlock_delete

	jr	Main_Menu

Quit_Main:
	call	_clrLCD
	call	_clrScrn
	call	_homeUp
	ret

lockunlock_link:
	call	Load_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, dashes
	call	_puts
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, input_pass
	call	Get_Password
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts
	call	Check_Password	; check for a password
	cp	0
	jr	z, Main_Menu	; oops it was wrong

	call	Load_Password

	ld	hl, pass_op_info-1
	rst	20h
	call	_findsym
	jr	c, Main_Menu	; return if no pass var

	ld	a, (blank_pass)
	xor	%00000001	; flip the link bit
	ld	(blank_pass), a

	call	Write_Password
	jp	check_link_locked
lockunlock_mem:
	call	Load_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, dashes
	call	_puts
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, input_pass
	call	Get_Password
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts
	call	Check_Password	; check for a password
	cp	0
	jp	z, Main_Menu	; oops it was wrong

	ld	hl, pass_op_info-1
	rst	20h
	call	_findsym
	jp	c, Main_Menu	; return if no pass var

	ld	a, (blank_pass)
	xor	%00000010	; flip the mem bit
	ld	(blank_pass), a
	call	Write_Password
	jp	check_link_locked
lockunlock_delete:
	call	Load_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, dashes
	call	_puts
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, input_pass
	call	Get_Password
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts
	call	Check_Password	; check for a password
	cp	0
	jp	z, Main_Menu	; oops it was wrong

	ld	hl, pass_op_info-1
	rst	20h
	call	_findsym
	jp	c, Main_Menu	; return if no pass var

	ld	a, (blank_pass)
	xor	%00000100	; flip the delete bit
	ld	(blank_pass), a
	call	Write_Password
	jp	check_link_locked

disp_installed_text:
	ld	hl, $0912
	ld	(_penCol), hl
	ld	hl, installed_str
	call	_vputs
	ret

check_disp_install:
	ld	hl, key_op_info-1
	rst	20h
	call	_findsym
	push	af
	call	c, disp_uninstalled_text
	pop	af
	call	nc, disp_installed_text
	ret

disp_uninstalled_text:
	ld	hl, $0912
	ld	(_penCol), hl
	ld	hl, uninstalled_str
	call	_vputs
	ret

Uninstall:
	call	Load_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, dashes
	call	_puts
	ld	hl, $0106
	ld	(_curRow), hl
	ld	hl, input_pass
	call	Get_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts
	call	Check_Password	; check for a password
	cp	0
	jp	z, Main_Menu	; oops it was wrong


	call	Delete_Password

	ld	hl, key_op_info-1	; load (sqrt)key op info into OP1
	rst	20h
	call	_findsym
	jp	c, Main_Menu		; no (sqrt)key so return
	call	_delvar			; there was so we uninstall it
	res	6,(iy+$24)		; reset the flag for (sqrt)key
	call	check_disp_install

	xor	a
	ld	(blank_pass), a
	jp	check_link_locked

Install:
	ld	hl, pass_op_info-1	; load pass op info into OP1
	rst	20h			; check if there is already a password
	call	_findsym		; variable
	jp	nc, Install_next	; yes so dont install again

	call	Create_Password
Install_next:
	ld	hl, key_op_info-1	; load (sqrt)key op info into OP1
	rst	20h
	call	_findsym
	jr	c, Install_cont		; no (sqrt)key so continue
	call	_delvar			; there was so we uninstall it
Install_cont:
	ld	hl, code_end - code_start	; get the length of the (sqrt)key program
	call	_createprog			; create the (sqrt)key program
	ld	a, b				; convert bde to ahl
	ex	de, hl
	call	$4c3f				; add 2 to ahl to point it to program data
	call	_set_abs_dest_addr		; set the destination to be our new (sqrt)key
	xor	a
	ld	hl,code_end - code_start	; set number of bytes to copy
	call	_set_mm_num_bytes		; as length of program
	xor	a
	ld	hl, code			; point to the beginning of the program
	call	_set_abs_src_addr
	call	_mm_ldir			; copy the program code
	set	6,(iy+$24)			; set the flag for (sqrt)key
	call	check_disp_install
	jp	Main_Menu			; done for now

Change_Password:
	ld	hl, key_op_info-1	; check if (sqrt)key is installed
	rst	20h
	call	_findsym
	jp	c, Main_Menu		; no so quit

	ld	hl, pass_op_info-1	; load pass op info into OP1
	rst	20h
	call	_findsym
	call	c, Create_Password

	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, old_prompt
	call	_puts
	ld	hl, dashes
	call	_puts
	ld	hl, $0506
	ld	(_curRow), hl
	ld	hl, input_pass
	call	Get_Password

	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts

	call	Check_Password
	cp	0
	jr	z, Change_Password_Bad
Change_Password_Good:
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, new_prompt
	call	_puts
	ld	hl, dashes
	call	_puts
	ld	hl, $0506
	ld	(_curRow), hl
	ld	hl, blank_pass+1
	call	Get_Password
	call	Write_Password
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, blank_line
	call	_puts
	jp	Main_Menu

Change_Password_Bad:
	ld	hl, $0006
	ld	(_curRow), hl
	ld	hl, Incorrect_str
	call	_puts
	jp	Main_Menu

Write_Password:
	ld	hl, pass_op_info-1
	rst	20h
	call	_findsym
	ret	c
	ld	a, b			; convert bde to ahl
	ex	de, hl
	call	$4c3f			; add 3 to ahl to point it to program data
	call	_set_abs_dest_addr	; set the destination to be our password var
	xor	a
	ld	hl,10			; set number of bytes to copy
	call	_set_mm_num_bytes
	xor	a
	ld	hl, blank_pass		; point to the beginning of the data
	call	_set_abs_src_addr
	call	_mm_ldir		; copy the data
	ret


Create_Password:
	call	Delete_Password

	ld	hl, 10		; make the length 10
	call	_createstrng

	ld	a, b		; convert bde to ahl
	ex	de, hl
	call	$4c3f		; add 2 to ahl to point it to program data
	ld	c, 0
	call	_writeb_inc_ahl
	call	_writeb_inc_ahl
	ret

Delete_Password:
	ld	hl, pass_op_info-1	; load pass op info into OP1
	rst	20h
	call	_findsym
	call	nc, _delvar
	ret

Get_Password:
	ld	(hl), 0		; set size to zero
	push	hl
Get_Password_loop:
	call	_GetKy
	cp	0
	jr	z, Get_Password_loop

	cp	9			; check if we should end input
	jr	z, Get_Password_end
	pop	hl			; get start of password string
	push	hl
	push	af
	ld	a, (hl)			; get current size
	inc	a
	ld	(hl), a			; increment the size
	ld	e, a
	ld	d, 0
	add	hl, de
	pop	af
	ld	(hl), a
	ld	a, '*'
	call	_putc
	pop	hl
	push	hl
	ld	a, (hl)
	cp	8
	jr	nz, Get_Password_loop
Get_Password_end:
	pop	hl
	ret

Load_Password:
	ld	hl, pass_op_info-1
	rst	20h
	call	_findsym
	ret	c
	ld	a, b			; convert bde to ahl
	ex	de, hl
	call	$4c3f			; add 2 to ahl to point it to program data
	call	_set_abs_src_addr	; set the source to be our password var
	xor	a
	ld	hl,10			; set number of bytes to copy
	call	_set_mm_num_bytes
	xor	a
	ld	hl, blank_pass		; point to the beginning of the data
	call	_set_abs_dest_addr
	call	_mm_ldir		; copy the data
	ret

Check_Password:
	call	Load_Password

	ld	hl, blank_pass+1
	ld	de, input_pass

	ld	a, (de)
	cp	(hl)
	jr	nz, Incorrect
	cp	0
	jr	z, Correct
	call	_strcmp
	jr		nz, Incorrect
Correct:
	ld	a, 1
	ret
Incorrect:
	xor	a
	ret


key_op_info:
	.db	$4
key_str:
	.db	$10
	.db	"KEY",0

Description:
Title_str:
	.db	"Calc Manager v1.2 KWB",0
Install_str:
	.db	"1) Install CalcMan",0
UnInstall_str:
	.db	"2) Uninstall Old ",$10,"KEY",0
Change_Password_str:
	.db	"3) Change Password",0
Quit_str:
	.db	"4) Quit",0

installed_str:
	.db	"Installed       ",0

uninstalled_str:
	.db	"Uninstalled",0

Incorrect_str:
	.db	"Incorrect",0

old_prompt:
	.db	"Old:",0
new_prompt:
	.db	"New:",0
unlocked_str:
	.db	" unlckd",0
locked_str:
	.db	" locked",0
link_str:
	.db	"Link",0
deletemenu_str:
	.db	"Del",0
mem_str:
	.db	"Mem",0
pass_op_info:
	.db	$5,$1
	.db	"PASS",0

input_pass:
	.db	0,0,0,0,0,0,0,0,0

blank_pass:
	.db	0,0,0,0,0,0,0,0,0,0

dashes:
	.db	" --------",0
blank_line:
	.db	"                    ",0


;------END (SQRT)KEY LOADER------


;------BEGIN (SQRT)KEY PROGRAM------

code:
.org _asm_exec_ram-2			; set the start of code to the proper place
								; so calls and jps can be executed properly
	.db		$8e,$28				; token for an asm program
code_start:

	nop
	jp		Key_Start
	.dw		0000h
	.dw		Key_Description
Key_Description:
	NAME
	.db		" (DO NOT RUN!)",0
Key_Start:
	call	$479f				; pop OP1
	ld		a, ($d625)			; load a with the last key press
	push	af					; save the key press
	ld		a, (_CXCURAPP)		; load a with the current app state


check_selftest:
	cp		$21
	jr		nz, check_reset_mem

	ld		a, ($FC00)			; check specific pixels to see if we are in mode
	or		a					; or selftest
	jr		nz, check_reset_mem	; oops we are just in mode

	pop		af					; time to intercept key presses

	cp		$9					; enter
	jp		nz, skip_key

	call	Load_Password_key	; check if reset menu is locked
	ld		a, (blank_pass_key)
	and		%00000010
	cp		0
	ld		a, $9
	jp		z, skip_key			; no so continue normally

	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, dashes_key
	call	_puts
	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, input_pass_key
	call	Get_Password_key
	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, blank_line_key
	call	_puts
	call	Check_Password_key		; check for a password

	cp		0					; oops wrong password, no soup for you
	ld		a, 1
	jp		z, skip_key
	ld		a, $9

skip_key:
	cp		a					; clear flags so the OS doesn't try
	ret							; to handle the key after we quit


check_reset_mem:
	cp		$1D
	jr		nz, check_reset_defaults
	jr		reset_menu
check_reset_defaults:
	cp		$1E
	jr		nz, check_reset_all
	jr		reset_menu
check_reset_all:
	cp		$1F
	jr		nz, check_delete
reset_menu:
	pop		af					; time to intercept key presses

	cp		$32					; f-4
	jp		nz, skip_key

	call	Load_Password_key	; check if reset menu is locked
	ld		a, (blank_pass_key)
	and		%00000010
	cp		0
	ld		a, $32
	jp		z, skip_key			; no so continue normally

	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, dashes_key
	call	_puts
	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, input_pass_key
	call	Get_Password_key
	ld		hl, $0D00
	ld		(_curRow), hl
	ld		hl, blank_line_key
	call	_puts
	call	Check_Password_key		; check for a password

	cp		0					; oops wrong password, no soup for you
	ld		a, $31
	jr		z, skip_key
	ld		a, $32
	jr		skip_key			; got it, so reset

 
check_delete:
	cp		$23					; check we are in the delete mode
	jp		nz, check_link

	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; see if it exists
	jp		c, skip_and_pop		; no so quit

	ld		a, ($FC00 + $370)	; check specific pixels right above the menu bar
	or		a					; to see if a sub menu is active, if it is then
	jp		nz, skip_and_pop	; quit without writing our text


	ld		hl, $3A36			; load hl with coordinates for the third
	ld		(_penCol), hl		; menu item (centered for certain text)
	ld		hl, rename_str		; place our text here
	call	_vputs				; this is a simple but effective patch


;---
	ld		hl, ase_op_info-1
	rst		20h
	call	_findsym
	jr		c, ase_not_found_disp_prot
	ld		a, (hl)
	cp		$12
	jr		nz, ase_not_found_disp_prot

	ld		hl, $0A59
	add		hl, de
	ld		a, b
	call	_abs_mov10toop1

	ld		a, (_OP1+1)
	cp		51
	jr		z, skip_disp_prot
ase_not_found_disp_prot:
;---

	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; get the variable info

	ld		de, 4
	sbc		hl, de
	ld		a, (hl)				; get its protected/unprotected state
	and		%00000001			; mask out unused bits

	ld		hl, $3A4F			; set the coords for fourth menu item
	ld		(_penCol), hl

	ld		(protected), a
	cp		0
	jr		nz, disp_unprot		; its protected so diplay correct text
disp_prot:
	ld		hl, prot_str
	jr		disp_prot_text
disp_unprot:
	ld		hl, unprot_str
disp_prot_text:
	call	_vputs
skip_disp_prot:
	pop		af					; time to intercept key presses

	cp		$9					; enter
	jr		z, check_stats
	cp		$33					; f-3
	jr		z, check_stats
	cp		$32					; f-4
	jr		z, check_stats
	jp		skip_key

check_stats:
	ld		(key), a			; save the key pressed

	call	Load_Password_key	; check if delete menu is locked
	ld		a, (blank_pass_key)
	and		%00000100
	cp		0
	jr		nz, locked			; yes so dont allow use of delete and rename


	ld		hl, (_curRow)		; save the cursor row and column for
	push	hl					; the OS's use in refreshing the text

	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; get the variable info

	push	hl					; save the address of the variable symbol


;---
	ld		hl, ase_op_info-1
	rst		20h
	call	_findsym
	jr		c, ase_not_found_check_prot
	ld		a, (hl)
	cp		$12
	jr		nz, ase_not_found_disp_prot

	ld		hl, $0A59
	add		hl, de
	ld		a, b
	call	_abs_mov10toop1
	ld		a, (_OP1+1)
	cp		51
	jr		z, skip_check_prot
ase_not_found_check_prot:
;---
	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; get the variable info

	ld		a, (key)			; check this next so we can individually lock
	cp		$32					; out the following functions
	jp		z, protect_unprotect

	ld		a, (protected)		; check if this specific variable is protected
	cp		0
	jr		nz, locked_pop		; yes so lock out functions
skip_check_prot:
	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; get the variable info

	ld		a, (key)			; everything is fine so allow renaming
	cp		$33					; and deleting
	jp		z, rename
	pop		hl
	pop		hl
	cp		a
	ret

locked_pop:
	pop		hl					; function is locked so we dont want any
	pop		hl					; keypresses going through
locked:
	xor		a
	cp		a
	ret

rename:
	ld		hl, (_curRow)		; increment the cursor column
	inc		h					; so we are at the start of the
	ld		(_curRow), hl		; variable name

	ld		hl, blank			; clear the variable name from the screen
	call	_puts

	ld		hl, (_curRow)
	ld		h, 1				; reset the column to the start of
	ld		(_curRow), hl		; the variable name

	xor		a
	ld		(case), a			; reset the case flag we will be using
	ld		(size), a			; reset the variable length

	ld		a, $E1
 	call	_putmap
rename_loop:
	ld	a, (case)				; get the current case we are in
	add	a, $E1				; add to above to get correct cursor
	call	_putmap				; display it

	ld		a, (size)			; check to make sure the size doesn't
	cp		8					; get longer than 8 characters, if it
	jp		z, putname			; does then end input and save it

	call	set_case			; load the address of the correct keymap
								; into hl and the correct letter offset
								; into b

	push	bc
	push	hl					; save the address
	call	_GetKy				; get a key
	pop		hl					; restore address
	pop		bc

	ld		e, a				; add the key value to the keymap address
	ld		d, 0				; to get the value of the key pressed
	add		hl, de
	ld		a, (hl)
	cp		0					; no key
	jr	z, rename_loop		; restart the loop
	cp		1					; enter
	jp		z, putname			; save the new name
	cp		2					; alpha
	jr		z, alpha			; swap between alpha modes
	cp		3					; second
	jr		z, second			; change to second mode
	cp		4					; exit
	jr		z, noname			; quit without renaming
	cp		5					; del
	jr		z, backspace		; go back one character if possible
	add		a, b				; no special key was pressed so display
	call	_putc				; the correct character

	ld		b, a				; save the character in b
	ld		hl, name			; load the offset of the name into hl
	ld		a, (size)			; load the size of name into a
	ld		e, a				; load de with a
	ld		d, 0				; add the offset of the name with the
	ld		a, b				; name length to get the offset to
	add 	hl, de				; put the character in
	ld		(hl), a				; load new character

	ld		a, (size)			; increment the size by one
	inc		a
	ld		(size), a

	ld		a, (case)			; display the correct cursor
	add		a, $E1
	call	_putmap
	jr		rename_loop			; restart the loop

set_case:						; get the offset for the correct keymap
								; and the value to add to the char
	ld		a, (case)			; check what mode we are in
	cp		2					; are we in second mode
	jr		z, set_case_second	; yes so get the second key map into hl
	ld		hl, alpha_keymap	; no so get the alpha key map into hl
	ld		b, 0					; reset the added value
	cp		0					; we are in ALPHA mode
	ret		z					; so return
	ld		b, 32				; we are in alpha mode so we need to add 32
	ret							; to the character to get the lower case char
set_case_second:
	ld		hl, second_keymap	; load hl with the second keymap offset
	ld	b, 0		; reset the added value
	ret

alpha:
	ld		hl, case			; load the current case into a
	ld		a, (hl)
	cp		0					; are we in upper case mode now?
	jr		z, alpha_lower		; yes, so set it to lower case mode
	ld		(hl), 0				; no, so set it to upper case mode
	jr		rename_loop			; restart the loop
alpha_lower:
	ld		(hl), 1				; set case to lower case
	jp		rename_loop			; restart the loop
	
second:
	ld	a, 2	; set the case to second mode
	ld		(case), a
	jp		rename_loop	; restart the loop

backspace:						; erase the last character if possible
	ld		a, (size)			; make sure the size is greater than zero
	cp		0
	jp		z, rename_loop		; nope, so dont backspace, restart the loop
	dec		a					; yup so decrease size by one
	ld		(size), a			; set the size
	ld		hl, (_curRow)		; write a ' ' over the last character
	ld		a, ' '
	call	_putmap
	dec		h					; decrement the column
	ld		(_curRow), hl
	jp		rename_loop			; restart the loop

noname:							; dont save the name
	pop	hl	; pop the address of the variable symbol
	pop	hl					; pop the row, col coords
	ld	a, $2E	; refresh the screen on quit
	cp		a
	ret

putname:
	ld		hl, $C1EF
	ld		de, name-1
	call	_strcmp
	jr		z, noname

	ld		a, (size)			; get the size of the new variable name
	cp		0					; its zero so we want to quit without save
	jr		z, noname

	ld		hl, name-2
	rst		20h
	rst		10h				; make sure that there isn't already a variable
	jr		nc, noname		; of this name, if so then quit


	ld		hl, name-2
	rst		20h
	ld		hl, 1
	call	_createstrng
	ld		de, temp_vat2+4
	ld		bc,	5
	lddr

	pop		hl					; pop the address of the variable's symbol
	push	hl
	ld		de, temp_vat+4		; copy 5 bytes from the vat
	ld		bc,	5
	lddr

	ld		hl, name-2
	rst		20h
	rst		10h
	ld		de, temp_vat+4
	ex		de, hl
	ld		bc,	5
	lddr

	pop		hl
	ld		de, temp_vat2+4		; copy 5 bytes from the vat
	ex		de, hl
	ld		bc,	5
	lddr

	ld		hl, $C1EE
	rst		20h
	rst		10h
	call	_delvar				; delete the old variable


	pop		hl					; pop the row, col coords
	ld		a, $2E				; refresh the screen
	cp		a
	ret							; quit

	ret							; quit

protect_unprotect:
	ld		hl, $C1EE			; this address holds the current variable
	rst		20h					; name selected, load it into OP1
	call	_findsym			; get the variable info
	ld		de, 4
	sbc		hl, de
	ld		a, (hl)				; check whether it is currently protected or not
	xor		%00000001			; flip that last bit
	ld		(hl), a	
	pop		hl					; pop everything before we quit
	pop		hl
	xor		a
	cp		a
	ret							; quit

check_link:
	cp		$1B
	jp		nz, skip_and_pop

	ld		hl, ($C232)			; check if snd85 is the third menu
	ld		a, h				; item
	cp		$59
	jr		nz, check_string
	ld		a, l
	cp		$BE
	jr		nz, check_string

	pop		af
	push	af

	cp		K_F1
	jr		z, test_link_lock
	cp		K_F2
	jr		z, test_link_lock
	cp		K_F3
	jr		z, test_link_lock
	jr		skip_and_pop
test_link_lock:
	call	Load_Password_key
	ld		a, (blank_pass_key)
	and		%00000001
	cp		0
	jr		z, skip_and_pop	

	ld		hl, $0106
	ld		(_curRow), hl
	ld		hl, dashes_key
	call	_puts
	ld		hl, $0106
	ld		(_curRow), hl
	ld		hl, input_pass_key
	call	Get_Password_key
	ld		hl, $0106
	ld		(_curRow), hl
	ld		hl, blank_line_key
	call	_puts
	call	Check_Password_key		; check for a password
	cp		0
	jr		nz, skip_and_pop		; ok it was right
	pop		af
	xor		a
	cp		a
	ret


check_string:
	ld		hl, ($C232)			; check if string is the third menu
	ld		a, h				; item
	cp		$5B
	jr		nz, skip_and_pop	
	ld		a, l
	cp		$8F
	jr		nz, skip_and_pop	

	ld		hl, $5B73			; load the address for the program listing
	ld		($C234), hl			; function into the fourth item

	ld		hl, $3A4F			; load hl with coordinates for the fourth
	ld		(_penCol), hl		; menu item (centered for certain text)
	ld		hl, prgm_str
	call	_vputs

	ld		hl, $5B36			; load the address for the ALL listing
	ld		($C236), hl			; function into the fifth item

	ld		hl, $3A6C			; load hl with coordinates for the fifth
	ld		(_penCol), hl		; menu item (centered for certain text)
	ld		hl, all_str
	call	_vputs


skip_and_pop:
	pop		af					; make sure we have popped a if needed
	cp		a					; clear flags so the OS doesn't try
	ret							; to handle the key after we quit


Load_Password_key:
	ld		hl, pass_op_info_key-1
	rst		20h
	call	_findsym
	ret		c
	ld		a, b		; convert bde to ahl
	ex		de, hl
	call	$4c3f		; add 2 to ahl to point it to program data
	call	_set_abs_src_addr	; set the source to be our password var
	xor		a
	ld		hl,10				; set number of bytes to copy
	call	_set_mm_num_bytes
	xor		a
	ld		hl, blank_pass_key	; point to the beginning of the data
	call	_set_abs_dest_addr
	call	_mm_ldir	; copy the data
	ret

Check_Password_key:
	call	Load_Password_key

	ld		hl, blank_pass_key+1
	ld		de, input_pass_key

	ld		a, (de)
	cp		(hl)
	jr		nz, Incorrect_key
	cp		0
	jr		z, Correct_key
	call	_strcmp
	jr		nz, Incorrect_key
Correct_key:
	ld		a, 1
	ret
Incorrect_key:
	xor		a
	ret


Get_Password_key:
	ld		(hl), 0				; set size to zero
	push	hl
Get_Password_loop_key:
	call	_GetKy
	cp		0
	jr		z, Get_Password_loop_key

	cp		9					; check if we should end input
	jr		z, Get_Password_end_key
	pop		hl					; get start of password string
	push	hl
	push	af
	ld		a, (hl)				; get current size
	inc		a
	ld		(hl), a				; increment the size
	ld		e, a
	ld		d, 0
	add		hl, de
	pop		af
	ld		(hl), a
	ld		a, '*'
	call	_putc
	pop		hl
	push	hl
	ld		a, (hl)
	cp		8
	jr		nz, Get_Password_loop_key
Get_Password_end_key:
	pop		hl
	ret


prgm_str:
	.db		"PRGM",0
all_str:
	.db		"ALL",0

pass_op_info_key:
	.db		$5,$1
	.db		"PASS",0

ase_op_info:
	.db		3, "ase",0
input_pass_key:
	.db		0,0,0,0,0,0,0,0,0

blank_pass_key:
	.db		0,0,0,0,0,0,0,0,0,0

dashes_key:
	.db		"--------",0
blank_line_key:
	.db		"                     ",0,0

alpha_keymap:
	.db		$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db		$01,'X','T','O','J','E',$00,$00
	.db		$00,'W','S','N','I','D',$00,$00
	.db		'Z','V','R','M','H','C',$00,$05
	.db		'Y','U','Q','L','G','B',$00,$00
	.db		$00,$00,'P','K','F','A',$00,$02
	.db		$00,$00,$00,$00,$00,$03,$04,$00

second_keymap:
	.db		$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db		$01,$00,$00,$00,$00,$00,$00,$00
	.db		$D2,'3','6','9',$00,$00,$00,$00
	.db		'.','2','5','8',$00,$00,$00,$05
	.db		'0','1','4','7',$00,$00,$00,$00
	.db		$00,$00,$00,$00,$00,$00,$00,$02
	.db		$00,$00,$00,$00,$00,$03,$04,$00

case:
	.db		0
newlength:			; multiple labels to make the code a little
key:				; bit easier to read
	.db		0

type:				; multiple labels to make the code a little
sizeaddr:			; bit easier to read
	.db		0,0

blank:
	.db		"        ",0
size:
	.db		0
name:
	.db		0,0,0,0,0,0,0,0,0
temp_vat:
	.db		0,0,0,0,0
temp_vat2:
	.db		0,0,0,0,0
bde:
	.db		0,0,0
strng:
	.db		"STRNG",0
prgm
	.db		"PRGM ",0
rename_str:
	.db		"Name",0
prot_str:
	.db		"  Prot ",0
unprot_str:
	.db		"UnPrt",0,0
protected:
	.db		0,0



code_end:

.end
