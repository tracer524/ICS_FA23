; R0 is the indicator for correctness
; R2 is the prompt pointer
; R3 stores the character to be printed or read
; R4 stores the password pointer

.ORIG   x3000
            AND     R5, R5, #0
            LD      R6, STACK
            AND     R1, R1, #0
            ADD     R1, R1, #3      ; Set the counter as 3
            LEA     R2, INITPRPT
            JSR     PRINT           ; Print the initial prompt
            LD      R2, W
READ_INIT   JSR     READ
            ADD     R3, R3, R2      ; Check if the input is "W"
            BRnp    READ_INIT
INPUT       LEA     R2, INPUTPRPT
            JSR     PRINT
            JSR     VERIFY
            ADD     R0, R0, #0
            BRz     TERM            ; Right
            LEA     R2, FAILIPRPT
            JSR     PRINT
            JSR     VERIFY
            ADD     R0, R0, #0
            BRz     TERM            ; Right
            LEA     R2, FAILIIPRPT
            JSR     PRINT
            JSR     VERIFY
            ADD     R0, R0, #0
            BRz     TERM            ; Right
            LEA     R2, FAILIIIPRPT
            JSR     PRINT
            BRnzp   INPUT
            
TERM        LEA     R2, SUCCPRPT
            JSR     PRINT
            HALT
            
PRINT       LD      R3, NEWLINE     
L1          LDI     R5, DSR
            BRzp    L1
            STI     R3, DDR         ; Move cursor to a new line
LOOP        LDR     R3, R2, #0      ; Write the prompt
            BRz     RET_PRINT       ; Prompt ended
L2          LDI     R5, DSR
            BRzp    L2              ; Loop until monitor is ready
            STI     R3, DDR         ; Write the character
            ADD     R2, R2, #1      ; Increment the prompt pointer
            BRnzp   LOOP
RET_PRINT   RET

READ        ADD     R6, R6, #-1
            STR     R5, R6, #0      ; Push R5 onto stack
L3          LDI     R5, KBSR
            BRzp    L3
            LDI     R3, KBDR
L4          LDI     R5, DSR
            BRzp    L4              ; Loop until monitor is ready
            STI     R3, DDR         ; Write the character
            LDR     R5, R6, #0      ; Pop R5 back
            ADD     R6, R6, #1
            RET

VERIFY      ADD     R6, R6, #-1
            STR     R7, R6, #0      ; Push R7 onto stack
            ADD     R6, R6, #-1
            STR     R3, R6, #0      ; Push R3 onto stack
            ADD     R6, R6, #-1
            STR     R1, R6, #0      ; Push R1 onto stack, then use R1 to check for Y
            AND     R0, R0, #0      ; Set R0 as 0
            AND     R5, R5, #0      ; Set R5 as 0
            LEA     R4, PSWD
            AND     R2, R2, #0      ; Clear R2 to count for characters
            ADD     R2, R2, #10
            LD      R1, Y
READ_VRFY   JSR     READ
            ADD     R1, R3, R1      ; Check if the input is "Y"
            BRz     RET_VRFY
            ADD     R5, R5, #1
            LD      R1, Y
            ADD     R2, R2, #-1
            BRn     FALSE           ; Length exceeded
            LDR     R7, R4, #0      ; Load the password into R7
            ADD     R4, R4, #1
            NOT     R7, R7
            ADD     R7, R7, #1
            ADD     R3, R3, R7      ; R3-R7
            BRz     READ_VRFY
FALSE       ADD     R0, R0, #0
            BRn     READ_VRFY       ; Input is wrong already
            NOT     R0, R0          ; Change the indicator if it's true(i.e. zero)
            BRnzp   READ_VRFY
RET_VRFY    ADD     R5, R5, #0
            BRp     SKIP
            NOT     R0, R0
SKIP        LDR     R1, R6, #0      ; Pop R1 back
            ADD     R6, R6, #1
            LDR     R3, R6, #0      ; Pop R3 back
            ADD     R6, R6, #1
            LDR     R7, R6, #0      ; Pop R7 back
            ADD     R6, R6, #1
            RET

STACK       .FILL       x4000
Y           .FILL       xFFA7
W           .FILL       xFFA9
DSR         .FILL       xFE04
DDR         .FILL       xFE06
KBSR        .FILL       xFE00
KBDR        .FILL       xFE02
NEWLINE     .FILL       x000A
INITPRPT    .STRINGZ    "Welcome to the bank system! Type 'W' to withdraw some fund."
SUCCPRPT    .STRINGZ    "Success!"
FAILIPRPT   .STRINGZ    "Incorrect password! 2 attempts remaining."
FAILIIPRPT  .STRINGZ    "Incorrect password! 1 attempt remaining."
FAILIIIPRPT .STRINGZ    "Fails."
INPUTPRPT   .STRINGZ    "Please input your password:"
PSWD        .STRINGZ    "PB22151743"

.END