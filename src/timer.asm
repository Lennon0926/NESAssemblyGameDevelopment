.export draw_timer
.export lose_screen
.export draw_win_timer

.include "constants.inc"

.import reset_handler

.importzp player_x, player_y
.importzp time_frame_counter, time_counter
.importzp pad1
.importzp players_lives
.importzp win_timer

.proc draw_win_timer
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA
  
  LDA win_timer
  CMP #$1E
  BEQ jmp_draw_30
  CMP #$1D
  BEQ jmp_draw_29
  CMP #$1C
  BEQ jmp_draw_28
  CMP #$1B
  BEQ jmp_draw_27
  CMP #$1A
  BEQ jmp_draw_26
  CMP #$19
  BEQ jmp_draw_25
  CMP #$18
  BEQ jmp_draw_24
  CMP #$17
  BEQ jmp_draw_23
  CMP #$16
  BEQ jmp_draw_22
  CMP #$15
  BEQ jmp_draw_21
  CMP #$14
  BEQ jmp_draw_20
  CMP #$13
  BEQ jmp_draw_19
  CMP #$12
  BEQ jmp_draw_18
  CMP #$11
  BEQ jmp_draw_17
  CMP #$10
  BEQ jmp_draw_16
  CMP #$0F
  BEQ jmp_draw_15
  CMP #$0E
  BEQ jmp_draw_14
  CMP #$0D
  BEQ jmp_draw_13
  CMP #$0C
  BEQ jmp_draw_12
  CMP #$0B
  BEQ jmp_draw_11
  CMP #$0A
  BEQ jmp_draw_10
  CMP #$09
  BEQ jmp_draw_9
  CMP #$08
  BEQ jmp_draw_8
  CMP #$07
  BEQ jmp_draw_7
  CMP #$06
  BEQ jmp_draw_6
  CMP #$05
  BEQ jmp_draw_5
  CMP #$04
  BEQ jmp_draw_4
  CMP #$03
  BEQ jmp_draw_3
  CMP #$02
  BEQ jmp_draw_2
  CMP #$01
  BEQ jmp_draw_1

jmp_draw_30:
  JMP draw_30
jmp_draw_29:
  JMP draw_29
jmp_draw_28:
  JMP draw_28
jmp_draw_27:
  JMP draw_27
jmp_draw_26:
  JMP draw_26
jmp_draw_25:
  JMP draw_25
jmp_draw_24:
  JMP draw_24
jmp_draw_23:
  JMP draw_23
jmp_draw_22:
  JMP draw_22
jmp_draw_21:
  JMP draw_21
jmp_draw_20:
  JMP draw_20
jmp_draw_19:
  JMP draw_19
jmp_draw_18:
  JMP draw_18
jmp_draw_17:
  JMP draw_17
jmp_draw_16:
  JMP draw_16
jmp_draw_15:
  JMP draw_15
jmp_draw_14:
  JMP draw_14
jmp_draw_13:
  JMP draw_13
jmp_draw_12:
  JMP draw_12
jmp_draw_11:
  JMP draw_11
jmp_draw_10:
  JMP draw_10
jmp_draw_9:
  JMP draw_9
jmp_draw_8:
  JMP draw_8
jmp_draw_7:
  JMP draw_7
jmp_draw_6:
  JMP draw_6
jmp_draw_5:
  JMP draw_5
jmp_draw_4:
  JMP draw_4
jmp_draw_3:
  JMP draw_3
jmp_draw_2:
  JMP draw_2
jmp_draw_1:
  JMP draw_1

draw_30:
  JSR draw_3_left
  JSR draw_0_right
  JMP Done
draw_29:
  JSR draw_2_left
  JSR draw_9_right
  JMP Done
draw_28:
  JSR draw_2_left
  JSR draw_8_right
  JMP Done
draw_27:
  JSR draw_2_left
  JSR draw_7_right
  JMP Done
draw_26:
  JSR draw_2_left
  JSR draw_6_right
  JMP Done
draw_25:
  JSR draw_2_left
  JSR draw_5_right
  JMP Done
draw_24:
  JSR draw_2_left
  JSR draw_4_right
  JMP Done
draw_23:
  JSR draw_2_left
  JSR draw_3_right
  JMP Done
draw_22:
  JSR draw_2_left
  JSR draw_2_right
  JMP Done
draw_21:
  JSR draw_2_left
  JSR draw_1_right
  JMP Done
draw_20:
  JSR draw_2_left
  JSR draw_0_right
  JMP Done
draw_19:
  JSR draw_1_left
  JSR draw_9_right
  JMP Done
draw_18:
  JSR draw_1_left
  JSR draw_8_right
  JMP Done
