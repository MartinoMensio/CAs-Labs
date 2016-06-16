; LAB 02
; Code by Martino Mensio

NMAX EQU 51             ; last position is for the carriage return (0Dh)
NMIN EQU 20             ; must be lower than 255
NCHAR EQU 52  
K EQU 26

.MODEL SMALL
.STACK
.DATA

FIRST_ROW_HEAD  DB NMAX, ?                      ; the buffer header
FIRST_ROW       DB NMAX DUP(?)                  ; where the array of chars will be stored
SECOND_ROW_HEAD DB NMAX, ?
SECOND_ROW      DB NMAX DUP(?)
THIRD_ROW_HEAD  DB NMAX, ?
THIRD_ROW       DB NMAX DUP(?)
FOURTH_ROW_HEAD DB NMAX, ?
FOURTH_ROW      DB NMAX DUP(?)

COUNTVETT1       DB NCHAR DUP (?)               ; each char can appear at most 50 times per row --> byte
COUNTVETT2       DB NCHAR DUP (?)
COUNTVETT3       DB NCHAR DUP (?)
COUNTVETT4       DB NCHAR DUP (?)
COUNTTOTAL       DB NCHAR DUP (?)               ; totally max repetition is 50*4 = 200 --> fits in a byte

ERROR_MSG       DB 10,13,'Too short string. Minimum 20 chars! Please$'
MSG_PRINT       DB 10,13,'Printing chars..',10,13,'$'
INPUT_MSG       DB 10,13,'Insert a string (between 20 and 50 chars):',10,13,'$'
MAX_MSG         DB 10,13,'Calculating and printing max among four rows:   $'
CAES_MSG        DB 10,13,'Caesar CIPHER:',10,13,'$'
GONEWLINE       DB 10,13,'$'

.CODE
.STARTUP

;------------------------------------------------
;1) Write the Assembly code required to get text by means of calls to INT 21H
; if the string is too short (less than NMIN) the user is asked to repeat input

READ_FIRST: MOV DX, NMIN                        ; prepare first parameter (min length)
    PUSH DX
    LEA DX, FIRST_ROW_HEAD                      ; prepare second parameter (location of buffer)
    PUSH DX
    CALL READROW                                ; call the procedure to read a row
    POP DX
    POP DX                                      ; read return value (0/1)
    CMP DX, 0                                   ; if it is 0, read was ok
    JE READ_SECOND                              ; and go to second row
    LEA DX, ERROR_MSG                           ; if it is not 0, print an error message
    MOV AH, 9
    INT 21H
    JMP READ_FIRST                              ; and ask again for valid input
    
READ_SECOND: MOV DX, NMIN                       ; first parameter (as above)
    PUSH DX
    LEA DX, SECOND_ROW_HEAD                     ; second parameter (as above)
    PUSH DX
    CALL READROW                                ; call (as above)
    POP DX
    POP DX                                      ; read return value (as above)
    CMP DX, 0
    JE READ_THIRD
    LEA DX, ERROR_MSG
    MOV AH, 9
    INT 21H
    JMP READ_SECOND
    
READ_THIRD: MOV DX, NMIN                        ; the same for the third row
    PUSH DX
    LEA DX, THIRD_ROW_HEAD
    PUSH DX
    CALL READROW
    POP DX
    POP DX
    CMP DX, 0
    JE READ_FOURTH
    LEA DX, ERROR_MSG
    MOV AH, 9
    INT 21H
    JMP READ_THIRD
                                                
READ_FOURTH: MOV DX, NMIN                       ; and for the fourth
    PUSH DX
    LEA DX, FOURTH_ROW_HEAD
    PUSH DX
    CALL READROW
    POP DX
    POP DX
    CMP DX, 0
    JE READ_ENDED
    LEA DX, ERROR_MSG
    MOV AH, 9
    INT 21H
    JMP READ_FOURTH

