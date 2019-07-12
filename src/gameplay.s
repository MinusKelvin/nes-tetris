LOCK_DELAY = 30*4
MAX_DELAY_RESETS = 15
SOFT_DROP_DELAY = 7

DAS_DELAY  = 8
DAS_PERIOD = 3

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
  LDA #DAS_PERIOD
  STA <p_shift_timer
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
  .dw redraw_0
  .dw redraw_1
  .dw redraw_2
  .dw redraw_3
  .dw redraw_4
  .dw redraw_5
  .dw end_anim
  .dw game_over

falling:
  LDA <p_sdrop_tspin
  AND #$7F
  STA <p_sdrop_tspin

  ;;;;;;;;;;;;;;;;
  ; Step 1: hold ;
  ;;;;;;;;;;;;;;;;

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
  STA <$04

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
  SEC
  SBC #1
  STA <p_piece_t

  CMP #8
  BNE .noinc
  INC <p_piece_x    ; O piece spawns 1 cell farther right
.noinc:

  JSR decode_piece
  JSR below_obstructed
  BEQ .no_lock_delay
  LDA #LOCK_DELAY
  STA <p_fall_timer
.no_lock_delay:

  ; set hold piece
  LDA <$04
  STA <p_hold
  RTS

.no_hold:
  JSR decode_piece

  ;;;;;;;;;;;;;;;;;;
  ; Step 2: rotate ;
  ;;;;;;;;;;;;;;;;;;

  LDA <p_gamepad_used
  AND #JOY_A
  BEQ .no_cw

  LDA #1
  STA <$04
  JSR rotate
  BEQ .no_cw

  LDA <p_gamepad_used
  AND #~JOY_A
  STA <p_gamepad_used

.no_cw:

  LDA <p_gamepad_used
  AND #JOY_B
  BEQ .no_ccw

  LDA #3
  STA <$04
  JSR rotate
  BEQ .no_ccw

  LDA <p_gamepad_used
  AND #~JOY_B
  STA <p_gamepad_used

.no_ccw:

  ;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
  ; Step 3: check for top out ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  JSR decoded_obstructed
  BEQ .no_top_out
  JMP topped_out

.no_top_out:

  ;;;;;;;;;;;;;;;;
  ; Step 4: move ;
  ;;;;;;;;;;;;;;;;

  LDA <p_gamepad_used
  AND #JOY_LEFT
  BEQ .no_move_left

  LDA #$FF
  STA <$04
  JSR move
  BEQ .no_move_left

  LDA <p_gamepad_used
  AND #~JOY_LEFT
  STA <p_gamepad_used

.no_move_left:

  LDA <p_gamepad_used
  AND #JOY_RIGHT
  BEQ .no_move_right

  LDA #$01
  STA <$04
  JSR move
  BEQ .no_move_right

  LDA <p_gamepad_used
  AND #~JOY_RIGHT
  STA <p_gamepad_used

.no_move_right:

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Step 5: gravity & soft drop ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDA <p_gamepad_used
  AND #JOY_DOWN
  BEQ .no_sdrop

  LDA <p_fall_timer
  CMP #SOFT_DROP_DELAY
  BCC .no_sdrop

  JSR below_obstructed
  BNE .no_sdrop

  LDA #SOFT_DROP_DELAY
  STA <p_fall_timer
  LDA <p_sdrop_tspin
  ORA #$80
  STA <p_sdrop_tspin

.no_sdrop:

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

  ;;;;;;;;;;;;;;;;;;;;;;;
  ; Step 6: ghost piece ;
  ;;;;;;;;;;;;;;;;;;;;;;;

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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Step 7: harddrop and 20G ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  LDA <p_gamepad_used
  AND #JOY_UP
  BEQ .no_hdrop

  LDA <p_piece_y
  SEC
  SBC <p_ghost_y
  STA <$0F

  LDA <p_ghost_y
  STA <p_piece_y

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

  ;;;;;;;;;;;;;;;;;;;
  ; Step 8: drawing ;
  ;;;;;;;;;;;;;;;;;;;

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

reset_lock_delay:
  LDA <p_delay_resets
  CMP #MAX_DELAY_RESETS
  BPL .end
  INC <p_delay_resets
  LDA #LOCK_DELAY
  STA <p_fall_timer
.end:
  RTS

; Expect: $04 is movement amount ($FF for left, 1 for right)
move:
  JSR below_obstructed
  STA <$09                    ; was floating

  LDA <p_piece_x
  STA <$08                    ; original x
  CLC
  ADC <$04
  STA <p_piece_x

  JSR full_obstructed
  BEQ .success
  
  LDA <$08
  STA <p_piece_x
  JSR decode_piece
  LDA #0
  RTS

