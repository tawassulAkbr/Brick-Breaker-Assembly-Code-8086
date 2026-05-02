.model small
.386
.stack 100h

.data
    current_screen  db 0 ; 0=Home, 1=Name, 2=Menu, 3=Instructions, 4=Scores, 5=Game
    menu_selected   db 0 ; 0=Start, 1=Inst, 2=Score, 3=Exit
    bg_color        db 6 ; Default brown background

    player_name     db 16 dup(0)
    name_len        db 0
    row_colors      db 0Eh, 0Ch, 0Ah, 0Bh, 0Dh, 09h, 2Ah, 04h
    rect_height     dw 10
    paddle_x        dw 130
    ball_x          dw 158
    ball_y          dw 145
    ball_dx         dw 2
    ball_dy         dw -2

    wide_box_top    db '+----------------------------------+', 0
    wide_box_empty  db '|                                  |',  0
    wide_box_bot    db '+----------------------------------+', 0

    title_box_top   db '+--------------------------+', 0
    title_msg       db '|     BRICK BREAKER        |', 0
    title_box_bot   db '+--------------------------+', 0
    instruction_msg db 'PRESS ANY KEY TO START!', 0

    prompt_top      db '+--------------------------+', 0
    prompt_msg      db '| Enter Player Name:       |', 0
    prompt_mid      db '|                          |', 0
    prompt_bot      db '+--------------------------+', 0
    
    menu_start      db '      Start Game          ', 0
    menu_inst       db '      Instructions        ', 0
    menu_score      db '      High Scores         ', 0
    menu_exit       db '      Exit                ', 0

    menu_box_top    db '+--------------------------+', 0
    menu_box_empty  db '|                          |', 0
    menu_box_bot    db '+--------------------------+', 0

    instr_title     db 'INSTRUCTIONS', 0
    instr_1         db 'Use Left/Right to move', 0
    instr_2         db 'Bounce ball to break bricks', 0
    instr_3         db 'Do not let the ball fall!', 0
    instr_ret       db 'Press Enter to return', 0

    score_title     db 'HIGH SCORES', 0
    score_1         db '1. Tawassul - 5000', 0
    score_2         db '2. Zubair - 4000', 0
    score_3         db '3. Zain - 3000', 0
    
    hud_score       db 'Score: 0000', 0
    hud_lives       db 'Lives: 3', 0
    hud_level       db 'Level: 1', 0
    hud_player      db 'Player: ', 0

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Enter VGA Mode 13h
    mov ax, 13h
    int 10h

GameLoop:
    call ClearScreen

    cmp current_screen, 0
    jne G_1
    call ShowHomePROC
    jmp GameLoop
G_1:
    cmp current_screen, 1
    jne G_2
    call ShowNameInputPROC
    jmp GameLoop
G_2:
    cmp current_screen, 2
    jne G_3
    call ShowMenuPROC
    jmp GameLoop
G_3:
    cmp current_screen, 3
    jne G_4
    call ShowInstrPROC
    jmp GameLoop
G_4:
    cmp current_screen, 4
    jne G_5
    call ShowScoresPROC
    jmp GameLoop
G_5:
    cmp current_screen, 5
    jne G_End
    call ShowGamePROC
G_End:
    jmp GameLoop

ShowHomePROC proc
    ; Top of the box
    mov dh, 7
    mov dl, 8
    mov si, offset title_box_top
    mov bl, 0Fh ; White
    call PrintString

    ; The title itself
    mov dh, 8
    mov dl, 8
    mov si, offset title_msg
    mov bl, 0Bh ; Light Cyan for Title
    call PrintString

    ; Bottom of the box
    mov dh, 9
    mov dl, 8
    mov si, offset title_box_bot
    mov bl, 0Fh ; White
    call PrintString

    ; Footer instruction
    mov dh, 23
    mov dl, 9
    mov si, offset instruction_msg
    mov bl, 0Eh ; Yellow
    call PrintString

    mov ah, 00h
    int 16h
    mov current_screen, 1 ; Goto Name Input
    ret

ShowHomePROC endp

ShowNameInputPROC proc
    mov dh, 9
    mov dl, 8
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString

    mov dh, 10
    mov dl, 8
    mov si, offset prompt_msg
    mov bl, 0Ah ; Light Green
    call PrintString

    mov dh, 11
    mov dl, 8
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString

    mov dh, 12
    mov dl, 8
    mov si, offset prompt_bot
    mov bl, 0Fh
    call PrintString

    ; Very simple name input reading