READ_ENDED: NOP
;------------------------------------------------
;2) For each row it is required to count the number of times each character appears
; (desired characters are only a..z, A...Z), printing, for each row,
; the character that appears a number of times equal to half the maximum times.
; If more than one character appears for the same number of times, it is required to print all of them
    LEA AX, FIRST_ROW                           ; first parameter is the array of chars
    PUSH AX
    XOR AH,AH
    MOV AL, FIRST_ROW_HEAD+1                    ; second parameter is the length of the array
    PUSH AX
    LEA AX, COUNTVETT1                          ; third parameter is the array counting char occurencies
    PUSH AX
    CALL COUNTCHAR_PRINT                        ; call a procedure that does everything
    POP AX
    POP AX
    POP AX
    
    LEA AX, SECOND_ROW                          ; same thing for the second row
    PUSH AX
    XOR AH,AH
    MOV AL, SECOND_ROW_HEAD+1
    PUSH AX
    LEA AX, COUNTVETT2
    PUSH AX
    CALL COUNTCHAR_PRINT
    POP AX
    POP AX
    POP AX
                                                ; for the third
    LEA AX, THIRD_ROW
    PUSH AX
    XOR AH,AH
    MOV AL, THIRD_ROW_HEAD+1
    PUSH AX
    LEA AX, COUNTVETT3
    PUSH AX
    CALL COUNTCHAR_PRINT
    POP AX
    POP AX
    POP AX
    
    LEA AX, FOURTH_ROW                          ; and for the last row
    PUSH AX
    XOR AH,AH
    MOV AL, FOURTH_ROW_HEAD+1
    PUSH AX
    LEA AX, COUNTVETT4
    PUSH AX
    CALL COUNTCHAR_PRINT
    POP AX
    POP AX
    POP AX
    
;---------------------------------------------------
;3) Print the character that appears more times given all the four rows together

; sum up the counts of the first two counting arrays
    LEA AX, COUNTVETT1                         ; the offset of the first counting array
    LEA BX, COUNTVETT2                         ; the offset of the second counting array
    MOV CX, NCHAR                              ; the length of the arrays to be summed
    LEA DX, COUNTTOTAL                         ; the destination array
    PUSH AX                                    ; push parameters
    PUSH BX
    PUSH CX
    PUSH DX
    CALL ADDARRAYS                             ; call procedure to sum up
    POP AX
    POP AX
    POP AX
    POP AX

; now sum up the previous result with the third counting array    
    LEA AX, COUNTTOTAL
    LEA BX, COUNTVETT3
    MOV CX, NCHAR
    LEA DX, COUNTTOTAL
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CALL ADDARRAYS
    POP AX
    POP AX
    POP AX
    POP AX

; and now the previous result with the last counting array    
    LEA AX, COUNTTOTAL
    LEA BX, COUNTVETT4
    MOV CX, NCHAR 
    LEA DX, COUNTTOTAL
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    CALL ADDARRAYS
    POP AX
    POP AX
    POP AX
    POP AX

; finally use a procedure to find the chars that appear the max number of times    
    LEA AX, COUNTTOTAL                          ; provide to the procedure the total count array
    PUSH AX
    CALL PRINTCHARMAX                           ; and call it
    POP AX

;-----------------------------------------------------
;4) Finally, print the text using a Caesar cipher, applied only to a..z and A..Z characters of each row
    LEA DX, CAES_MSG                            ; output some text
    MOV AH, 9
    INT 21H
    LEA AX, FIRST_ROW                           ; first parameter: the array of chars
    PUSH AX
    MOV AL, FIRST_ROW_HEAD+1                    ; second parameter: the array length
    XOR AH, AH
    PUSH AX
    MOV AX, K                                   ; third parameter: K = translation number
    PUSH AX
    CALL CAESARCIPHER
    POP AX
    POP AX
    POP AX
    
    LEA DX, GONEWLINE                           ; some output "prettify"
    MOV AH, 9
    INT 21H
    
    LEA AX, SECOND_ROW                          ; same for second row
    PUSH AX
    MOV AL, SECOND_ROW_HEAD+1
    XOR AH, AH
    PUSH AX
    MOV AX, K+1                                 ; pass K+1 to second row 
    PUSH AX
    CALL CAESARCIPHER
    POP AX
    POP AX
    POP AX
    
    LEA DX, GONEWLINE                           ; same for third row
    MOV AH, 9
    INT 21H
    
    LEA AX, THIRD_ROW
    PUSH AX
    MOV AL, THIRD_ROW_HEAD+1
    XOR AH, AH
    PUSH AX
    MOV AX, K+2                                 ; pass K+2
    PUSH AX
    CALL CAESARCIPHER
    POP AX
    POP AX
    POP AX
    
    LEA DX, GONEWLINE
    MOV AH, 9
    INT 21H
    
    LEA AX, FOURTH_ROW                          ; same for last row
    PUSH AX
    MOV AL, FOURTH_ROW_HEAD+1
    XOR AH, AH
    PUSH AX
    MOV AX, K+3                                 ; pass K+3
    PUSH AX
    CALL CAESARCIPHER
    POP AX
    POP AX
    POP AX
    

    .EXIT
    
 



