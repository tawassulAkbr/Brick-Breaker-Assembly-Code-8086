.model small
.386
.stack 100h

BRICK_ROWS      equ 6
BRICK_COLS      equ 12
BRICK_COUNT     equ 72
BRICK_START_X   equ 16
BRICK_START_Y   equ 30
BRICK_W         equ 21
BRICK_H         equ 6
BRICK_STEP_X    equ 24
BRICK_STEP_Y    equ 9

.data
    current_screen  db 0 ; 0=Home, 1=Name, 2=Menu, 3=Instructions, 4=Scores, 5=Game, 6=GameOver
    last_screen     db 255
    screen_redraw   db 1
    menu_selected   db 0 ; 0=Start, 1=Inst, 2=Score, 3=Exit
    bg_color        db 0 ; Dark background

    player_name     db 16 dup(0)
    name_len        db 0
    row_colors      db 0Ch, 0Eh, 0Ah, 0Bh, 0Dh, 09h
    hard2_color     db 07h
    hard3_color     db 0Fh
    rect_height     dw 10

    wide_box_top    db '+-------------------------------+', 0
    wide_box_empty  db '|                               |', 0
    wide_box_bot    db '+-------------------------------+', 0

    title_box_top   db '+-----------------------------+', 0
    title_msg       db '|        BRICK BREAKER        |', 0
    title_box_bot   db '+-----------------------------+', 0
    instruction_msg db 'PRESS ANY KEY', 0

    prompt_top      db '+-----------------------------+', 0
    prompt_msg      db '|      Enter Player Name      |', 0
    prompt_mid      db '|                             |', 0
    prompt_bot      db '+-----------------------------+', 0
    
    menu_start      db '  Start Game      ', 0
    menu_inst       db '  Instructions    ', 0
    menu_score      db '  High Scores     ', 0
    menu_exit       db '  Exit            ', 0

    menu_box_top    db '+------------------------+', 0
    menu_box_empty  db '|                        |', 0
    menu_box_bot    db '+------------------------+', 0

    instr_title     db 'INSTRUCTIONS', 0
    instr_1         db 'Use A/D or Left/Right', 0
    instr_2         db 'Bounce ball to break bricks', 0
    instr_3         db 'Do not let the ball fall!', 0
    instr_4         db 'Press P to pause/resume', 0
    instr_ret       db 'Press Enter/Backspace', 0

    score_title     db 'HIGH SCORES', 0
    score_1         db '1. Tawassul - 5000', 0
    score_2         db '2. Zubair - 4000', 0
    score_3         db '3. Zain - 3000', 0
    
    hud_score       db 'Score: 0000', 0
    hud_lives       db 'Lives: 3', 0
    hud_level       db 'Level: 1', 0

    game_over_title db 'GAME OVER', 0
    level1_done_msg db 'LEVEL 1 COMPLETE!', 0
    level2_done_msg db 'LEVEL 2 COMPLETE!', 0
    level3_done_msg db 'YOU BEAT THE GAME!', 0
    game_over_ret   db 'Press Enter/Backspace', 0
    next_level_msg   db 'Loading next level...', 0
    pause_title     db 'PAUSED', 0
    pause_hint      db 'Press P to resume', 0

    active_rows     db 3
    active_bricks   db 36
    frame_delay     dw 18000
    ball_speed       dw 2
    ball_edge_speed  dw 3
    paddle_width     dw 60
    paddle_half      dw 30
    paddle_left_zone dw 12
    paddle_right_zone dw 48
    paddle_max_x     dw 256

    paddle_x        dw 130
    paddle_y        dw 184
    prev_paddle_x   dw 130
    prev_paddle_y   dw 184
    ball_x          dw 160
    ball_y          dw 174
    prev_ball_x     dw 160
    prev_ball_y     dw 174
    ball_dx         dw 2
    ball_dy         dw -2
    score           dw 0
    lives           db 3
    bricks_left     db BRICK_COUNT
    game_result     db 0 ; 0=lost, 1=level complete
    bricks          db BRICK_COUNT dup(1)
    draw_index      dw 0
    draw_row        db 0
    draw_color      db 0
    scan_row        db 0
    game_first_draw db 1
    hud_dirty       db 1

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Enter VGA Mode 13h
    mov ax, 13h
    int 10h

