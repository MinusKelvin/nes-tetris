LOCK_DELAY = 30*4

game_init:
  ; clear player variables
  LDA #0
  LDX #0
.clearloop:
  STA player1, X
  STA player2, X
  INX
  BNE .clearloop

  ; init piece sequences
  LDA #0
  STA <p_next_array2+0
  LDA #4
  STA <p_next_array2+1
  LDA #8
  STA <p_next_array2+2
  LDA #12
  STA <p_next_array2+3
  LDA #16
  STA <p_next_array2+4
  LDA #20
  STA <p_next_array2+5
  LDA #24
  STA <p_next_array2+6

  ; player 1
  JSR shuffle
  LDA <p_next_array2+0
  STA player1 + p_next_array2+0
  LDA <p_next_array2+1
  STA player1 + p_next_array2+1
  LDA <p_next_array2+2
  STA player1 + p_next_array2+2
  LDA <p_next_array2+3
  STA player1 + p_next_array2+3
  LDA <p_next_array2+4
  STA player1 + p_next_array2+4
  LDA <p_next_array2+5
  STA player1 + p_next_array2+5
  LDA <p_next_array2+6
  STA player1 + p_next_array2+6

  ; player 2
  JSR shuffle
  LDA <p_next_array2+0
  STA player2 + p_next_array2+0
  LDA <p_next_array2+1
  STA player2 + p_next_array2+1
  LDA <p_next_array2+2
  STA player2 + p_next_array2+2
  LDA <p_next_array2+3
  STA player2 + p_next_array2+3
  LDA <p_next_array2+4
  STA player2 + p_next_array2+4
  LDA <p_next_array2+5
  STA player2 + p_next_array2+5
  LDA <p_next_array2+6
  STA player2 + p_next_array2+6

  ; init next piece
  LDA #7
  STA player1 + p_next_index
  STA player2 + p_next_index

  ; tailcall to init gamepad states
  JMP read_input

shuffle:
  ; swap index 1 with index rng%2
  JSR rng
  AND #$01    ; mod 2
  TAX
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+1
  STA <p_next_array2, X    ; ary[rng] = ary[1]
  STY <p_next_array2+1     ; ary[1] = tmp

  ; swap index 2 with index rng%3
  JSR rng
  TAY
  LDX mod_3, Y    ; mod 3
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+2
  STA <p_next_array2, X    ; ary[rng] = ary[2]
  STY <p_next_array2+2     ; ary[2] = tmp

  ; swap index 3 with index rng%4
  JSR rng
  AND #$03    ; mod 4
  TAX
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+3
  STA <p_next_array2, X    ; ary[rng] = ary[3]
  STY <p_next_array2+3     ; ary[3] = tmp

  ; swap index 4 with index rng%5
  JSR rng
  TAY
  LDX mod_5, Y    ; mod 5
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+4
  STA <p_next_array2, X    ; ary[rng] = ary[4]
  STY <p_next_array2+4     ; ary[4] = tmp

  ; swap index 5 with index rng%6
  JSR rng
  TAY
  LDX mod_6, Y    ; mod 6
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+5
  STA <p_next_array2, X    ; ary[rng] = ary[5]
  STY <p_next_array2+5     ; ary[5] = tmp

  ; swap index 6 with index rng%7
  JSR rng
  TAY
  LDX mod_7, Y    ; mod 7
  LDY <p_next_array2, X    ; tmp = ary[rng]
  LDA <p_next_array2+6
  STA <p_next_array2, X    ; ary[rng] = ary[6]
  STY <p_next_array2+6     ; ary[6] = tmp

  RTS

DAS_DELAY  = 10
DAS_PERIOD = 4

tick_input:
  ; found to turn on when pressed, off when released, and maintain state when held
  LDA <p_gamepad_old
  EOR #$FF
  ORA <p_gamepad_used
  AND <p_gamepad_new
  STA <p_gamepad_used

  ; If left or right were pressed, start DAS
  LDA <p_gamepad_old
  EOR #$FF
  AND <p_gamepad_new
  AND #JOY_LEFT | JOY_RIGHT
  BNE .start_das

  ; If shift timer > DAS_PERIOD, do auto shift
  LDA <p_shift_timer
  CMP #DAS_PERIOD+1
  BPL .auto_shift

  ; If used == 0 but new == 1, do auto shift
  LDA <p_gamepad_used
  EOR #$FF
  AND <p_gamepad_new
  AND #JOY_LEFT | JOY_RIGHT
  BNE .auto_shift

  JMP .das_end

