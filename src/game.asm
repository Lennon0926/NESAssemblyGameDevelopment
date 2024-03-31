.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
frame_counter: .res 1
animation_counter: .res 1

player2_x: .res 1
player2_y: .res 1
frame_counter2: .res 1
animation_counter2: .res 1

player3_x: .res 1
player3_y: .res 1
frame_counter3: .res 1
animation_counter3: .res 1

player4_x: .res 1
player4_y: .res 1
frame_counter4: .res 1
animation_counter4: .res 1

.exportzp player_x, player_y, frame_counter, animation_counter
.exportzp player2_x, player2_y, frame_counter2, animation_counter2
.exportzp player3_x, player3_y, frame_counter3, animation_counter3
.exportzp player4_x, player4_y, frame_counter4, animation_counter4

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

  ; update tiles *after* DMA transfer
  JSR draw_player
  JSR draw_player2
  JSR draw_player3
  JSR draw_player4

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

; Right
.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter
  LDA animation_counter
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$46      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$47
  STA $0205
  LDA #$56
  STA $0209
  LDA #$57
  STA $020d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$44      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$45
  STA $0205
  LDA #$54
  STA $0209
  LDA #$55
  STA $020d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$42      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$43
  STA $0205
  LDA #$52
  STA $0209
  LDA #$53
  STA $020d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; Increment frame counter
  INC frame_counter

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Left
.proc draw_player2
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter2
  LDA animation_counter2
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter2
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$66      ; Use tile number for the third frame of animation
  STA $0211
  LDA #$67
  STA $0215
  LDA #$76
  STA $0219
  LDA #$77
  STA $021d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$64      ; Use tile number for the second frame of animation
  STA $0211
  LDA #$65
  STA $0215
  LDA #$74
  STA $0219
  LDA #$75
  STA $021d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$62      ; Use tile number for the first frame of animation
  STA $0211
  LDA #$63
  STA $0215
  LDA #$72
  STA $0219
  LDA #$73
  STA $021d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  ; store tile locations
  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213

  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f

  ; Increment frame counter
  INC frame_counter2

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Up
.proc draw_player3
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter3
  LDA animation_counter3
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter3
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$26      ; Use tile number for the third frame of animation
  STA $0221
  LDA #$27
  STA $0225
  LDA #$36
  STA $0229
  LDA #$37
  STA $022d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$24      ; Use tile number for the second frame of animation
  STA $0221
  LDA #$25
  STA $0225
  LDA #$34
  STA $0229
  LDA #$35
  STA $022d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$22      ; Use tile number for the first frame of animation
  STA $0221
  LDA #$23
  STA $0225
  LDA #$32
  STA $0229
  LDA #$33
  STA $022d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e

  ; store tile locations
  ; top left tile:
  LDA player3_y
  STA $0220
  LDA player3_x
  STA $0223

  ; top right tile (x + 8):
  LDA player3_y
  STA $0224
  LDA player3_x
  CLC
  ADC #$08
  STA $0227

  ; bottom left tile (y + 8):
  LDA player3_y
  CLC
  ADC #$08
  STA $0228
  LDA player3_x
  STA $022b

  ; bottom right tile (x + 8, y + 8)
  LDA player3_y
  CLC
  ADC #$08
  STA $022c
  LDA player3_x
  CLC
  ADC #$08
  STA $022f

  ; Increment frame counter
  INC frame_counter3

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Down
.proc draw_player4
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animation_counter4
  LDA animation_counter4
  AND #$04      ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter4
  AND #$0F      ; Mask out lower 4 bits
  CMP #$05      ; Check which frame of animation to use
  BCC frame_1   ; If less than 5, use the first frame
  CMP #$0A      ; Check if it's the second or third frame
  BCC frame_2   ; If less than 10, use the second frame
  JMP frame_3   ; Otherwise, use the third frame

trampoline:
  JMP skip_animation

frame_3:
  ; Third frame of animation
  LDA #$06      ; Use tile number for the third frame of animation
  STA $0231
  LDA #$07
  STA $0235
  LDA #$16
  STA $0239
  LDA #$17
  STA $023d
  JMP tile_set_done

frame_2:
  ; Second frame of animation
  LDA #$04      ; Use tile number for the second frame of animation
  STA $0231
  LDA #$05
  STA $0235
  LDA #$14
  STA $0239
  LDA #$15
  STA $023d
  JMP tile_set_done

frame_1:
  ; First frame of animation
  LDA #$02      ; Use tile number for the first frame of animation
  STA $0231
  LDA #$03
  STA $0235
  LDA #$12
  STA $0239
  LDA #$13
  STA $023d
  JMP tile_set_done

tile_set_done:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ; store tile locations
  ; top left tile:
  LDA player4_y
  STA $0230
  LDA player4_x
  STA $0233

  ; top right tile (x + 8):
  LDA player4_y
  STA $0234
  LDA player4_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA player4_y
  CLC
  ADC #$08
  STA $0238
  LDA player4_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA player4_y
  CLC
  ADC #$08
  STA $023c
  LDA player4_x
  CLC
  ADC #$08
  STA $023f

  ; Increment frame counter
  INC frame_counter4

  ; restore registers and return
skip_animation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
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

.segment "CHR"
.incbin "sprites.chr"