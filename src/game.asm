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
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$04
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$A0       ; # Sprites x 4 bytes
  BNE load_sprites

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

.segment "RODATA"
palettes:
.byte $0F, $28, $30, $19

sprites:
; RIGHT
.byte $70, $06, $00, $80
.byte $70, $07, $00, $88
.byte $78, $16, $00, $80
.byte $78, $17, $00, $88

.byte $70, $02, $00, $90
.byte $70, $03, $00, $98
.byte $78, $12, $00, $90
.byte $78, $13, $00, $98

.byte $70, $04, $00, $A0
.byte $70, $05, $00, $A8
.byte $78, $14, $00, $A0
.byte $78, $15, $00, $A8

.segment "CHR"
.incbin "sprites.chr"