.auto_shift:
  DEC <p_shift_timer
  BEQ .set_shift
  JMP .das_end

.set_shift:
  LDA <p_gamepad_new
  AND #JOY_LEFT | JOY_RIGHT
  ORA <p_gamepad_used
  STA <p_gamepad_used
  JMP .das_end

.start_das:
  LDA #DAS_DELAY
  STA <p_shift_timer

.das_end:

  ; Special-case hard drop to instantly clear when held
  LDA <p_gamepad_new
  AND <p_gamepad_old
  AND #JOY_UP
  EOR #$FF
  AND <p_gamepad_used
  STA <p_gamepad_used

  RTS

; Expect: player info has been copied to zeropage $C8-$FF
; Expect: $C0-$C1 is address of playfield
; Expect: $C2 is rightwards PPU offset of graphical origin
; Expect: $C3 is offset from draw_10_0 for first draw10 buffer
; Expect: $C4 is offset from draw_4_0 for first draw4 buffer
; Expect: $C5 is offset from draw_5_0 for first draw5 buffer
p_update:
  JSR tick_input

  LDA <p_state
  ASL A
  TAX
  LDA .jt, X
  STA <$00
  LDA .jt+1, X
  STA <$01
  JMP [$0000]

.jt:
  .dw garbage_hook
  .dw spawn_delay_0
  .dw spawn_delay_1
  .dw spawn_delay_2
  .dw spawn_delay_3
  .dw falling
  .dw locked
  .dw clear_anim
  .dw redraw

garbage_hook:
  LDA #PS_SPAWN_DELAY
  STA <p_state
  RTS

spawn_delay_0:
  LDA <p_next_index
  CMP #7
  BNE .skip_new_bag

  LDA <p_next_array2
  STA <p_next_array1
  LDA <p_next_array2+1
  STA <p_next_array1+1
  LDA <p_next_array2+2
  STA <p_next_array1+2
  LDA <p_next_array2+3
  STA <p_next_array1+3
  LDA <p_next_array2+4
  STA <p_next_array1+4
  LDA <p_next_array2+5
  STA <p_next_array1+5
  LDA <p_next_array2+6
  STA <p_next_array1+6

  JSR shuffle

  LDA #0

.skip_new_bag:
  CLC
  TAX
  ADC #1
  STA <p_next_index

  ; init piece
  LDA #3
  STA <p_piece_x

  LDA #20
  STA <p_piece_y

  LDA #0
  STA <p_delay_resets
  STA <p_sdrop_tspin

  LDA #1
  STA <p_fall_timer

  LDA <p_next_array1, X
  STA <p_piece_t

  CMP #8
  BNE .noinc
  INC <p_piece_x    ; O piece spawns 1 cell farther right
.noinc:

  CLC
  LDY <draw_4_offset

  ; high bytes of PPU addresses
  LDA #$20
  STA draw_4_0, Y
  STA draw_4_1, Y
  LDA #$21
  STA draw_4_2, Y

  ; low bytes of PPU addresses
  LDA #$CB
  ADC <ppu_offset
  STA draw_4_0+1, Y
  LDA #$EB
  ADC <ppu_offset
  STA draw_4_1+1, Y
  LDA #$0B
  ADC <ppu_offset
  STA draw_4_2+1, Y

  ; next piece 1
  LDX <p_next_index
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_0+2, Y
  ADC #1
  STA draw_4_0+3, Y
  ADC #1
  STA draw_4_0+4, Y
  ADC #1
  STA draw_4_0+5, Y
  ADC #1
  STA draw_4_1+2, Y
  ADC #1
  STA draw_4_1+3, Y
  ADC #1
  STA draw_4_1+4, Y
  ADC #1
  STA draw_4_1+5, Y

  ; top half of next piece 2
  INX
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_2+2, Y
  ADC #1
  STA draw_4_2+3, Y
  ADC #1
  STA draw_4_2+4, Y
  ADC #1
  STA draw_4_2+5, Y

  LDA #PS_SPAWN_DELAY+1
  STA <p_state

  RTS

