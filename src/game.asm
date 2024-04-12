.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
pad1: .res 1
frame_counter: .res 1
animation_counter: .res 1

scroll: .res 1
ppuctrl_settings: .res 1

; Indexes
tileIndex: .res 1  ; Reserve 1 byte for the tile index
megaIndex: .res 1  ; Reserve 1 byte for the mega index

.exportzp player_x, player_y, pad1, frame_counter, animation_counter

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "STARTUP"

.segment "RODATA"
palettes:
.byte $0F, $12, $23, $34 ; Neon
.byte $0F, $0B, $1A, $29 ; Grass
.byte $0F, $00, $10, $2D ; Gray scale
.byte $0F, $09, $19, $3A

.byte $0F, $36, $2A, $14
.byte $0F, $00, $00, $00
.byte $0F, $00, $00, $00
.byte $0F, $00, $00, $00

.include "background.asm"

.segment "CHR"
.incbin "sprites.chr"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import ReadController

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00

  JSR ReadController
  ; update tiles *after* DMA transfer
	; and after reading controller state
	JSR update_player
  JSR drawSprites

; 	LDA scroll
; 	CMP #$00 ; did we scroll to the end of a nametable?
; 	BNE set_scroll_positions
; 	; if yes,
; 	; Update base nametable
; 	LDA ppuctrl_settings
; 	EOR #%00000010 ; flip bit 1 to its opposite
; 	STA ppuctrl_settings
; 	STA PPUCTRL
; 	LDA #240
; 	STA scroll

; set_scroll_positions:
;   DEC scroll
;   LDA scroll ; X scroll first
;   STA PPUSCROLL
;   LDA #$00 ; then Y scroll
;   STA PPUSCROLL
  RTI
.endproc

.import reset_handler

.export main
.proc main
	LDA #239	 ; Y is only 240 lines tall!
	STA scroll
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

load_nametable_1:
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$00
  STA PPUADDR
  ldx #$00
  
first_nametable_1:	
  lda background, x 	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00 
  bne first_nametable_1
  ldx $00
second_nametable_1:
  lda secondbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne second_nametable_1   
  ldx $00
third_nametable_1:
  lda thirdbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne third_nametable_1 
  ldx $00
fourth_nametable_1:
  lda fourthbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne fourth_nametable_1


load_nametable_2:
  LDA PPUSTATUS
  LDA #$24
  STA PPUADDR
  LDA #$00
  STA PPUADDR
  ldx #$00
  
first_nametable_2:	
  lda background, x 	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00 
  bne first_nametable_2
  ldx $00
second_nametable_2:
  lda secondbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne second_nametable_2   
  ldx $00
third_nametable_2:
  lda thirdbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne third_nametable_2 
  ldx $00
fourth_nametable_2:
  lda fourthbackground, x	; Load the hello message into SPR-RAM
  sta PPUDATA
  inx
  cpx #$00
  bne fourth_nametable_2



vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
	STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc


.proc update_player
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player_x  ; If the branch is not taken, move player left
  LDA #DIR_LEFT  ; Update player direction to left
  STA player_dir
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
  LDA #DIR_RIGHT  ; Update player direction to right
  STA player_dir
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
  LDA #DIR_UP  ; Update player direction to up
  STA player_dir
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y
  LDA #DIR_DOWN  ; Update player direction to down
  STA player_dir
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc drawSprites

  LDA player_dir   ; Load the value of player_dir into the accumulator
  CMP #DIR_RIGHT      ; Compare it with the constant value for 'right'
  BEQ jump_right    ; If equal, branch to drawRight
  CMP #DIR_LEFT        ; Compare it with the constant value for 'left'
  BEQ jump_left     ; If equal, branch to drawLeft
  CMP #DIR_UP         ; Compare it with the constant value for 'up'
  BEQ jump_up       ; If equal, branch to drawUp
  CMP #DIR_DOWN        ; Compare it with the constant value for 'down'
  BEQ jump_down     ; If equal, branch to drawDown

jump_right:
  JMP drawRight

jump_left:
  JMP drawLeft

jump_up:
  JMP drawUp

jump_down:
  JMP drawDown

drawRight:
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
  BNE trampoline_right
  LDA frame_counter
  AND #$06          ; Mask out lower 4 bits
  CMP #$02          ; Check which frame of animation to use
  BCC frame1Right   ; If less than 5, use the first frame
  CMP #$04          ; Check if it's the second or third frame
  BCC frame2Right   ; If less than 10, use the second frame
  JMP frame3Right   ; Otherwise, use the third frame

trampoline_right:
  JMP skipAnimation_right

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
  JMP setTile_right

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
  JMP setTile_right

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
  JMP setTile_right

setTile_right:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$20
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

  LDA pad1
  BEQ skipIncrement_right ; If no button is pressed, skip incrementing frame counter

  ; Increment frame counter
  INC frame_counter

skipIncrement_right:

  ; restore registers and return
skipAnimation_right:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS

drawLeft:
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
  BNE trampoline_left
  LDA frame_counter
  AND #$06         ; Mask out lower 4 bits
  CMP #$02         ; Check which frame of animation to use
  BCC frame1Left   ; If less than 5, use the first frame
  CMP #$04         ; Check if it's the second or third frame
  BCC frame2Left   ; If less than 10, use the second frame
  JMP frame3Left   ; Otherwise, use the third frame

trampoline_left:
  JMP skipAnimation_left

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
  JMP setTile_left

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
  JMP setTile_left

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
  JMP setTile_left

setTile_left:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$20
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

  LDA pad1
  BEQ skipIncrement_left ; If no button is pressed, skip incrementing frame counter

  ; Increment frame counter
  INC frame_counter

skipIncrement_left:

  ; restore registers and return
skipAnimation_left:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS

drawUp:
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
  BNE trampoline_up
  LDA frame_counter
  AND #$06          ; Mask out lower 4 bits
  CMP #$02          ; Check which frame of animation to use
  BCC frame1Up      ; If less than 5, use the first frame
  CMP #$04          ; Check if it's the second or third frame
  BCC frame2Up      ; If less than 10, use the second frame
  JMP frame3Up      ; Otherwise, use the third frame

trampoline_up:
  JMP skipAnimation_up

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
  JMP setTile_up

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
  JMP setTile_up

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
  JMP setTile_up

setTile_up:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$20
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

  LDA pad1
  BEQ skipIncrement_up ; If no button is pressed, skip incrementing frame counter

  ; Increment frame counter
  INC frame_counter

skipIncrement_up:

  ; restore registers and return
skipAnimation_up:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS

drawDown:
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
  BNE trampoline_down
  LDA frame_counter
  AND #$06         ; Mask out lower 4 bits
  CMP #$02         ; Check which frame of animation to use
  BCC frame1Down   ; If less than 5, use the first frame
  CMP #$04         ; Check if it's the second or third frame
  BCC frame2Down   ; If less than 10, use the second frame
  JMP frame3Down   ; Otherwise, use the third frame

trampoline_down:
  JMP skipAnimation_down

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
  JMP setTile_down

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
  JMP setTile_down

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
  JMP setTile_down

setTile_down:

  ; write player ship tile attributes
  ; use palette 0
  LDA #$20
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

  LDA pad1
  BEQ skipIncrement_down ; If no button is pressed, skip incrementing frame counter

  ; Increment frame counter
  INC frame_counter

skipIncrement_down:

  ; restore registers and return
skipAnimation_down:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