;---------------------------------------------------------------------------------------  
; procedure to read a row   
READROW PROC NEAR
    ;params: 1 (BP+6) -> minimum length
    ;        2 (BP+4) -> offset of buffer to be read: first byte already filled with max char number
    ;return: (BP+6) 0 if read was ok, 1 if too short           
    
    PUSH BP                             ; save BP
    MOV BP,SP                           
    PUSH AX                             ; save some registers
    PUSH BX
    PUSH CX
    PUSH DX
    
    LEA DX, INPUT_MSG                   ; some string output
    MOV AH,9
    INT 21H
    
    MOV DX, [BP+4]                      ; move the offset of the buffer into DX
    MOV AH,10                           
    INT 21H                             ; interrupt to read buffer
    MOV BX,DX                           ; copy the buffer offset in BX (for accessing memory) 
    MOV AL, [BX+1]                      ; in the second byte of buffer: how may chars have been read
    MOV CX, [BP+6]                      ; minimum length now in CL (CH is 0 because of buffer limit)
    CMP AL, CL                          ; compare nchar read with minimum length
    JB ERROR_READROW                    ; if lower, error
    MOV DX, 0                           ; DX will be return value (0 = ok)
    JMP END_READROW                     ; go to end
ERROR_READROW: MOV DX, 1                ; return value = 1 = error (too short)                     ; 
END_READROW: MOV [BP+6], DX             ; save the return value in the stack
    POP DX
    POP CX
    POP BX
    POP AX
    
    POP BP
    RET
READROW ENDP


;-----------------------------------------------------------------------------------------------
; this procedure counts the occurrencies of chars A-Za-z (26)
; and prints the chars that appears a number of times equal to half the maximum times
; in case maximum times is odd (e.g. 7), the print is done for FLOOR(n/2) (e.g. 3) 
COUNTCHAR_PRINT PROC NEAR
    ;params: 1 (BP+8) -> offset of array (bytes)
    ;        2 (BP+6) -> number of characters in the array
    ;        3 (BP+4) -> counting array for A-Za-z
    PUSH BP
    MOV BP,SP
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    LEA DX, MSG_PRINT                   ; print message
    MOV AH,9
    INT 21H
    
    MOV SI, [BP+8]                      ; SI used for scanning array (bytes)
    MOV BX, [BP+4]                      ; BX used for the counting array
    
    XOR AH, AH                          ; AX will contain in AL the index to access the counting array, in AH 00H
    XOR DX, DX                          ; DH for max repetition, DL for current char repetition
    XOR DI, DI
    
    MOV CX, NCHAR                       ; initialize loop counter with number of chars to count (52)
RESET_L: MOV [BX+DI], DL                ; zeroing the counting array
    INC DI
    LOOP RESET_L
    
    MOV CX, [BP+6]                      ; initialize the loop counter with number of characters read in the buffer