spawn_delay_1:
  CLC
  LDY <draw_4_offset

  ; high bytes of PPU addresses
  LDA #$21
  STA draw_4_0, Y
  STA draw_4_1, Y
  STA draw_4_2, Y

  ; low bytes of PPU addresses
  LDA #$2B
  ADC <ppu_offset
  STA draw_4_0+1, Y
  LDA #$4B
  ADC <ppu_offset
  STA draw_4_1+1, Y
  LDA #$6B
  ADC <ppu_offset
  STA draw_4_2+1, Y

  ; bottom half of next piece 2
  LDX <p_next_index
  INX
  LDA <p_next_array1, X
  ASL A
  ADC #$84
  STA draw_4_0+2, Y
  ADC #1
  STA draw_4_0+3, Y
  ADC #1
  STA draw_4_0+4, Y
  ADC #1
  STA draw_4_0+5, Y

  ; next piece 3
  INX
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_1+2, Y
  ADC #1
  STA draw_4_1+3, Y
  ADC #1
  STA draw_4_1+4, Y
  ADC #1
  STA draw_4_1+5, Y
  ADC #1
  STA draw_4_2+2, Y
  ADC #1
  STA draw_4_2+3, Y
  ADC #1
  STA draw_4_2+4, Y
  ADC #1
  STA draw_4_2+5, Y

  LDA #PS_SPAWN_DELAY+2
  STA <p_state

  RTS

spawn_delay_2:
  CLC
  LDY <draw_4_offset

  ; high bytes of PPU addresses
  LDA #$21
  STA draw_4_0, Y
  STA draw_4_1, Y
  STA draw_4_2, Y

  ; low bytes of PPU addresses
  LDA #$8B
  ADC <ppu_offset
  STA draw_4_0+1, Y
  LDA #$AB
  ADC <ppu_offset
  STA draw_4_1+1, Y
  LDA #$CB
  ADC <ppu_offset
  STA draw_4_2+1, Y

  ; next piece 4
  LDA <p_next_index
  ADC #3
  TAX
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_0+2, Y
  ADC #1
  STA draw_4_0+3, Y
  ADC #1
  STA draw_4_0+4, Y
  ADC #1
  STA draw_4_0+5, Y
  ADC #1
  STA draw_4_1+2, Y
  ADC #1
  STA draw_4_1+3, Y
  ADC #1
  STA draw_4_1+4, Y
  ADC #1
  STA draw_4_1+5, Y

  ; top half of next piece 5
  INX
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_2+2, Y
  ADC #1
  STA draw_4_2+3, Y
  ADC #1
  STA draw_4_2+4, Y
  ADC #1
  STA draw_4_2+5, Y

  LDA #PS_SPAWN_DELAY+3
  STA <p_state

  RTS

spawn_delay_3:
  CLC
  LDY <draw_4_offset

  ; high bytes of PPU addresses
  LDA #$21
  STA draw_4_0, Y
  LDA #$22
  STA draw_4_1, Y
  STA draw_4_2, Y

  ; low bytes of PPU addresses
  LDA #$EB
  ADC <ppu_offset
  STA draw_4_0+1, Y
  LDA #$0B
  ADC <ppu_offset
  STA draw_4_1+1, Y
  LDA #$2B
  ADC <ppu_offset
  STA draw_4_2+1, Y

  ; bottom half of next piece 5
  LDA <p_next_index
  ADC #4
  TAX
  LDA <p_next_array1, X
  ASL A
  ADC #$84
  STA draw_4_0+2, Y
  ADC #1
  STA draw_4_0+3, Y
  ADC #1
  STA draw_4_0+4, Y
  ADC #1
  STA draw_4_0+5, Y

  ; next piece 3
  INX
  LDA <p_next_array1, X
  ASL A
  ADC #$80
  STA draw_4_1+2, Y
  ADC #1
  STA draw_4_1+3, Y
  ADC #1
  STA draw_4_1+4, Y
  ADC #1
  STA draw_4_1+5, Y
  ADC #1
  STA draw_4_2+2, Y
  ADC #1
  STA draw_4_2+3, Y
  ADC #1
  STA draw_4_2+4, Y
  ADC #1
  STA draw_4_2+5, Y

  LDA #PS_FALLING
  STA <p_state
  RTS
  
falling:
  ; Step 1: hold
  LDA <p_gamepad_used
  AND #JOY_SELECT
  BEQ .jno_hold

  LDA <p_gamepad_used
  AND #~JOY_SELECT
  STA <p_gamepad_used

  LDA <p_hold
  BMI .jno_hold    ; check can't hold flag
  JMP .jskip
.jno_hold:
  JMP .no_hold
