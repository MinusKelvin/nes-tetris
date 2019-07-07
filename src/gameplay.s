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

; Expect: player info has been copied to zeropage $D0->$FF
; Expect: $C0-$C1 is address of playfield
; Expect: $C2-$C3 is LE PPU address of graphical origin
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
  .dw p_spawn_delay
  .dw p_falling
  .dw p_clear_delay

p_spawn_delay:
  LDA #PS_FALLING
  STA player1 + p_state
  RTS

p_falling:
  
  RTS

p_clear_delay:
  RTS