NameInputLoop:
    ; Erase previous name segment (reprint empty mid)
    mov dh, 11
    mov dl, 8
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString

    ; Print typed name
    mov dh, 11
    mov dl, 12
    mov si, offset player_name
    mov bl, 0Fh ; White for typed text
    call PrintString

    mov ah, 00h
    int 16h
    cmp al, 13 ; Enter key
    je NameInputDone
    cmp al, 8 ; Backspace
    je NameInputBS
    
    ; Add char
    xor bx, bx
    mov bl, name_len
    cmp bl, 15
    jge NameInputLoop
    mov player_name[bx], al
    inc name_len
    mov player_name[bx+1], 0

    call ClearScreen
    mov dh, 9
    mov dl, 8
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString
    mov dh, 10
    mov dl, 8
    mov si, offset prompt_msg
    mov bl, 0Ah
    call PrintString
    mov dh, 11
    mov dl, 8
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString
    mov dh, 12
    mov dl, 8
    mov si, offset prompt_bot
    mov bl, 0Fh
    call PrintString
    jmp NameInputLoop

NameInputBS:
    cmp name_len, 0
    je NameInputLoop
    dec name_len
    xor bx, bx
    mov bl, name_len
    mov player_name[bx], 0

    call ClearScreen
    mov dh, 9
    mov dl, 8
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString
    mov dh, 10
    mov dl, 8
    mov si, offset prompt_msg
    mov bl, 0Ah
    call PrintString
    mov dh, 11
    mov dl, 8
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString
    mov dh, 12
    mov dl, 8
    mov si, offset prompt_bot
    mov bl, 0Fh
    call PrintString
    jmp NameInputLoop

NameInputDone:
    mov current_screen, 2 ; Goto Menu
    ret

ShowNameInputPROC endp

ShowMenuPROC proc
    ; Draw Box
    mov dh, 6
    mov dl, 10
    mov si, offset menu_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 7
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 8
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 9
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 10
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 11
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 12
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 13
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 14
    mov dl, 10
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 15
    mov dl, 10
    mov si, offset menu_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 8
    mov dl, 11
    mov si, offset menu_start
    mov bl, 0Fh
    cmp menu_selected, 0
    jne M1
    mov bl, 0Ch ; Light Red Highlight
M1: call PrintString

    mov dh, 10
    mov dl, 11
    mov si, offset menu_inst
    mov bl, 0Fh
    cmp menu_selected, 1
    jne M2
    mov bl, 0Ch
M2: call PrintString

    mov dh, 12
    mov dl, 11
    mov si, offset menu_score
    mov bl, 0Fh
    cmp menu_selected, 2
    jne M3
    mov bl, 0Ch
M3: call PrintString

    mov dh, 14
    mov dl, 11
    mov si, offset menu_exit
    mov bl, 0Fh
    cmp menu_selected, 3
    jne M4
    mov bl, 0Ch
M4: call PrintString

    mov ah, 00h
    int 16h
    cmp ah, 48h ; Up arrow
    je MenuUp
    cmp ah, 50h ; Down arrow
    je MenuDown
    cmp al, 13 ; Enter
    je MenuSelect
    ret

MenuUp:
    cmp menu_selected, 0
    je GameLoop
    dec menu_selected
    ret
MenuDown:
    cmp menu_selected, 3
    je GameLoop
    inc menu_selected
    ret
MenuSelect:
    cmp menu_selected, 0
    je StartGame
    cmp menu_selected, 1
    je GoInstr
    cmp menu_selected, 2
    je GoScore
    cmp menu_selected, 3
    je ExitGame
StartGame:
    mov bg_color, 0 ; 0 = Black background!
    mov current_screen, 5
    ret
GoInstr:
    mov bg_color, 12 ; Light Red 0Ch
    mov current_screen, 3
    ret
GoScore:
    mov bg_color, 2 ; Green 02h
    mov current_screen, 4
    ret
ExitGame:
    jmp ExitProgram

ShowMenuPROC endp

ShowInstrPROC proc
    mov dh, 4
    mov dl, 3
    mov si, offset wide_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 5
    mov cx, 12
