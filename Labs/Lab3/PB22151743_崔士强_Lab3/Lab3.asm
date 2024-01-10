            .ORIG       x3000

            LD          R0, S1_ADDR     ;Load the address of S1 into R0
            LD          R1, S2_ADDR     ;Load the address of S2 into R1
            
LOOP        LDR         R3, R0, #0      ;Load a character in S1 into R3
            LDR         R4, R1, #0      ;Load a character in S2 into R4
            ADD         R5, R3, R4      ;If both are NULL, return #0
            BRz         RETURN_NULL
            AND         R5, R5, #0      ;Clear R5
            NOT         R4, R4
            ADD         R4, R4, #1
            ADD         R2, R3, R4      ;R3-R4
            BRnp        RETURN
            ADD         R0, R0, #1
            ADD         R1, R1, #1      ;Check the next character
            BRnzp       LOOP
           
RETURN_NULL AND         R2, R2, #0

RETURN      STI         R2, RESULT
            HALT

S1_ADDR     .FILL       x3100
S2_ADDR     .FILL       x3200
RESULT      .FILL       x3300

            .END