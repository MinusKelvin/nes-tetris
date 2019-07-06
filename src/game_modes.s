to_sprint_1_state:
  ppumem NAMETABLE1
  LDA #LOW(player1_screen)
  STA <$00
  LDA #HIGH(player1_screen)
  STA <$01
  JSR blit

  LDA #S_ABOUT
  STA game_state

  JMP frame_end

to_marathon_1_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

to_ultra_1_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

to_battle_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

to_sprint_2_state:
  ppumem NAMETABLE1
  LDA #LOW(player2_screen)
  STA <$00
  LDA #HIGH(player2_screen)
  STA <$01
  JSR blit

  LDA #S_SPRINT_2
  STA game_state

  JMP frame_end

to_marathon_2_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

to_ultra_2_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

sprint_1_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

marathon_1_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

ultra_1_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

battle_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

sprint_2_state:
  JSR draw
  ; reset camera location & enable rendering
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  LDA #PPU_ENABLE
  STA PPUMASK

  JSR read_input

  pressed JOY_B
  BEQ .no_b
  LDA #S_TO_MENU
  STA game_state

.no_b:
  LDX #00
  LDA player1 + p_gamepad_new
  AND #JOY_A
  BEQ .draw2

.draw1:
  LDA testdraw, X
  STA draw_10_0, X
  INX
  TXA
  CMP #draw_len
  BNE .draw1
  JMP frame_end

.draw2:
  LDA testdraw2, X
  STA draw_10_0, X
  INX
  TXA
  CMP #draw_len
  BNE .draw2
  JMP frame_end

marathon_2_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

ultra_2_state:
  LDA #S_TO_ABOUT
  STA game_state
  JMP frame_end

;;;;;;;;
; data ;
;;;;;;;;

player1_screen:
  .incbin "1player.bin"

player2_screen:
  .incbin "2player.bin"

testdraw:
  .db $23, $02, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $E2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $C2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $A2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $23, $11, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $F1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $D1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $22, $B1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41

  .db $20, $CC, $80, $81, $82, $83
  .db $20, $EC, $84, $85, $86, $87
  .db $21, $0C, $88, $89, $8A, $8B
  .db $21, $2C, $8C, $8D, $8E, $8F
  .db $20, $DB, $90, $91, $92, $93
  .db $20, $FB, $94, $95, $96, $97
  .db $21, $1B, $98, $99, $9A, $9B
  .db $21, $3B, $9C, $9D, $9E, $9F

  .db $23, $2B, $75, $49, $4A, $4B, $4C
  .db $23, $3A, $4D, $4E, $4A, $4B, $4C

  .db $00, $A1
  .db $71, $71, $71, $71, $71, $71, $71, $71, $71, $71
  .db $71, $71, $71, $71, $71, $71, $71, $71, $7A, $7A
  .db $00, $B0
  .db $71, $71, $71, $71, $71, $71, $71, $71, $71, $71
  .db $71, $71, $71, $7A, $7A, $7A, $7A, $7A, $7A, $7A

testdraw2:
  .db $00, $02, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $E2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $C2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $A2, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $11, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $F1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $D1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
  .db $00, $B1, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41

  .db $20, $CC, $80, $81, $82, $83
  .db $20, $EC, $84, $85, $86, $87
  .db $21, $0C, $88, $89, $8A, $8B
  .db $21, $2C, $8C, $8D, $8E, $8F
  .db $20, $DB, $90, $91, $92, $93
  .db $20, $FB, $94, $95, $96, $97
  .db $21, $1B, $98, $99, $9A, $9B
  .db $21, $3B, $9C, $9D, $9E, $9F

  .db $23, $2B, $75, $49, $4A, $4B, $4C
  .db $23, $3A, $4D, $4E, $4A, $4B, $4C

  .db $20, $A1
  .db $71, $71, $71, $71, $71, $71, $71, $71, $71, $71
  .db $71, $71, $71, $71, $71, $71, $71, $71, $7A, $7A
  .db $20, $B0
  .db $71, $71, $71, $71, $71, $71, $71, $71, $71, $71
  .db $71, $71, $71, $7A, $7A, $7A, $7A, $7A, $7A, $7A