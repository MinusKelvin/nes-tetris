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

redraw:
  RTS