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
  CPX #$FF       ; # Sprites x 4 bytes
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

; LEFT
.byte $80, $06, %01000000, $88
.byte $80, $07, %01000000, $80
.byte $88, $16, %01000000, $88
.byte $88, $17, %01000000, $80

.byte $80, $02, %01000000, $98
.byte $80, $03, %01000000, $90
.byte $88, $12, %01000000, $98
.byte $88, $13, %01000000, $90

.byte $80, $04, %01000000, $A8
.byte $80, $05, %01000000, $A0
.byte $88, $14, %01000000, $A8
.byte $88, $15, %01000000, $A0

; UP
.byte $60, $26, $00, $80
.byte $60, $27, $00, $88
.byte $68, $36, $00, $80
.byte $68, $37, $00, $88

.byte $60, $22, $00, $90
.byte $60, $23, $00, $98
.byte $68, $32, $00, $90
.byte $68, $33, $00, $98

.byte $60, $24, $00, $A0
.byte $60, $25, $00, $A8
.byte $68, $34, $00, $A0
.byte $68, $35, $00, $A8

; DOWN
.byte $98, $26, %10000000, $80
.byte $98, $27, %10000000, $88
.byte $90, $36, %10000000, $80
.byte $90, $37, %10000000, $88

.byte $98, $22, %10000000, $90
.byte $98, $23, %10000000, $98
.byte $90, $32, %10000000, $90
.byte $90, $33, %10000000, $98

.byte $98, $24, %10000000, $A0
.byte $98, $25, %10000000, $A8
.byte $90, $34, %10000000, $A0
.byte $90, $35, %10000000, $A8



.segment "CHR"
.incbin "sprites.chr"