draw_17:
  JSR draw_1_left
  JSR draw_7_right
  JMP Done
draw_16:
  JSR draw_1_left
  JSR draw_6_right
  JMP Done
draw_15:
  JSR draw_1_left
  JSR draw_5_right
  JMP Done
draw_14:
  JSR draw_1_left
  JSR draw_4_right
  JMP Done
draw_13:
  JSR draw_1_left
  JSR draw_3_right
  JMP Done
draw_12:
  JSR draw_1_left
  JSR draw_2_right
  JMP Done
draw_11:
  JSR draw_1_left
  JSR draw_1_right
  JMP Done
draw_10:
  JSR draw_1_left
  JSR draw_0_right
  JMP Done
draw_9:
  JSR draw_0_left
  JSR draw_9_right
  JMP Done
draw_8:
  JSR draw_0_left
  JSR draw_8_right
  JMP Done
draw_7:
  JSR draw_0_left
  JSR draw_7_right
  JMP Done
draw_6:
  JSR draw_0_left
  JSR draw_6_right
  JMP Done
draw_5:
  JSR draw_0_left
  JSR draw_5_right
  JMP Done
draw_4:
  JSR draw_0_left
  JSR draw_4_right
  JMP Done
draw_3:
  JSR draw_0_left
  JSR draw_3_right
  JMP Done
draw_2:
  JSR draw_0_left
  JSR draw_2_right
  JMP Done
draw_1:
  JSR draw_0_left
  JSR draw_1_right
  JMP Done

Done:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_lose
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

  ; O
  LDA #$28
  STA $0241
  LDA #$29
  STA $0245
  LDA #$38
  STA $0249
  LDA #$39
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

  ; S
  LDA #$48
  STA $0251
  LDA #$49
  STA $0255
  LDA #$58
  STA $0259
  LDA #$59
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

  ; E
  LDA #$68
  STA $0261
  LDA #$69
  STA $0265
  LDA #$78
  STA $0269
  LDA #$79
  STA $026D

  LDA #$00
  STA $0262
  STA $0266
  STA $026A
  STA $026E

  LDA #$70
  STA $0260
  LDA #$8D
  STA $0263

  LDA #$70
  STA $0264
  LDA #$8D
  CLC
  ADC #$08
  STA $0267

  LDA #$70
  CLC
  ADC #$08
  STA $0268
  LDA #$8D
  STA $026B

  LDA #$70
  CLC
  ADC #$08
  STA $026C
  LDA #$8D
  CLC
  ADC #$08
  STA $026F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc lose_screen
  LDA players_lives
  CMP #$00
  BEQ show_lose_screen

  JMP Done

show_lose_screen:
  LDA pad1
  CMP #%00010000 
  BEQ restar_game

  LDA #%00010110 ; turn on screen
  STA PPUMASK

  JSR draw_lose

  JMP Done

restar_game:
  JSR reset_handler

Done:
  RTS
.endproc

.proc draw_timer
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA players_lives
  CMP #$00
  BNE draw

  JMP Done

draw:
  LDA time_counter
  CMP #$0A
  BEQ tram_30
  CMP #$0B
  BEQ tram_29
  CMP #$0C
  BEQ tram_28
  CMP #$0D
  BEQ tram_27
  CMP #$0E
  BEQ tram_26
  CMP #$0F
  BEQ tram_25
  CMP #$10
  BEQ tram_24
  CMP #$11
  BEQ tram_23
  CMP #$12
  BEQ tram_22
  CMP #$13
  BEQ tram_21
  CMP #$14
  BEQ tram_20
  CMP #$15
  BEQ tram_19
  CMP #$16
  BEQ tram_18
  CMP #$17
  BEQ tram_17
  CMP #$18
  BEQ tram_16
  CMP #$19
  BEQ tram_15
  CMP #$1A
  BEQ tram_14
  CMP #$1B
  BEQ tram_13
  CMP #$1C
  BEQ tram_12
  CMP #$1D
  BEQ tram_11
  CMP #$1E
  BEQ tram_10
  CMP #$1F
  BEQ tram_9
  CMP #$20
  BEQ tram_8
  CMP #$21
  BEQ tram_7
  CMP #$22
  BEQ tram_6
  CMP #$23
  BEQ tram_5
  CMP #$24
  BEQ tram_4
  CMP #$25
  BEQ tram_3
  CMP #$26
  BEQ tram_2
  CMP #$27
  BEQ tram_1
  CMP #$28
  BEQ tram_0

tram_30:
  JMP Number_30
tram_29:
  JMP Number_29
tram_28:
  JMP Number_28
tram_27:
  JMP Number_27
