.ORIG   x800
            ; (1) Initialize interrupt vector table.
            LD      R0, VEC
            LD      R1, ISR
            STR     R1, R0, #0      ; Store x1000 in memory location x0180
    
            ; (2) Set bit 14 of KBSR as 1.
            LDI     R0, KBSR
            LD      R1, MASK
            NOT     R1, R1
            AND     R0, R0, R1
            NOT     R1, R1
            ADD     R0, R0, R1      
            STI     R0, KBSR
    
            ; (3) Set up system stack to enter user space.
            LD      R0, PSR
            ADD     R6, R6, #-1
            STR     R0, R6, #0      ; Push PSR on the stack
            LD      R0, PC
            ADD     R6, R6, #-1
            STR     R0, R6, #0      ; Push PC on the stack
            ; Enter user space.
            RTI
        
VEC         .FILL   x0180
ISR         .FILL   x1000
KBSR        .FILL   xFE00
MASK        .FILL   x4000
PSR         .FILL   x8002
PC          .FILL   x3000
.END



; R5 is the indicator for whether the loop should continue
;   0 = continue, 1 = HALT

.ORIG   x3000
            LD      R6, USP         ; Initialize USP
            AND     R5, R5, #0
WAIT        ADD     R5, R5, #0
            BRp     TERM            ; If R5 is 1, halt the program
            LEA     R0, STU_ID
            PUTS
            JSR     DELAY
            BRnzp   WAIT

TERM        HALT

; Beginning of subroutine DELAY
DELAY       ST      R1, SaveR1
            LD      R1, COUNT
REP         ADD     R1, R1, #-1
            BRp     REP
            LD      R1, SaveR1
            RET
; End of subroutine DELAY
            
USP         .FILL   xFE00
SaveR1      .FILL   x4000
COUNT       .FILL   x3000
STU_ID      .STRINGZ    "PB22151743 "
.END



.ORIG   x3FFF
            ; *** Begin factorial data here ***
FACT_N      .FILL   xFFFF
            ; *** End factorial data here ***
.END



; R1 is ued to check the input
; R2 stores the result of subroutine FACT
; R3 stores the literal number of the input
; R4 is another stack pointer

.ORIG   x1000
            ; *** Begin interrupt service routine code here ***
            LD      R0, NEWLINE
            LD      R4, STACK
            OUT
            GETC
            ST      R0, INPUT
            OUT
            AND     R3, R3, #0      
            LD      R1, ASCII_0
            ADD     R1, R0, R1
            ADD     R3, R1, R3      ; At this time R1 is the decimal number of the input
            BRn     NON_DEC         ; Smaller than '0'
            LD      R1, ASCII_9
            ADD     R1, R0, R1
            BRp     NON_DEC         ; Larger than '9'
            LD      R1, ASCII_7
            ADD     R1, R0, R1
            BRp     EXCEED          ; Input is 8 or 9
            ADD     R5, R5, #1      ; Input is within expected range
            LEA     R0, MSG_Y
            PUTS
            LD      R0, NEWLINE
            OUT
            ADD     R3, R3, #-1
            BRn     RES0
            ADD     R3, R3, #-1
            BRn     RES1
            ADD     R3, R3, #-1
            BRn     RES2
            ADD     R3, R3, #-1
            BRn     RES3
            ADD     R3, R3, #-1
            BRn     RES4
            ADD     R3, R3, #-1
            BRn     RES5
            ADD     R3, R3, #-1
            BRn     RES6
            ADD     R3, R3, #-1
            BRn     RES7
            
RES0        LEA     R0, MSG_RES0
            PUTS
            BRnzp   RETURN
RES1        LEA     R0, MSG_RES1
            PUTS
            BRnzp   RETURN
RES2        LEA     R0, MSG_RES2
            PUTS
            BRnzp   RETURN
RES3        LEA     R0, MSG_RES3
            PUTS
            BRnzp   RETURN
RES4        LEA     R0, MSG_RES4
            PUTS
            BRnzp   RETURN
RES5        LEA     R0, MSG_RES5
            PUTS
            BRnzp   RETURN
RES6        LEA     R0, MSG_RES6
            PUTS
            BRnzp   RETURN
RES7        LEA     R0, MSG_RES7
            PUTS
            BRnzp   RETURN

NON_DEC     LEA     R0, MSG_N
            PUTS
            LD      R0, NEWLINE
            OUT
            BRnzp   RETURN

EXCEED      LEA     R0, MSG_Y
            PUTS
            LD      R0, NEWLINE
            OUT
            LD      R0, INPUT
            OUT
            LEA     R0, MSG_EXCD
            PUTS
            ADD     R5, R5, #1
            BRnzp   RETURN

RETURN      RTI

NEWLINE     .FILL   x000A
MSG_Y       .STRINGZ    " is a decimal digit."
MSG_N       .STRINGZ    " is not a decimal digit."
MSG_EXCD    .STRINGZ    "! is too large for LC-3."
MSG_RES0    .STRINGZ    "0! = 1."
MSG_RES1    .STRINGZ    "1! = 1."
MSG_RES2    .STRINGZ    "2! = 2."
MSG_RES3    .STRINGZ    "3! = 6."
MSG_RES4    .STRINGZ    "4! = 24."
MSG_RES5    .STRINGZ    "5! = 120."
MSG_RES6    .STRINGZ    "6! = 720."
MSG_RES7    .STRINGZ    "7! = 5040."
STACK       .FILL   x4100
KBDR        .FILL   xFE02
N           .FILL   x3FFF
ASCII_0     .FILL   xFFD0
ASCII_7     .FILL   xFFC9
ASCII_9     .FILL   xFFC7
INPUT       .FILL   x4001

            ; *** End interrupt service routine code here ***
.END