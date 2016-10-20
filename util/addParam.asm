//Add parameter to arbitrary localVar area at R6
//After you call setupMethodCall

addParam
  STR R0, R6, #0
  ADD R6, R6, #-1
RET