.importzp current_stage
.importzp player_x, player_y
.importzp pad1
.importzp player_win

.include "constants.inc"

.import reset_handler

.export win_screen


.proc win_screen
    LDA current_stage
    CMP #$02
    BEQ draw_win_screen

    JMP Check_nametable_1

draw_win_screen:
    LDA player_x
    CMP #$F0
    BEQ check_y

    JMP Done

check_y:
    LDA player_y
    CMP #$D0
    BEQ show_win_screen

    JMP Done

show_win_screen:
  LDA pad1
  CMP #%00010000 
  BEQ restar_game

  LDA #%00010110 ; turn on screen
  STA PPUMASK

  LDA #$01
  STA player_win

  JSR draw_win

  JMP Done

restar_game:
  JSR reset_handler

Check_nametable_1:
    LDA current_stage
    CMP #$01
    BEQ draw_win_screen

    RTS
.endproc

.proc draw_win
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  ; L
  LDA #$08
  STA $0231
  LDA #$09
  STA $0235
  LDA #$18
  STA $0239
  LDA #$19
  STA $023D

  LDA #$00
  STA $0232
  STA $0236
  STA $023A
  STA $023E

  LDA #$70
  STA $0230
  LDA #$60
  STA $0233

  LDA #$70
  STA $0234
  LDA #$60
  CLC
  ADC #$08
  STA $0237

  LDA #$70
  CLC
  ADC #$08
  STA $0238
  LDA #$60
  STA $023B

  LDA #$70
  CLC
  ADC #$08
  STA $023C
  LDA #$60
  CLC
  ADC #$08
  STA $023F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc