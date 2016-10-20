//void Sleep(R1 delayMs) {
//	 while(--delayMs != 0) {
//    	wait(1ms);
//	 }
//}

Sleep 
	LD R0, oneMilli
	loop: 
		ADD R0, R0, #-1
		BRP loop
	ADD R1, R1, #-1
	BRP Sleep
RET

oneMilli .FILL 546
oneSec .FILL 1000