; LAB 01
; Code by Martino Mensio

N EQU 10

.MODEL SMALL
.STACK
.DATA

;data assumption: every number is considered as unsigned (binary)

ARRAY_A DB  N   DUP(?)
ARRAY_B DB  N-1 DUP(?)
MIN_A   DB  ?
MIN_B   DB  ?
MATRIX  DW  (N-1)*(N-1) DUP (?)
MAX_M   DW ?
STR1 DB 10,13,"Insert a number (0-255):$"
OVERFLOW_MESSAGE DB 10,13,"Overflow occurred. Unexpected results!$"
INVALID_MESSAGE DB 10,13,"Invalid character detected. Unexpected results!$"
NEWLINE DB 10,13,"$"
MESSAGE1 DB 10,13,"Content of array_b:$"
MESSAGE2a DB 10,13,"Minimum value for array_a:$" 
MESSAGE2b DB 10,13,"Minimum value for array_b:$"
MESSAGE3a DB 10,13,"Matrix values:$"
MESSAGE3b DB 10,13,"Maximum value of matrix:$"     

.CODE
.STARTUP

;------------------------------------------------------------------------------------------
;initialization of array_a by input from keyboard 
 
        MOV CX,N                        ;initialize counter for input loop
        XOR SI,SI                       ;SI will be used to access the array
    
INITLOOP:MOV AH,9                       ;for printing a message to output
        LEA DX,STR1
        INT 21H
        PUSH AX                         ;push something useless (only to have a element writable on the stack)
        CALL INPUTTOBYTE                ;this procedure reads a number unsigned from keyboard
        POP AX                          ;the return value of the procedure is in the stack
        MOV ARRAY_A[SI],AL              ;store in array the result returned
        INC SI                          ;increasing by 1 because array_a is a byte array
        LOOP INITLOOP
    
;INITIALIZATION with increasing values [0,1,2,3,...]
;       MOV CX,N		    
;       XOR AX,AX
;       XOR SI,SI
;L0:    MOV ARRAY_A[SI],AL
;       INC SI
;       INC AL
;       LOOP L0
 
;-----------------------------------------------------------------------------------------
;PART 1    Compute the sum for each pair of consecutive values, putting the result in a 9 elements array (Bj = Aj + Aj+1)
;array_b is the destination array. I chose a byte vector
;advantages: in part 3 the mul of byte*byte won't cause overflow in a word matrix
;drawbacks: summing two byte operands can produce overflow if the result is a byte
;if i choose array_b as a word, then the mul of byte*word can produce overflow if the result is a word

;on overflow detection, i simply print out a message. An alternative could have been to stop the program

        MOV AH,9                        ;three instructions to print out a message
        LEA DX,MESSAGE1
        INT 21H
        
        XOR AX,AX
        XOR DX,DX                            
        MOV CX,N		        ;cx for loop count
        XOR BL,BL		        ;BL will store the previous element (Aj-1)
        XOR SI,SI		        ;index of source vett A & B
L1:     MOV AL,ARRAY_A[SI]              ;load new element from array into AL
        CMP SI,0                        ;the first time i must do nothing
        JE L1NEXT
        MOV DL,AL		        ;current element (Aj) is copied into DL
        ADD DL,BL		        ;into DL i calculate (Aj-1 + Aj)
        JNC NOOVERFLOWSUM               ;overflow can occurr in the sum of unsigned (carry flag)
        CALL OVERFLOW                   ;
NOOVERFLOWSUM:MOV ARRAY_B[SI-1],DL      ;save in array_B
        PUSH DX                         ;pass parameter to procedure (DH is currently 00h). The out procedure uses words
        CALL OUTWORD                    ;call procedure
        POP DX
L1NEXT: MOV BL,AL                       ;Aj is moved into BL for next iteration
        INC SI
        LOOP L1
        