GameLoop:
    mov al, current_screen
    cmp al, last_screen
    je SkipScreenClear
    call ClearScreen
    mov al, current_screen
    mov last_screen, al
    mov screen_redraw, 1
    jmp ScreenDispatch

SkipScreenClear:
    mov screen_redraw, 0

ScreenDispatch:
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
    cmp current_screen, 6
    je ShowGameOver

ShowHome:
    call MaybeDrawUiBackdrop
    ; Top of the box
    mov dh, 7
    mov dl, 5
    mov si, offset title_box_top
    mov bl, 0Fh ; White
    call PrintString

    ; The title itself
    mov dh, 8
    mov dl, 5
    mov si, offset title_msg
    mov bl, 0Bh ; Light Cyan for Title
    call PrintString

    ; Bottom of the box
    mov dh, 9
    mov dl, 5
    mov si, offset title_box_bot
    mov bl, 0Fh ; White
    call PrintString

    ; Footer instruction
    mov dh, 23
    mov dl, 14
    mov si, offset instruction_msg
    mov bl, 0Eh ; Yellow
    call PrintString

    mov ah, 00h
    int 16h
    mov current_screen, 1 ; Goto Name Input
    jmp GameLoop

ShowNameInput:
    call MaybeDrawUiBackdrop
    mov dh, 9
    mov dl, 5
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString

    mov dh, 10
    mov dl, 5
    mov si, offset prompt_msg
    mov bl, 0Ah ; Light Green
    call PrintString

    mov dh, 11
    mov dl, 5
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString

    mov dh, 12
    mov dl, 5
    mov si, offset prompt_bot
    mov bl, 0Fh
    call PrintString

    ; Very simple name input reading
NameInputLoop:
    ; Erase previous name segment (reprint empty mid)
    mov dh, 11
    mov dl, 5
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString

    ; Print typed name
    mov dh, 11
    mov dl, 13
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
    jmp NameInputLoop

    mov dh, 9
    mov dl, 5
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString
    mov dh, 10
    mov dl, 5
    mov si, offset prompt_msg
    mov bl, 0Ah
    call PrintString
    mov dh, 11
    mov dl, 5
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString
    mov dh, 12
    mov dl, 5
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
    jmp NameInputLoop

    mov dh, 9
    mov dl, 5
    mov si, offset prompt_top
    mov bl, 0Fh
    call PrintString
    mov dh, 10
    mov dl, 5
    mov si, offset prompt_msg
    mov bl, 0Ah
    call PrintString
    mov dh, 11
    mov dl, 5
    mov si, offset prompt_mid
    mov bl, 0Ah
    call PrintString
    mov dh, 12
    mov dl, 5
    mov si, offset prompt_bot
    mov bl, 0Fh
    call PrintString
    jmp NameInputLoop

NameInputDone:
    mov current_screen, 2 ; Goto Menu
    jmp GameLoop

ShowMenu:
    call MaybeDrawUiBackdrop
    ; Draw Box
    mov dh, 6
    mov dl, 7
    mov si, offset menu_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 7
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 8
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 9
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 10
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 11
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 12
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 13
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 14
    mov dl, 7
    mov si, offset menu_box_empty
    mov bl, 0Fh
    call PrintString

    mov dh, 15
    mov dl, 7
    mov si, offset menu_box_bot
    mov bl, 0Fh
    call PrintString

    mov dh, 8
    mov dl, 12
    mov si, offset menu_start
    mov bl, 0Fh
    cmp menu_selected, 0
    jne M1
    mov bl, 0Ch ; Light Red Highlight
M1: call PrintString

    mov dh, 10
    mov dl, 12
    mov si, offset menu_inst
    mov bl, 0Fh
    cmp menu_selected, 1
    jne M2
    mov bl, 0Ch
M2: call PrintString

    mov dh, 12
    mov dl, 12
    mov si, offset menu_score
    mov bl, 0Fh
    cmp menu_selected, 2
    jne M3
    mov bl, 0Ch
M3: call PrintString

    mov dh, 14
    mov dl, 12
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
    mov bg_color, 0
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
    call InitGame
    mov bg_color, 0 ; 0 = Black background!
    mov current_screen, 5
    jmp GameLoop
GoInstr:
    mov bg_color, 0
    mov current_screen, 3
    jmp GameLoop
