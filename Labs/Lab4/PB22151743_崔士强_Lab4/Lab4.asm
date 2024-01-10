; R0 stores n
; R1 stores current state
; R2 is used for check
; R3 is initialized with x3100 and stores the state after each move
; R5 is used to operate on the i-th ring
; R6 is the stack pointer

.ORIG x3000
                LDI     R0, N
                LD      R3, N
                AND     R1, R1, #0
                LD      R6, STACK
                JSR     REMOVE
                HALT
                
; Beginning of REMOVE
REMOVE          ADD     R6, R6, #-1
                STR     R0, R6, #0      ; Push R0 onto stack
                
                ADD     R6, R6, #-1
                STR     R7, R6, #0      ; Push return linkage onto stack
                
                ADD     R2, R0, #0
                BRz     RETURN_REMOVE   ; i=0
                ADD     R2, R0, #-1
                BRz     REMOVE_FIRST    ; i=1
                
                ADD     R0, R0, #-2
                JSR     REMOVE          ; R(i-2)
                
                ADD     R0, R0, #2      ; Restore R0
                JSR     SINGLEBIT
                NOT     R1, R1
                NOT     R5, R5
                AND     R1, R1, R5
                NOT     R1, R1
                ADD     R3, R3, #1
                STR     R1, R3, #0      ; Remove the i-th ring
                
                ADD     R0, R0, #-2     
                JSR     PUT             ; P(i-2)
                ADD     R0, R0, #1
                JSR     REMOVE          ; R(i-1)
                BRnzp   RETURN_REMOVE
                
REMOVE_FIRST    ADD     R1, R1, #1      ; Remove the first ring
                ADD     R3, R3, #1      ; 
                STR     R1, R3, #0      ; Store the result
              
RETURN_REMOVE   LDR     R7, R6, #0      ; Pop return linkage into R7
                ADD     R6, R6, #1
                LDR     R0, R6, #0      ; Pop R0 back
                ADD     R6, R6, #1
                RET
; End of REMOVE
            
; Beginning of PUT
PUT             ADD     R6, R6, #-1
                STR     R0, R6, #0      ; Push R0 onto stack
                
                ADD     R6, R6, #-1
                STR     R7, R6, #0      ; Push return linkage onto stack
                
                ADD     R2, R0, #0
                BRz     RETURN_PUT      ; i=0
                ADD     R2, R0, #-1
                BRz     PUT_FIRST       ; i=1
                
                ADD     R0, R0, #-1
                JSR     PUT             ; P(i-1)
                
                ADD     R0, R0, #-1
                JSR     REMOVE          ; R(i-2)
                
                ADD     R0, R0, #2      ; Restore R0
                JSR     SINGLEBIT
                NOT     R5, R5
                AND     R1, R1, R5      
                ADD     R3, R3, #1
                STR     R1, R3, #0      ; Put the i-th ring
               
                ADD     R0, R0, #-2
                JSR     PUT             ; P(i-2)
                BRnzp   RETURN_PUT
                
PUT_FIRST       ADD     R1, R1, #-1     ; Put the first ring
                ADD     R3, R3, #1      ; 
                STR     R1, R3, #0      ; Store the result
                
RETURN_PUT      LDR     R7, R6, #0      ; Pop return linkage into R7
                ADD     R6, R6, #1
                
                LDR     R0, R6, #0      ; Pop R0 back
                ADD     R6, R6, #1
                RET
; End of PUT

; Beginning of SINGLEBIT
SINGLEBIT       ADD     R6, R6, #-1
                STR     R0, R6, #0      ; Push R0 onto stack
                
                ADD     R0, R0, #-1
                AND     R5, R5, #0      ; Clear R5
                ADD     R5, R5, #1      ; Set R5 as 1
                
MOVE_LEFT       ADD     R5, R5, R5      ; Multiply R5 by 2
                ADD     R0, R0, #-1
                BRp     MOVE_LEFT
                
                LDR     R0, R6, #0      ; Pop R0 back
                ADD     R6, R6, #1
                RET
; End of SINGLEBIT

N       .FILL   x3100
STACK   .FILL   x4000

.END