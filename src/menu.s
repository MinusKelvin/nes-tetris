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

  LDA #PPU_ENABLE
  STA PPUMASK

  ; logic time
  JSR read_input

  pressed JOY_START | JOY_A
  BEQ .end
  LDA #S_TO_MENU
  STA game_state
.end:
  JMP frame_end

;;;;;;;;;;;;;;;;;;;;
; main menu screen ;
;;;;;;;;;;;;;;;;;;;;

to_menu_state:
  ppumem NAMETABLE1
  LDA #LOW(main_menu_screen)
  STA <$00
  LDA #HIGH(main_menu_screen)
  STA <$01
  JSR blit

  LDA #S_MENU
  STA game_state
  
  JMP frame_end

menu_state:
  ; set VRAM address increment to 32
  LDA #%100
  STA PPUCTRL

  LDA #$20
  STA PPUADDR
  LDA #$E3
  STA PPUADDR

  LDA #$40
  LDX cursor_pos
.dcloop1:
  BEQ .drawcursor
  STA PPUDATA
  DEX
  JMP .dcloop1
.drawcursor:
  LDA #$2F
  STA PPUDATA
  LDA #$40
  STA PPUDATA
  STA PPUDATA
  STA PPUDATA
  STA PPUDATA
  STA PPUDATA
  STA PPUDATA
  STA PPUDATA
  
  ; reset camera location & enable rendering
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  LDA #PPU_ENABLE
  STA PPUMASK

  JSR read_input

  pressed JOY_B
  BEQ .noback
  LDA #S_TO_TITLE
  STA game_state
  JMP frame_end

.noback:
  pressed JOY_UP
  BEQ .noup
  LDA cursor_pos
  SEC
  SBC #1
  AND #$07
  STA cursor_pos

.noup:
  pressed JOY_DOWN
  BEQ .nodown
  LDA cursor_pos
  CLC
  ADC #1
  AND #$07
  STA cursor_pos

.nodown:
  pressed JOY_A | JOY_START
  BEQ .end
  LDA cursor_pos
  CLC
  ADC #S_TO_40L_1
  STA game_state

.end:
  JMP frame_end

;;;;;;;;;;;;;;;;
; about screen ;
;;;;;;;;;;;;;;;;

to_about_state:
  ppumem NAMETABLE1
  LDA #LOW(about_screen)
  STA <$00
  LDA #HIGH(about_screen)
  STA <$01
  JSR blit

  LDA #S_ABOUT
  STA game_state

  JMP frame_end

about_state:
  ; reset camera location & enable rendering
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

  LDA #PPU_ENABLE
  STA PPUMASK

  JSR read_input

  pressed JOY_B
  BEQ .end
  LDA #S_TO_MENU
  STA game_state

.end:
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

about_screen:
  .incbin "about.bin"