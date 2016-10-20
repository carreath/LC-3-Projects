//R6 = stack Pointer
//R5 = frame Pointer
//
//x7FF7  
//x7FF8      <- R6 - 3
//x7FF9  FP  <- R6 - 2 **Store R5 here and set R5 = x7FF9
//x7FFA  RA  <- R6 - 1
//x7FFB  RV  <- R6
//x7FFC  lv. <- arbitrary number of local vars
//x7FFD  FP  <- R5
//x7FFE  RA  <- Return Address
//x7FFF  RV  <- Return Value

setupCall
  ADD R6, R6, #-3
  STR R5, R6, #1
  ADD R5, R6, #1
RET