.success:
  JSR below_obstructed
  BEQ .floating

  ; if not floating then reset lock delay
  JSR reset_lock_delay
  LDA #0
  STA <p_sdrop_tspin

  LDA #1
  RTS

.floating:
  LDA <$09
  BEQ .end

  ; not floating -> floating means gravity applies
  LDA <p_gravity
  STA <p_fall_timer

.end:
  LDA #1
  RTS

; Expect: $04 is rotation amount (0 for slow no-op, 1 CW, 2 flip, 3 CCW)
rotate:
  JSR below_obstructed
  STA <$06            ; was floating
  LDA <p_piece_t
  STA <$07            ; original rotation state
  AND #~3
  STA <$08
  LDA <$07
  CLC
  ADC <$04
  AND #3
  ORA <$08
  STA <p_piece_t      ; set target rotation state
  TAX
  LDA mul_5, X
  STA <$09            ; target rotation offset index
  LDX <$07
  LDA mul_5, X
  STA <$08            ; inital rotation offset index
  LDA <p_piece_x
  STA <$0A            ; original x
  LDA <p_piece_y
  STA <$0B            ; original y
  LDA #5
  STA <$0C            ; loop counter

.loop:
  LDX <$08
  LDA piece_offset_x, X
  LDX <$09
  SEC
  SBC piece_offset_x, X
  CLC
  ADC <$0A
  STA <p_piece_x

  LDX <$08
  LDA piece_offset_y, X
  LDX <$09
  SEC
  SBC piece_offset_y, X
  CLC
  ADC <$0B
  STA <p_piece_y

  JSR full_obstructed
  BEQ .success

  INC <$08
  INC <$09
  DEC <$0C
  BNE .loop

  ; rotation failed
  LDA <$07
  STA <p_piece_t
  LDA <$0A
  STA <p_piece_x
  LDA <$0B
  STA <p_piece_y
  JSR decode_piece
  
  LDA #0
  RTS

.success:
  JSR below_obstructed
  BEQ .floating

  ; not floating = reset lock delay
  JSR reset_lock_delay
  JMP .tspin_check

.floating:
  LDA <$06
  BEQ .tspin_check

  ; not floating -> floating means gravity applies
  LDA <p_gravity
  STA <p_fall_timer

.tspin_check:
  LDA <p_piece_t
  AND #~3
  CMP #4           ; T piece
  BNE .no_tspin

  LDA #3
  STA <$08

  LDA <p_piece_t
  AND #3
  ASL A
  ASL A
  STA <$09

.corner_loop:
  LDX <$09
  LDA <p_piece_x
  CLC
  ADC t_corners_x, X
  STA <$00

  LDA <p_piece_y
  CLC
  ADC t_corners_y, X
  STA <$01

  JSR is_occupied
  LDX <$08
  STA <$04, X

  INC <$09
  DEC <$08
  BPL .corner_loop

  LDA #0
  CLC
  ADC <$04
  ADC <$05
  ADC <$06
  ADC <$07
  CMP #3
  BMI .no_tspin

  LDA #0
  CLC
  ADC <$06
  ADC <$07
  CMP #2
  BEQ .full_tspin

  LDA <$0C
  CMP #3       ; $0C = 1 for 5th kick, 2 for 4th kick, and we consider both to be TST twists.
  BMI .full_tspin                                    ; this means you can't do a Mini TSD.

  LDA #1
  STA <p_sdrop_tspin
  JMP .end_tspin

.full_tspin:
  LDA #2
  STA <p_sdrop_tspin
  JMP .end_tspin

.no_tspin:
  LDA #0
  STA <p_sdrop_tspin

.end_tspin:
  LDA #1
  RTS

.no_rotate:
  LDA #0
  RTS

; Expect: $00 is x, $01 is y (preserves X)
is_occupied:
  LDA <$00
  BMI .occupied
  CMP #10
  BPL .occupied

  ; calc mask
  LSR A
  STA <$00
  BCS .high_nibble
  LDA #$0F
  STA <$03
  JMP .past_high
.high_nibble:
  LDA #$F0
  STA <$03
.past_high:

  LDA <$01
  BMI .occupied
  CMP #40
  BPL .occupied

  TAY
  LDA mul_5, Y
  CLC
  ADC <$00

  TAY
  LDA [playfield_addr], Y
  AND <$03
  BNE .occupied
  RTS              ; A = 0

.occupied:
  LDA #1
  RTS