GoScore:
    mov bg_color, 0
    mov current_screen, 4
    jmp GameLoop
ExitGame:
    jmp ExitProgram

ShowInstr:
    call MaybeDrawUiBackdrop
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
    mov dl, 8
    mov si, offset instr_1
    mov bl, 0Fh ; White
    call PrintString

    mov dh, 10
    mov dl, 6
    mov si, offset instr_2
    mov bl, 0Ah ; Light Green
    call PrintString

    mov dh, 12
    mov dl, 7
    mov si, offset instr_3
    mov bl, 0Ch ; Light Red
    call PrintString

    mov dh, 14
    mov dl, 8
    mov si, offset instr_4
    mov bl, 0Eh
    call PrintString

    mov dh, 16
    mov dl, 10
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
    call MaybeDrawUiBackdrop
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
    mov dl, 7
    mov si, offset score_1
    mov bl, 0Eh ; Yellow for 1st
    call PrintString

    mov dh, 10
    mov dl, 7
    mov si, offset score_2
    mov bl, 07h ; Light Gray for 2nd
    call PrintString

    mov dh, 12
    mov dl, 7
    mov si, offset score_3
    mov bl, 06h ; Brown/Orange for 3rd
    call PrintString

    mov dh, 14
    mov dl, 10
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
    mov bg_color, 0
    mov current_screen, 2
    jmp GameLoop

ShowGame:
    call HandleGameInput
    cmp current_screen, 5
    jne GameLoop
    call UpdateBall
    cmp current_screen, 5
    jne GameLoop
    call UpdateHud
    call DrawGameFrame
    call DelayFrame
    jmp GameLoop

ShowGameOver:
    call MaybeDrawUiBackdrop
    mov dh, 7
    mov dl, 5
    mov si, offset title_box_top
    mov bl, 0Fh
    call PrintString

    mov dh, 8
    mov dl, 15
    mov si, offset game_over_title
    cmp game_result, 0
    je GameOverTitleReady
    
    mov dl, 12
    mov si, offset level1_done_msg
    cmp hud_level[7], '1'
    je GameOverTitleReady
    
    mov si, offset level2_done_msg
    cmp hud_level[7], '2'
    je GameOverTitleReady
    
    mov si, offset level3_done_msg

GameOverTitleReady:
    mov bl, 0Ch
    call PrintString

    mov dh, 9
    mov dl, 5
    mov si, offset title_box_bot
    mov bl, 0Fh
    call PrintString

    call UpdateHud
    mov dh, 12
    mov dl, 14
    mov si, offset hud_score
    mov bl, 0Eh
    call PrintString

    mov dh, 14
    mov dl, 7
    mov si, offset game_over_ret
    cmp game_result, 1
    jne GameOverPromptReady
    mov dl, 10
    mov si, offset next_level_msg
GameOverPromptReady:
    mov bl, 08h
    call PrintString

    cmp game_result, 1
    je AutoNextLevel

    mov ah, 00h
    int 16h
    cmp al, 13
    je CheckGameOverReturn
    cmp al, 8 ; Backspace
    je CheckGameOverReturn
    cmp al, 27 ; Escape
    je CheckGameOverReturn
    jmp GameLoop

CheckGameOverReturn:
    cmp game_result, 1
    je GoNextLevel
    jmp ReturnMenu

AutoNextLevel:
    mov cx, 70
AutoNextLevelPause:
    call DelayFrame
    loop AutoNextLevelPause
    jmp GoNextLevel

GoNextLevel:
    inc hud_level[7]
    cmp hud_level[7], '4'
    je ReturnMenu ; Go to menu on level 4 (win)
    
    cmp hud_level[7], '2'
    je SetupLevel2
    cmp hud_level[7], '3'
    je SetupLevel3
    jmp SetupLevel1

SetupLevel1:
    mov active_rows, 3     ; L1 rows
    mov active_bricks, 36  ; L1 bricks
    mov frame_delay, 18000 ; L1 speed
    mov ball_speed, 2
    mov ball_edge_speed, 3
    mov paddle_width, 60
    mov paddle_half, 30
    mov paddle_left_zone, 12
    mov paddle_right_zone, 48
    mov paddle_max_x, 256
    jmp StartLevelRun

