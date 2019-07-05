;;;;;;;;;;;;;;;;
; title screen ;
;;;;;;;;;;;;;;;;

title_text_shown = $0580
title_text_timer = $0581
TITLE_TEXT_DELAY = 33

to_title_state:
  ; Draw title screen
  ppumem NAMETABLE1
  LDA #LOW(title_screen)
  STA <$00
  LDA #HIGH(title_screen)
  STA <$01
  JSR blit

  LDA #$01
  STA game_state

  LDA #$00
  STA title_text_shown

  LDA #120
  STA title_text_timer

  JMP frame_end

title_state:
  DEC title_text_timer
  BNE .done

  LDA #TITLE_TEXT_DELAY
  STA title_text_timer
  LDA title_text_shown
  BEQ .show

  LDA #0
  STA title_text_shown

  ; clear text
  ppumem NAMETABLE1+$30A
  LDY #12
  LDA #$40
.ct_loop:
  STA PPUDATA
  DEY
  BNE .ct_loop
  JMP .done

.show:
  LDA #1
  STA title_text_shown

  ; draw text
  ppumem NAMETABLE1+$30A
  LDX #$00
  LDY #12
.dt_loop:
  LDA title_text, X
  STA PPUDATA
  INX
  DEY
  BNE .dt_loop

.done:
  ; reset camera location & enable rendering
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  LDA #$08
  STA PPUMASK

  ; logic time
  JSR read_input

  LDA player1 + p_gamepad_old
  AND #(JOY_START | JOY_A)
  EOR #(JOY_START | JOY_A)
  AND player1 + p_gamepad_new
  BEQ .end
  LDA #S_TO_MENU
  STA game_state
.end:
  JMP frame_end

;;;;;;;;;;;;;;;;;;;;
; main menu screen ;
;;;;;;;;;;;;;;;;;;;;

cursor_pos = $0580

to_menu_state:
  ppumem NAMETABLE1
  LDA #LOW(main_menu_screen)
  STA <$00
  LDA #HIGH(main_menu_screen)
  STA <$01
  JSR blit

  LDA #S_MENU
  STA game_state
  LDA #0
  STA cursor_pos
  
  JMP frame_end

menu_state:
  ; reset camera location & enable rendering
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  LDA #$08
  STA PPUMASK
  JMP frame_end

;;;;;;;;;;;;;;;;
; about screen ;
;;;;;;;;;;;;;;;;

to_about_state:
  JMP frame_end

about_state:
  JMP frame_end

;;;;;;;;
; data ;
;;;;;;;;

title_text:
  .db $19, $1B, $0E, $1C, $1C, $40, $40, $1C, $1D, $0A, $1B, $1D

title_screen:
  .incbin "title.bin"

main_menu_screen:
  .incbin "main_menu.bin"