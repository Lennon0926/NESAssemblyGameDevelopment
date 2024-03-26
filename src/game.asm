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
.byte $50, $06, $00, $60
.byte $50, $07, $00, $68
.byte $58, $16, $00, $60
.byte $58, $17, $00, $68

.byte $50, $02, $00, $70
.byte $50, $03, $00, $78
.byte $58, $12, $00, $70
.byte $58, $13, $00, $78

.byte $50, $04, $00, $80
.byte $50, $05, $00, $88
.byte $58, $14, $00, $80
.byte $58, $15, $00, $88

; LEFT
; Y, TILE, ATTR, X
.byte $60, $06, %01000000, $68
.byte $60, $07, %01000000, $60
.byte $68, $16, %01000000, $68
.byte $68, $17, %01000000, $60

.byte $60, $02, %01000000, $78
.byte $60, $03, %01000000, $70
.byte $68, $12, %01000000, $78
.byte $68, $13, %01000000, $70

.byte $60, $04, %01000000, $88
.byte $60, $05, %01000000, $80
.byte $68, $14, %01000000, $88
.byte $68, $15, %01000000, $80

; UP
; Y, TILE, ATTR, X
.byte $40, $26, $00, $60
.byte $40, $27, $00, $68
.byte $48, $36, $00, $60
.byte $48, $37, $00, $68

.byte $40, $22, $00, $70
.byte $40, $23, $00, $78
.byte $48, $32, $00, $70
.byte $48, $33, $00, $78

.byte $40, $24, $00, $80
.byte $40, $25, $00, $88
.byte $48, $34, $00, $80
.byte $48, $35, $00, $88

; DOWN
; Y, TILE, ATTR, X
.byte $78, $26, %10000000, $60
.byte $78, $27, %10000000, $68
.byte $70, $36, %10000000, $60
.byte $70, $37, %10000000, $68

.byte $78, $22, %10000000, $70
.byte $78, $23, %10000000, $78
.byte $70, $32, %10000000, $70
.byte $70, $33, %10000000, $78

.byte $78, $24, %10000000, $80
.byte $78, $25, %10000000, $88
.byte $70, $34, %10000000, $80
.byte $70, $35, %10000000, $88

; BACKGROUND
; FIRST STAGE
; Y, TILE, ATTR, X
; .byte $80, $08, $00, $30
; .byte $80, $09, $00, $38
; .byte $88, $18, $00, $30
; .byte $88, $19, $00, $38

; .byte $80, $0A, $00, $40
; .byte $80, $0B, $00, $48
; .byte $88, $1A, $00, $40
; .byte $88, $1B, $00, $48

; .byte $80, $28, $00, $50
; .byte $80, $29, $00, $58
; .byte $88, $38, $00, $50
; .byte $88, $39, $00, $58

; .byte $00, $2A, $00, $00
; .byte $00, $2B, $00, $08
; .byte $08, $3A, $00, $00
; .byte $08, $3B, $00, $08


; SECOND STAGE
; Y, TILE, ATTR, X



.segment "CHR"
.incbin "sprites.chr"