;-------------------------------------------------------------------------------------------    
;PART 2    Find the minimum value both for the first (A) and the second (B) array
;the procedure used to calculate the minimum receives the offset of array and its dimension. Returns a word whose least significant byte
; is the result byte (the minimum of an array of bytes is a byte)
        
        MOV AH,9                        ;print out a message
        LEA DX,MESSAGE2a
        INT 21H
        
        XOR AX,AX                       ;passing parameters to procedure
        PUSH AX                         ;"empty" space in stack for return value
        LEA AX,ARRAY_A
        PUSH AX                         ;first parameter: offset of array to be accessed
        MOV AX,N
        PUSH AX                         ;second parameter: dimension of array
        CALL CALCMIN                    ;calculate the minimum
        POP AX                          ;nothing useful, only to balance push
        POP AX                          ;nothing useful, only to balance push
        POP AX                          ;the result is a word (because of stack) but higher part is 00h
        MOV MIN_A,AL                    ;write to memory result (only the lower part)
        
        ;OUTPUT     
        PUSH AX                         ;pass parameter to procedure to print ax (currently ah=00h)
        CALL OUTWORD                    ;call function to print out a word in decimal
        POP AX 
        
        MOV AH,9                        ;print again a message
        LEA DX,MESSAGE2b
        INT 21H
        
        XOR AX,AX                       ;pass parameters to procedure
        PUSH AX                         ;analog to previus call
        LEA AX,ARRAY_B
        PUSH AX                         ;but i push the offset of array_b
        MOV AX,N-1
        PUSH AX                         ;and the right dimension
        CALL CALCMIN
        POP AX              
        POP AX
        POP AX                          ;the result is in AL
        MOV MIN_B,AL                    ;write to memory result
        
        ;OUTPUT     
        PUSH AX                         ;pass parameter to procedure to print ax (currently ah=00h)
        CALL OUTWORD                    ;call function to print out a word in decimal
        POP AX
        
        
;---------------------------------------------------------------------------------------------------    
;PART 3     Compute all possible products among first 9 values of first array and all 9 values of second array, putting results in a matrix of 9x9 values (words)
;overflow on mul of byte*byte does not exixt on a word result

        MOV AH,9                        ;print out a message
        LEA DX,MESSAGE3a
        INT 21H
        
        XOR SI,SI                       ;SI USED FOR accessing BYTE VECTORS
        XOR DI,DI                       ;DI USED FOR accessing WORD MATRIX (considered as a VECTOR)
        ;XOR BX,BX                       ;BX STORES MAX VALUE
        MOV CX,N-1                      ;counter initialization
L3O:    MOV DL,ARRAY_A[SI]              ;FIRST ELEMENT of multiplication IN DL 
        PUSH CX                         ;save in the stack CX and SI for outer loop
        PUSH SI             
        XOR SI,SI                       ;set up SI and CX for inner loop
        MOV CX,N-1
L3I:    MOV AL,DL                       ;FIRST ELEMENT PUT IN AX EVERY TIME (MUL overwriters AX)
        MUL ARRAY_B[SI]                 ;do a (byte*byte)->word ==> no overflow can occurr
        MOV MATRIX[DI],AX               ;the mul result is put in the result matrix
        PUSH AX                         
        CALL OUTWORD                    ;print the current value
        POP AX
        INC SI                          ;increment SI to access new value
        INC DI
        INC DI                          ;DI increased by 2 because matrix is made of words
        LOOP L3I
        POP SI                          ;restore outer loop registers
        POP CX
        INC SI
        ;ADD BX,2*(N-1)
        LOOP L3O
        
        
        
;---------------------------------------------------------------------------------------------------
;PART 4     Find the maximum value among values of the so computed matrix. Is there overflow?
;overflow doesn't occur in the matrix as discussed above
        
        MOV AH,9                        ;print message
        LEA DX,MESSAGE3b
        INT 21H
        
        MOV CX, (N-1)*(N-1)             ;i will access the matrix as an array
        XOR DX,DX                       ;DX stores max value of matrix
        LEA BX,MATRIX                   ;BX is used to poit elements
        
L4:     MOV AX,[BX]                     ;put in AX the current value
        CMP AX,DX                       ;if AX<=DX
        JBE LESS                        ;do nothing
        MOV DX,AX                       ;else (AX>DX) update the max value
LESS:   INC BX
        INC BX                          ;increasing BX by two (next word)
        LOOP L4
        
        MOV MAX_M,DX                    ;save the max value of matrix       
        
        ;OUTPUT     
        PUSH DX                         ;and print max
        CALL OUTWORD
        POP DX  

        .EXIT
        
        
        
        
        
;------------------------------------------------------------------------------------------        
        
OVERFLOW PROC NEAR                      ;this procedure prints out the overflow message
        PUSH AX
        PUSH DX
        LEA DX,OVERFLOW_MESSAGE         ;message to be printed
        MOV AH,9
        INT 21H                         ;interrupt to print message
        POP DX
        POP AX
        RET
OVERFLOW ENDP

;-----------------------------------------------------------------------------------------

INVALIDCHAR PROC NEAR                   ;this procedure prints out the INVALID char message
        PUSH AX
        PUSH DX
        LEA DX,INVALID_MESSAGE          ;message to be printed
        MOV AH,9
        INT 21H                         ;interrupt to print message
        POP DX
        POP AX
        RET
INVALIDCHAR ENDP
 
;------------------------------------------------------------------------------------------