SetupLevel2:
    mov active_rows, 5     ; L2 rows
    mov active_bricks, 60  ; L2 bricks
    mov frame_delay, 13846 ; L2 speed = 1.3x L1
    mov ball_speed, 2
    mov ball_edge_speed, 3
    mov paddle_width, 50
    mov paddle_half, 25
    mov paddle_left_zone, 10
    mov paddle_right_zone, 40
    mov paddle_max_x, 266
    jmp StartLevelRun

SetupLevel3:
    mov active_rows, 6     ; L3 rows
    mov active_bricks, 72  ; L3 bricks
    mov frame_delay, 11250 ; L3 speed = 1.6x L1
    mov ball_speed, 2
    mov ball_edge_speed, 3
    mov paddle_width, 40
    mov paddle_half, 20
    mov paddle_left_zone, 8
    mov paddle_right_zone, 32
    mov paddle_max_x, 276
    jmp StartLevelRun

StartLevelRun:
    mov al, active_bricks
    mov bricks_left, al
    mov game_result, 0
    mov game_first_draw, 1
    mov hud_dirty, 1
    call ResetBall

    ; Clear and reload bricks
    push di
    push cx
    push ax
    mov di, offset bricks
    cmp hud_level[7], '3'
    je ResetLevel3Bricks

    xor cx, cx
    mov cl, active_bricks
    mov al, 1
ResetBricksLoop:
    mov [di], al
    inc di
    loop ResetBricksLoop
    jmp ResetBricksDone

ResetLevel3Bricks:
    mov scan_row, 0
ResetLevel3Row:
    mov al, 3
    cmp scan_row, 2
    jl ResetLevel3ColSetup

    mov al, 2
    cmp scan_row, 4
    jl ResetLevel3ColSetup

    mov al, 1

ResetLevel3ColSetup:
    xor cx, cx
    mov cl, BRICK_COLS
ResetLevel3Col:
    mov [di], al
    inc di
    loop ResetLevel3Col

    inc scan_row
    mov al, active_rows
    cmp scan_row, al
    jl ResetLevel3Row

ResetBricksDone:
    pop ax
    pop cx
    pop di

    call UpdateHud
    mov bg_color, 0
    mov current_screen, 5
    jmp GameLoop

ExitProgram:
    mov ax, 03h
    int 10h
    mov ah, 4Ch
    int 21h
main endp

; ======================================================
; UI PROCEDURE: MaybeDrawUiBackdrop
; Draws shared UI chrome only when entering a screen.
; ======================================================
MaybeDrawUiBackdrop proc
    cmp screen_redraw, 1
    jne MaybeBackdropDone
    call DrawUiBackdrop
MaybeBackdropDone:
    ret
MaybeDrawUiBackdrop endp

; ======================================================
; UI PROCEDURE: DrawUiBackdrop
; Dark shared backdrop for menu, name, score, and message screens.
; ======================================================
DrawUiBackdrop proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 0
    mov cx, 0
    mov dx, 320
    mov al, 01h
    mov rect_height, 18
    call DrawRect

    mov bx, 182
    mov cx, 0
    mov dx, 320
    mov al, 01h
    mov rect_height, 18
    call DrawRect

    mov bx, 20
    mov cx, 18
    mov dx, 284
    mov al, 08h
    mov rect_height, 2
    call DrawRect

    mov bx, 180
    mov cx, 18
    mov dx, 284
    mov al, 08h
    mov rect_height, 2
    call DrawRect

    mov bx, 20
    mov cx, 18
    mov dx, 2
    mov al, 08h
    mov rect_height, 160
    call DrawRect

    mov bx, 20
    mov cx, 300
    mov dx, 2
    mov al, 08h
    mov rect_height, 160
    call DrawRect

    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawUiBackdrop endp

; ======================================================
; GAME PROCEDURE: InitGame
; Resets Level 1 state before gameplay starts.
; ======================================================
InitGame proc
    push ax
    push cx
    push di

    mov score, 0
    mov lives, 3
    mov hud_level[7], '1'
    
    mov active_rows, 3     ; L1 rows
    mov active_bricks, 36  ; L1 bricks
    mov frame_delay, 18000 ; L1 speed
    mov ball_speed, 2
    mov ball_edge_speed, 3
    mov paddle_width, 60
    mov paddle_half, 30
    mov paddle_left_zone, 12
    mov paddle_right_zone, 48
    mov paddle_max_x, 256

    mov al, active_bricks
    mov bricks_left, al
    mov game_result, 0
    mov game_first_draw, 1
    mov hud_dirty, 1
    call ResetBall

    mov di, offset bricks
    xor cx, cx
    mov cl, active_bricks
    mov al, 1
