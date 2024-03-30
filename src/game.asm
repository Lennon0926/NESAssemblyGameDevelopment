.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
frame_counter: .res 1
animation_counter: .res 1
controller_input: .res 1

.exportzp controller_input
.exportzp player_x, player_y, frame_counter, animation_counter

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

  ; Update controller input
  JSR ReadController

  ; Check if "A" key is pressed
  LDA $4016
  AND #%10000001
  BEQ ReadADone

  ; Move sprite based on "A" key press
  JSR drawRight
  LDA player_x
  CLC
  ADC #1
  STA player_x

ReadADone:
  LDA $4016
  AND #%10000001
  BEQ ReadBDone

  ; Move sprite based on "B" key press
  JSR drawLeft

  LDA player_x
  SEC
  SBC #1
  STA player_x

ReadBDone:
  ; Check if "A" key is pressed
  LDA $4016
  AND #%10000011
  BEQ ReadUpDone

  ; Move sprite based on "Up" key press
  JSR drawDown
  LDA player_y
  CLC
  ADC #1
  STA player_y

ReadUpDone:
  LDA $4016
  AND #%10000011
  BEQ ReadDownDone

  ; Move sprite based on "Down" key press
  JSR drawUp

  LDA player_y
  SEC
  SBC #1
  STA player_y

ReadDownDone:
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

.proc drawRight
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
  AND #$03          ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F          ; Mask out lower 4 bits
  CMP #$05          ; Check which frame of animation to use
  BCC frame1Right   ; If less than 5, use the first frame
  CMP #$0A          ; Check if it's the second or third frame
  BCC frame2Right   ; If less than 10, use the second frame
  JMP frame3Right   ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Right:
  ; Third frame of animation
  LDA #$46      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$47
  STA $0205
  LDA #$56
  STA $0209
  LDA #$57
  STA $020d
  JMP setTile

frame2Right:
  ; Second frame of animation
  LDA #$44      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$45
  STA $0205
  LDA #$54
  STA $0209
  LDA #$55
  STA $020d
  JMP setTile

frame1Right:
  ; First frame of animation
  LDA #$42      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$43
  STA $0205
  LDA #$52
  STA $0209
  LDA #$53
  STA $020d
  JMP setTile

setTile:

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
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawLeft
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
  AND #$03         ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F         ; Mask out lower 4 bits
  CMP #$05         ; Check which frame of animation to use
  BCC frame1Left   ; If less than 5, use the first frame
  CMP #$0A         ; Check if it's the second or third frame
  BCC frame2Left   ; If less than 10, use the second frame
  JMP frame3Left   ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Left:
  ; Third frame of animation
  LDA #$66      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$67
  STA $0205
  LDA #$76
  STA $0209
  LDA #$77
  STA $020d
  JMP setTile

frame2Left:
  ; Second frame of animation
  LDA #$64      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$65
  STA $0205
  LDA #$74
  STA $0209
  LDA #$75
  STA $020d
  JMP setTile

frame1Left:
  ; First frame of animation
  LDA #$62      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$63
  STA $0205
  LDA #$72
  STA $0209
  LDA #$73
  STA $020d
  JMP setTile

setTile:

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
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawUp
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
  AND #$03          ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F          ; Mask out lower 4 bits
  CMP #$05          ; Check which frame of animation to use
  BCC frame1Up      ; If less than 5, use the first frame
  CMP #$0A          ; Check if it's the second or third frame
  BCC frame2Up      ; If less than 10, use the second frame
  JMP frame3Up      ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Up:
  ; Third frame of animation
  LDA #$26      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$27
  STA $0205
  LDA #$36
  STA $0209
  LDA #$37
  STA $020d
  JMP setTile

frame2Up:
  ; Second frame of animation
  LDA #$24      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$25
  STA $0205
  LDA #$34
  STA $0209
  LDA #$35
  STA $020d
  JMP setTile

frame1Up:
  ; First frame of animation
  LDA #$22      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$23
  STA $0205
  LDA #$32
  STA $0209
  LDA #$33
  STA $020d
  JMP setTile

setTile:

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
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawDown
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
  AND #$03         ; Update animation every 4 cycles
  BNE trampoline
  LDA frame_counter
  AND #$0F         ; Mask out lower 4 bits
  CMP #$05         ; Check which frame of animation to use
  BCC frame1Down   ; If less than 5, use the first frame
  CMP #$0A         ; Check if it's the second or third frame
  BCC frame2Down   ; If less than 10, use the second frame
  JMP frame3Down   ; Otherwise, use the third frame

trampoline:
  JMP skipAnimation

frame3Down:
  ; Third frame of animation
  LDA #$06      ; Use tile number for the third frame of animation
  STA $0201
  LDA #$07
  STA $0205
  LDA #$16
  STA $0209
  LDA #$17
  STA $020d
  JMP setTile

frame2Down:
  ; Second frame of animation
  LDA #$04      ; Use tile number for the second frame of animation
  STA $0201
  LDA #$05
  STA $0205
  LDA #$14
  STA $0209
  LDA #$15
  STA $020d
  JMP setTile

frame1Down:
  ; First frame of animation
  LDA #$02      ; Use tile number for the first frame of animation
  STA $0201
  LDA #$03
  STA $0205
  LDA #$12
  STA $0209
  LDA #$13
  STA $020d
  JMP setTile

setTile:

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
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc ReadController
  ; Initialize the output memory
  LDA #1
  STA $4016
  LDA #0
  STA $4016

  ; Read the buttons from the data line
  LDA $4016
  AND #%10000001
  STA controller_input

  ; Check if the "Up" button is pressed
  LDA controller_input
  AND #%00010000
  BEQ checkDown

checkDown:
  ; Check if the "Down" button is pressed
  LDA controller_input
  AND #%00100000
  BEQ done

done:
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