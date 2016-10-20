.orig x3000
init
  LD R6, callStack
  ADD R5, R6, #-2
  LEA R0, map
  AND R1, R1, 0
  ADD R1, R1, #1
  STR R1, R0, #0

main
  JSR setupCall
  AND R0, R0, #0
  ADD R0, R0, #1
  JSR addParam //1 player
  JSR addParam //diff 1
  JSR game
  HALT

//void game(int players, int difficulty)
game 
  STR R7, R5, #1

  gameLoop
    JSR setupCall
    JSR drawMap
    LD R1, oneSec
    JSR Sleep
  BR gameLoop

  LDR R7, R5, #1 
  RET
//return

//void drawMap()
drawMap
  STR R7, R5, #1

  LD R1, mapSizeX //R1 = maxSizeX
  LD R2, mapSizeY //R2 = maxSizeY
  LEA R3, map     //R3 = mapPointer
  AND R4, R4, #0  //R4 = currentX

  //for(R4=0; R4<mapSizeX; R4++) {
  //  for(R5=0; R5<mapSizeY; R5++) {
  //    if(map[R4][R5] == 0) print(" ");
  //    else print("[]");
  //  }
  //  print("\n");
  //}

  forX
    ADD R7, R4, R1 //if(R4 >= mapSizeX) then Br endForX
    BRZP endForX
    ST R4, curX
    AND R4, R4, #0
    forY
      ADD R7, R4, R2 //if(R4 >= mapSizeY) then Br endForX
      BRZP endForY
      
      LDR R0, R3, #0
      BRP next
        LEA R0, space
        PUTS
      BRP endY      
      next
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

  LDR R7, R5, #1 
  RET

//funct Sleep(60ms * R1)
Sleep 
  LD R0, maxInt
  loop: 
    ADD R0, R0, #-1
    BRP loop
   ADD R1, R1, #-1
   BRP Sleep
  RET

addParam
  STR R0, R6, #0
  ADD R6, R6, #-1
  RET

setupCall
  ADD R6, R6, #-3
  STR R5, R6, #1
  ADD R5, R6, #1
  RET

maxInt .FILL x7FFF
oneSec .FILL 15
callStack .FILL x8000
player .STRINGZ "[]"
space .STRINGZ "."
newLine .STRINGZ "\n"
curX .FILL #0
mapSizeX .FILL -4
mapSizeY .FILL -4
map .BLKW 400 0
.END