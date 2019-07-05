  .inesprg 1
  .ineschr 1
  .inesmap 0
  .inesmir 2

;;;;;;;;;;;;;;;;;;;;;
; interrupt vectors ;
;;;;;;;;;;;;;;;;;;;;;

  .bank 1
  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

;;;;;;;;;;;;;;;;;
; graphics file ;
;;;;;;;;;;;;;;;;;

  .bank 2
  .org $0000
  .incbin "../tetris.chr"

;;;;;;;;;;;;;;;;;;;;;;;
; convienience macros ;
;;;;;;;;;;;;;;;;;;;;;;;

ppumem .macro
  LDA #HIGH(\1)
  STA PPUADDR
  LDA #LOW(\1)
  STA PPUADDR
  .endm

; really only for menu navigation
pressed .macro
  LDA player1 + p_gamepad_old
  AND #\1
  EOR #\1
  AND player1 + p_gamepad_new
  .endm

;;;;;;;;;;;;;
; game code ;
;;;;;;;;;;;;;

  .include "vars.s"

  .bank 0
  .org $C000

RESET:
  SEI            ; disable IRQs
  CLD            ; disable decimal mode
  LDX #$40
  STX $4017      ; disable APU frame IRQ
  LDX #$FF
  TXS            ; setup stack
  LDX #$00
  STX PPUCTRL    ; disable NMI
  STX PPUMASK    ; disable rendering
  STX $4010      ; disable DMC IRQs
  BIT PPUSTATUS
.vblankwait1:
  BIT PPUSTATUS
  BPL .vblankwait1
  LDX #$00
.clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  INX
  BNE .clrmem
.vblankwait2:
  BIT PPUSTATUS
  BPL .vblankwait2

  ; init palettes
  ppumem BG_COLOR
  LDA #$0F
  STA PPUDATA
  ; BG palette 0
  LDA #$20    ; white
  STA PPUDATA
  LDA #$10    ; light gray
  STA PPUDATA
  LDA #$00    ; dark gray
  STA PPUDATA
  STA PPUDATA ; skip
  ; BG palette 1
  LDA #$27    ; orange
  STA PPUDATA
  LDA #$2A    ; green
  STA PPUDATA
  LDA #$12    ; blue
  STA PPUDATA
  STA PPUDATA ; skip
  ; BG palette 2
  LDA #$20    ; white
  STA PPUDATA
  LDA #$10    ; light gray
  STA PPUDATA
  LDA #$00    ; dark gray
  STA PPUDATA
  STA PPUDATA ; skip
  ; BG palette 3
  LDA #$20    ; white
  STA PPUDATA

  ; set first tetris palette
  LDY #0
  JSR tetris_palette

  ; enable NMI (begin game next frame)
  LDA #$80
  STA PPUCTRL
.forever:
  JMP .forever

NMI:
  ; begin frame: force blanking, disable NMI, clear vblank flag, prep controller state
  LDA PPUSTATUS
  LDA #$00
  STA PPUCTRL
  STA PPUMASK
  LDA #1
  STA JOY_STROBE
  LDA #0
  STA JOY_STROBE

  LDA game_state
  ASL A
  TAX
  LDA state_jt, X
  STA <$00
  LDA state_jt+1, X
  STA <$01
  JMP [$0000]

frame_end:
  ; end game logic: enable NMI
  LDA #$80
  STA PPUCTRL

  RTI

state_jt:
  .dw to_title_state
  .dw title_state
  .dw to_menu_state
  .dw menu_state
  .dw to_40L_1_state
  .dw to_150L_1_state
  .dw to_ultra_1_state
  .dw to_battle_state
  .dw to_40L_2_state
  .dw to_150L_2_state
  .dw to_ultra_2_state
  .dw to_about_state
  .dw about_state

tetris_palette:
  LDY #$00
  ppumem BG_PALETTE3+1
  LDA tris_palettes, Y
  STA PPUDATA
  INY
  LDA tris_palettes, Y
  STA PPUDATA
  RTS

; Expect: ($00, $01) is pointer to 960 bytes (tile) + 64 bytes (attribute) data
; Expect: PPUADDR is set
blit:
  LDX #$00    ; 256 iterations, each putting 4 bytes = 1024 bytes transfered
.loop:
  LDY #$00
  LDA [$00], Y
  STA PPUDATA
  INY
  LDA [$00], Y
  STA PPUDATA
  INY
  LDA [$00], Y
  STA PPUDATA
  INY
  LDA [$00], Y
  STA PPUDATA
  LDA <$00
  CLC
  ADC #4
  STA <$00
  LDA <$01
  ADC #0
  STA <$01
  INX
  BNE .loop

  ; reset camera location
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL
  RTS

read_input:
  ; remember previous state
  LDA player1 + p_gamepad_new
  STA player1 + p_gamepad_old
  LDA player2 + p_gamepad_new
  STA player2 + p_gamepad_old

  ; read new state (player 1)
  LDA #0
  STA player1 + p_gamepad_new
  LDX #8
.loop1:
  ASL player1 + p_gamepad_new
  LDA JOY1
  AND #1
  ORA player1 + p_gamepad_new
  STA player1 + p_gamepad_new
  DEX
  BNE .loop1

  ; read new state (player 2)
  LDA #0
  STA player2 + p_gamepad_new
  LDX #8
.loop2:
  ASL player2 + p_gamepad_new
  LDA JOY2
  AND #1
  ORA player2 + p_gamepad_new
  STA player2 + p_gamepad_new
  DEX
  BNE .loop2
  RTS

; other files
  .include "menu.s"
  .include "game_modes.s"

;;;;;;;;;;;;;;;
; data tables ;
;;;;;;;;;;;;;;;

mul_5:
  .db 0,   5,   10,  15,  20,  25,  30,  35,  40,  45
  .db 50,  55,  60,  65,  70,  75,  80,  85,  90,  95
  .db 100, 105, 110, 115, 120, 125, 130, 135, 140, 145

tris_palettes:
  .db $11, $21