InstrBox:
    push cx
    mov dl, 3
    mov si, offset wide_box_empty
    mov bl, 0Fh
    call PrintString
    inc dh
    pop cx
    loop InstrBox

    mov dl, 3
    mov si, offset wide_box_bot
    mov bl, 0Fh
    call PrintString

    mov dh, 5
    mov dl, 14
    mov si, offset instr_title
    mov bl, 0Bh ; Light Cyan
    call PrintString

    mov dh, 8
    mov dl, 6
    mov si, offset instr_1
    mov bl, 0Fh ; White
    call PrintString

    mov dh, 10
    mov dl, 6
    mov si, offset instr_2
    mov bl, 0Ah ; Light Green
    call PrintString

    mov dh, 12
    mov dl, 6
    mov si, offset instr_3
    mov bl, 0Ch ; Light Red
    call PrintString

    mov dh, 14
    mov dl, 9
    mov si, offset instr_ret
    mov bl, 08h ; Dark Gray
    call PrintString

    mov ah, 00h
    int 16h
    cmp al, 13
    je ReturnMenu
    ret

ShowInstrPROC endp

ShowScoresPROC proc
    mov dh, 4
    mov dl, 3
    mov si, offset wide_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 5
    mov cx, 12
ScoreBox:
    push cx
    mov dl, 3
    mov si, offset wide_box_empty
    mov bl, 0Fh
    call PrintString
    inc dh
    pop cx
    loop ScoreBox

    mov dl, 3
    mov si, offset wide_box_bot
    mov bl, 0Fh
    call PrintString

    mov dh, 5
    mov dl, 14
    mov si, offset score_title
    mov bl, 0Bh ; Light Cyan
    call PrintString

    mov dh, 8
    mov dl, 6
    mov si, offset score_1
    mov bl, 0Eh ; Yellow for 1st
    call PrintString

    mov dh, 10
    mov dl, 6
    mov si, offset score_2
    mov bl, 07h ; Light Gray for 2nd
    call PrintString

    mov dh, 12
    mov dl, 6
    mov si, offset score_3
    mov bl, 06h ; Brown/Orange for 3rd
    call PrintString

    mov dh, 14
    mov dl, 9
    mov si, offset instr_ret
    mov bl, 08h ; Dark Gray
    call PrintString

    mov ah, 00h
    int 16h
    cmp al, 13
    je ReturnMenu
    ret

ReturnMenu:
    mov bg_color, 6
    mov current_screen, 2
    ret

ShowScoresPROC endp

ShowGamePROC proc
    ; Draw Bricks: 8 rows, 8 columns
    mov si, 0        ; row index
    mov bx, 10       ; starting y position (shifted up!)

DrawRowLoop:
    mov cx, 25       ; starting x position resets for every row
    push si
    mov di, 8        ; 8 bricks per row
    mov al, row_colors[si] ; load different color for each row

DrawColLoop:
    push bx          ; PROTECT BX
    push cx          ; PROTECT CX
    push ax          ; PROTECT AX
    mov rect_height, 8 ; brick height
    mov dx, 32       ; width of 32 pixels
    call DrawRect
    pop ax           ; restore AX
    pop cx           ; restore CX
    pop bx           ; restore BX

    add cx, 35       ; next x = 32 width + 3 gap
    dec di
    jnz DrawColLoop

    add bx, 12       ; next y
    pop si
    inc si
    cmp si, 5        ; limit to exactly 5 rows
    jl DrawRowLoop

    ; Draw Slider (Paddle)
    mov bx, 155     ; y position
    mov cx, paddle_x ; dynamic x position
    mov dx, 60       ; paddle width
    mov al, 0Ch      ; color Light Red
    mov rect_height, 8 ; paddle height
    call DrawRect

    ; Draw Round Ball 
    ; Top line
    mov bx, ball_y   ; dynamic y
    mov cx, ball_x
    inc cx           ; indent 1
    mov dx, 4        ; line width
    mov al, 0Fh      ; color White
    mov rect_height, 1 ; line height
    call DrawRect

    ; Mid Body
    mov bx, ball_y
    inc bx           ; mid start
    mov cx, ball_x   ; expand to full 6 width
    mov dx, 6        
    mov rect_height, 4 ; inner height
    call DrawRect

    ; Bottom Line
    mov bx, ball_y
    add bx, 5        ; bottom start
    mov cx, ball_x
    inc cx           ; indent 1
    mov dx, 4        
    mov rect_height, 1 ; line height
    call DrawRect

    ; Draw Bottom HUD
    mov dh, 22
    mov dl, 2
    mov si, offset hud_score
    mov bl, 0Fh
    call PrintString

    mov dh, 22
    mov dl, 14
    mov si, offset hud_lives
    mov bl, 0Fh
    call PrintString

    mov dh, 22
    mov dl, 25
    mov si, offset hud_level
    mov bl, 0Fh
    call PrintString

    mov dh, 23
    mov dl, 2
    mov si, offset hud_player
    mov bl, 0Fh
    call PrintString

    mov dh, 23
    mov dl, 10
    mov si, offset player_name
    mov bl, 0Eh
    call PrintString

    ; --- GAME LOGIC ---
    ; Move Ball
    mov ax, ball_dx
    add ball_x, ax
    mov ax, ball_dy
    add ball_y, ax

    ; Bounce Walls Left/Right
    cmp ball_x, 5
    jge CheckRight
    mov ball_dx, 2
