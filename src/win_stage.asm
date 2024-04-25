.importzp current_stage, current_nametable
.importzp player_x, player_y
.importzp pad1
.importzp player_win
.importzp background_flag

.include "constants.inc"

.import reset_handler

.export win_screen
.export next_stage

.proc win_screen
    LDA current_stage
    CMP #$02
    BEQ check_x

    JMP Done

check_x:
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

Done:
    RTS
.endproc

.proc next_stage
  LDA current_stage
  CMP #$01
  BEQ check_x

  JMP Done

check_x:
   LDA player_x
   CMP #$F0
   BEQ check_y

   JMP Done

check_y:
  LDA player_y
  CMP #$D0
  BEQ next_level

next_level:
  LDA #$01
  STA background_flag

  JMP Done

Done:
    RTS
.endproc

.proc draw_win
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  ; W
  LDA #$88
  STA $0231
  LDA #$89
  STA $0235
  LDA #$98
  STA $0239
  LDA #$99
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

  ; I
  LDA #$A8
  STA $0241
  LDA #$A9
  STA $0245
  LDA #$B8
  STA $0249
  LDA #$B9
  STA $024D

  LDA #$00
  STA $0242
  STA $0246
  STA $024A
  STA $024E

  LDA #$70
  STA $0240
  LDA #$6F
  STA $0243

  LDA #$70
  STA $0244
  LDA #$6F
  CLC
  ADC #$08
  STA $0247

  LDA #$70
  CLC
  ADC #$08
  STA $0248
  LDA #$6F
  STA $024B

  LDA #$70
  CLC
  ADC #$08
  STA $024C
  LDA #$6F
  CLC
  ADC #$08
  STA $024F

  ; N
  LDA #$C8
  STA $0251
  LDA #$C9
  STA $0255
  LDA #$D8
  STA $0259
  LDA #$D9
  STA $025D

  LDA #$00
  STA $0252
  STA $0256
  STA $025A
  STA $025E

  LDA #$70
  STA $0250
  LDA #$7F
  STA $0253

  LDA #$70
  STA $0254
  LDA #$7F
  CLC
  ADC #$08
  STA $0257

  LDA #$70
  CLC
  ADC #$08
  STA $0258
  LDA #$7F
  STA $025B

  LDA #$70
  CLC
  ADC #$08
  STA $025C
  LDA #$7F
  CLC
  ADC #$08
  STA $025F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc