; Unfortunately we have not YET installed Windows or Linux on the LC-3,
; so we are going to have to write some operating system code to enable
; keyboard interrupts. The OS code does three things:
;
;    (1) Initializes the interrupt vector table with the starting
;        address of the interrupt service routine. The keyboard
;        interrupt vector is x80 and the interrupt vector table begins
;        at memory location x0100. The keyboard interrupt service routine
;        begins at x1000. Therefore, we must initialize memory location
;        x0180 with the value x1000.
;    (2) Sets bit 14 of the KBSR to enable interrupts.
;    (3) Pushes a PSR and PC to the system stack so that it can jump
;        to the user program at x3000 using an RTI instruction.

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
        AND	R1,	R1,	#0
        AND	R2,	R1,	#0
        AND	R3,	R1,	#0
        AND	R4,	R4,	#0
        AND	R5,	R1,	#0
        AND	R7,	R7,	#0
        ;R6初始化为用户栈指针
        LD	R6,	UP

L1      LDI	R0,	HN;HN为x3FFF，输入并且interrupt后的存储地址
        ADD	R1,	R0,	#1
        ;如果N值不再是xFFFF，执行HANOI
        BRnp	SKIP
        ;否则循环打印学号
        LEA	R0,	MYNUM
        TRAP	x22
        LD	R0,	KGG
        TRAP	x21
        JSR	DELAY
        BRnzp	L1

SKIP    JSR	HANOI   
        LD	R0,	LINE
        TRAP	x21
        ;convert result to string  and cout      
        LEA	R4,	RESULT
        AND	R5,	R5,	#0
        LD	R2,	NHUND
        AND	R3,	R3,	#0
        ;百位
QUOT    ADD	R3,	R3,	#1
        ADD	R1,	R1,	R2
        BRzp	QUOT
        LD	R2,	HUNDRED
        ADD	R1,	R1,	R2
        LD	R2,	ASICC
        ADD	R3,	R3,	#-1
        BRz	QUOT1
        ADD	R3,	R3,	R2
        STR     R3,     R4, #0
        ADD	R4,	R4,	#1
        ADD	R5,	R5,	#1
        AND	R3,	R3,	#0
        ;十位
QUOT1   ADD	R3,	R3,	#1
        ADD	R1,	R1,	#-10
        BRzp	QUOT1
        ADD	R1,	R1,	#10
        ADD	R3,	R3,	#-1
        BRnp	#2
        ADD	R5,	R5,	#0
        BRz	QUOT2
        ADD	R3,	R3,	R2
        STR     R3,     R4,     #0
        ADD	R4,	R4,	#1
        ;个位
QUOT2   ADD	R1,	R1,	R2
        STR     R1,     R4,     #0
        ADD	R4,	R4,	#1
        AND	R1,	R1,	#0
        STR     R1,     R4,     #0
        ;按要求打印结果
        LEA     R0,     ENDS1
        TRAP    X22
        LEA     R0,     RESULT
        TRAP    X22
        LEA     R0,     ENDS2
        TRAP    X22
        TRAP    X25

        ;code of HANOI,input in R0,output in R1
        ;SAVE
HANOI   ADD	R6,	R6,	#-1
        STR	R7,	R6,	#0
        ADD	R6,	R6,	#-1
        STR	R0,	R6,	#0

        ADD	R0,	R0,	#0
        BRz     BASE
        ADD	R0,	R0,	#-1
        JSR     HANOI
        ADD	R1,	R1,	R1
        ADD	R1,	R1,	#1
        BRnzp   DONE

BASE    ADD	R1,	R0,	#0

DONE    LDR	R0,	R6,	#0
        ADD	R6,	R6,	#1
        LDR	R7,	R6,	#0
        ADD	R6,	R6,	#1
        RET

MYNUM   .STRINGZ	"PB21051020"
KGG     .FILL	#32
LINE    .FILL	#10
HUNDRED .FILL	#100
NHUND   .FILL	#-100
RESULT  .BLKW	4
ASICC   .FILL	#48
HN      .FILL   X3FFF
UP      .FILL	XFDFF
ENDS1   .STRINGZ        "Tower of hanoi needs "
ENDS2   .STRINGZ        " moves."
        ; code of delay
DELAY   ST      R1,     SaveR1
        LD      R1,     COUNT
REP     ADD     R1,     R1,     #-1
        BRp     REP
        LD      R1,     SaveR1
        RET
SaveR1  .BLKW	1
COUNT   .FILL	#2500

; *** End user program code here ***
        .END

        .ORIG x3FFF
        ; *** Begin hanoi data here ***
HANOI_N .FILL xFFFF
        ; *** End hanoi data here ***
        .END

        .ORIG x1000
        ; *** Begin interrupt service routine code here ***
        ;SAVE
        ADD	R6,	R6,	#-1
        STR	R1,	R6,	#0
        ADD	R6,	R6,	#-1
        STR	R0,	R6,	#0

        LDI	R0,	KBDR
        LD	R1,	NASICC
        ;把R0转化为整数
        ADD	R1,	R0,	R1
        ;判断是否0-9
        BRn	FAULT
        ADD	R1,	R1,	#-9
        BRp	FAULT
        ;是数字，打印提示
        ADD	R1,	R1,	#9
        STI     R1,     HN1
        LD	R0,	LINE1
        TRAP    x21
        LDI	R0,	KBDR
        TRAP    x21
        LEA	R0,	RIGHT
        TRAP    x22
        BRnzp	DONE1
;不是数字，打印提示
FAULT   LD	R0,	LINE1
        TRAP    x21
        LDI	R0,	KBDR
        TRAP    x21
        LEA	R0,	WRONG
        TRAP    x22
        LD	R0,	LINE1
        TRAP    x21

DONE1   LDR	R0,	R6,	#0
        ADD	R6,	R6,	#1
        LDR	R1,	R6,	#0
        ADD	R6,	R6,	#1
        RTI

        ; *** End interrupt service routine code here ***
KBDR    .FILL	XFE02
NASICC  .FILL	#-48
RIGHT   .STRINGZ	" is a decimal digit"
WRONG   .STRINGZ	" is not a decimal digit"
LINE1   .FILL	X0A
HN1     .FILL   X3FFF
        .END