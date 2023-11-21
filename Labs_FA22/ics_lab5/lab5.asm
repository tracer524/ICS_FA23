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
LOOP    LEA R0,Prompt1
        PUTS        ;打印字符串
        JSR DELAY    ;延迟输出
        BRnzp LOOP
DELAY   ST R1, SaveR1   ;延迟子程序
        LD R1, COUNT
REP     ADD R1, R1, #-1
        BRp REP
        LD R1, SaveR1
        RET
Prompt1 .STRINGZ "PB21151807 "
COUNT   .FILL x7FFF
SaveR1  .BLKW #1
        ; *** End user program code here ***
        .END


        .ORIG x1000
        ; *** Begin interrupt service routine code here ***
        ST R0,SAVER_0
        ST R1,SAVER_1
        LD R0,Newline
        OUT
        LD R1,ASCII0;   -48
        GETC    ;读取输入的数
        OUT
        ADD R1,R0,R1    ;判断是否是十进制数
        BRn NO
        ADD R1,R1,#-9
        BRnz YES
        BRnzp NO
        
YES     LEA R0,Prompt2
        PUTS
        BRnzp DONE
NO      LEA R0,Prompt3
        PUTS
DONE    LD R0,Newline
        OUT
        LD R0,SAVER_0
        LD R1,SAVER_1
        RTI
SAVER_0  .BLKW #1
SAVER_1  .BLKW #1
Newline .FILL x000A    
ASCII0  .FILL #-48
Prompt2 .STRINGZ " is a decimal digit."
Prompt3 .STRINGZ " is not a decimal digit."
        ; *** End interrupt service routine code here ***
        .END