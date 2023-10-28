.ORIG x3000
LDI R0, NUM
LD  R1, DATA    ;R1是指针，指向地址

AND R2, R2, #0
AND R5, R5, #0
ADD R2, R2, #1  ;R2置1
ADD R5, R5, #1  ;R5置1
ADD R0, R0, #-1 ;N-1

LDR R3, R1, #0  ;R3读取R1指向的内容，即第一个字符
ADD R1, R1, #1  ;指针移动
LDR R4, R1, #0  ;R4作为后指针

LOOP NOT R3, R3 ;比较前后字符，R4-R3=0时字符相等
ADD R3, R3, #1
ADD R3, R3, R4
BRnp DIFF
ADD R5, R5, #1
ADD R0, R0, #-1
BRz RE          ;跳转更新R2

NEXT AND R3, R3, #0 ;前后指针移动
ADD R3, R4, #0
ADD R1, R1, #1
LDR R4, R1, #0
BRnzp LOOP

DIFF NOT R6, R5  ;一个子串结束的时候比较R2和R5取最大值放入R2
ADD R6, R6, #1
ADD R6, R2, R6
BRp #4           ;R5>R2时更新R2的值
AND R2, R2, #0
ADD R2, R5, #0
AND R5, R5, #0
ADD R5, R5, #1
ADD R0, R0, #-1
BRnp NEXT
BRz RES

RE NOT R6, R5    ;比较结束的时候再更新一次R2
ADD R6, R6, #1
ADD R6, R2, R6
BRp #2
AND R2, R2, #0
ADD R2, R5, #0

RES STI R2, RESULT
HALT
RESULT .FILL x3050
NUM    .FILL x3100
DATA   .FILL x3101

.END