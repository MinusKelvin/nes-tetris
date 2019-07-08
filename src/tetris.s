  .inesprg 2
  .ineschr 1
  .inesmap 0
  .inesmir 2

;;;;;;;;;;;;;;;;;;;;;
; interrupt vectors ;
;;;;;;;;;;;;;;;;;;;;;

  .bank 3
  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

;;;;;;;;;;;;;;;;;
; graphics file ;
;;;;;;;;;;;;;;;;;

  .bank 4
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
  .org $8000

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
  STA $0000, X
  STA $0100, X
  STA $0300, X
  STA $0400, X
  STA $0500, X
  STA $0600, X
  STA $0700, X
  LDA #$FF
  STA $0200, X    ; hide all sprites
  INX
  BNE .clrmem
  LDA #1
  STA <rng_addr
.vblankwait2:
  BIT PPUSTATUS
  BPL .vblankwait2

  ; init palettes
  ppumem BG_COLOR
  LDX #$00
.paloop:
  LDA palettes, X
  STA PPUDATA
  INX
  CPX #$20
  BNE .paloop

  ; blit pause screen
  ; TODO

  ; enable NMI (begin game next frame)
  LDA #$80
  STA PPUCTRL
.forever:
  JMP .forever

NMI:
  ; begin frame: force blanking, disable NMI, clear vblank flag,
  ;              prep controller state, and do OAM DMA
  LDA PPUSTATUS
  LDA #$00
  STA PPUCTRL
  STA PPUMASK
  LDA #1
  STA JOY_STROBE
  LDA #0
  STA JOY_STROBE
  STA OAMADDR
  LDA #HIGH(oam_page)
  STA OAMDMA

  LDA <game_state
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

  JSR rng    ; source entropy from player behaviour by running RNG every frame

  RTI

state_jt:
  .dw to_title_state
  .dw title_state
  .dw to_menu_state
  .dw menu_state
  .dw to_sprint_1_state
  .dw to_marathon_1_state
  .dw to_ultra_1_state
  .dw to_battle_state
  .dw to_sprint_2_state
  .dw to_marathon_2_state
  .dw to_ultra_2_state
  .dw to_about_state
  .dw about_state
  .dw sprint_1_state
  .dw marathon_1_state
  .dw ultra_1_state
  .dw battle_state
  .dw sprint_2_state
  .dw marathon_2_state
  .dw ultra_2_state

; https://wiki.nesdev.com/w/index.php/Random_number_generator#Linear_feedback_shift_register
rng:
  LDX #8
  LDA rng_addr
.loop:
  ASL A
  ROL <rng_addr+1
  BCC .skipxor
  EOR #$2D
.skipxor:
  DEX
  BNE .loop
  STA <rng_addr
  CMP #0    ; Z and N now reflect the state of A
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

; https://wiki.nesdev.com/w/index.php/16-bit_BCD
bcd_convert_24:
  ; vars
.bcdNum = $00
.curDigit = $04
.bcdResult = $08
.b0 = $05
.b1 = $06
.BCD_BITS = 29
  LDA #$80 >> ((.BCD_BITS - 1) & 3)
  STA <.curDigit
  LDX #(.BCD_BITS - 1) >> 2
  LDY #.BCD_BITS - 5

.loop:
  ; Trial subtract this bit to A:b
  SEC
  LDA <.bcdNum
  SBC bcd_table_low, Y
  STA <.b0
  LDA <.bcdNum+1
  SBC bcd_table_mid, Y
  STA <.b1
  LDA <.bcdNum+2
  SBC bcd_table_high, Y

  ; If A:b > bcdNum then bcdNum = A:b
  BCC .trial_lower
  STA <.bcdNum+2
  LDA <.b1
  STA <.bcdNum+1
  LDA <.b0
  STA <.bcdNum
.trial_lower:

  ; Copy bit from carry into digit and pick up 
  ; end-of-digit sentinel into carry
  ROL <.curDigit
  DEY
  BCC .loop

  ; Copy digit into result
  LDA <.curDigit
  STA <.bcdResult, X
  LDA #$10  ; Empty digit; sentinel at 4 bits
  STA <.curDigit
  ; If there are digits left, do those
  DEX
  BNE .loop
  LDA <.bcdNum
  STA <.bcdResult
  
  RTS


; other files
  .include "menu.s"
  .include "game_modes.s"
  .include "draw.s"
  .include "gameplay.s"

; data tables
  .include "data.s"