.jskip:

  ; draw new hold piece
  LDX <draw_4_offset
  LDA #$22
  STA draw_4_0, X
  STA draw_4_1, X

  CLC
  LDA #$8B
  ADC <ppu_offset
  STA draw_4_0+1, X
  LDA #$AB
  ADC <ppu_offset
  STA draw_4_1+1, X

  LDA <p_piece_t
  AND #~3
  ASL A
  ADC #$80
  STA draw_4_0+2, X
  ADC #1
  STA draw_4_0+3, X
  ADC #1
  STA draw_4_0+4, X
  ADC #1
  STA draw_4_0+5, X
  ADC #1
  STA draw_4_1+2, X
  ADC #1
  STA draw_4_1+3, X
  ADC #1
  STA draw_4_1+4, X
  ADC #1
  STA draw_4_1+5, X

  LDA <p_hold
  BNE .do_hold

  ; no hold piece, so set it and go to spawn delay state
  LDA <p_piece_t
  CLC
  ADC #1
  ORA #$80
  STA <p_hold

  LDA #PS_SPAWN_DELAY
  STA <p_state

  RTS

.do_hold:
  ; remember new hold piece
  LDA <p_piece_t
  AND #~3
  CLC
  ADC #1
  ORA #$80
  STA <$00

  ; init new piece
  LDA #3
  STA <p_piece_x
  LDA #20
  STA <p_piece_y
  LDA #0
  STA <p_delay_resets
  STA <p_sdrop_tspin
  LDA #1
  STA <p_fall_timer

  LDA <p_hold
  SBC #0          ; carry is clear (from ADC above): subtracts 1
  STA <p_piece_t

  CMP #8
  BNE .noinc
  INC <p_piece_x    ; O piece spawns 1 cell farther right
.noinc:
  ; set hold piece
  LDA <$00
  STA <p_hold

.no_hold:

  ; Step 2: rotate
  ; TODO

  JSR decode_piece

  ; Step 2a: check for top out
  JSR decoded_obstructed
  BEQ .no_top_out

  ; TODO go to proper state
  LDA #S_TO_TITLE
  STA <game_state
  RTS

.no_top_out:

  ; Step 2: move
  ; TODO

  ; Step 3: gravity
  DEC <p_fall_timer
  BNE .no_fall_0
  JSR fall
.no_fall_0:

  DEC <p_fall_timer
  BNE .no_fall_1
  JSR fall
.no_fall_1:

  DEC <p_fall_timer
  BNE .no_fall_2
  JSR fall
.no_fall_2:

  DEC <p_fall_timer
  BNE .no_fall_3
  JSR fall
.no_fall_3:

  ; Step 4: ghost piece
  LDA <p_piece_y
  STA <p_ghost_y
  SEC
.ghost_loop:
  JSR below_obstructed
  BNE .ghost_end

  DEC <p_ghost_y
  LDA <$10
  SBC #5
  STA <$10
  LDA <$11
  SBC #5
  STA <$11
  LDA <$12
  SBC #5
  STA <$12
  LDA <$13
  SBC #5
  STA <$13
  
  JMP .ghost_loop

.ghost_end:

  ; Step 5: harddrop and 20G
  LDA <p_gamepad_used
  AND #JOY_UP
  BEQ .no_hdrop

  JMP lock_piece
.no_hdrop:

  LDA <p_flags
  AND #PF_20G
  BEQ .no_20G

  LDA <p_ghost_y
  CMP <p_piece_y
  BEQ .no_20G

  STA <p_piece_y
  LDA #LOCK_DELAY
  STA <p_fall_timer
.no_20G:

  ; Sprite pattern
  LDX <oam_offset
  LDA <p_piece_t
  LSR A
  LSR A
  CLC
  ADC #$41
  STA oam_page+$01, X
  STA oam_page+$05, X
  STA oam_page+$09, X
  STA oam_page+$0D, X
  LDA #$4F
  STA oam_page+$11, X
  STA oam_page+$15, X
  STA oam_page+$19, X
  STA oam_page+$1D, X

  ; Sprite attributes
  LDA #%00100000
  ORA <sprite_palette
  STA oam_page+$02, X
  STA oam_page+$06, X
  STA oam_page+$0A, X
  STA oam_page+$0E, X
  STA oam_page+$12, X
  STA oam_page+$16, X
  STA oam_page+$1A, X
  STA oam_page+$1E, X

  ; loop counter
  LDY #4

  ; loop oam_offset
  LDA <oam_offset
  STA <$00

  ; piece_shape index
  LDA <p_piece_t
  ASL A
  ASL A
  STA <$01

