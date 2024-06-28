.orig x3000
init
  LD R6, callStack
  ADD R5, R6, #-2

  LEA R0, map
  LD R2, playerPos
  ADD R0, R0, R2
  AND R1, R1, 0
  ADD R1, R1, #1 ; Put player in map[0][0]
  STR R1, R0, #0

main
  AND R0, R0, #0
  ADD R0, R0, #-16
  JSR createStackFrame
  JSR game
  HALT

; void game(int players, int difficulty)
game 
  gameLoop
    JSR createStackFrame
    JSR drawMap
    JSR createStackFrame
    JSR Sleep
	
    JSR createStackFrame
    JSR movePlayer
    ; BR exit
  BR gameLoop

  exit

  JSR return
; return

; void drawMap()
drawMap
  LD R1, mapSizeY ; R1 = maxSizeY
  LD R2, mapSizeX ; R2 = maxSizeX
  LEA R3, map     ; R3 = mapPointer
  AND R4, R4, #0  ; R4 = currentX

  ; for(R4=0; R4<mapSizeX; R4++) {
  ;   for(R5=0; R5<mapSizeY; R5++) {
  ;     if(map[R4][R5] == 0) print(" ");
  ;     else print("|");
  ;   }
  ;   print("\n");
  ; }

  forX
    ADD R7, R4, R1 ; if(R4 >= mapSizeX) then Br endForX
    BRZP endForX
    ST R4, curX
    AND R4, R4, #0
    forY
      ADD R7, R4, R2 ; if(R4 >= mapSizeY) then Br endForX
      BRZP endForY
      
      LDR R0, R3, #0
      BRP printPlayer
        LEA R0, space
        PUTS
      BRP endY      
      printPlayer
        LEA R0, player
        PUTS
      endY
        ADD R3, R3, #1
        ADD R4, R4, #1
      BR forY
    endForY
    LD R4, curX

    LEA R0, newLine
    PUTS
    ADD R4, R4, #1
    BR forX
  endForX  

  JSR return

movePlayer
	; Reset Player In Map
	LEA R0, map
	LD R1, playerPos
  	ADD R0, R0, R1
	AND R1, R1, 0
	STR R1, R0, #0

	; Move Player
	LD R1, playerPos
	LD R3, playerDir
	ADD R1, R1, R3 ; new pos
	ST R1, playerPos

	; Check Dir
	LD R2, maxPlayerPos
	NOT R2, R2
	ADD R2, R2, #1 		; -maxPos
	ADD R2, R2, R1 		; Pos - maxPos: [-144,0]
	BRZP negDir 		; If pos >= 144 flip dir to -12
	LD R2, playerPos
	NOT R2, R2   		; else check if pos == 0
	ADD R2, R2, #1 		; Pos: [0,144]
	BRZP checkDir 		; If Pos <= 0 flip
	BR endFlip
	checkDir
	LD R2, playerDir
	NOT R2, R2   		
	ADD R2, R2, #1 		
	BRP posDir			; if dir < 0 flip
	BR endFlip

	negDir
	AND R3, R3, #0
	ST R3, playerDir
	LD R3, maxPlayerPos
	ST R3, playerPos
	BR endFlip
	
	posDir
	AND R3, R3, #0
	ST R3, playerDir
	AND R3, R3, #0
	ST R3, playerPos

	endFlip
	; Place player
	LEA R0, map
	LD R1, playerPos
  	ADD R0, R0, R1
	AND R1, R1, 0
	ADD R1, R1, #1
	STR R1, R0, #0

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
; Access param: LDR R0, R5, #(paramIndex + 1)
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

randomCount .FILL 0
maxInt .FILL x7FFF
oneSec .FILL 40 ;77 == one second
quartSec .FILL 5 ; 20 == 0.25 s
callStack .FILL x8000
player .STRINGZ "|"
space .STRINGZ " "
ball .STRINGZ "o"
newLine .STRINGZ "\n"
curX .FILL #0
mapSizeX .FILL -36
mapSizeY .FILL -12
playerPos .FILL 0
playerDir .FILL 36
posPlayerDir .FILL 36
negPlayerDir .FILL -36
maxPlayerPos .FILL 396
KBSR        .FILL xFE00         ; Keyboard status register address
KBDR        .FILL xFE02         ; Keyboard data register address
W    		.FILL 119         	; W keycode
S  			.FILL 115         	; S keycode
map .BLKW 400 0
.END
