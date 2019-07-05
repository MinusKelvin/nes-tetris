to_sprint_1_state:
  ppumem NAMETABLE1
  LDA #LOW(player1_screen)
  STA <$00
  LDA #HIGH(player1_screen)
  STA <$01
  JSR blit

  ppumem NAMETABLE2
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
  
  ppumem NAMETABLE2
  LDA #LOW(player2_screen)
  STA <$00
  LDA #HIGH(player2_screen)
  STA <$01
  JSR blit

  LDA #S_ABOUT
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
  LDA #S_TO_ABOUT
  STA game_state
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