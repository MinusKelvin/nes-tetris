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

; Important constants

PPU_ENABLE  = %00001110
PPU_SPRITES = %00010000

;;;;;;;;;;;;;;;;;;;
; drawing buffers ;
;;;;;;;;;;;;;;;;;;;

            .rsset $0300
draw_10_0   .rs 12        ; p1 lc1, p1 score
draw_10_1   .rs 12        ; p1 lc2
draw_10_2   .rs 12        ; p1 lc3
draw_10_3   .rs 12        ; p1 lc4
draw_10_4   .rs 12        ; p2 lc1, p2 score
draw_10_5   .rs 12        ; p2 lc2
draw_10_6   .rs 12        ; p2 lc3
draw_10_7   .rs 12        ; p2 lc4
draw_4_0    .rs 6         ; p1 next 1, p1 combo
draw_4_1    .rs 6         ; p1 next 2, p1 objective
draw_4_2    .rs 6         ; p1 next 3, p1 b2b, p1 hold 1
draw_4_3    .rs 6         ; p1 next 4, p1 hold 2
draw_4_4    .rs 6         ; p2 next 1, p2 combo
draw_4_5    .rs 6         ; p2 next 2, p2 objective
draw_4_6    .rs 6         ; p2 next 3, p2 b2b, p2 hold 1
draw_4_7    .rs 6         ; p2 next 4, p2 hold 2
draw_5_0    .rs 7         ; p1 clearname
draw_5_1    .rs 7         ; p2 clearname
draw_20_0   .rs 22        ; (vertical) p1 garbage
draw_20_1   .rs 22        ; (vertical) p2 garbage

_draw_len    .rs 0
draw_len = LOW(_draw_len)

;;;;;;;;;;;;;;;;
; global state ;
;;;;;;;;;;;;;;;;

; Notes:
; $0500-$057F is for data that persists between states
; $0580-$05FF is for state-specific data

game_state      = $0500
cursor_pos      = $0501

; Global state values

                 .rsset 0
S_TO_TITLE       .rs 1
S_TITLE          .rs 1
S_TO_MENU        .rs 1
S_MENU           .rs 1
S_TO_SPRINT_1    .rs 1
S_TO_MARATHON_1  .rs 1
S_TO_ULTRA_1     .rs 1
S_TO_BATTLE      .rs 1
S_TO_SPRINT_2    .rs 1
S_TO_MARATHON_2  .rs 1
S_TO_ULTRA_2     .rs 1
S_TO_ABOUT       .rs 1
S_ABOUT          .rs 1
S_SPRINT_1       .rs 1
S_MARATHON_1     .rs 1
S_ULTRA_1        .rs 1
S_BATTLE         .rs 1
S_SPRINT_2       .rs 1
S_MARATHON_2     .rs 1
S_ULTRA_2        .rs 1
S_PAUSED         .rs 1

;;;;;;;;;;;;;;;;
; player state ;
;;;;;;;;;;;;;;;;

; Notes:
; A board cell (x, y) is the nibble at byte offset y*5 + x/2, where X.5 is the high nibble.

p_board        = $00    ; length 200 bytes. 
p_score        = $C8    ; length 8 bytes, little endian, 1 byte per digit
p_lines        = $D0
p_level        = $D1
p_state        = $D2
p_timer        = $D3
p_combo        = $D4
p_b2b_possible = $D5
p_piece_x      = $D6
p_piece_y      = $D7
p_piece_t      = $D8
p_gamepad_new  = $D9
p_gamepad_old  = $DA
p_gamepad_used = $DB
p_shift_timer  = $DC
p_ghost_y      = $DD
p_next_index   = $F0
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