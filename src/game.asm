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
  CPX #$10       ; # Palettes x 4 bytes
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$F0       ; # Sprites x 4 bytes
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
.byte $0F, $20, $15, $28

sprites:
; SPRITES
; RIGHT 
; Y, TILE, ATTR, X
.byte $50, $07, $01, $68
.byte $50, $06, $01, $60
.byte $58, $16, $01, $60
.byte $58, $17, $01, $68

.byte $50, $02, $01, $70
.byte $50, $03, $01, $78
.byte $58, $12, $01, $70
.byte $58, $13, $01, $78

.byte $50, $04, $01, $80
.byte $50, $05, $01, $88
.byte $58, $14, $01, $80
.byte $58, $15, $01, $88

; LEFT
; Y, TILE, ATTR, X
.byte $60, $06, $41, $68
.byte $60, $07, $41, $60
.byte $68, $16, $41, $68
.byte $68, $17, $41, $60

.byte $60, $02, $41, $78
.byte $60, $03, $41, $70
.byte $68, $12, $41, $78
.byte $68, $13, $41, $70

.byte $60, $04, $41, $88
.byte $60, $05, $41, $80
.byte $68, $14, $41, $88
.byte $68, $15, $41, $80

; UP
; Y, TILE, ATTR, X
.byte $40, $26, $01, $60
.byte $40, $27, $01, $68
.byte $48, $36, $01, $60
.byte $48, $37, $01, $68

.byte $40, $22, $01, $70
.byte $40, $23, $01, $78
.byte $48, $32, $01, $70
.byte $48, $33, $01, $78

.byte $40, $24, $01, $80
.byte $40, $25, $01, $88
.byte $48, $34, $01, $80
.byte $48, $35, $01, $88

; DOWN
; Y, TILE, ATTR, X
.byte $78, $26, $81, $60
.byte $78, $27, $81, $68
.byte $70, $36, $81, $60
.byte $70, $37, $81, $68

.byte $78, $22, $81, $70
.byte $78, $23, $81, $78
.byte $70, $32, $81, $70
.byte $70, $33, $81, $78

.byte $78, $24, $81, $80
.byte $78, $25, $81, $88
.byte $70, $34, $81, $80
.byte $70, $35, $81, $88

.segment "CHR"
.incbin "sprites.chr"