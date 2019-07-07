
draw:
  CLC
  LDX #00
.draw10:
  LDA draw_10_0, X
  BEQ .skip10
  STA PPUADDR
  LDA draw_10_0+1, X
  STA PPUADDR

  LDA draw_10_0+2, X
  STA PPUDATA
  LDA draw_10_0+3, X
  STA PPUDATA
  LDA draw_10_0+4, X
  STA PPUDATA
  LDA draw_10_0+5, X
  STA PPUDATA
  LDA draw_10_0+6, X
  STA PPUDATA
  LDA draw_10_0+7, X
  STA PPUDATA
  LDA draw_10_0+8, X
  STA PPUDATA
  LDA draw_10_0+9, X
  STA PPUDATA
  LDA draw_10_0+10, X
  STA PPUDATA
  LDA draw_10_0+11, X
  STA PPUDATA

.skip10:
  TXA
  ADC #12
  TAX
  CMP #12*10
  BNE .draw10

  CLC
  LDX #00
.draw4:
  LDA draw_4_0, X
  BEQ .skip4
  STA PPUADDR
  LDA draw_4_0+1, X
  STA PPUADDR

  LDA draw_4_0+2, X
  STA PPUDATA
  LDA draw_4_0+3, X
  STA PPUDATA
  LDA draw_4_0+4, X
  STA PPUDATA
  LDA draw_4_0+5, X
  STA PPUDATA

.skip4:
  TXA
  ADC #6
  TAX
  CMP #6*6
  BNE .draw4

  LDA draw_5_0
  BEQ .skip51
  STA PPUADDR
  LDA draw_5_0+1
  STA PPUADDR

  LDA draw_5_0+2
  STA PPUDATA
  LDA draw_5_0+3
  STA PPUDATA
  LDA draw_5_0+4
  STA PPUDATA
  LDA draw_5_0+5
  STA PPUDATA
  LDA draw_5_0+6
  STA PPUDATA

.skip51:
  LDA draw_5_1
  BEQ .skip52
  STA PPUADDR
  LDA draw_5_1+1
  STA PPUADDR

  LDA draw_5_1+2
  STA PPUDATA
  LDA draw_5_1+3
  STA PPUDATA
  LDA draw_5_1+4
  STA PPUDATA
  LDA draw_5_1+5
  STA PPUDATA
  LDA draw_5_1+6
  STA PPUDATA

.skip52

  LDA #%00000100
  STA PPUCTRL
  LDX #00
.drawv20:
  CLC
  LDA draw_20_0, X
  BEQ .skipv20
  STA PPUADDR
  LDA draw_20_0+1, X
  STA PPUADDR

  LDY #00
.drawv20_l:
  LDA draw_20_0+2, X
  STA PPUDATA
  LDA draw_20_0+3, X
  STA PPUDATA
  LDA draw_20_0+4, X
  STA PPUDATA
  LDA draw_20_0+5, X
  STA PPUDATA
  LDA draw_20_0+6, X
  STA PPUDATA
  LDA draw_20_0+7, X
  STA PPUDATA
  LDA draw_20_0+8, X
  STA PPUDATA
  LDA draw_20_0+9, X
  STA PPUDATA
  LDA draw_20_0+10, X
  STA PPUDATA
  LDA draw_20_0+11, X
  STA PPUDATA

  TXA
  ADC #10
  TAX
  TYA
  BNE .contv20
  LDY #1
  JMP .drawv20_l

.skipv20:
  TXA
  ADC #20
  TAX
.contv20:
  TXA
  ADC #2
  TAX
  CMP #22*2
  BNE .drawv20

  RTS