COUNT_L: MOV AL, [SI]                   ; retrieve current character
    CMP AL, 'z'                         ; compare with the greatest valid ASCII code
    JA NEXT_CHAR                        ; if above, skip to next char
    CMP AL, 'A'                         ; compare with the lowest valid ASCII code
    JB NEXT_CHAR                        ; if below, skip to next char
    CMP AL, 'Z'                         ; compare with the last capital letter
    JBE ZIPPED                          ; if is not greater, no need to remove the unused char space
    CMP AL, 'a'                         ; compare to see if is lowercase letter
    JB NEXT_CHAR                        ; if not, this is an invalid char (between 'Z' and 'a')
    SUB AL, 'a'-'Z'-1                   ; remove the unused space between 'Z' and 'a'
ZIPPED: SUB AL, 'A'                     ; transform in a index ('A'=0,...'Z'=25,'a'=26,...'z'=51)
    MOV DI, AX                          ; move in DI to be able to use as index
    MOV DL, [BX+DI]                     ; read the count for this letter
    INC DL
    MOV [BX+DI], DL                     ; update count
    CMP DL,DH                           ; compare with current max (DH)
    JBE NOTNEWMAX                       
    MOV DH,DL                           ; update new max if it is greater
NOTNEWMAX: NOP
     
NEXT_CHAR: INC SI
    LOOP COUNT_L    

; end of counting, now let's check and print

    SHR DH,1                            ; half the max repetition count
    CMP DH,0
    JE ENDPRINT                         ; avoid printing chars that don't appear (in the case max = 1 or max = 0)

    MOV CX, NCHAR                       ; reinitialize loop counter to scan the counting array (52)
    MOV BX, [BP+4]                      ; the counting array offset is retrieved
    XOR SI, SI                  
CHECK_L: MOV DL, [BX+SI]                ; load count for current char
    CMP DL,DH                           ; compare with the wanted number of repetitions
    JNE NOTCORRECT                      ; if different, go ahead
    MOV AX, SI                          ; copy the current index used to access the counting array
    CMP AL, 'Z'-'A'                     ; check if is uppercase or lowercase
    JBE UNZIPPED                        ; if uppercase skip next instruction
    ADD AL, 'a'-'Z'-1                   ; if is lowercase, add this value to restore the unused space between 'Z' and 'a'
UNZIPPED: ADD AL, 'A'                   ; converto to ASCII
    MOV DL, AL                          ; put in register to output
    MOV AH, 2
    INT 21H                             ; print char
NOTCORRECT: INC SI                      
    LOOP CHECK_L
    
ENDPRINT: NOP   
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    POP BP
    RET
COUNTCHAR_PRINT ENDP


;---------------------------------------------------------------------------------------------
; procedure to sum up two arrays in a destination array
ADDARRAYS PROC NEAR
    ;params: 1 (BP+10) -> first array offset (byte ptr)
    ;        2 (BP+8) -> second array offset (byte ptr)
    ;        3 (BP+6) -> dimension
    ;        4 (BP+4) -> destination array offset (byte ptr)
    PUSH BP
    MOV BP, SP
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV SI, [BP+10]                     ; SI used for the first source array
    MOV DI, [BP+8]                      ; DI used for the second source array
    MOV BX, [BP+4]                      ; BX used for destination array
    MOV CX, [BP+6]                      ; CX for loop counting
    
ADD_L: MOV AL, [SI]                     ; get a byte from first array
    ADD AL, [DI]                        ; add with the corresponding byte from second array
    MOV [BX], AL                        ; store result in the destination array
    INC SI                              ; update pointers
    INC DI
    INC BX
    LOOP ADD_L
    
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    
    POP BP    
    RET
ADDARRAYS ENDP
    
;----------------------------------------------------------------------------------
; this procedure receives an array of bytes, finds the maximum value and the corresponding indexes.
; Assumnig a mapping between array index and ASCII characters
; 0->'A', 1->'B', ..., 25->'Z', 26->'a', ..., 51->'z'
; converts the indexes found before in the corresponding ASCII and prints them out  
PRINTCHARMAX PROC NEAR
    ;params: 1 (BP+4) -> array with dimension = NCHAR = 52 = 26*2
    PUSH BP
    MOV BP, SP
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA DX, MAX_MSG                     ; print out some text
    MOV AH, 9
    INT 21H
    
    MOV BX, [BP+4]                      ; the counting array
    XOR SI, SI
    MOV CX, NCHAR                       ; init CX
    XOR DH, DH                          ; and reset some registers (DH for max)
    XOR DI, DI
    ; loop to find max value
