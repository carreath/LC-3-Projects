.orig x3000
init
  LEA R0, row
  LD R1, mapSizeX
  NOT R1, R1
  ADD R0, R0, R1
  LD R2, newLine
  STR R2, R0, #1

  LD R6, callStack
  ADD R5, R6, #-2

  main
  AND R0, R0, #0
  ADD R0, R0, #-16
  JSR createStackFrame
  JSR game
  HALT

; game(int players, int difficulty)
game 
  gameLoop
  
    JSR createStackFrame
    JSR movePlayer

    JSR draw
    JSR createStackFrame
    JSR Sleep

	LD R0, running
    BRP exit
  BR gameLoop

  exit

  JSR return

; checkBounds(position, direction, negative_max_value)
; returns (0) True  (R0 == 0) if the position + direction is OOB
; returns (1) False (R0 == 1) if within bounds 
checkBounds
  AND R0, R0, #0 ; Set R0 = 0

  ; Get params
  LDR R1, R5, #3 ; dir
  LDR R2, R5, #4 ; neg_max

  ADD R1, R1, R2 ; if (dir + neg_max < 0) return 0
  BRN checkBounds_true

  LDR R2, R5, #2 ; position
  ADD R1, R1, R2 ; if (dir + neg_max + pos > 0) return 0
  BRP checkBounds_true

  ADD R0, R0, #1 ; return 1

  checkBounds_true
  JSR return

; xCollision()
; returns (0) True  (R0 == 0) if the ball collides with a paddle
; returns (1) False (R0 == 1) if Ball either hits the wall or is not colliding
hCollision
	AND R1, R1, #0 ; Collision True

	ADD R6, R6, #-1
	ADD R6, R6, #-1
	LD R0, mapSizeX
	ADD R0, R0, #2
	JSR addParam
	JSR createStackFrame
	JSR checkBounds			; if (checkBounds(ballPosX-1,ballDirX,-34))
	BRZ hCollision_true		; true return 0

	LD R0, ballPosX
	JSR addParam
	LD R0, ballDirX
	JSR addParam
	LD R0, mapSizeX
	JSR addParam
	JSR createStackFrame
	JSR checkBounds 		; if (checkBounds(ballPosX,ballDirX,-36))
	BRP hCollision_false 	; false return 1

	ST R1, running
	BRZ hCollision_true   	; true return 0 and stop loop

	hCollision_false
	ADD R1, R1, #1

	hCollision_true
	ADD R0, R1, #0
	JSR return

; draw()
draw
	LEA R0, newLine
	PUTS
	PUTS
	; for y = 0; y < 12
	AND R1, R1, #0
	draw_for_y
		LEA R0, row
		LD R3, space

		; for x = 0; x < 36
		LD R2, mapSizeX
		draw_for_x
			STR R3, R0, #0
			ADD R0, R0, #1
			ADD R2, R2, #1
			BRN draw_for_x
		
		LEA R0, row
		LD R2, ballPosY
		ADD R2, R1, R2
		BRNP NOT_BALL
		LD R3, ball
		LD R2, ballPosX
		ADD R0, R0, R2
		STR R3, R0, #0
		LEA R0, row

		NOT_BALL
		LD R2, playerPosY
		ADD R2, R1, R2
		BRNP NOT_PLAYER
		LD R3, player
		STR R3, R0, #1

		NOT_PLAYER
		LD R2, enemyPosY
		ADD R2, R1, R2
		BRNP printRow
		LD R3, enemy
		LD R2, mapSizeX
		NOT R2, R2
		ADD R2, R2, #1
		ADD R0, R0, R2
		STR R3, R0, #-2
		LEA R0, row

		printRow
		PUTS

		LD R2, mapSizeY
		NOT R2, R2
		ADD R2, R2, #1
		ADD R2, R1, R2
		BRZ draw_return
		ADD R1, R1, #-1
		BR draw_for_y
	draw_return
	RET

