.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #$0F ; black
  STA PPUDATA
  LDA #$19
  STA PPUDATA
  LDA #$09
  STA PPUDATA
  LDA #$0f
  STA PPUDATA

  ; first sprite
  LDA #$00
  STA $0200 ; Y-coord of first sprite
  LDA #$02
  STA $0201 ; tile number of first sprite
  LDA #$00
  STA $0202 ; attributes of first sprite
  LDA #$00
  STA $0203 ; X-coord of first sprite

  ; second sprite
  LDA #$00
  STA $0204 ; Y-coord of first sprite
  LDA #$03
  STA $0205 ; tile number of first sprite
  LDA #$00
  STA $0206 ; attributes of first sprite
  LDA #$08
  STA $0207 ; X-coord of first sprite

  ; second sprite
  LDA #$08
  STA $0208 ; Y-coord of first sprite
  LDA #$12
  STA $0209 ; tile number of first sprite
  LDA #$00
  STA $020A ; attributes of first sprite
  LDA #$00
  STA $020B ; X-coord of first sprite

  ; second sprite
  LDA #$08
  STA $020C ; Y-coord of first sprite
  LDA #$13
  STA $020D ; tile number of first sprite
  LDA #$00
  STA $020E ; attributes of first sprite
  LDA #$08
  STA $020F ; X-coord of first sprite


vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "sprites.chr"
