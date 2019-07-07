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

JOY_A      = %10000000
JOY_B      = %01000000
JOY_SELECT = %00100000
JOY_START  = %00010000
JOY_UP     = %00001000
JOY_DOWN   = %00000100
JOY_LEFT   = %00000010
JOY_RIGHT  = %00000001

;;;;;;;;;;;;;;;;;;;
; drawing buffers ;
;;;;;;;;;;;;;;;;;;;

oam_page = $0200

            .rsset $0300
draw_10_0   .rs 12        ; p1 lc1, p1 score
draw_10_1   .rs 12        ; p1 lc2, p1 all clear text
draw_10_2   .rs 12        ; p1 lc3
draw_10_3   .rs 12        ; p1 lc4
draw_10_4   .rs 12        ; p1 timer
draw_10_5   .rs 12        ; p2 lc1, p2 score
draw_10_6   .rs 12        ; p2 lc2, p2 all clear text
draw_10_7   .rs 12        ; p2 lc3
draw_10_8   .rs 12        ; p2 lc4
draw_10_9   .rs 12        ; p2 timer
draw_4_0    .rs 6         ; p1 next1, p1 hold1, p1 b2b
draw_4_1    .rs 6         ; p1 next2, p1 hold2, p1 combo
draw_4_2    .rs 6         ; p1 next3, p1 palette
draw_4_3    .rs 6         ; p2 next1, p2 hold1, p2 b2b
draw_4_4    .rs 6         ; p2 next2, p2 hold2, p2 combo
draw_4_5    .rs 6         ; p2 next3, p2 palette
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
; $0000-$003F is for temporary (<NMI function) data
; $0040-$007F is for data that persists between states
; $0080-$00BF is for state-specific data
; $00C0-$00FF is for working player data

game_state      = $40
cursor_pos      = $41
rng_addr        = $42

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
; All the player variables (beside the board) are copied onto the zeropage then back after
; doing the player update routine.

; State that persists through state changes

p_board         = $00    ; length 200 bytes.
p_stat_lines    = $C8
p_stat_singles  = $CA
p_stat_doubles  = $CC
p_stat_triples  = $CE
p_stat_tetrises = $D0
p_stat_tspin_0  = $D2
p_stat_tspin_1  = $D4
p_stat_tspin_2  = $D6
p_stat_tspin_3  = $D8
p_stat_b2bs     = $DA
p_stat_allclear = $DC
p_gravity       = $DE    ; fall delay (= 4 / speed in Gs)
p_state         = $DF
p_combo         = $E0    ; binary combo count
p_flags         = $E1
p_garbage_col   = $E2
p_gamepad_new   = $E3
p_gamepad_old   = $E4
p_gamepad_used  = $E5
p_shift_timer   = $E6
p_garbage       = $E7
p_special_timer = $E8
p_hold          = $E9
p_next_index    = $EA
p_next_array1   = $EB    ; length 7 bytes
p_next_array2   = $F2    ; length 7 bytes

; State-specific data

; Spawn delay state - doesn't use first draw10 buffer
; (no extra data - encoded in state id and inits falling state)

; Falling state - doesn't use first draw10 buffer if soft dropped is true, checks special timer
p_piece_x      = $F9
p_piece_y      = $FA
p_piece_t      = $FB    ; top 6 bits = piece type, bottom 2 bits = rotation state
p_ghost_y      = $FC    ; ghost piece y
p_fall_timer   = $FD
p_delay_resets = $FE
p_sdrop_tspin  = $FF    ; 0=no, 1=mini, 2=full, bit 7 = soft drop

; Locked state - doesn't use first draw10 buffer (goes to either clear animation or garbage hook)
p_clear0       = $F9
p_clear1       = $FA
p_clear2       = $FB
p_clear3       = $FC
p_lines_sent   = $FD
p_clear_kind   = $FE
p_hdrop_dist   = $FF

; Clear animation state - does use first draw10 buffer (goes to redraw), doesn't use draw4 buffers
; p_clear0
; p_clear1
; p_clear2
; p_clear3
p_anim_timer   = $FD
p_should_flash = $FE

; Redraw screen state - does use first draw10 buffer (goes to spawn)
p_row          = $F9

player1 = $0600
player2 = $0700

; Player flags
PF_B2B_POSSIBLE = %00000001
PF_ALL_CLEAR    = %00000010
PF_20G          = %00000100

; Player state values
                   .rsset 0
PS_GARBAGE_HOOK    .rs 1
PS_SPAWN_DELAY     .rs 4    ; 4 iterations of updating displayed next pieces
PS_FALLING         .rs 1
PS_LOCKED          .rs 1
PS_CLEAR_ANIM      .rs 1
PS_REDRAW_SCREEN   .rs 1
PS_END_ANIMATION   .rs 1
PS_GAME_OVER       .rs 1

; Clear ids
CL_NONE              = $00
CL_MINI_TSPIN_ZERO   = $01
CL_TSPIN_ZERO        = $02
CL_SINGLE            = $04
CL_MINI_TSPIN_SINGLE = $05
CL_TSPIN_SINGLE      = $06
CL_DOUBLE            = $08
CL_TSPIN_DOUBLE      = $0A
CL_TRIPLE            = $0C
CL_TSPIN_TRIPLE      = $0E
CL_TETRIS            = $10

CF_BACK_TO_BACK      = $20
CF_ALL_CLEAR         = $40

; Indirection variables
playfield_addr = $C0
ppu_offset     = $C2
draw_10_offset = $C3
draw_4_offset  = $C4
draw_5_offset  = $C5