CheckRight:
    cmp ball_x, 310
    jle CheckTop
    mov ball_dx, -2

CheckTop:
    ; Bounce Top Wall
    cmp ball_y, 0
    jge CheckPaddle
    mov ball_dy, 2

CheckPaddle:
    ; Bounce Paddle (ball bottom reaches paddle top)
    cmp ball_y, 149
    jl CheckBottom
    mov ax, ball_x
    add ax, 6    ; ball right edge
    cmp ax, paddle_x
    jl CheckBottom ; left of paddle
    mov cx, paddle_x
    add cx, 60   ; paddle right edge
    cmp ball_x, cx
    jg CheckBottom ; right of paddle

    ; Hit paddle
    mov ball_dy, -2
    mov ball_y, 148 ; Prevent getting stuck in paddle

CheckBottom:
    ; Fall off bottom
    cmp ball_y, 190
    jl CheckInput
    ; Reset position to continue testing
    mov ball_x, 158
    mov ball_y, 145
    mov paddle_x, 130

CheckInput:
    ; Non-blocking keyboard check
    mov ah, 01h
    int 16h
    jz WaitLoop ; no key pressed

    ; Consume key
    mov ah, 00h
    int 16h

    cmp al, 27 ; Esc = exit to menu
    je ReturnMenu

    cmp ah, 4Bh ; Left Arrow
    jne CheckRightKey
    cmp paddle_x, 5
    jle WaitLoop
    sub paddle_x, 10
    jmp WaitLoop

CheckRightKey:
    cmp ah, 4Dh ; Right Arrow
    jne WaitLoop
    cmp paddle_x, 255
    jge WaitLoop
    add paddle_x, 10

WaitLoop:
    ; Delay to slow down frame rate (~30 ms limit)
    mov cx, 00h  ; High word 
    mov dx, 6000h  ; Low word (adjust for speed)
    mov ah, 86h
    int 15h

    ret

ShowGamePROC endp

ExitProgram:
    mov ax, 03h
    int 10h
    mov ah, 4Ch
    int 21h
main endp

; ======================================================
; HELPER PROCEDURE: ClearScreen
; ======================================================
ClearScreen proc
    push ax
    push cx
    push di
    push es
    mov ax, 0A000h
    mov es, ax
    xor di, di
    mov al, bg_color   ; Use variable background color
    mov cx, 64000
    rep stosb
    pop es
    pop di
    pop cx
    pop ax
    ret
ClearScreen endp

; ======================================================
; HELPER PROCEDURE: DrawRect
; BX = Y, CX = X, DX = Width, AL = Color
; ======================================================
DrawRect proc
    push ax
    push cx
    push dx
    push si
    push di
    push es

    mov si, ax ; save color
    
    mov ax, 0A000h
    mov es, ax

    ; calc di = y * 320 + x
    push dx    ; PROTECT DX (WIDTH) FROM MUL
    mov ax, 320
    mul bx
    pop dx     ; RESTORE DX
    add ax, cx
    mov di, ax

    mov cx, rect_height ; Use explicit height
DrawRectH:
    push cx
    mov cx, dx ; Width
    mov ax, si ; color
DrawRectW:
    mov es:[di], al
    inc di
    loop DrawRectW
    
    pop cx
    add di, 320
    sub di, dx ; Move to next line start
    loop DrawRectH

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret
DrawRect endp

; ======================================================
; HELPER PROCEDURE: PrintString
; Inputs: DH = Row, DL = Col, SI = String Offset, BL = Color
; ======================================================
PrintString proc
    push ax
    push cx
    push dx
    push si
    
NextChar:
    mov ah, 02h
    mov bh, 0
    int 10h

    lodsb
    cmp al, 0
    je DonePrinting

    mov ah, 09h
    mov cx, 1
    int 10h

    inc dl
    jmp NextChar

DonePrinting:
    pop si
    pop dx
    pop cx
    pop ax
    ret
PrintString endp

end main