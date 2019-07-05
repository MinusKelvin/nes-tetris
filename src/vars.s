;;;;;;;;;;;;;;;;;;;;
; system variables ;
;;;;;;;;;;;;;;;;;;;;

; CPU address space

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

JOY_STROBE = $4016
JOY1       = $4016
JOY2       = $4017

; PPU address space

NAMETABLE1  = $2000
NAMETABLE2  = $2800
BG_COLOR    = $3F00
BG_PALETTE0 = $3F01
BG_PALETTE1 = $3F05
BG_PALETTE2 = $3F09
BG_PALETTE3 = $3F0D
SP_PALETTE0 = $3F11
SP_PALETTE1 = $3F15
SP_PALETTE2 = $3F19
SP_PALETTE3 = $3F1D

;;;;;;;;;;;;;;;;
; global state ;
;;;;;;;;;;;;;;;;

; Notes:
; $0500-$057F is for data that persists between states
; $0580-$05FF is for state-specific data

game_state      = $0500

; Global state values

            .rsset 0
S_TO_TITLE  .rs 1
S_TITLE     .rs 1
S_TO_MENU   .rs 1
S_MENU      .rs 1
S_TO_ABOUT  .rs 1

;;;;;;;;;;;;;;;;
; player state ;
;;;;;;;;;;;;;;;;

; Notes:
; A board cell (x, y) is the nibble at byte offset y*5 + x/2, where X.5 is the high nibble.

p_board        = $00    ; length 200 bytes. 
p_score        = $C8    ; length 8 bytes, little endian, 1 byte per digit
p_lines        = $D0    ; length 3 bytes, little endian, 1 byte per digit
p_level        = $D3
p_state        = $D4
p_timer        = $D5
p_combo        = $D6    ; length 2 bytes, little endian, 1 byte per digit
p_b2b_possible = $D8
p_piece_x      = $D9
p_piece_y      = $DA
p_piece_t      = $DB
p_gamepad_new  = $DC
p_gamepad_old  = $DD
p_gamepad_used = $DE
p_shift_timer  = $DF
p_ghost_x      = $E0
p_ghost_y      = $E1
p_next_piece   = $F0
p_next_array   = $F1    ; length 14 bytes

player1 = $0600
player2 = $0700

; Player state values

                .rsset 0
PS_SPAWN_DELAY  .rs 1
PS_FALLING      .rs 1
PS_CLEAR_DELAY  .rs 1

; Gamepad bits

JOY_A      = %10000000
JOY_B      = %01000000
JOY_SELECT = %00100000
JOY_START  = %00010000
JOY_UP     = %00001000
JOY_DOWN   = %00000100
JOY_LEFT   = %00000010
JOY_RIGHT  = %00000001