InitBricksLoop:
    mov [di], al
    inc di
    loop InitBricksLoop

    call UpdateHud

    pop di
    pop cx
    pop ax
    ret
InitGame endp

; ======================================================
; GAME PROCEDURE: ResetBall
; Restores paddle and ball after start or life loss.
; ======================================================
ResetBall proc
    mov ax, 160
    sub ax, paddle_half
    mov paddle_x, ax
    mov paddle_y, 184
    mov prev_paddle_x, ax
    mov prev_paddle_y, 184
    mov ball_x, 160
    mov ball_y, 174
    mov prev_ball_x, 160
    mov prev_ball_y, 174
    mov ax, ball_speed
    mov ball_dx, ax
    neg ax
    mov ball_dy, ax
    ret
ResetBall endp

; ======================================================
; GAME PROCEDURE: HandleGameInput
; Non-blocking paddle input for arrows, A/D, and exit keys.
; ======================================================
HandleGameInput proc
    push ax

    mov ah, 01h
    int 16h
    jz NoGameKey

    mov ah, 00h
    int 16h

    cmp al, 27 ; Escape
    je GameInputReturnMenu
    cmp al, 8 ; Backspace
    je GameInputReturnMenu
    cmp al, 'p'
    je GameInputPause
    cmp al, 'P'
    je GameInputPause

    cmp ah, 4Bh ; Left arrow
    je MovePaddleLeft
    cmp al, 'a'
    je MovePaddleLeft
    cmp al, 'A'
    je MovePaddleLeft

    cmp ah, 4Dh ; Right arrow
    je MovePaddleRight
    cmp al, 'd'
    je MovePaddleRight
    cmp al, 'D'
    je MovePaddleRight
    jmp NoGameKey

MovePaddleLeft:
    mov ax, paddle_x
    cmp ax, 12
    jb SetPaddleLeftEdge
    sub ax, 8
    mov paddle_x, ax
    jmp NoGameKey

SetPaddleLeftEdge:
    mov paddle_x, 4
    jmp NoGameKey

MovePaddleRight:
    mov ax, paddle_x
    add ax, 8
    cmp ax, paddle_max_x
    ja SetPaddleRightEdge
    mov paddle_x, ax
    jmp NoGameKey

SetPaddleRightEdge:
    mov ax, paddle_max_x
    mov paddle_x, ax
    jmp NoGameKey

GameInputReturnMenu:
    mov bg_color, 0
    mov current_screen, 2
    jmp NoGameKey

GameInputPause:
    call PauseGame

NoGameKey:
    pop ax
    ret
HandleGameInput endp

; ======================================================
; GAME PROCEDURE: PauseGame
; Stops gameplay until P resumes, or Escape/Backspace returns to menu.
; ======================================================
PauseGame proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 82
    mov cx, 82
    mov dx, 156
    mov al, 01h
    mov rect_height, 38
    call DrawRect

    mov bx, 86
    mov cx, 86
    mov dx, 148
    mov al, 08h
    mov rect_height, 30
    call DrawRect

    mov dh, 11
    mov dl, 17
    mov si, offset pause_title
    mov bl, 0Eh
    call PrintString

    mov dh, 13
    mov dl, 12
    mov si, offset pause_hint
    mov bl, 0Fh
    call PrintString

PauseWaitKey:
    mov ah, 00h
    int 16h
    cmp al, 'p'
    je PauseResume
    cmp al, 'P'
    je PauseResume
    cmp al, 27 ; Escape
    je PauseReturnMenu
    cmp al, 8 ; Backspace
    je PauseReturnMenu
    jmp PauseWaitKey

PauseResume:
    mov game_first_draw, 1
    mov hud_dirty, 1
    jmp PauseDone

PauseReturnMenu:
    mov bg_color, 0
    mov current_screen, 2

PauseDone:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PauseGame endp

