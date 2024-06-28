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
  JSR setupCall
  AND R0, R0, #0
  ADD R0, R0, #1
  JSR game
  HALT

; void game(int players, int difficulty)
game 
  STR R7, R5, #1

  gameLoop
    JSR setupCall
    JSR drawMap
    LD R1, quartSec
    JSR setupCall
    JSR Sleep
	
	JSR setupCall
	JSR movePlayer
	; BR exit
  BR gameLoop

  exit

  JSR return
; return

return
  LDR R7, R5, #1 
  LDR R5, R5, #0
  RET

; void drawMap()
drawMap
  STR R7, R5, #1

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
  STR R7, R5, #1

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
	LD R3, playerDirNeg
	ST R3, playerDir
	LD R3, maxPlayerPos
	ST R3, playerPos
	BR endFlip
	
	posDir
	LD R3, playerDirPos
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

; funct Sleep(60ms * R1)
Sleep 
  STR R7, R5, #1

	goback
	LD R2, maxInt
	loop: 
		ADD R2, R2, #-1
		BRP loop
	ADD R1, R1, #-1
	BRP goback

  JSR return

; Store R0 @ R6
; move stackPtr
; Access param: LDR R0, R5, #(paramIndex + 1)
addParam
  STR R0, R6, #0
  ADD R6, R6, #-1
  RET

; R7 = return
; R6 = next frame
; R5 = stackframePtr
setupCall
  ADD R6, R6, #-2
  STR R5, R6, #1
  ADD R5, R6, #1
  RET

randomCount .FILL 0
maxInt .FILL x7FFF
oneSec .FILL 77
quartSec .FILL 20
callStack .FILL x8000
player .STRINGZ "|"
space .STRINGZ "."
ball .STRINGZ "•"
newLine .STRINGZ "\n"
curX .FILL #0
mapSizeX .FILL -36
mapSizeY .FILL -12
playerPos .FILL 0
playerDir .FILL 36
playerDirPos .FILL 36
playerDirNeg .FILL -36
maxPlayerPos .FILL 396
map .BLKW 400 0
.END
