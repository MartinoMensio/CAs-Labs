;Lab 03
;Code by Martino Mensio

public _countweeks

JAN EQU 31
FEB EQU 28
FEB_L EQU 29
MAR EQU 31
APR EQU 30
MAY EQU 31
JUN EQU 30
JUL EQU 31
AUG EQU 31
SEP EQU 30
OCT EQU 31
NOV EQU 30
DECE EQU 31
YEAR_DAYS EQU 365
LEAP_YEAR_DAYS EQU 366


.model small
.stack

.data

MONTHS_OFFSET DW 0
             DW JAN
             DW JAN+FEB
             DW JAN+FEB+MAR
             DW JAN+FEB+MAR+APR
             DW JAN+FEB+MAR+APR+MAY
             DW JAN+FEB+MAR+APR+MAY+JUN
             DW JAN+FEB+MAR+APR+MAY+JUN+JUL
             DW JAN+FEB+MAR+APR+MAY+JUN+JUL+AUG
             DW JAN+FEB+MAR+APR+MAY+JUN+JUL+AUG+SEP
             DW JAN+FEB+MAR+APR+MAY+JUN+JUL+AUG+SEP+OCT
             DW JAN+FEB+MAR+APR+MAY+JUN+JUL+AUG+SEP+OCT+NOV
LEAP_MONTHS_OFFSET DW 0
             DW JAN
             DW JAN+FEB_L
             DW JAN+FEB_L+MAR
             DW JAN+FEB_L+MAR+APR
             DW JAN+FEB_L+MAR+APR+MAY
             DW JAN+FEB_L+MAR+APR+MAY+JUN
             DW JAN+FEB_L+MAR+APR+MAY+JUN+JUL
             DW JAN+FEB_L+MAR+APR+MAY+JUN+JUL+AUG
             DW JAN+FEB_L+MAR+APR+MAY+JUN+JUL+AUG+SEP
             DW JAN+FEB_L+MAR+APR+MAY+JUN+JUL+AUG+SEP+OCT
             DW JAN+FEB_L+MAR+APR+MAY+JUN+JUL+AUG+SEP+OCT+NOV

.code

_countweeks proc
        ; from 1/1/2000 to 31/12/2099 -> up to 36525 days
        ; word: up to 65536
    
    PUSH BP
    MOV BP, SP
    
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI                        ;in MASM 6.11 documentation, found that must preserve the direction flag and the values of BP, SI, DI, SS, and DS
    PUSH DI                        ;BX, CX and DX are saved but is not necessary

    
    MOV DX, [BP+4]                 ;this is the pointer to the first char of the string
    
    ;READ dd (0-31 -> byte)
    PUSH DX                        ;point to dd (string[0] and string[1])
    CALL READ_TWO_DIGITS_INT       ;procedure to read two chars into a byte (stored in a word because of stack)
    POP AX                         ;dd value
    MOV CX, AX                     ;CX = dd
    ;READ mm (1/12 -> byte)        
    ADD DX, 3                      ;point to mm (string[3] and string[4])
    PUSH DX                        
    CALL READ_TWO_DIGITS_INT       ;read mm
    POP AX
    MOV SI, AX                     ;SI = mm
    ;READ yy (0-99 -> byte)
    ADD DX, 3                      ;point to yy (string[5] and string[6])
    PUSH DX
    CALL READ_TWO_DIGITS_INT       ;read yy
    POP AX
    
    ;some checks on year
    MOV BX, AX                     ;BX = AX = yy
    ; leap year occurr every 4 years, BUT secular years are leap
    ; only if they are multiples of 400
    ; in the range 2000-2099 all the multiples of 4 are leap
    
    ;take the last 2 bits from year (to see if current year is leap)
    XOR DI, DI
    SHR BL, 1                      ;extract LSB from yy
    RCL DI, 1                      ;put it in DI
    SHR BL, 1                      ;extract LSB-1 from yy
    RCL DI, 1                      ;put it in DI
    ;now DI contains the 2 LSBs of year (if DI == 0 the current year is leap)
    
    ; calculate how many leap years have finished
    MOV BX, AX                     ;reload yy in BX
    ADD BX, 3
    SHR BL, 1
    SHR BL, 1                      ;BX = (yy-1)/4 + 1 = (yy + 3)/4 = number of leap year already finished
    XOR BH, BH                     ;just to be sure to remove junk from BH
    ;now BX contains the count of already finished leap years

    ;add the days of finished years
    ; do yy(word) * year_days(byte) -> (word) up to 36525 days
    MOV DX, YEAR_DAYS
    MUL DX                         ;AX contains result, DX = 0
    ADD AX, BX                     ;add leap year count
    
    ;add the days of preceding months in the same year
    DEC SI                         ;months are in range [1-12], pass to [0-11] 
    SHL SI, 1                      ; WORD index
    CMP DI, 0                      ;see if current year is leap
    JE LEAP_Y
    ADD AX, MONTHS_OFFSET[SI]      ;add the days of previous months of the same year
    JMP UNIFIED
LEAP_Y: ADD AX, LEAP_MONTHS_OFFSET[SI]  ;add the days..., this is a leap year

    ;add the days of this month
UNIFIED:ADD AX, CX                 ;add the day of the current month
    DEC AX                         ;remove 01/01/2000 day from count
    
    ;compute the number of weeks
    MOV CX, 7
    XOR DX, DX
    ;do double/word = word (up to 5217 weeks)
    DIV CX                         ;AX stores final result
      
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
        
    POP BP
    RET
_countweeks endp

READ_TWO_DIGITS_INT PROC NEAR
        ; params: 1) pointer to first of two char
        ; result: word
        PUSH BP
        MOV BP, SP
        
        PUSH AX
        PUSH BX
        PUSH CX
        
        XOR AX, AX
        MOV BX, [BP+4]              ;move in BX the pointer to the string
        MOV AL, [BX]                ;read first char
        SUB AL, '0'                 ;convert from ASCII to int
        SHL AL, 1                   ;|
        MOV CL, AL                  ;|
        SHL AL, 1                   ;|
        SHL AL, 1                   ;|
        ADD AL, CL                  ;-> multiply by 10 first char
        MOV CL, [BX+1]              ;read second char
        SUB CL, '0'                 ;convert from ASCII to int
        ADD AL, CL                  ;add tens to units
        
        MOV [BP+4], AX              ;result
        
        POP CX
        POP BX
        POP AX
        
        POP BP
        RET
READ_TWO_DIGITS_INT ENDP


end