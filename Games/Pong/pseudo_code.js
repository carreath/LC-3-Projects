const playerX = 1
const enemyX = 35
const run = 0

let playerPos = 0
let enemyPos = 0
let ballPosX = 16
let ballPosY = 6

let playerDir = 1
let enemyDir = 1
let ballDirX = 4
let ballDirY = 1

function checkBounds(pos,dir,neg_max) {
	if (dir + neg_max < 0) return 0
  if (dir + neg_max + pos > 0) return 0
  return 1
}

function xCollision() {
	if (checkBounds(ballPosX,ballDirX,-36)) {
  	scorePoint()
    run = 1;
    return 1;
  }
  
  if (checkBounds(ballPosX-1,ballDirX,-34)) {
  	return 0;
  }
  
  return 1;
}

function draw() {
  let row = "<36chars>\n" // length 37
	for y=0;y<12;y++ {
  	for x=0;x<36;x++ {
      row[x] = " "
    }

    if (ballY - y == 0) {
			row[ballX] = "o"
    }
    if (playerPos - y == 0) {
			row[1] = "]"
    }
    if (enemyPos - y == 0) {
			row[35] = "["
    }
    
    // OUT
    console.log(row)
  }
}

function getInput() {
	if (downArrow) return 1
  if (upArrow) return -1
	return 0
}

while (true) {
	moveBall()
  movePlayer()
  moveEnemy()
  
  playerDir = getInput()
  
  const flipY = checkBounds(ballPosY,ballDirY,-12)
  if (flipY == 0) {
  	ballDirY = -ballDirY
  }

  const type = xCollision()
  if (type == 0) {
  	ballDir = -ballDir
  } 
  
  draw()
  
  if (run > 0) {
  	break;
  }
  
  sleep()
}
