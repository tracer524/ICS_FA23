.ORIG x3000         ; Program starts at x3000

        LDI R0, N           ; Load N into R0
        AND R1, R1, #0      ; Clear R1 to store the term of sequence
        ADD R1, R1, #3      ; Initialize R1 with 3
        AND R2, R2, #0      ; Clear R2 to store the indicator of operand
        AND R3, R3, #0      ; Clear R3 to store x0FFF to mask the result
        LD R3, MASK
        AND R4, R4, #0      ; Clear R4 as a counter
        AND R5, R5, #0      ; Clear R5 to store the result during check
      
TERM    ADD R0, R0, #-1
        BRp CKD             ; Check the conditions of changing the operand
        STI R1, DEST        ; Computation completed, store the result
        TRAP x25
       
CKD     AND R5, R5, #0      ; ChecK for Divisibility
        ADD R5, R1, R5      
DIVE    ADD R5, R5, #-8     ; DIVide by Eight
        BRp DIVE
        BRz FLIP            ; Divisible by 8
        
CKLD    AND R5, R5, #0      ; ChecK for the Last Digit
        ADD R5, R1, R5
DIVT    ADD R5, R5, #-10    ; DIVide by Ten
        BRp DIVT
        
        ADD R5, R5, #2      ; If the last digit is 8, R5 should be #-2 now 
        BRnp CHOOSE         ; The last digit is not 8
       
FLIP    NOT R2, R2          ; Change the indicator
        BRnzp CHOOSE

CHOOSE  ADD R2, R2, #0      ; Get the value of R2
        BRn SUBS            ; If the indicator is negative, perform substraction 
        
PLUS    ADD R1, R1, R1      ; Multilpy R1 by 2
        ADD R1, R1, #2      ; R1 adds 2
        AND R1, R1, R3      ; Mask out the first 4 bits of R1
        BRnzp TERM

SUBS    ADD R1, R1, R1      ; Multiply R1 by 2
        ADD R1, R1, #-2     ; R1 substracts 2
        AND R1, R1, R3      ; Mask out the first 4 bits of R1 
        BRnzp TERM
    
N       .FILL x3102
MASK    .FILL x0FFF
DEST    .FILL x3103

.END