note_b3 equ 4830
note_c4 equ 4560
note_cs4 equ 4304
note_d4 equ 4063
note_ds4 equ 3834
note_e4 equ 3619
note_f4 equ 3416
note_fs4 equ 3224
note_g4 equ 3043
note_gs4 equ 2873
note_a4 equ 2711
note_as4 equ 2559
note_b4 equ 2415
note_c5 equ 2280
note_cs5 equ 2152
note_d5 equ 2031
note_ds5 equ 1917
note_e5 equ 1809
note_f5 equ 1715
note_fs5 equ 1612
note_g5 equ 1521
note_gs5 equ 1436
note_a5 equ 1355
note_as5 equ 1292
note_b5 equ 1207
note_c6 equ 1140
note_cs6 equ 1076
note_d6 equ 1015
note_ds6 equ 958
note_e6 equ 904
note_f6 equ 858
note_fs6 equ 806
note_g6 equ 760

.model small
.stack
.data
msg1 db "Press a key to hear a beep",10,13,"$"
msg2 db "press a key to stop$"
; starting from 32 (space) till 149 (ï)
key_bind dw 0       ;space
        dw 0        ;!
        dw 0        ;"
        dw 0        ;#
        dw 0        ;$
        dw 0        ;%
        dw 0        ;&
        dw 0        ;'
        dw 0        ;(
        dw 0        ;)
        dw 0        ;*
        dw note_g6  ;+
        dw note_c5  ;,
        dw note_e5  ;-
        dw note_d5  ;.
        dw 0        ;/
	dw note_ds6 ;0
        dw 0        ;1
        dw note_cs5 ;2
        dw note_ds5 ;3
        dw 0        ;4
        dw note_fs5 ;5
        dw note_gs5 ;6
        dw note_as5 ;7
        dw 0        ;8
	dw note_cs6 ;9
        dw 0        ;:
        dw 0        ;;
        dw note_b3  ;<
        dw 0        ;=
        dw 02fffh   ;>
        dw 0        ;?
        dw 0        ;@
        dw 0        ;A
        dw note_g4  ;B
        dw note_e4  ;C
        dw note_ds4 ;D
        dw note_e5  ;E
        dw 0        ;F
        dw note_fs4 ;G
        dw note_gs4 ;H
        dw note_c6  ;I
        dw note_as4 ;J
        dw 0        ;K
        dw note_cs5 ;L
        dw note_b4  ;M
        dw note_a4  ;N
	dw note_d6  ;O
	dw note_e6  ;P
        dw note_c5  ;Q
        dw note_f5  ;R
        dw note_cs4 ;S
        dw note_g5  ;T
        dw note_b5  ;U
        dw note_f4  ;V
        dw note_d5  ;W
        dw note_d4  ;X
        dw note_a5  ;Y
        dw note_c4  ;Z
        dw 0        ;[
        dw 0        ;\
        dw 0        ;]
        dw 0        ;^
        dw 0        ;_
        dw 0        ;`
        dw 0        ;a
        dw note_g4  ;b
        dw note_e4  ;c
        dw note_ds4 ;d
        dw note_e5  ;e
        dw 0        ;f
        dw note_fs4 ;g
        dw note_gs4 ;h
        dw note_c6  ;i
        dw note_as4 ;j
        dw 0        ;k
        dw note_cs5 ;l
        dw note_b4  ;m
        dw note_a4  ;n
	dw note_d6  ;o
	dw note_e6  ;p
        dw note_c5  ;q
        dw note_f5  ;r
        dw note_cs4 ;s
        dw note_g5  ;t
        dw note_b5  ;u
        dw note_f4  ;v
        dw note_d5  ;w
        dw note_d4  ;x
        dw note_a5  ;y
        dw note_c4  ;z
        dw 0        ;{
        dw 0        ;|
        dw 0        ;}
        dw 0        ;~
        dw 0        ;?
        dw 0        ;Ä
        dw 0        ;Å
        dw 0        ;Ç
        dw 0        ;É
        dw 0        ;Ñ
        dw 0        ;Ö
        dw 0        ;Ü
        dw 0        ;á
        dw 0        ;à
        dw 0        ;â
        dw note_f6  ;ä
        dw 0        ;ã
        dw 0        ;å
        dw note_fs6 ;ç
        dw 0        ;é
        dw 0        ;è
        dw 0        ;ê
        dw 0        ;ë
        dw 0        ;í
        dw 0        ;ì
        dw 0        ;î
        dw note_ds5 ;ï
.code
.startup

;set up speaker
out 43h, al
;print message
lea dx, msg1
mov ah,9
int 21h

l:  mov ah,1
    int 21h
    cmp al, 13
    je ending
    
    mov bl,al
    xor bh,bh
    cmp al,' '
    jb no_note
    cmp al, 'ï'
    ja no_note
    
    sub bx,' '
    cmp bx,0
    je special_space
    shl bx,1
    mov dx, key_bind[bx]
    cmp dx,0
    je no_note
    jmp setfreq
    
no_note:jmp l

special_space:mov dx, 2
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov dx, 4
    mov ax, note_b5
    call play_AX_l_DX
    mov dx,1
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b4
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    mov ax, note_b4
    call play_AX_l_DX
    
    mov dx,2
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov dx, 4
    mov ax, note_b5
    call play_AX_l_DX
    mov dx,1
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b4
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    mov ax, note_b4
    call play_AX_l_DX
    
    mov dx,2
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_d6
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_g5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_a5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov dx,8
    mov ax, note_b5
    call play_AX_l_DX
    mov dx,2
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_fs4
    call play_AX_l_DX
    mov ax, note_e4
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    
    mov dx,2
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_c4
    call play_AX_l_DX
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_e4
    call play_AX_l_DX
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_c4
    call play_AX_l_DX
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_e4
    call play_AX_l_DX
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    mov ax, note_b5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    
    mov ax, note_d6
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    mov ax, note_d6
    call play_AX_l_DX
    mov ax, note_d4
    call play_AX_l_DX
    mov ax, note_c6
    call play_AX_l_DX
    mov ax, note_e4
    call play_AX_l_DX
    mov ax, note_a5
    call play_AX_l_DX
    mov ax, note_fs4
    call play_AX_l_DX
    mov dx, 8
    mov ax, note_g5
    call play_AX_l_DX
    mov ax, note_g4
    call play_AX_l_DX
    jmp l
       
    ;set frequency
setfreq:mov ax, dx
    out 42h,al
    mov al,ah
    out 42h,al
    
    ;generate sound (already done)
    in al, 61h
    or al, 3
    out 61h, al
    jmp l
ending:

;stop sound
in al, 61h
and al, not 3
out 61h,al

.exit


play_AX_l_DX proc near
    push ax
    push bx
    push cx
    push dx
    push es
    
    ;set frequency
    out 42h,al
    mov al,ah
    out 42h,al
    
    ;turn on
    in al, 61h
    or al, 3
    out 61h, al
    
    ;wait a bit
    xor cx,cx
    mov es,cx
    ;xor dx,dx
   ;CX:DX stores the tick count to wait
    add dx,es:[46Ch]
    adc cx,es:[46Eh]

w_l:mov bx,es:[46Ch]
    mov ax,es:[46Eh]
    sub bx,dx
    sbb ax,cx
    jb w_l
    
    in al, 61h
    and al, not 3
    out 61h,al
    
    pop es
    pop dx
    pop cx
    pop bx
    pop ax

    ret
play_AX_l_DX endp

end
