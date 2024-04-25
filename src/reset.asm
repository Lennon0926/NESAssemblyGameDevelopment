.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, frame_counter, animation_counter
.importzp current_stage, current_nametable, scroll, ppuctrl_settings, scroll_flag
.importzp time_frame_counter, time_counter, players_lives, player_win
.importzp background_flag

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
	LDA #$00
	STA player_x
	LDA #$D0
	STA player_y

  LDA #$3F
  STA time_frame_counter

  LDA #$00
  STA time_counter

  LDA #%00011110  ; turn on screen
  STA PPUMASK

  LDA #$01
  STA players_lives

  LDA #$00
  STA player_win

  LDA #$01
  STA current_stage

  LDA #$00
  STA current_nametable

  LDA #$00
  STA background_flag

  STA scroll
  STA scroll_flag
  STA PPUSCROLL
  STA PPUSCROLL 
  
vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2
  JMP main
.endproc
