.ORIG x3000
LD R1, DATA; 16384
AND R7, R7, #0
ADD R7, R7, #15
ADD R7, R7, #1
AND R6, R6, #0
ADD R6, R6, #15
ADD R6, R6, #1
AND R3, R3, #0
AND R4, R4, #0
LDR R0, R1, #0

AGAIN NOT R0, R0
ADD R0, R0, #1
LD R1, DATA
;ADD R1, R1, #1
LESS LDR R2, R1, #0
ADD R2, R2, R0
BRzp #1
ADD R3, R3, #1
ADD R1, R1, #1
ADD R7, R7, #-1
BRnp  LESS
LD R4, START
ADD R4, R3, R4
AND R3, R3, #0
ADD R0, R0, #-1
NOT R0, R0
STR R0, R4, #0
LD R1, DATA
NOT R5, R6
ADD R5, R5, #1
ADD R1, R1, R5
ADD R1, R1, #15
ADD R1, R1, #2;借助R5让R1指向下一个要处理的数
LDR R0, R1, #0
AND R7, R7, #0
ADD R7, R7, #15
ADD R7, R7, #1
ADD R6, R6, #-1
BRnp AGAIN

LD R1, MAX; 20495
AND R7, R7, #0
ADD R7, R7, #4
AND R5, R5, #0
AND R6, R6, #0
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #10
TESTA LDR R0, R1, #0
NOT R0, R0
ADD R0, R0, #1
ADD R0, R6, R0
BRp #1
ADD R5, R5, #1
ADD R1, R1, #-1
ADD R7, R7, #-1
BRnp TESTA
STI R5, RESULTA

LD R1, MAX
AND R7, R7, #0
ADD R7, R7, #8
AND R4, R4, #0
AND R6, R6, #0
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
ADD R6, R6, #15
TESTB LDR R0, R1, #0
NOT R0, R0
ADD R0, R0, #1
ADD R0, R6, R0
BRp #1
ADD R4, R4, #1
ADD R1, R1, #-1
ADD R7, R7, #-1
BRnp TESTB
NOT R5, R5
ADD R5, R5, #1
ADD R4, R4, R5
STI R4, RESULTB

HALT
RESULTA .FILL x5100
RESULTB .FILL X5101
MAX .FILL x500F
START .FILL x5000
DATA .FILL x4000
.END