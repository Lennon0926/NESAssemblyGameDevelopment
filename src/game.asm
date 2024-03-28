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
  	LDA #$00
	  STA $2005
	  STA $2005
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
  CPX #$20       ; # Palettes x 4 bytes
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$F0       ; # Sprites x 4 bytes
  BNE load_sprites

  ; First Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$28
	STA PPUADDR
	LDX #$02
	STX PPUDATA

  ; Second Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$29
	STA PPUADDR
	LDX #$04
	STX PPUDATA

  ; Third Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2A
	STA PPUADDR
	LDX #$06
	STX PPUDATA

  ; Forth Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2B
	STA PPUADDR
	LDX #$08
	STX PPUDATA

  ; Fifth Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2C
	STA PPUADDR
	LDX #$22
	STX PPUDATA

  ; Sixth Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2D
	STA PPUADDR
	LDX #$24
	STX PPUDATA

  ; Seventh Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2E
	STA PPUADDR
	LDX #$26
	STX PPUDATA
  
  ; Eight Tile
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2F
	STA PPUADDR
	LDX #$28
	STX PPUDATA

  ; attribute table First Stage
	LDA PPUSTATUS
	LDA #$2B
	STA PPUADDR
	LDA #$E2
	STA PPUADDR
	LDA #%00001000
	STA PPUDATA

  ; attribute table Second Stage
	LDA PPUSTATUS
	LDA #$2B
	STA PPUADDR
	LDA #$E3
	STA PPUADDR
	LDA #%00000111
	STA PPUDATA


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
.byte $0F, $05, $16, $27 ; Bricks
.byte $0F, $0B, $1A, $29 ; Grass
.byte $0F, $00, $10, $2D ; Gray scale
.byte $0F, $09, $19, $3A

.byte $0F, $36, $2A, $14
.byte $0F, $00, $00, $00
.byte $0F, $00, $00, $00
.byte $0F, $00, $00, $00

sprites:
; SPRITES
; RIGHT 
; Y, TILE, ATTR, X
.byte $50, $42, $00, $60
.byte $50, $43, $00, $68
.byte $58, $52, $00, $60
.byte $58, $53, $00, $68

.byte $50, $44, $00, $70
.byte $50, $45, $00, $78
.byte $58, $54, $00, $70
.byte $58, $55, $00, $78

.byte $50, $46, $00, $80
.byte $50, $47, $00, $88
.byte $58, $56, $00, $80
.byte $58, $57, $00, $88

; LEFT
; Y, TILE, ATTR, X
.byte $60, $62, $00, $60
.byte $60, $63, $00, $68
.byte $68, $72, $00, $60
.byte $68, $73, $00, $68

.byte $60, $64, $00, $70
.byte $60, $65, $00, $78
.byte $68, $74, $00, $70
.byte $68, $75, $00, $78

.byte $60, $66, $00, $80
.byte $60, $67, $00, $88
.byte $68, $76, $00, $80
.byte $68, $77, $00, $88

; UP
; Y, TILE, ATTR, X
.byte $40, $22, $00, $60
.byte $40, $23, $00, $68
.byte $48, $32, $00, $60
.byte $48, $33, $00, $68

.byte $40, $24, $00, $70
.byte $40, $25, $00, $78
.byte $48, $34, $00, $70
.byte $48, $35, $00, $78

.byte $40, $26, $00, $80
.byte $40, $27, $00, $88
.byte $48, $36, $00, $80
.byte $48, $37, $00, $88

; DOWN
; Y, TILE, ATTR, X
.byte $70, $02, $00, $60
.byte $70, $03, $00, $68
.byte $78, $12, $00, $60
.byte $78, $13, $00, $68

.byte $70, $04, $00, $70
.byte $70, $05, $00, $78
.byte $78, $14, $00, $70
.byte $78, $15, $00, $78

.byte $70, $06, $00, $80
.byte $70, $07, $00, $88
.byte $78, $16, $00, $80
.byte $78, $17, $00, $88

.segment "CHR"
.incbin "sprites.chr"