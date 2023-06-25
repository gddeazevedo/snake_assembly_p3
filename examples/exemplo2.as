; Programa aula1_2.as

LetraA          EQU     'A'     ; caracter ASCII
ConstUmByte     EQU     0fh     ; hexadecimal
ConstUmaWord    EQU     65535   ; decimal

                ORIG    8000h
VarUmByte       WORD    12h
VarOutroByte    WORD    0fh
VarUmaWord      WORD    1234h
VarUmaString    STR     'Arquitectura de Computadores'

                ORIG    0000h
Inicio:         MOV     R0, LetraA
                MOV     R1, ConstUmByte
                MOV     R2, ConstUmaWord
                MOV     R3, R2
                MOV     R4, M[R1+VarOutroByte]
                MOV     R5, M[VarOutroByte]
                MOV     R6, M[SP] 
                MOV     R7, M[PC+ConstUmByte] 

; Aqui devera' colocar o seu codigo
Halt:           BR      Halt