INPUTTOBYTE PROC NEAR                   ;READS AN ITEGER FROM KEYBOARD RETURNING A BYTE (inside a word: higher part set to 00h)
        PUSH BP
        MOV BP,SP                       ;[BP+4] -> RET VALUE
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV CX,3                        ;MAX = 255 -> 3 CHARS
        
        XOR BX,BX                       ;BX USED FOR PREVIOUS VALUE
        MOV AH,1                        ;want to read using int21h                        
LIN:    INT 21H                         ;read a byte (ASCII)
        CMP AL,13                       ;is it the return key?
        JE ENDIN                        ;in this case stop reading ASCII codes
        CMP AL,'0'                      ;check if ASCII below range
        JB INVALID
        CMP AL,'9'                      ;check if ASCII above range
        JA INVALID
        JMP VALID
INVALID:CALL INVALIDCHAR                ;show a warning
VALID:  SUB AL,'0'                      ;otherwise/then translate ASCII code to decimal digit
        MOV DX,BX                       ;OLDVALUE IS NOW IN both BX AND DX
        SHL BX,1                        ;multiply old value by 10 --> X*10 = X*8 + X*2
        SHL BX,1                        ;doing (4*X+X)*2                        
        ADD BX,DX
        SHL BX,1                        ;MUL BY 10 DONE in a fast way!
        ADD BL,AL                       ;ADD CURRENT DIGIT
        ADC BH,0                        ;this add is only to be able to detect overflow
        LOOP LIN                        ;the loop is ended after 3 chars automatically
    
ENDIN:  CMP BH,0
        JZ NOOVERFLOWIN                 ;if bh is 0, no overflow (number can be represented on a byte)
        CALL OVERFLOW                   ;else print out overflow message
NOOVERFLOWIN:XOR BH,BH                  ;return a byte into a word by zeroing higer part
        MOV [BP+4],BX			;return value saved in the stack
        
        POP DX                                        
        POP CX
        POP BX
        POP AX
        
        POP BP                                                
        RET
INPUTTOBYTE ENDP
   
;-------------------------------------------------------------------------------------------------------    

CALCMIN PROC NEAR                       ;CALCULATES MIN VALUE (UNSIGNED) OF AN ARRAY OF BYTES
        PUSH BP
        MOV BP,SP                       ;[BP+4] -> DIMENSION
        
        PUSH DX                         ;[BP+6] -> POINTER TO ARRAY
        PUSH CX                         ;[BP+8] -> RET VALUE
        PUSH BX
        PUSH AX
        PUSH SI
    
        MOV CX,[BP+4]                   ;move into counter the dimension
        MOV BX,[BP+6]                   ;move int BX the offset of array
        MOV DL,0FFH                     ;DL STORES MIN (start with largest value possible)
        XOR SI,SI
        XOR AH,AH
LMIN:   MOV AL,[BX][SI]                 ;LOAD ELEMENT FROM VETT
        CMP AL,DL                       ;compare current value with minimum
        JAE GREATER
        MOV DL,AL                       ;it is smaller: UPDATE MIN
GREATER:INC SI
        LOOP LMIN
         
        XOR DH,DH                       ;set the high part of value because the stack is made of words
        MOV [BP+8],DX                   ;STORE IN RESERVED STACK POSITION
    
        POP SI
        POP AX
        POP BX
        POP CX
        POP DX
        
        POP BP
        RET
CALCMIN ENDP

;---------------------------------------------------------------------------------------------------

OUTWORD PROC NEAR                       ;this procedure prints out a word value in decimal representation
        PUSH BP                         ; [BP+4] is the parameter
        MOV BP,SP
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        XOR CX,CX                       ;counts the digits
        MOV AX,[BP+4]                   ;VALUE to be printed
        MOV BX,10                       ;the base is stored in BX and used as a word
LCALCDIGITS:XOR DX,DX                   ;reset higher part of dividend
        DIV BX                          ;divide DX(00h):AX by BX (32 bits dividend to have result on 16 bits --> no overflow
        PUSH DX                         ;save current digit into the stack
        INC CX                          ;CX counts the digits pushed
        CMP AX,0                        ;termination test
        JZ ENDDIGITS       
        JMP LCALCDIGITS
                
ENDDIGITS:MOV AH,2                      ;print a space
        MOV DX,' '
        INT 21H


OUTDIGIT:POP DX                         ;pop a digit (stack is used to unreverse digits)
        ADD DL,'0'                      ;make it ASCII
        MOV AH,2                        ;and print out digit
        INT 21H
        LOOP OUTDIGIT                   ;for every digit pushed
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        POP BP
        RET
OUTWORD ENDP
    
    
END
