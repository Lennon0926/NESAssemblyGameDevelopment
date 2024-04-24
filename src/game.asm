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
scroll_flag: .res 1
ppuctrl_settings: .res 1

tile_bit: .res 1
tile_byte: .res 1

process_counter: .res 1
nametable_address_high: .res 1
nametable_address_low: .res 1
background_flag: .res 1

current_stage: .res 1
current_nametable: .res 1

.exportzp player_x, player_y, pad1, frame_counter, animation_counter
.exportzp scroll, scroll_flag

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

.include "backgrounds/stage_1.asm"
.include "backgrounds/stage_2.asm"

.segment "CHR"
.incbin "sprites_and_background.chr"

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

  ; reset accumulator
  LDA #$00

  ; read controller inputs
  JSR ReadController
  ; Updateb player position
	JSR update_player
  ; Draw player sprite
  JSR drawSprites
  ; Change stage if necessary
  JSR change_stage

  ; check if background needs to be drawn
  LDA background_flag
  CMP #$01
  BNE skip_background

  ; Initialize player position in stage 2
init_stage_2_pos:
	LDA #$00
	STA player_x
	LDA #$D0
	STA player_y

  ; Toggle current stage between 1, 2, 0
  LDA current_stage 
  EOR #%11
  STA current_stage

  ; Draw background
  JSR draw_background
  LDA #$00
  STA background_flag

  ; Reset scroll variables
reset_scroll:
  STA scroll
  STA scroll_flag
  STA PPUSCROLL
  STA PPUSCROLL 

skip_background:
  ; check if scrolling is activated
  LDA scroll_flag
  CMP #$01
  BEQ done
  ; Increment scroll position
  ; INC scroll
  LDA scroll
  BNE skip_reset

  ; Reset scroll position to 0 after reaching 255 to create a loop
  LDA #00
  STA scroll 
  
skip_reset:
  STA PPUSCROLL
  LDA #$00
  STA PPUSCROLL

done:

  RTI
.endproc

.import reset_handler

.export main
.proc main  
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  LDA #$01
  STA current_stage
  JSR draw_background

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

init_ppuscroll:
  LDA #$00
  STA PPUSCROLL
  STA PPUSCROLL

forever:
  JMP forever
.endproc

; -------------------------Subroutines-------------------------
.proc change_stage
  LDA pad1          ; Load the value of the controller input
  CMP #%1000000     ; Compare it with the mask for the A button
  BNE skip_change   ; If not equal, skip the stage change

  LDA #$01          ; Set the background flag to switch the background
  STA background_flag

skip_change:
  RTS               ; Return from subroutine
.endproc

.proc draw_background
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Disable rendering
disable:
  ; Disable rendering by setting PPUMASK to #%00000000
  LDA #%00000000
  STA PPUMASK
    
  ; Clear the sprite pattern table address in PPUCTRL
  LDA ppuctrl_settings
  AND #%01111000
  STA PPUCTRL
  STA ppuctrl_settings

  ; Check the current stage
  LDA current_stage
  CMP #$02
  BEQ stage_2

stage_1:
  ; Set current_nametable to #$00 for stage 1
  LDA #$00
  STA current_nametable
  ; Jump to the finished label
  JMP finished

stage_2:
  ; Set current_nametable to #$02 for stage 2
  LDA #$02
  STA current_nametable


finished:
  ; Initialize variables for rendering
  LDY #$00
  STY process_counter
  STY nametable_address_low

  ; Set nametable_address_high to #$20 for rendering
  LDA #$20
  STA nametable_address_high

  ; Call the display_nametables subroutine
  JSR display_nametables

  ; Increment current_nametable for the next iteration
  LDA current_nametable
  CLC
  ADC #$01
  STA current_nametable

  ; Reset variables for the next nametable
  LDY #$00
  STY process_counter
  STY nametable_address_low

  ; Set nametable_address_high to #$24 for rendering the second nametable
  LDA #$24
  STA nametable_address_high

 ; Call the display_nametables subroutine again for the second nametable
  JSR display_nametables

enable_rendering:
  ; Enable rendering by setting PPUCTRL to #%10010000
  LDA #%10010000
  STA PPUCTRL
  STA ppuctrl_settings
  ; Set PPUMASK to #%00011110 for showing background and sprites
  LDA #%00011110
  STA PPUMASK

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP 
  RTS
.endproc

.proc display_nametables
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

load_background:
  ; Load current nametable based on the current stage
  LDA current_nametable
  CMP #$00
  BNE nametable_2_stage_1

  ; Load tile data from stage 1, nametable 1
  LDA S1_nametable_1, Y
  JMP selected_nametable

nametable_2_stage_1:
  CMP #$01
  BNE nametable_1_stage_2

  ; Load tile data from stage 1, nametable 2
  LDA S1_nametable_2, Y
  JMP selected_nametable

nametable_1_stage_2:
  CMP #$02
  BNE nametable_2_stage_2

  ; Load tile data from stage 2, nametable 1
  LDA S2_nametable_1, Y
  JMP selected_nametable

nametable_2_stage_2:
  ; Load tile data from stage 2, nametable 2
  LDA S2_nametable_2, Y

selected_nametable:
  ; Store loaded tile byte in tile_byte
  STA tile_byte
  ; Process the loaded byte
  JSR process_tiles
  ; Increment Y to move to the next tile byte
  INY

