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

  JSR decode_piece
  JSR below_obstructed
  BEQ .no_lock_delay
  LDA #LOCK_DELAY
  STA <p_fall_timer
.no_lock_delay:

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

clear_anim:
  RTS

redraw_0:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low
  ADC <ppu_offset
  STA draw_10_0+1, X
  LDA line_ppu_low+1
  ADC <ppu_offset
  STA draw_10_1+1, X
  LDA line_ppu_low+2
  ADC <ppu_offset
  STA draw_10_2+1, X
  LDA line_ppu_low+3
  ADC <ppu_offset
  STA draw_10_3+1, X

  LDA line_ppu_high
  STA draw_10_0, X
  LDA line_ppu_high+1
  STA draw_10_1, X
  LDA line_ppu_high+2
  STA draw_10_2, X
  LDA line_ppu_high+3
  STA draw_10_3, X

  LDY #0
  LDX <draw_10_offset
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #5
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #10
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #15
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDA #PS_REDRAW_SCREEN + 1
  STA <p_state
  RTS

redraw_1:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low+4
  ADC <ppu_offset
  STA draw_10_0+1, X
  LDA line_ppu_low+5
  ADC <ppu_offset
  STA draw_10_1+1, X
  LDA line_ppu_low+6
  ADC <ppu_offset
  STA draw_10_2+1, X
  LDA line_ppu_low+7
  ADC <ppu_offset
  STA draw_10_3+1, X

  LDA line_ppu_high+4
  STA draw_10_0, X
  LDA line_ppu_high+5
  STA draw_10_1, X
  LDA line_ppu_high+6
  STA draw_10_2, X
  LDA line_ppu_high+7
  STA draw_10_3, X

  LDY #20
  LDX <draw_10_offset
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #25
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #30
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #35
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDA #PS_REDRAW_SCREEN + 2
  STA <p_state
  RTS

redraw_2:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low+8
  ADC <ppu_offset
  STA draw_10_0+1, X
  LDA line_ppu_low+9
  ADC <ppu_offset
  STA draw_10_1+1, X
  LDA line_ppu_low+10
  ADC <ppu_offset
  STA draw_10_2+1, X
  LDA line_ppu_low+11
  ADC <ppu_offset
  STA draw_10_3+1, X

  LDA line_ppu_high+8
  STA draw_10_0, X
  LDA line_ppu_high+9
  STA draw_10_1, X
  LDA line_ppu_high+10
  STA draw_10_2, X
  LDA line_ppu_high+11
  STA draw_10_3, X

  LDY #40
  LDX <draw_10_offset
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #45
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #50
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #55
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDA #PS_REDRAW_SCREEN + 3
  STA <p_state
  RTS

redraw_3:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low+12
  ADC <ppu_offset
  STA draw_10_0+1, X
  LDA line_ppu_low+13
  ADC <ppu_offset
  STA draw_10_1+1, X
  LDA line_ppu_low+14
  ADC <ppu_offset
  STA draw_10_2+1, X
  LDA line_ppu_low+15
  ADC <ppu_offset
  STA draw_10_3+1, X

  LDA line_ppu_high+12
  STA draw_10_0, X
  LDA line_ppu_high+13
  STA draw_10_1, X
  LDA line_ppu_high+14
  STA draw_10_2, X
  LDA line_ppu_high+15
  STA draw_10_3, X

  LDY #60
  LDX <draw_10_offset
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #65
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #70
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #75
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDA #PS_REDRAW_SCREEN + 4
  STA <p_state
  RTS

redraw_4:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low+16
  ADC <ppu_offset
  STA draw_10_0+1, X
  LDA line_ppu_low+17
  ADC <ppu_offset
  STA draw_10_1+1, X
  LDA line_ppu_low+18
  ADC <ppu_offset
  STA draw_10_2+1, X
  LDA line_ppu_low+19
  ADC <ppu_offset
  STA draw_10_3+1, X

  LDA line_ppu_high+16
  STA draw_10_0, X
  LDA line_ppu_high+17
  STA draw_10_1, X
  LDA line_ppu_high+18
  STA draw_10_2, X
  LDA line_ppu_high+19
  STA draw_10_3, X

  LDY #80
  LDX <draw_10_offset
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #85
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #90
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDY #95
  TXA
  CLC
  ADC #12
  TAX
  LDA #$40
  STA <$01
  JSR decode_line_draw

  LDA #PS_REDRAW_SCREEN + 5
  STA <p_state
  RTS

redraw_5:
  LDX <draw_10_offset
  CLC

  LDA line_ppu_low+20
  ADC <ppu_offset
  STA draw_10_0+1, X

  LDA line_ppu_high+20
  STA draw_10_0, X

  LDY #100
  LDX <draw_10_offset
  LDA #$50
  STA <$01
  JSR decode_line_draw

  LDA #PS_ADD_GARBAGE
  STA <p_state
  RTS

end_anim:
  RTS

game_over:
  RTS