tram_26:
  JMP Number_26
tram_25:
  JMP Number_25
tram_24:
  JMP Number_24
tram_23:
  JMP Number_23
tram_22:
  JMP Number_22
tram_21:
  JMP Number_21
tram_20:
  JMP Number_20
tram_19:
  JMP Number_19
tram_18:
  JMP Number_18
tram_17:
  JMP Number_17
tram_16:
  JMP Number_16
tram_15:
  JMP Number_15
tram_14:  
  JMP Number_14 
tram_13:  
  JMP Number_13
tram_12:
  JMP Number_12
tram_11:
  JMP Number_11
tram_10:  
  JMP Number_10
tram_9: 
  JMP Number_9
tram_8:
  JMP Number_8
tram_7:
  JMP Number_7
tram_6: 
  JMP Number_6  
tram_5:
  JMP Number_5
tram_4: 
  JMP Number_4
tram_3:
  JMP Number_3
tram_2:
  JMP Number_2
tram_1:
  JMP Number_1
tram_0:
  JMP Number_0  

Number_30:
  JSR draw_3_left
  JSR draw_0_right
  LDA #$3F
  STA time_frame_counter
  LDA #00
  STA win_timer
  JMP Done

Number_29:
  JSR draw_2_left
  JSR draw_9_right
  LDA #01
  STA win_timer
 
  JMP Done

Number_28:
  JSR draw_2_left
  JSR draw_8_right
  LDA #02
  STA win_timer
 
  JMP Done

Number_27:
  JSR draw_2_left
  JSR draw_7_right
  LDA #03
  STA win_timer

  JMP Done

Number_26:
  JSR draw_2_left
  JSR draw_6_right
  LDA #04
  STA win_timer

  JMP Done

Number_25:
  JSR draw_2_left
  JSR draw_5_right
  LDA #05
  STA win_timer
 
  JMP Done

Number_24:
  JSR draw_2_left
  JSR draw_4_right
  LDA #06
  STA win_timer
 
  JMP Done

Number_23:
  JSR draw_2_left
  JSR draw_3_right
  LDA #07
  STA win_timer
 
  JMP Done

Number_22:
  JSR draw_2_left
  JSR draw_2_right
  LDA #08
  STA win_timer
 
  JMP Done

Number_21:
  JSR draw_2_left
  JSR draw_1_right
  LDA #09
  STA win_timer
 
  JMP Done

Number_20:
  JSR draw_2_left
  JSR draw_0_right
  LDA #10
  STA win_timer
 
  JMP Done

Number_19:
  JSR draw_1_left
  JSR draw_9_right
  LDA #11
  STA win_timer
 
  JMP Done

Number_18:
  JSR draw_1_left
  JSR draw_8_right
  LDA #12
  STA win_timer
 
  JMP Done

Number_17:
  JSR draw_1_left
  JSR draw_7_right
  LDA #13
  STA win_timer
 
  JMP Done

Number_16:
  JSR draw_1_left
  JSR draw_6_right
  LDA #14
  STA win_timer
 
  JMP Done

Number_15:
  JSR draw_1_left
  JSR draw_5_right
  LDA #15
  STA win_timer
 
  JMP Done

Number_14:
  JSR draw_1_left
  JSR draw_4_right
  LDA #16
  STA win_timer
 
  JMP Done

Number_13:
  JSR draw_1_left
  JSR draw_3_right
  LDA #17
  STA win_timer
 
  JMP Done

Number_12:
  JSR draw_1_left
  JSR draw_2_right
  LDA #18
  STA win_timer
 
  JMP Done

Number_11:
  JSR draw_1_left
  JSR draw_1_right
  LDA #19
  STA win_timer
 
  JMP Done

Number_10:
  JSR draw_1_left
  JSR draw_0_right
  LDA #20
  STA win_timer
 
  JMP Done

Number_9:
  JSR draw_0_left
  JSR draw_9_right
  LDA #21
  STA win_timer
 
  JMP Done

Number_8:
  JSR draw_0_left
  JSR draw_8_right
  LDA #22
  STA win_timer
 
  JMP Done

Number_7:
  JSR draw_0_left
  JSR draw_7_right
  LDA #23
  STA win_timer
 
  JMP Done

Number_6:
  JSR draw_0_left
  JSR draw_6_right
  LDA #24
  STA win_timer
 
  JMP Done

Number_5:
  JSR draw_0_left
  JSR draw_5_right
  LDA #25
  STA win_timer
 
  JMP Done

Number_4:
  JSR draw_0_left
  JSR draw_4_right
  LDA #26
  STA win_timer
 
  JMP Done

