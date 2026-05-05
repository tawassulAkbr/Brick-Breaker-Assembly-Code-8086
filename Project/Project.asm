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

    ; Draw Slider (Paddle)
    mov bx, 155     ; y position
    mov cx, 130      ; x position
    mov dx, 60       ; paddle width
    mov al, 0Ch      ; color Light Red
    mov rect_height, 8 ; paddle height
    call DrawRect

    ; Draw Round Ball 
    ; Top line
    mov bx, 145      ; y position
    mov cx, 159      ; x position (indent 1)
    mov dx, 4        ; line width
    mov al, 0Fh      ; color White
    mov rect_height, 1 ; line height
    call DrawRect

    ; Mid Body
    mov bx, 146      
    mov cx, 158      ; expand to full 6 width
    mov dx, 6        
    mov rect_height, 4 ; inner height
    call DrawRect

    ; Bottom Line
    mov bx, 150      
    mov cx, 159      ; indent 1
    mov dx, 4        
    mov rect_height, 1 ; line height
    call DrawRect

    ; Draw Top HUD (Header)
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

    ; Wait for Enter or Backspace to return to menu
    mov ah, 00h
    int 16h
    cmp al, 13
    je ReturnMenu
    cmp al, 8 ; Backspace
    je ReturnMenu
    jmp GameLoop

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