.piece_loop:
  ; calc y
  LDX <$01
  LDA #24
  SEC
  SBC <p_piece_y
  SEC
  SBC piece_shape_y, X
  ASL A
  ASL A
  ASL A
  SEC
  SBC #1

  LDX <$00
  STA oam_page, X

  LDA <p_piece_y
  CMP <p_ghost_y
  BEQ .skip_ghost
  ; calc ghost y
  LDX <$01
  LDA #24
  SEC
  SBC <p_ghost_y
  SEC
  SBC piece_shape_y, X
  ASL A
  ASL A
  ASL A
  SEC
  SBC #1

  LDX <$00
  STA oam_page+$10, X
.skip_ghost:

  ; calc x
  LDX <$01
  LDA #1
  CLC
  ADC <p_piece_x
  ADC piece_shape_x, X
  ADC <ppu_offset
  ASL A
  ASL A
  ASL A

  LDX <$00
  STA oam_page+$03, X
  STA oam_page+$13, X

  ; increment loop oam_offset
  TXA
  CLC
  ADC #4
  STA <$00

  ; increment shape index
  INC <$01

  ; loop counter
  DEY
  BNE .piece_loop
  
  RTS

; Expect: piece is in bounds
; result goes into $10-$13 (indices) and $14-$17 (masks)
decode_piece:
  ; setup index
  LDA <p_piece_t
  ASL A
  ASL A
  STA <$00
  ; loop counter
  LDX #0

.loop:
  CLC
  ; calc x index and mask
  LDY <$00
  LDA piece_shape_x, Y
  ADC <p_piece_x             ; carry clear from CLC
  LSR A
  STA <$01                   ; x-index

  LDA #$0F
  BCC .low_mask
  CLC
  LDA #$F0
.low_mask:
  STA <$14, X                ; mask

  ; calc y index
  LDA piece_shape_y, Y
  ADC <p_piece_y             ; carry clear from BCC/CLC
  TAY
  LDA mul_5, Y
  ADC <$01                   ; carry clear from ADC
  STA <$10, X                ; index

  INC <$00
  INX
  CPX #4
  BNE .loop

  RTS

decoded_obstructed:
  LDY <$10
  LDA [playfield_addr], Y
  AND <$14
  BNE _obstructed

  LDY <$11
  LDA [playfield_addr], Y
  AND <$15
  BNE _obstructed

  LDY <$12
  LDA [playfield_addr], Y
  AND <$16
  BNE _obstructed

  LDY <$13
  LDA [playfield_addr], Y
  AND <$17
  BNE _obstructed

  LDA #0
  RTS

_obstructed:
  LDA #1
  RTS

full_obstructed:
  LDX <p_piece_t
  LDA <p_piece_x
  BMI _obstructed        ; bounds check x < 0
  CLC
  ADC piece_width, X
  CMP #11
  BPL _obstructed        ; bounds check x+w > 10

  LDA <p_piece_y
  BMI _obstructed        ; bounds check y < 0
  CLC
  ADC piece_height, X
  CMP #41
  BPL _obstructed        ; bounds check y+h > 40

  JSR decode_piece

  JMP decoded_obstructed ; tailcall

below_obstructed:
  SEC

  LDA <$10
  SBC #5
  BCC _obstructed
  TAY
  LDA [playfield_addr], Y
  AND <$14
  BNE _obstructed

  LDA <$11
  SBC #5
  BCC _obstructed
  TAY
  LDA [playfield_addr], Y
  AND <$15
  BNE _obstructed

  LDA <$12
  SBC #5
  BCC _obstructed
  TAY
  LDA [playfield_addr], Y
  AND <$16
  BNE _obstructed

  LDA <$13
  SBC #5
  BCC _obstructed
  TAY
  LDA [playfield_addr], Y
  AND <$17
  BNE _obstructed

  LDA #0
  RTS

fall:
  JSR below_obstructed
  BNE .lock

  DEC <p_piece_y

  SEC
  LDA <$10
  SBC #5
  STA <$10

  LDA <$11
  SBC #5
  STA <$11

  LDA <$12
  SBC #5
  STA <$12

  LDA <$13
  SBC #5
  STA <$13

  JSR below_obstructed
  BNE .lock_delay
  LDA <p_gravity
  STA <p_fall_timer
  RTS

.lock_delay:
  LDA #LOCK_DELAY
  STA <p_fall_timer
  RTS

.lock:
  ; pop return to falling state function (there's nothing to do there)
  PLA
  PLA
  JMP lock_piece

; Expect: returns from update function
lock_piece:
  ; allow hold again
  LDA <p_hold
  AND #$7F
  STA <p_hold

  ; TODO actually lock the piece
  LDA #PS_SPAWN_DELAY
  STA <p_state
  RTS

locked:
  RTS
  
clear_anim:
  RTS
  
redraw:
  RTS