add_process_counter:
  ; Increment process_counter
  LDA process_counter
  CLC
  ADC #$01
  STA process_counter
  ; Check if process_counter has reached 4 (end of a row)
  LDA process_counter
  CMP #$04
  BNE skip_low_byte_row_fix

  ; If end of row, adjust nametable address
  LDA nametable_address_low
  CLC
  ADC #$20
  STA nametable_address_low
  BCC skip_overflow

  LDA nametable_address_high
  CLC
  ADC #$01
  STA nametable_address_high

skip_overflow:
  ; Reset process_counter to start a new row
  LDA #$00
  STA process_counter

skip_low_byte_row_fix:
  ; Check if all rows have been processed
  CPY #$3C
  BNE load_background

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP 
  RTS
.endproc

.proc process_tiles
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Initialize X register to 0 for loop counter
  LDX #$00
process_loop:
  ; Reset tile_bit to 0
  LDA #$00
  STA tile_bit
  ; Shift left and rotate tile_byte into tile_bit
  ASL tile_byte
  ROL tile_bit
  ASL tile_byte
  ROL tile_bit

  ; Check if current stage is 1 to skip adding 4 to tile_bit
  LDA current_stage
  CMP #$01
  BEQ skip_add

  ; Add 4 to tile_bit
  LDA tile_bit
  CLC
  ADC #$04
  STA tile_bit

skip_add:
  ; Call draw_megatiles subroutine
  JSR draw_megatiles

  ; Increment nametable address low by 2
  LDA nametable_address_low
  CLC 
  ADC #$02 
  STA nametable_address_low

  ; Check for overflow in nametable address low, adjust high if needed
  BCC skip_overflow
  LDA nametable_address_high
  CLC
  ADC #$01
  STA nametable_address_high

skip_overflow:
  ; Increment X (loop counter)
  INX
  ; Check if X is less than 4 to continue loop
  CPX #$04
  BNE process_loop

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP   
  RTS
.endproc

.proc draw_megatiles
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Set PPU address to nametable_address_high
  LDA PPUSTATUS
  LDA nametable_address_high
  STA PPUADDR
  ; Set PPU address to nametable_address_low
  LDA nametable_address_low
  STA PPUADDR
  ; Store tile_bit into PPUDATA (pattern table)
  LDA tile_bit
  STA PPUDATA
  STA PPUDATA

  ; Draw bottom LEFT tile
  LDX #$00
  JSR helper_tiles

  ; Draw bottom RIGHT tile
  LDX #$01
  JSR helper_tiles

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc helper_tiles
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

 ; Check if X register is equal to 1 (right tile)
  TXA
  CMP #$01
  BEQ right

  ; Add 32 to nametable_address_low for left tile
  LDA nametable_address_low
  CLC
  ADC #$20
  JMP overflow

right:
  ; Add 33 to nametable_address_low for right tile
  LDA nametable_address_low
  CLC
  ADC #$21

overflow:
  ; Check for overflow
  BCC no_overflow

  ; If overflow, increment nametable_address_high
  LDA nametable_address_high
  CLC 
  ADC #$01
  STA PPUADDR
  TXA
  CMP #$01 
  BEQ low_byte_right

  ; Add 32 to nametable_address_low for left tile after overflow
  LDA nametable_address_low
  CLC 
  ADC #$20
  STA PPUADDR 
  JMP tile_ppu

low_byte_right:
  ; Add 33 to nametable_address_low for right tile after overflow
  LDA nametable_address_low
  CLC 
  ADC #$21
  STA PPUADDR
  JMP tile_ppu
  
no_overflow: 
  ; If no overflow, set nametable_address_high
  LDA nametable_address_high
  STA PPUADDR
  TXA
  CMP #$01
  BEQ low_byte_no_overflow

  ; Add 32 to nametable_address_low for left tile without overflow
  LDA nametable_address_low
  CLC
  ADC #$20 
  STA PPUADDR
  JMP tile_ppu

low_byte_no_overflow:
  ; Add 33 to nametable_address_low for right tile without overflow
  LDA nametable_address_low
  CLC
  ADC #$21
  STA PPUADDR

tile_ppu:
  ; Store tile_bit into PPUDATA
  LDA tile_bit
  STA PPUDATA

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_UP     ; Filter out all but Up
  BEQ check_down  ; If result is zero, up not pressed
  DEC player_y
  LDA #DIR_UP  ; Update player direction to up
  STA player_dir
  JMP check_left  ; Skip to next check
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ check_left
  INC player_y
  LDA #DIR_DOWN  ; Update player direction to down
  STA player_dir
  JMP check_left  ; Skip to next check
check_left:
  LDA pad1
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  LDA scroll
  CMP #00  ; Compare scroll with minimum scroll value
  BNE decrement_scroll  ; If scroll is not at min, decrement scroll
  LDA player_x
  CMP #00  ; Compare player_x with 00
  BEQ check_right  ; If player_x is equal to 00, skip decrementing player_x
  DEC player_x  ; If scroll is at min, decrement player x
  JMP check_right  ; Skip to next check
decrement_scroll:
  DEC scroll  ; Decrement scroll
  LDA #DIR_LEFT  ; Update player direction to left
  STA player_dir
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ done_checking
  LDA scroll
  CMP #255  ; Compare scroll with maximum scroll value
  BNE increment_scroll  ; If scroll is not at max, increment scroll
  LDA player_x
  CMP #240  ; Compare player_x with 245
  BEQ done_checking  ; If player_x is equal to f8, skip incrementing player_x
  INC player_x  ; If scroll is at max, increment player x
increment_scroll:
  LDA scroll
  CMP #255  ; Compare scroll with maximum scroll value
  BEQ done_incrementing  ; If scroll is already at max, skip incrementing
  INC scroll
done_incrementing:
  LDA #DIR_RIGHT  ; Update player direction to right
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