movePlayer
  ; Move Player
  LD R1, playerPosY
  LD R3, playerDir
  ADD R1, R1, R3 ; new pos
  ST R1, playerPosY

  ; Check Dir
  LD R2, maxPlayerPos
  NOT R2, R2
  ADD R2, R2, #1    ; -maxPos
  ADD R2, R2, R1    ; Pos - maxPos: [-144,0]
  BRZP negDir     ; If pos >= 144 flip dir to -12
  LD R2, playerPosY
  NOT R2, R2      ; else check if pos == 0
  ADD R2, R2, #1    ; Pos: [0,144]
  BRZP checkDir     ; If Pos <= 0 flip
  BR endFlip
  checkDir
  LD R2, playerDir
  NOT R2, R2      
  ADD R2, R2, #1    
  BRP posDir      ; if dir < 0 flip
  BR endFlip

  negDir
  AND R3, R3, #0
  ST R3, playerDir
  LD R3, maxPlayerPos
  ST R3, playerPosY
  BR endFlip
  
  posDir
  AND R3, R3, #0
  ST R3, playerDir
  AND R3, R3, #0
  ST R3, playerPosY

  endFlip

  JSR return

; funct Sleep(12ms * R3)
Sleep 
    LD R3, quartSec
  AND R2, R2, #0
  ADD R2, R2, #5
  goback
    LD R4, maxInt
    twelveMillis: 
      ADD R4, R4, #-1
    BRP twelveMillis

    ; Get User Input
    ADD R2, R2, #-1
    BRP skipInput
    JSR GET_KEY
    ST R0, playerDir
    AND R2, R2, #0
    ADD R2, R2, #5
    skipInput
    ADD R3, R3, #-1
  BRP goback

    JSR return

; Store R0 @ R6 in the next stack frame
; Access param: LDR R0, R5, #(paramIndex + 2)
; Add params before createStackFrame
addParam
  STR R0, R6, #0
  ADD R6, R6, #-1
  RET

; Pushes sub routine in stack frame
; JSR createStackFrame immediately before JSR <complex function>, JSR return to pop frame
; R7 = return
; R6 = next frame
; R5 = stackframePtr
createStackFrame
  ADD R6, R6, #-2
  STR R5, R6, #1
  ADD R5, R7, #1 
  STR R5, R6, #2 ; Store return address
  ADD R5, R6, #1
  RET

; returns from the stack frame
return
  LDR R7, R5, #1 
  LDR R5, R5, #0
  ADD R6, R5, #-1
  RET

GET_KEY
  LDI R0, KBSR        ; Load the status of the keyboard
  BRz NO_KEY_PRESSED  ; If no key is pressed, jump to NO_KEY_PRESSED

  LDI R0, KBDR        ; Load the key code from the keyboard data register

  ; Check if the key is the up arrow (ASCII code xE048)
  LD R1, W
  NOT R1, R1
  ADD R1, R1, #1
  ADD R1, R0, R1
  BRz SET_W

  ; Check if the key is the down arrow (ASCII code xE050)
  LD R1, S
  NOT R1, R1
  ADD R1, R1, #1
  ADD R1, R0, R1
  BRz SET_S
  NO_KEY_PRESSED
    AND R0, R0, #0    
  RET                 ; Return from subroutine
  SET_W
    LD R0, negPlayerDir
    STI R1, KBSR
  RET                 ; Return from subroutine
  SET_S
    LD R0, posPlayerDir
    STI R1, KBSR
  RET                 ; Return from subroutine

player 			.STRINGZ "]"
playerPosY 		.FILL 6
enemy 			.STRINGZ "["
enemyPosY 		.FILL 6
ball 			.STRINGZ "o"
ballPosX 		.FILL 18
ballPosY 		.FILL 6
ballDirX 		.Fill 4
ballDirY 		.FILL 1
running 		.FILL 0
randomCount	 	.FILL 0
maxInt 			.FILL x7FFF
oneSec 			.FILL 40 ;77 == one second
quartSec 		.FILL 5 ; 20 == 0.25 s
space 			.STRINGZ " "
newLine 		.STRINGZ "\n"
curX 			.FILL #0
mapSizeX 		.FILL -36
mapSizeY 		.FILL -11
playerDir 		.FILL 0
posPlayerDir 		.FILL 1
negPlayerDir 		.FILL -1
maxPlayerPos		.FILL 11

callStack 		.FILL x8000
KBSR        		.FILL xFE00         ; Keyboard status register address
KBDR        		.FILL xFE02         ; Keyboard data register address
W       		.FILL 119           ; W keycode
S       		.FILL 115           ; S keycode
row 			.BLKW 38 0
.END
