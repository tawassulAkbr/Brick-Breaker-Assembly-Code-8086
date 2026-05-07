.model small
.386
.stack 100h

.data
    current_screen  db 0 ; 0=Home, 1=Name, 2=Menu, 3=Instructions, 4=Scores, 5=Game
    menu_selected   db 0 ; 0=Start, 1=Inst, 2=Score, 3=Exit
    bg_color        db 6 ; Default brown background
    
    ; Day 1 Iteration 2 requirements
    ballX dw 160
    ballY dw 100
    ballDX dw 1
    ballDY dw -1
    paddleX dw 130
    paddleY dw 155
    paddleWidth dw 60
    lives db 3
    score dw 0
    ballColor db 0Fh
    bgColorGame db 0

    bricks db 40 dup(1) ; 5 rows * 8 columns = 40 bricks (1=alive, 0=destroyed)

    player_name     db 16 dup(0)
    name_len        db 0
    row_colors      db 0Eh, 0Ch, 0Ah, 0Bh, 0Dh, 09h, 2Ah, 04h
    rect_height     dw 10

    wide_box_top    db '+-------------------------------+', 0
    wide_box_empty  db '|                               |', 0
    wide_box_bot    db '+-------------------------------+', 0

    title_box_top   db '+-----------------------+', 0
    title_msg       db '|     BRICK BREAKER     |', 0
    title_box_bot   db '+-----------------------+', 0
    instruction_msg db 'PRESS ANY KEY TO START', 0

    prompt_top      db '+-----------------------+', 0
    prompt_msg      db '| Enter Player Name:    |', 0
    prompt_mid      db '|                       |', 0
    prompt_bot      db '+-----------------------+', 0
    
    menu_start      db '  Start Game      ', 0
    menu_inst       db '  Instructions    ', 0
    menu_score      db '  High Scores     ', 0
    menu_exit       db '  Exit            ', 0

    menu_box_top    db '+------------------+', 0
    menu_box_empty  db '|                  |', 0
    menu_box_bot    db '+------------------+', 0

    instr_title     db 'INSTRUCTIONS', 0
    instr_1         db 'Use Left/Right to move', 0
    instr_2         db 'Bounce ball to break bricks', 0
    instr_3         db 'Do not let the ball fall!', 0
    instr_4         db 'Collect bonuses for extra power', 0
    instr_ret       db 'Press Enter/Backspace', 0

    score_title     db 'HIGH SCORES', 0
    score_1         db '1. Tawassul - 5000', 0
    score_2         db '2. Zubair - 4000', 0
    score_3         db '3. Zain - 3000', 0
    
    hud_score       db 'Score: 0000', 0
    hud_lives       db 'Lives: 3', 0
    hud_level       db 'Level: 1', 0

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
    je ShowHome
    cmp current_screen, 1
    je ShowNameInput
    cmp current_screen, 2
    je ShowMenu
    cmp current_screen, 3
    je ShowInstr
    cmp current_screen, 4
    je ShowScores
    cmp current_screen, 5
    je ShowGame

ShowHome:
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
    jmp GameLoop

ShowNameInput:
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
    jmp GameLoop

ShowMenu:
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
    mov si, offset menu_box_bot
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
    cmp al, 8  ; Backspace
    je GoNameInput
    jmp GameLoop

GoNameInput:
    mov name_len, 0
    mov byte ptr player_name, 0

    mov current_screen, 1
    mov bg_color, 6
    jmp GameLoop

MenuUp:
    cmp menu_selected, 0
    je GameLoop
    dec menu_selected
    jmp GameLoop
MenuDown:
    cmp menu_selected, 3
    je GameLoop
    inc menu_selected
    jmp GameLoop
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
    jmp GameLoop
GoInstr:
    mov bg_color, 12 ; Light Red 0Ch
    mov current_screen, 3
    jmp GameLoop
GoScore:
    mov bg_color, 2 ; Green 02h
    mov current_screen, 4
    jmp GameLoop
ExitGame:
    jmp ExitProgram

ShowInstr:
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
    mov dl, 5
    mov si, offset instr_4
    mov bl, 0Eh
    call PrintString

    mov dh, 16
    mov dl, 9
    mov si, offset instr_ret
    mov bl, 08h
    call PrintString
    
    mov ah, 00h
    int 16h
    cmp al, 13
    je ReturnMenu
    cmp al, 8 ; Backspace
    je ReturnMenu
    jmp GameLoop