Number_3:
  JSR draw_0_left
  JSR draw_3_right
  LDA #27
  STA win_timer
 
  JMP Done

Number_2:
  JSR draw_0_left
  JSR draw_2_right
  LDA #28
  STA win_timer
 
  JMP Done

Number_1:
  JSR draw_0_left
  JSR draw_1_right
  LDA #29
  STA win_timer
 
  JMP Done

Number_0:
  JSR draw_0_left
  JSR draw_0_right
  LDA #30
  STA win_timer
  LDA #$00
  STA players_lives
  JSR lose_screen
  JMP Done


Done:
  INC time_frame_counter
  LDA time_frame_counter
  AND #$3F
  BNE skipIncrement
  INC time_counter

skipIncrement:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_0_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$0A
  STA $0211
  LDA #$0B
  STA $0215
  LDA #$1A
  STA $0219
  LDA #$1B
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  ; Restore registers
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_0_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$0A
  STA $0221
  LDA #$0B
  STA $0225
  LDA #$1A
  STA $0229
  LDA #$1B
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_1_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$2A
  STA $0211
  LDA #$2B
  STA $0215
  LDA #$3A
  STA $0219
  LDA #$3B
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_1_right

  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$2A
  STA $0221
  LDA #$2B
  STA $0225
  LDA #$3A
  STA $0229
  LDA #$3B
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_2_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$4A
  STA $0211
  LDA #$4B
  STA $0215
  LDA #$5A
  STA $0219
  LDA #$5B
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_2_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$4A
  STA $0221
  LDA #$4B
  STA $0225
  LDA #$5A
  STA $0229
  LDA #$5B
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_3_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$6A
  STA $0211
  LDA #$6B
  STA $0215
  LDA #$7A
  STA $0219
  LDA #$7B
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_3_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$6A
  STA $0221
  LDA #$6B
  STA $0225
  LDA #$7A
  STA $0229
  LDA #$7B
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_4_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$8A
  STA $0211
  LDA #$8B
  STA $0215
  LDA #$9A
  STA $0219
  LDA #$9B
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_4_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$8A
  STA $0221
  LDA #$8B
  STA $0225
  LDA #$9A
  STA $0229
  LDA #$9B
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc draw_5_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$AA
  STA $0211
  LDA #$AB
  STA $0215
  LDA #$BA
  STA $0219
  LDA #$BB
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_5_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$AA
  STA $0221
  LDA #$AB
  STA $0225
  LDA #$BA
  STA $0229
  LDA #$BB
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_6_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$CA
  STA $0211
  LDA #$CB
  STA $0215
  LDA #$DA
  STA $0219
  LDA #$DB
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_6_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$CA
  STA $0221
  LDA #$CB
  STA $0225
  LDA #$DA
  STA $0229
  LDA #$DB
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_7_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$E
  STA $0211
  LDA #$EB
  STA $0215
  LDA #$FA
  STA $0219
  LDA #$FB
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_7_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$EA
  STA $0221
  LDA #$EB
  STA $0225
  LDA #$FA
  STA $0229
  LDA #$FB
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_8_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$0C
  STA $0211
  LDA #$0D
  STA $0215
  LDA #$1C
  STA $0219
  LDA #$1D
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_8_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$0C
  STA $0221
  LDA #$0D
  STA $0225
  LDA #$1C
  STA $0229
  LDA #$1D
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_9_left
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$2C
  STA $0211
  LDA #$2D
  STA $0215
  LDA #$3C
  STA $0219
  LDA #$3D
  STA $021D

  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  LDA #$00
  STA $0210
  LDA #$64
  STA $0213

  LDA #$00
  STA $0214
  LDA #$64
  CLC
  ADC #$08
  STA $0217

  LDA #$00
  CLC
  ADC #$08
  STA $0218
  LDA #$64
  STA $021b

  LDA #$00
  CLC
  ADC #$08
  STA $021c
  LDA #$64
  CLC
  ADC #$08
  STA $021f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_9_right
  PHP  ; Save registers
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$2C
  STA $0221
  LDA #$2D
  STA $0225
  LDA #$3C
  STA $0229
  LDA #$3D
  STA $022D

  LDA #$00
  STA $0222
  STA $0226
  STA $022A
  STA $022E

  LDA #$00
  STA $0220
  LDA #$80
  STA $0223

  LDA #$00
  STA $0224
  LDA #$80
  CLC
  ADC #$08
  STA $0227

  LDA #$00
  CLC
  ADC #$08
  STA $0228
  LDA #$80
  STA $022B

  LDA #$00
  CLC
  ADC #$08
  STA $022C
  LDA #$80
  CLC
  ADC #$08
  STA $022F

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc