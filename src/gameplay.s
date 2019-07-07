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

; Expect: player info has been copied to zeropage $C8-$FF
; Expect: $C0-$C1 is address of playfield
; Expect: $C2 is rightwards PPU offset of graphical origin
; Expect: $C3 is offset from draw_10_0 for first draw10 buffer
; Expect: $C4 is offset from draw_4_0 for first draw4 buffer
; Expect: $C5 is offset from draw_5_0 for first draw5 buffer
p_update:
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
  STA <p_fall_timer
  STA <p_delay_resets
  STA <p_sdrop_tspin

  LDA <p_next_array1, X
  STA p_piece_t

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
  RTS
  
locked:
  RTS
  
clear_anim:
  RTS
  
redraw:
  RTS