; ======================================================
; GAME PROCEDURE: UpdateBall
; Moves the ball and checks wall, paddle, and brick collisions.
; ======================================================
UpdateBall proc
    push ax
    push dx

    mov ax, ball_x
    add ax, ball_dx
    mov ball_x, ax

    mov ax, ball_y
    add ax, ball_dy
    mov ball_y, ax

    mov ax, ball_x
    cmp ax, 3
    jge BallCheckRightWall
    mov ball_x, 3
    mov ax, ball_speed
    mov ball_dx, ax

BallCheckRightWall:
    mov ax, ball_x
    cmp ax, 311
    jle BallCheckTopWall
    mov ball_x, 311
    mov ax, ball_speed
    neg ax
    mov ball_dx, ax

BallCheckTopWall:
    mov ax, ball_y
    cmp ax, 20
    jge BallCheckBottom
    mov ball_y, 20
    mov ax, ball_speed
    mov ball_dy, ax

BallCheckBottom:
    mov ax, ball_y
    cmp ax, 191
    jle BallCheckPaddle
    call LoseLife
    jmp UpdateBallDone

BallCheckPaddle:
    mov ax, ball_dy
    cmp ax, 0
    jl BallCheckBricks

    mov ax, ball_y
    add ax, 6
    cmp ax, paddle_y
    jl BallCheckBricks

    mov ax, paddle_y
    add ax, 6
    mov dx, ball_y
    cmp dx, ax
    jg BallCheckBricks

    mov ax, ball_x
    add ax, 6
    cmp ax, paddle_x
    jl BallCheckBricks

    mov ax, paddle_x
    add ax, paddle_width
    mov dx, ball_x
    cmp dx, ax
    jg BallCheckBricks

    mov ax, paddle_y
    sub ax, 6
    mov ball_y, ax
    mov ax, ball_speed
    neg ax
    mov ball_dy, ax

    mov ax, ball_x
    add ax, 3
    mov dx, paddle_x
    add dx, paddle_half
    cmp ax, dx
    jl PaddleHitLeftSide

    mov ax, ball_speed
    mov ball_dx, ax
    mov ax, ball_x
    add ax, 3
    mov dx, paddle_x
    add dx, paddle_right_zone
    cmp ax, dx
    jl UpdateBallDone
    mov ax, ball_edge_speed
    mov ball_dx, ax
    jmp UpdateBallDone

PaddleHitLeftSide:
    mov ax, ball_speed
    neg ax
    mov ball_dx, ax
    mov ax, ball_x
    add ax, 3
    mov dx, paddle_x
    add dx, paddle_left_zone
    cmp ax, dx
    jg UpdateBallDone
    mov ax, ball_edge_speed
    neg ax
    mov ball_dx, ax
    jmp UpdateBallDone

BallCheckBricks:
    call CheckBrickCollision

UpdateBallDone:
    pop dx
    pop ax
    ret
UpdateBall endp

; ======================================================
; GAME PROCEDURE: LoseLife
; Reduces lives, resets ball, or switches to game over.
; ======================================================
LoseLife proc
    cmp lives, 0
    je LoseLifeDone

    dec lives
    mov hud_dirty, 1
    cmp lives, 0
    je NoLivesLeft

    mov game_first_draw, 1
    call ResetBall
    jmp LoseLifeDone

NoLivesLeft:
    mov game_result, 0
    mov current_screen, 6
    mov bg_color, 0

LoseLifeDone:
    ret
LoseLife endp

; ======================================================
; GAME PROCEDURE: CheckBrickCollision
; Damages one active brick per frame and updates score when it breaks.
; ======================================================
CheckBrickCollision proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor si, si
    mov bx, BRICK_START_Y
    mov scan_row, 0

BrickScanRow:
    mov cx, BRICK_START_X
    mov di, BRICK_COLS

BrickScanCol:
    cmp byte ptr bricks[si], 0
    je NextBrickCheck

    mov ax, ball_x
    add ax, 6
    cmp ax, cx
    jl NextBrickCheck

    mov ax, cx
    add ax, BRICK_W
    mov dx, ball_x
    cmp dx, ax
    jg NextBrickCheck

    mov ax, ball_y
    add ax, 6
    cmp ax, bx
    jl NextBrickCheck

    mov ax, bx
    add ax, BRICK_H
    mov dx, ball_y
    cmp dx, ax
    jg NextBrickCheck

    neg ball_dy
    dec byte ptr bricks[si]
    cmp byte ptr bricks[si], 0
    jne BrickDamaged

    add score, 10
    mov hud_dirty, 1
    dec bricks_left
    push ax
    push dx
    mov rect_height, BRICK_H
    mov dx, BRICK_W
    mov al, 0
    call DrawRect
    pop dx
    pop ax

    cmp bricks_left, 0
    jne BrickCollisionDone
    mov game_result, 1
    mov current_screen, 6
    mov bg_color, 0
    jmp BrickCollisionDone