ShowScores:
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
    cmp al, 8 ; Backspace
    je ReturnMenu
    jmp GameLoop

ReturnMenu:
    mov bg_color, 6
    mov current_screen, 2
    jmp GameLoop

ShowGame:
    mov lives, 3
    mov score, 0
    mov ballX, 160
    mov ballY, 140
    mov ballDX, 1
    mov ballDY, -1
    mov paddleX, 130

    ; Initialize the bricks array to 1 (alive)
    mov cx, 40
    mov di, offset bricks
InitBricksLoop:
    mov byte ptr [di], 1
    inc di
    loop InitBricksLoop

    ; Draw Bricks: 5 rows, 8 columns
    mov si, 0        ; row index
    mov bx, 25       ; starting y position (beneath header)

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

    ; Draw Top HUD (Header)
    call UPDATE_HUD

PlayGameLoop:
    call READ_INPUT
    call MOVE_PADDLE

    ; Erase Ball
    mov al, bgColorGame
    call DRAW_BALL_AT

    call MOVE_BALL

    call CHECK_WALL_COLLISION
    call CHECK_PADDLE_COLLISION
    call CHECK_BRICK_COLLISION

    ; Draw Ball
    mov al, ballColor
    call DRAW_BALL_AT

    ; Frame Delay
    mov cx, 0000h
    mov dx, 0A000h ; roughly 40ms
    mov ah, 86h
    int 15h

    ; End condition
    cmp lives, 0
    jle GameOver

    ; Quit to menu if user pressed ESC (optional, let's say Esc=1)
    ; But we don't need it per spec yet unless specified, but let's check input
    jmp PlayGameLoop

GameOver:
    ; Game Over transition
    mov current_screen, 2
    jmp GameLoop

ExitProgram:
    mov ax, 03h
    int 10h
    mov ah, 4Ch
    int 21h
main endp

; ======================================================
; MODULAR PROCEDURES FOR ITERATION 2
; ======================================================

READ_INPUT proc
    mov ah, 01h
    int 16h
    jz NoInput
    mov ah, 00h
    int 16h
NoInput:
    ret
READ_INPUT endp

MOVE_PADDLE proc
    ; Erase paddle at old pos
    mov bx, paddleY
    mov cx, paddleX
    mov dx, paddleWidth
    mov al, bgColorGame
    mov rect_height, 8
    call DrawRect

    ; Check input in AL/AH (from previous READ_INPUT if not overwritten, but actually we should read directly or use last key)
    ; But INT 16h AH=01 returns ZF=0 if key. If we consume with AH=00h, it is in AL/AH.
    ; Realistically, it's safer to read inside MOVE_PADDLE or just check keyboard buffer again.
    ; The plan says: "Step 1: Read Input ... If key exists, read it... Step 2: Update Paddle"
    cmp ah, 4Bh ; Left arrow
    jne CheckRight
    mov ax, paddleX
    cmp ax, 0
    jle EndPaddleMove
    sub ax, 10
    cmp ax, 0
    jge StorePaddleX
    mov ax, 0
    jmp StorePaddleX

CheckRight:
    cmp ah, 4Dh ; Right arrow
    jne EndPaddleMove
    mov ax, paddleX
    mov cx, 320
    sub cx, paddleWidth
    cmp ax, cx
    jge EndPaddleMove
    add ax, 10
    cmp ax, cx
    jle StorePaddleX
    mov ax, cx

StorePaddleX:
    mov paddleX, ax

EndPaddleMove:
    ; Draw paddle
    mov bx, paddleY
    mov cx, paddleX
    mov dx, paddleWidth
    mov al, 0Ch      ; Light Red
    mov rect_height, 8
    call DrawRect
    ret
MOVE_PADDLE endp

DRAW_BALL_AT proc
    ; Assumes AL = color
    ; Draws a 4x4 ball at ballX, ballY
    push ax
    mov bx, ballY
    mov cx, ballX
    mov dx, 4
    mov rect_height, 4
    call DrawRect
    pop ax
    ret
DRAW_BALL_AT endp

MOVE_BALL proc
    mov ax, ballDX
    add ballX, ax
    mov ax, ballDY
    add ballY, ax
    ret
MOVE_BALL endp

CHECK_WALL_COLLISION proc
    ; ballX <= 0
    cmp ballX, 0
    jg CheckRightWall
    mov ballDX, 2
    jmp WallYCheck
CheckRightWall:
    ; ballX >= 315 (319 - ballWidth)
    cmp ballX, 315
    jl WallYCheck
    mov ballDX, -2
WallYCheck:
    ; ballY <= 15
    cmp ballY, 15
    jg CheckMiss
    mov ballDY, 2
    jmp EndWallCheck
CheckMiss:
    ; ballY > 195 (missed)
    cmp ballY, 195
    jl EndWallCheck
    dec lives
    ; Reset ball
    mov ballX, 160
    mov ballY, 140
    mov ballDX, 1
    mov ballDY, -1
    ; Pause briefly
    mov cx, 0005h
    mov dx, 0000h
    mov ah, 86h
    int 15h
    ; Update HUD to reflect lives
    call UPDATE_HUD_VALUES

EndWallCheck:
    ret
CHECK_WALL_COLLISION endp

CHECK_PADDLE_COLLISION proc
    ; Pixel check - simple method: read A000h at ball position + some offset
    mov ax, 0A000h
    mov es, ax
    ; Let's check bottom-middle of the ball
    mov bx, ballY
    add bx, 4      ; just below the ball
    mov cx, ballX
    add cx, 2      ; middle of ball width
    ; calc di = bx * 320 + cx
    mov ax, 320
    mul bx
    add ax, cx
    mov di, ax
    mov al, es:[di]
    cmp al, 0Ch    ; Paddle color (Light Red)
    jne SkipPaddleCol
    ; bounce
    mov ballDY, -2
SkipPaddleCol:
    ret
CHECK_PADDLE_COLLISION endp

CHECK_BRICK_COLLISION proc
    mov ax, 0A000h
    mov es, ax

    ; Calculate the leading edge of the ball to know EXACTLY which brick it hits
    mov bx, ballY
    cmp ballDY, 0
    jl CheckYUp
    add bx, 3 ; if moving DOWN, leading edge is bottom of ball
CheckYUp:

    mov cx, ballX
    cmp ballDX, 0
    jl CheckXLeft
    add cx, 3 ; if moving RIGHT, leading edge is right of ball
CheckXLeft:

    ; Limit bounds so we don't trigger Division Overflow and keep within array!
    ; 5 rows * 12 height = up to Y=85
    cmp bx, 25
    jl SkipBrickCol
    cmp bx, 84    ; bricks don't exist below Y=84
    jg SkipBrickCol
    cmp cx, 25
    jl SkipBrickCol
    cmp cx, 304    ; total width 25 + 8*35 = 305
    jg SkipBrickCol

    ; We are in the bounds of the brick grid
    ; Row = (Y - 25) / 12
    mov ax, bx
    sub ax, 25
    xor dx, dx
    push cx
    mov cx, 12
    div cx
    pop cx
    ; Let's make sure it's not strictly in the gap space (dx >= 8)
    cmp dx, 8
    jge SkipBrickCol
    mov di, ax ; DI = row

    ; Col = (X - 25) / 35
    mov ax, cx
    sub ax, 25
    xor dx, dx
    push cx
    mov cx, 35
    div cx
    pop cx
    ; Let's make sure it's not strictly in the gap space (dx >= 32)
    cmp dx, 32
    jge SkipBrickCol
    ; AX = col
    
    ; Check if brick is alive: bricks[row * 8 + col]
    push bx
    mov bx, di
    shl bx, 3 ; row * 8
    add bx, ax
    mov dl, byte ptr [bricks + bx]
    cmp dl, 0
    pop bx
    je SkipBrickCol ; already destroyed

    ; It's a live brick! Hit it!
    ; Mark as destroyed
    push bx
    push ax ; save col
    mov bx, di
    shl bx, 3 ; row * 8
    add bx, ax
    mov byte ptr [bricks + bx], 0
    pop ax
    pop bx

    ; Reverse ballDY properly avoiding edge case
    push ax
    mov ax, ballDY
    neg ax
    mov ballDY, ax
    pop ax

    add score, 100
    call UPDATE_HUD_VALUES

    ; Erase the brick visual
    ; Find base X and Y again for DrawRect inside the exact slot
    ; base Y = row * 12 + 25
    push ax ; Save COL
    mov ax, di
    push cx
    mov cx, 12
    mul cx
    pop cx
    add ax, 25
    push ax ; base Y

    ; base X = col * 35 + 25
    pop bx ; BX = base Y (oops wait, need to calculate X first without losing Y)
    push bx
    
    ; Wait, we saved col in memory above `push ax`. Let's restore it.
    pop bx ; base Y (discarded temporarily)
    pop ax ; restore COL
    
    push cx
    mov cx, 35
    mul cx
    pop cx
    add ax, 25
    mov cx, ax ; CX = base X

    ; Now restore base Y perfectly
    mov ax, di
    push cx
    mov cx, 12
    mul cx
    pop cx
    add ax, 25
    mov bx, ax ; BX = base Y

    mov dx, 32 ; brick width
    mov rect_height, 8
    mov al, bgColorGame ; Erase visually using background color
    call DrawRect

SkipBrickCol:
    ret
CHECK_BRICK_COLLISION endp

UPDATE_HUD_VALUES proc
    ; Updates the underlying ascii string parameters for score and lives
    ; 1. Process Score into hud_score ('Score: 0000')
    mov ax, score
    mov bx, 10
    mov cx, 4
    mov di, offset hud_score + 10 ; Point to last digit of '0000'
ScoreLoop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    loop ScoreLoop

    ; 2. Process Lives into hud_lives ('Lives: 3')
    mov al, lives
    add al, '0'
    mov di, offset hud_lives + 7
    mov [di], al

    ; Redraw HUD
    call UPDATE_HUD
    ret
UPDATE_HUD_VALUES endp

UPDATE_HUD proc
    mov dh, 1
    mov dl, 2
    mov si, offset hud_score
    mov bl, 0Fh
    call PrintString

    mov dh, 1
    mov dl, 14
    mov si, offset hud_lives
    mov bl, 0Fh
    call PrintString

    mov dh, 1
    mov dl, 25
    mov si, offset hud_level
    mov bl, 0Fh
    call PrintString

    ; Draw player name
    mov dh, 1
    mov dl, 39
    sub dl, name_len
    mov si, offset player_name
    mov bl, 0Eh
    call PrintString
    ret
UPDATE_HUD endp

SHOW_GAME_OVER proc
    ret
SHOW_GAME_OVER endp

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

; ======================================================
; ADVANCED PROCEDURE: PrintChar_Mode13h
; AL = Character to print, CX = X, DX = Y, BL = Color
; ======================================================
PrintChar_Mode13h proc
    pusha
    push es

    ; Save color and character
    push bx
    push ax

    ; 1. Get BIOS Font Table Pointer (INT 43h)
    xor ax, ax
    mov es, ax
    mov bp, es:[43h * 4]      ; Offset of font table
    mov ax, es:[43h * 4 + 2]  ; Segment of font table
    mov es, ax                ; ES:BP now points to ASCII 0

    ; 2. Find specific character (8 bytes per char)
    pop ax                    ; Restore AX (AL has char)
    xor ah, ah
    shl ax, 3                 ; Multiply ASCII by 8
    add bp, ax                ; BP points to our character

    ; 3. Setup Video Memory
    mov ax, 0A000h
    mov fs, ax                ; Use FS for Video RAM

    pop bx                    ; Restore BX (BL has color)

    mov si, 0                 ; Row counter (0-7)
RowLoop:
    mov al, es:[bp + si]      ; Load 1 byte (8 pixels) from font table
    mov di, 8                 ; Bit counter (8 bits per byte)
BitLoop:
    dec di
    test al, 1                ; Check if the rightmost bit is 1
    jz SkipPixel

    ; Calculate Pixel Index: (Y + si) * 320 + (X + di)
    push ax                   ; Save pixel row data

    mov ax, dx                ; ax = Y
    add ax, si                ; ax = Y + si
    push dx                   ; Save dx (Y)
    mov dx, 320
    mul dx                    ; dx:ax = (Y + si) * 320
    pop dx                    ; Restore dx (Y)

    add ax, cx                ; ax = (Y + si) * 320 + X
    add ax, di                ; ax = (Y + si) * 320 + X + di

    push di                   ; Save bit counter
    mov di, ax                ; DI = pixel index

    mov byte ptr fs:[di], bl  ; Draw pixel with chosen color

    pop di                    ; Restore bit counter
    pop ax                    ; Restore pixel row data

SkipPixel:
    shr al, 1                 ; Shift to next bit
    cmp di, 0
    jne BitLoop

    inc si
    cmp si, 8
    jne RowLoop

    pop es
    popa
    ret
PrintChar_Mode13h endp

end main