fall:
  JSR below_obstructed
  BNE .lock

  DEC <p_piece_y
  LDA <p_sdrop_tspin
  AND #~3
  STA <p_sdrop_tspin

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
  ; pop return to falling state subroutine (there's nothing to do there)
  PLA
  PLA
  LDA #0
  STA <$0F
  JMP lock_piece

; Expect: returns from update subroutine
; Expect: $0F contains hard drop distance
lock_piece:
  ; allow hold again
  LDA <p_hold
  AND #$7F
  STA <p_hold

  ; piece id
  LDA <p_piece_t
  LSR A
  LSR A
  CLC
  ADC #1
  STA <$00
  ASL A
  ASL A
  ASL A
  ASL A
  STA <$01

  LDX #0
.loop:
  LDY <$10, X
  LDA <$14, X
  BPL .lower_0
  
  LDA [playfield_addr], Y
  AND #$0F
  ORA <$01
  STA [playfield_addr], Y
  JMP .end_0

.lower_0:
  LDA [playfield_addr], Y
  AND #$F0
  ORA <$00
  STA [playfield_addr], Y

.end_0:
  INX
  CPX #4
  BNE .loop

  ; draw lines
  LDA <p_piece_y
  STA <$08
  LDA #$40
  STA <$01
  LDA <draw_10_offset
  STA <$09

.draw_loop:
  LDA <$08
  CMP #20
  BEQ .row21
  BPL .done
  JMP .cont
.row21:
  LDA #$50
  STA <$01
.cont:
  LDX <$08
  LDY mul_5, X
  LDA line_ppu_high, X
  LDX <$09
  STA draw_10_0, X
  LDX <$08
  LDA line_ppu_low, X
  CLC
  ADC <ppu_offset
  LDX <$09
  STA draw_10_0+1, X
  JSR decode_line_draw
  LDA <$09
  CLC
  ADC #12
  STA <$09
  LDA <$08
  ADC #1
  STA <$08
  SEC
  SBC #4
  CMP <p_piece_y
  BNE .draw_loop
.done:

  ; a piece locking above the playfield is game over
  LDA <p_piece_y
  CMP #20
  BMI .no_lock_out
  JMP topped_out
.no_lock_out:

  ; check for line clears
  ; $08 = row
  ; $09 = counter
  ; $0A = all clear flag
  ; $0B = cleared lines
  LDA #0
  STA <$0B
  LDA <p_piece_y
  STA <$08
  BNE .no_allclear
  LDA #CF_ALL_CLEAR
  STA <$0A
.no_allclear:
  LDA #0
  STA <$09

.check_clear_loop:
  LDX <$08
  LDY mul_5, X

  LDA [playfield_addr], Y
  AND #$0F
  BEQ .no_clear
  LDA [playfield_addr], Y
  AND #$F0
  BEQ .no_clear
  INY

  LDA [playfield_addr], Y
  AND #$0F
  BEQ .no_clear
  LDA [playfield_addr], Y
  AND #$F0
  BEQ .no_clear
  INY

  LDA [playfield_addr], Y
  AND #$0F
  BEQ .no_clear
  LDA [playfield_addr], Y
  AND #$F0
  BEQ .no_clear
  INY

  LDA [playfield_addr], Y
  AND #$0F
  BEQ .no_clear
  LDA [playfield_addr], Y
  AND #$F0
  BEQ .no_clear
  INY

  LDA [playfield_addr], Y
  AND #$0F
  BEQ .no_clear
  LDA [playfield_addr], Y
  AND #$F0
  BEQ .no_clear

  LDX <$09
  LDA <$08
  STA <p_clear0, X
  INC <$0B
  JMP .check_loop_end

.no_clear:
  LDY mul_5, X            ; X is maintained
  LDX <$09
  LDA #$FF
  STA <p_clear0, X
  LDA #0
  ORA [playfield_addr], Y
  INY
  ORA [playfield_addr], Y
  INY
  ORA [playfield_addr], Y
  INY
  ORA [playfield_addr], Y
  INY
  ORA [playfield_addr], Y
  BEQ .check_loop_end
  LDA #0
  STA <$0A

.check_loop_end:
  INC <$08
  INC <$09
  LDA <$09
  CMP #5
  BEQ .check_loop_after
  JMP .check_clear_loop

.check_loop_after:
  LDA <$0B
  ASL A
  ASL A
  ORA <p_sdrop_tspin
  AND #$7F
  STA <p_clear_kind

  ; Stuff to check on line clear
  LDA <$0B
  BNE .lines_cleared

  ; end combo
  LDA #0
  STA <p_combo
  JMP .end_clear_stuff

.lines_cleared:
  INC <p_combo

  ; check clear kind
  LDA <p_clear_kind
  AND #$13               ; $10 means tetris, $03 means t-spin
  BNE .hard_move

  ; "easy" move; no b2b
  LDA <p_flags
  AND #~PF_B2B_POSSIBLE
  STA <p_flags
  JMP .end_clear_stuff

.hard_move:
  LDA <p_flags
  AND #PF_B2B_POSSIBLE
  BEQ .not_b2b
  LDA <p_clear_kind
  ORA #CF_B2B
  STA <p_clear_kind
.not_b2b:
  LDA <p_flags
  ORA #PF_B2B_POSSIBLE
  STA <p_flags

.end_clear_stuff:

  LDA <$0F
  STA <p_hdrop_dist

  LDA #PS_LOCKED
  STA <p_state
  RTS

; Expect: Y is start of line to draw, X is draw10 to use, $01 is image offset
decode_line_draw:
  LDA [playfield_addr], Y
  STA <$00
  AND #$0F
  CLC
  ADC <$01
  STA draw_10_0+2, X
  LDA <$00
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC <$01
  STA draw_10_0+3, X
  INY

  LDA [playfield_addr], Y
  STA <$00
  AND #$0F
  CLC
  ADC <$01
  STA draw_10_0+4, X
  LDA <$00
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC <$01
  STA draw_10_0+5, X
  INY

  LDA [playfield_addr], Y
  STA <$00
  AND #$0F
  CLC
  ADC <$01
  STA draw_10_0+6, X
  LDA <$00
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC <$01
  STA draw_10_0+7, X
  INY

  LDA [playfield_addr], Y
  STA <$00
  AND #$0F
  CLC
  ADC <$01
  STA draw_10_0+8, X
  LDA <$00
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC <$01
  STA draw_10_0+9, X
  INY

  LDA [playfield_addr], Y
  STA <$00
  AND #$0F
  CLC
  ADC <$01
  STA draw_10_0+10, X
  LDA <$00
  LSR A
  LSR A
  LSR A
  LSR A
  CLC
  ADC <$01
  STA draw_10_0+11, X
  INY

  RTS

; Expect: returns from update subroutine
topped_out:
  ; TODO
  LDA #PS_END_ANIMATION
  STA <p_state
  RTS

locked:
  LDA <p_clear0
  CMP #$FF
  BNE .clear_lines
  LDA <p_clear1
  CMP #$FF
  BNE .clear_lines
  LDA <p_clear2
  CMP #$FF
  BNE .clear_lines
  LDA <p_clear3
  CMP #$FF
  BNE .clear_lines

  LDA #PS_ADD_GARBAGE
  STA <p_state
  LDA #0
  STA <p_garbage_amt

  RTS

.clear_lines:

  LDA #0
  STA <$00        ; src index
  STA <$01        ; dst index

.copy_loop:
  LDX <p_clear0
  LDA mul_5, X
  CMP <$00
  BEQ .skip_row

  LDX <p_clear1
  LDA mul_5, X
  CMP <$00
  BEQ .skip_row
  
  LDX <p_clear2
  LDA mul_5, X
  CMP <$00
  BEQ .skip_row
  
  LDX <p_clear3
  LDA mul_5, X
  CMP <$00
  BEQ .skip_row

  LDY <$00
  LDA [playfield_addr], Y
  LDY <$01
  STA [playfield_addr], Y
  INC <$01
  INC <$00

  LDY <$00
  LDA [playfield_addr], Y
  LDY <$01
  STA [playfield_addr], Y
  INC <$01
  INC <$00

  LDY <$00
  LDA [playfield_addr], Y
  LDY <$01
  STA [playfield_addr], Y
  INC <$01
  INC <$00

  LDY <$00
  LDA [playfield_addr], Y
  LDY <$01
  STA [playfield_addr], Y
  INC <$01
  INC <$00

  LDY <$00
  LDA [playfield_addr], Y
  LDY <$01
  STA [playfield_addr], Y
  INC <$01
  INC <$00

  JMP .copy_cond

.skip_row:
  LDA <$00
  CLC
  ADC #5
  STA <$00

.copy_cond:
  LDA <$00
  CMP #200
  BNE .copy_loop

  LDA #0
  LDY <$01
.empty_loop:
  STA [playfield_addr], Y
  INY
  STA [playfield_addr], Y
  INY
  STA [playfield_addr], Y
  INY
  STA [playfield_addr], Y
  INY
  STA [playfield_addr], Y
  INY
  CPY #200
  BNE .empty_loop

  LDA #PS_REDRAW_SCREEN
  STA <p_state

  RTS