MAX_L: MOV DL, [BX + SI]                ; load the current value in DL
    CMP DL, DH                          ; compare with max
    JBE NOTNEWMAX2
    MOV DH, DL                          ; update the max
NOTNEWMAX2: INC SI
    LOOP MAX_L
    
    XOR AX, AX                          ; count how many chars to print (in draw case)
    MOV CX, NCHAR
    XOR SI, SI
    ;loop to pick chars to be printed (those who appear max times)
FINDM: MOV DL, [BX+SI]                  ; load the current value in DL
    CMP DL, DH                          ; compare with max
    JB NOTMAX
    PUSH SI                             ; this char must be printed. Instead of printing it now,
                                        ; I store it in the stack and will print later
                                        ; only because i am running out of registers
                                        ; and don't want to accidentally overwrite some of them
                                        ; during doing INT 21H
    INC AX                              ; i must remember that I stored another char
NOTMAX: INC SI
    LOOP FINDM
    
    MOV CX, AX                          ; init counter to pop the appropriate number of chars
PRINTMAX: POP DX                        ; copy the current index used to access the counting array
    CMP DL, 'Z'-'A'                     ; check if is "uppercase" or "lowercase"
    JBE UNZIPPED2
    ADD DL, 'a'-'Z'-1                   ; if is lowercase, add this value to restore the unused space between 'Z' and 'a'
UNZIPPED2: ADD DL, 'A'                  ; converto to ASCII
    MOV AH, 2
    INT 21H
    LOOP PRINTMAX
    
    
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    POP BP
    RET
PRINTCHARMAX ENDP


;-----------------------------------------------------------------------------------------
; this procedure applies a caesar cipher to an array of chars. The cipher is applied only
; to chars A-Za-z

CAESARCIPHER PROC NEAR
    ;params: 1 (BP+8) -> array offset (byte ptr)
    ;        2 (BP+6) -> dimension
    ;        3 (BP+4) -> shift number
    PUSH BP
    MOV BP, SP
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    
    
    MOV SI, [BP+8]                      ; SI for accessing the array
    MOV CX, [BP+6]                      ; CX counts down the loop
    MOV DI, [BP+4]                      ; DI is the number of shifts
    MOV BX, NCHAR
CAES_L: XOR AH, AH
    MOV AL, [SI]                        ; retrieve current character
    CMP AL, 'z'                         ; compare with the greatest valid ASCII code
    JA CAES_PRINT                       ; if above, skip to next char
    CMP AL, 'A'                         ; compare with the lowest valid ASCII code
    JB CAES_PRINT                       ; if below, skip to next char
    CMP AL, 'Z'                         ; compare with the last capital letter
    JBE ZIPPED3                         ; if is not greater, no need to remove the unused char space
    CMP AL, 'a'                         ; compare to see if is lowercase letter
    JB CAES_PRINT                       ; if not, this is an invalid char (between 'Z' and 'a')
    SUB AL, 'a'-'Z'-1                   ; remove the unused space between 'Z' and 'a'
ZIPPED3: SUB AL, 'A'                    ; convert to range 0-51
    ADD AX, DI                          ; can use k very big: can do a lot of complete tours around the alphabet
    DIV BL                              ; THE RESIDUAL of div 52 is needed to be sure to be in range 0-51
                                        ; the residual is in AH
    CMP AH, 'Z'-'A'                     ; check if is uppercase or lowercase
    JBE UNZIPPED3
    ADD AH, 'a'-'Z'-1                   ; if is lowercase, add this value to restore the unused space between 'Z' and 'a'    
UNZIPPED3: ADD AH, 'A'                  ; convert to ASCII
    MOV AL, AH
CAES_PRINT: MOV DL, AL                  ; move to output register
    MOV AH, 2
    INT 21H                             ; and print this char
    INC SI
    LOOP CAES_L

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    
    POP BP
    RET
CAESARCIPHER ENDP

END
