        .ORIG x800
        ; (1) Initialize interrupt vector table.
        LD R0, VEC
        LD R1, ISR
        STR R1, R0, #0

        ; (2) Set bit 14 of KBSR.
        LDI R0, KBSR
        LD R1, MASK
        NOT R1, R1
        AND R0, R0, R1
        NOT R1, R1
        ADD R0, R0, R1
        STI R0, KBSR

        ; (3) Set up system stack to enter user space.
        LD R0, PSR
        ADD R6, R6, #-1
        STR R0, R6, #0
        LD R0, PC
        ADD R6, R6, #-1
        STR R0, R6, #0
        ; Enter user space.
        RTI
        
VEC     .FILL x0180
ISR     .FILL x1000
KBSR    .FILL xFE00
MASK    .FILL x4000
PSR     .FILL x8002
PC      .FILL x3000
        .END

        .ORIG x3000
        ; *** Begin user program code here ***
        LD R6, POINTER
LOOP    LDI	R0,	NUM        ;加载N的值
        ADD	R1,	R0, #1       ;如果N不是xFFFF说明有了正确输入，执行汉诺塔函数，此时条件码不为0；否则条件码为0，打印学号
        BRnp TURN
        LEA R0, Prompt1
        PUTS        ;打印字符串
        JSR DELAY    ;延迟输出
        BRnzp LOOP
        ;
DELAY   ST R1, SaveR1   ;延迟子程序
        LD R1, COUNT
REP     ADD R1, R1, #-1
        BRp REP
        LD R1, SaveR1
        RET
        ;
HANOI   ADD	R6,	R6, #-1   ;用栈结构完成汉诺塔的递归
        STR	R7,	R6, #0
        ADD	R6,	R6, #-1
        STR	R0,	R6, #0
        ADD	R0,	R0, #0
        BRz BASE
        ADD	R0,	R0, #-1
        JSR HANOI
        ADD	R1,	R1,	R1
        ADD	R1,	R1, #1
        BRnzp DONE
BASE    ADD	R1,	R0, #0
DONE    LDR	R0,	R6, #0
        ADD	R6,	R6, #1
        LDR	R7,	R6, #0
        ADD	R6,	R6, #1
        RET
        ;
TURN    JSR	HANOI   ;之后的部分是把R1中的汉诺塔结果从二进制转换成ASCII码输出到显示器上
        LEA	R5,	RESULT
        AND	R4,	R4, #0
        AND	R3,	R3, #0
        LD	R2,	Neg100
HUNDRED ADD	R3,	R3, #1
        ADD	R1,	R1,	R2   ;一直减100直到为负值，就可以判断百位的数字
        BRzp HUNDRED
        LD	R2,	Pos100   ;还原十位数和个位数
        ADD	R1,	R1,	R2
        LD	R2,	ASCII
        ADD	R3,	R3, #-1
        BRz	TEN          ;说明只有两位数
        ADD	R3,	R3,	R2   ;R3放百位数字，+48变成ASCII码后存入结果
        STR R3, R5, #0
        ADD	R5,	R5, #1
        ADD	R4,	R4, #1
        AND	R3,	R3, #0
TEN     ADD	R3,	R3, #1
        ADD	R1,	R1, #-10
        BRzp TEN
        ADD	R1,	R1, #10  ;还原个位数
        ADD	R3,	R3, #-1  ;判断到负数多减了一位
        BRnp #2
        ADD	R4,	R4, #0
        BRz	SINGLE
        ADD	R3,	R3,	R2   ;R3放十位数字，+48变成ASCII码后存入结果
        STR R3, R5, #0
        ADD	R5,	R5, #1
SINGLE  ADD	R1,	R1,	R2
        STR R1, R5, #0
        ADD	R5,	R5, #1
        AND	R1,	R1, #0
        STR R1, R5, #0
        LEA R0, RE1     ;输出结果
        TRAP x22
        LEA R0, RESULT
        TRAP x22
        LEA R0, RE2
        TRAP x22
        TRAP x25
Prompt1 .STRINGZ "PB21151807 "
COUNT   .FILL x7FFF
SaveR1  .BLKW #1
NUM     .FILL x3FFF
POINTER .FILL xFDFF
Pos100  .FILL x0064
Neg100  .FILL xFF9C
RESULT  .BLKW #4
ASCII   .FILL #48
RE1     .STRINGZ "Tower of hanoi needs "
RE2     .STRINGZ " moves."
        ; *** End user program code here ***
        .END

        .ORIG x3FFF
        ; *** Begin hanoi data here ***
HANOIN .FILL xFFFF
        ; *** End hanoi data here ***
        .END

        .ORIG x1000
        ; *** Begin interrupt service routine code here ***
        ST R0, SAVER_0
        ST R1, SAVER_1
        ST R2, SAVER_2
        LD R0, Newline
        OUT
        LD R2, ASCII0;
        LD R1, ASCII0;   -48
        GETC    ;读取输入的数
        OUT
        ADD R2, R0, R2   ;把ASCII码转化成数字放进R2，之后存入内存
        ADD R1, R0, R1    ;判断是否是十进制数
        BRn NO
        ADD R1, R1, #-9   ;判断是否是0-9
        BRnz YES
        BRnzp NO
YES     STI R2, HANOI_N   ;N值存入内存x3FFF
        LEA R0, Prompt2
        PUTS
        BRnzp DONE0
NO      LEA R0, Prompt3
        PUTS
DONE0   LD R0, Newline
        OUT
        LD R0, SAVER_0
        LD R1, SAVER_1
        LD R2, SAVER_2
        RTI
SAVER_0  .BLKW #1
SAVER_1  .BLKW #1
SAVER_2  .BLKW #1
HANOI_N .FILL x3FFF
Newline .FILL x000A    
ASCII0  .FILL #-48
Prompt2 .STRINGZ " is a decimal digit."
Prompt3 .STRINGZ " is not a decimal digit."
        ; *** End interrupt service routine code here ***
        .END