BrickDamaged:
    push ax
    push dx
    mov al, bricks[si]
    cmp al, 2
    je DrawDamagedHard2

    push si
    xor ah, ah
    mov al, scan_row
    mov si, ax
    mov al, row_colors[si]
    pop si
    jmp DrawDamagedBrick

DrawDamagedHard2:
    mov al, hard2_color

DrawDamagedBrick:
    mov rect_height, BRICK_H
    mov dx, BRICK_W
    call DrawRect
    pop dx
    pop ax
    jmp BrickCollisionDone

NextBrickCheck:
    inc si
    add cx, BRICK_STEP_X
    dec di
    jnz BrickScanCol

    add bx, BRICK_STEP_Y
    inc scan_row
    mov al, active_rows
    cmp scan_row, al
    jl BrickScanRow

BrickCollisionDone:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CheckBrickCollision endp

; ======================================================
; GAME PROCEDURE: UpdateHud
; Converts score and lives variables into display strings.
; ======================================================
UpdateHud proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov al, lives
    add al, '0'
    mov hud_lives[7], al

    mov ax, score
    cmp ax, 9999
    jbe ScoreInRange
    mov ax, 9999

ScoreInRange:
    mov di, offset hud_score
    add di, 10
    mov bx, 10
    mov cx, 4

ScoreDigitLoop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    loop ScoreDigitLoop

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UpdateHud endp

; ======================================================
; GAME PROCEDURE: DrawGameFrame
; Draws active bricks, paddle, ball, and HUD.
; ======================================================
DrawGameFrame proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    cmp game_first_draw, 1
    je DrawFrameStatic

    ; Erase only the old moving objects. Bricks are redrawn after this,
    ; so the ball never leaves holes when it crosses the brick rows.
    mov bx, prev_paddle_y
    mov cx, prev_paddle_x
    mov dx, paddle_width
    mov al, 0
    mov rect_height, 6
    call DrawRect

    mov bx, prev_ball_y
    mov cx, prev_ball_x
    mov dx, 7
    mov al, 0
    mov rect_height, 7
    call DrawRect
    call RestoreBricksUnderOldBall

    jmp DrawFrameMoving

DrawFrameStatic:
    ; One-time playfield setup for this round.
    mov bx, 19
    mov cx, 2
    mov dx, 316
    mov al, 0
    mov rect_height, 179
    call DrawRect

    ; HUD band
    mov bx, 0
    mov cx, 0
    mov dx, 320
    mov al, 01h
    mov rect_height, 17
    call DrawRect

    ; Playfield border
    mov bx, 17
    mov cx, 0
    mov dx, 320
    mov al, 08h
    mov rect_height, 2
    call DrawRect

    mov bx, 198
    mov cx, 0
    mov dx, 320
    mov al, 08h
    mov rect_height, 2
    call DrawRect

    mov bx, 17
    mov cx, 0
    mov dx, 2
    mov al, 08h
    mov rect_height, 183
    call DrawRect

    mov bx, 17
    mov cx, 318
    mov dx, 2
    mov al, 08h
    mov rect_height, 183
    call DrawRect

    mov game_first_draw, 0

DrawFrameBricks:
    mov draw_index, 0
    mov draw_row, 0
    mov bx, BRICK_START_Y

DrawFrameRow:
    mov cx, BRICK_START_X
    mov di, BRICK_COLS
    xor ax, ax
    mov al, draw_row
    mov si, ax
    mov al, row_colors[si]
    mov draw_color, al

DrawFrameCol:
    mov si, draw_index
    cmp byte ptr bricks[si], 0
    je SkipBrickDraw

    mov rect_height, BRICK_H
    mov dx, BRICK_W
    mov al, draw_color
    cmp byte ptr bricks[si], 3
    je DrawHard3Brick
    cmp byte ptr bricks[si], 2
    je DrawHard2Brick
    jmp DrawBrickReady

