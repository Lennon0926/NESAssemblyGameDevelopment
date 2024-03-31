.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, frame_counter, animation_counter
.importzp player2_x, player2_y, frame_counter2, animation_counter2
.importzp player3_x, player3_y, frame_counter3, animation_counter3
.importzp player4_x, player4_y, frame_counter4, animation_counter4

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX PPUCTRL
  STX PPUMASK
  STX $4010
  BIT PPUSTATUS
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

  ; initialize zero-page values
	LDA #130
	STA player_x
	LDA #60
	STA player_y

  LDA #80
	STA player2_x
	LDA #60
	STA player2_y

  LDA #105
	STA player3_x
	LDA #30
	STA player3_y

  LDA #105
	STA player4_x
	LDA #90
	STA player4_y
  
vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2
  JMP main
.endproc