DrawHard3Brick:
    mov al, hard3_color
    jmp DrawBrickReady

DrawHard2Brick:
    mov al, hard2_color

DrawBrickReady:
    call DrawRect

SkipBrickDraw:
    inc draw_index
    add cx, BRICK_STEP_X
    dec di
    jnz DrawFrameCol

    add bx, BRICK_STEP_Y
    inc draw_row
    mov al, active_rows
    cmp draw_row, al
    jl DrawFrameRow

DrawFrameMoving:
    mov bx, paddle_y
    mov cx, paddle_x
    mov dx, paddle_width
    mov al, 0Ch
    mov rect_height, 6
    call DrawRect

    mov bx, ball_y
    mov cx, ball_x
    inc cx
    mov dx, 4
    mov al, 0Fh
    mov rect_height, 1
    call DrawRect

    mov bx, ball_y
    inc bx
    mov cx, ball_x
    mov dx, 6
    mov al, 0Fh
    mov rect_height, 4
    call DrawRect

    mov bx, ball_y
    add bx, 5
    mov cx, ball_x
    inc cx
    mov dx, 4
    mov al, 0Fh
    mov rect_height, 1
    call DrawRect

    cmp hud_dirty, 1
    jne DrawFrameSavePositions

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

    mov dh, 1
    mov dl, 39
    sub dl, name_len
    mov si, offset player_name
    mov bl, 0Eh
    call PrintString
    mov hud_dirty, 0

DrawFrameSavePositions:
    mov ax, paddle_x
    mov prev_paddle_x, ax
    mov ax, paddle_y
    mov prev_paddle_y, ax
    mov ax, ball_x
    mov prev_ball_x, ax
    mov ax, ball_y
    mov prev_ball_y, ax

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DrawGameFrame endp

; ======================================================
; GAME PROCEDURE: RestoreBricksUnderOldBall
; Redraws only active bricks touched by the old ball erase.
; ======================================================
RestoreBricksUnderOldBall proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor si, si
    mov bx, BRICK_START_Y
    mov scan_row, 0

RestoreBrickRow:
    mov cx, BRICK_START_X
    mov di, BRICK_COLS
    xor ax, ax
    mov al, scan_row
    push si
    mov si, ax
    mov al, row_colors[si]
    mov draw_color, al
    pop si

RestoreBrickCol:
    cmp byte ptr bricks[si], 0
    je RestoreNextBrick

    mov ax, prev_ball_x
    add ax, 7
    cmp ax, cx
    jl RestoreNextBrick

    mov ax, cx
    add ax, BRICK_W
    mov dx, prev_ball_x
    cmp dx, ax
    jg RestoreNextBrick

    mov ax, prev_ball_y
    add ax, 7
    cmp ax, bx
    jl RestoreNextBrick

    mov ax, bx
    add ax, BRICK_H
    mov dx, prev_ball_y
    cmp dx, ax
    jg RestoreNextBrick

    mov rect_height, BRICK_H
    mov dx, BRICK_W
    mov al, draw_color
    cmp byte ptr bricks[si], 3
    je RestoreHard3Brick
    cmp byte ptr bricks[si], 2
    je RestoreHard2Brick
    jmp RestoreBrickReady

RestoreHard3Brick:
    mov al, hard3_color
    jmp RestoreBrickReady

RestoreHard2Brick:
    mov al, hard2_color

RestoreBrickReady:
    call DrawRect

RestoreNextBrick:
    inc si
    add cx, BRICK_STEP_X
    dec di
    jnz RestoreBrickCol

    add bx, BRICK_STEP_Y
    inc scan_row
    mov al, active_rows
    cmp scan_row, al
    jl RestoreBrickRow

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
RestoreBricksUnderOldBall endp

; ======================================================
; GAME PROCEDURE: DelayFrame
; Uses BIOS wait to control game speed.
; ======================================================
DelayFrame proc
    push ax
    push cx
    push dx

    mov ah, 86h
    mov cx, 0
    mov dx, frame_delay
    int 15h
    jnc DelayDone

    mov cx, 0FFFFh
DelayFallback:
    loop DelayFallback

DelayDone:
    pop dx
    pop cx
    pop ax
    ret
DelayFrame endp

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
