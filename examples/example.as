CR              EQU     0Ah
FIM_TEXTO       EQU     '!'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d
LINE_SIZE		EQU     80d
COLUMN_SIZE     EQU     23d

                ORIG    8000h
Line1Map		STR     ' SCORE: 00                       |Record:00             |Vidas:0                '
Line2Map		STR		'________________________________________________________________________________'
Line3Map		STR		'                                                                                '
Line4Map		STR		'  ############################################################################  '
Line5Map		STR		'  #                                                                          #  '
Line6Map		STR		'  #                                                                          #  '
Line7Map		STR		'  #                                                                          #  '
Line8Map		STR		'  #                                                                          #  '
Line9Map		STR		'  #                                                                          #  '
Line10Map		STR		'  #                                                                          #  '
Line11Map		STR		'  #                                                                          #  '
Line12Map		STR		'  #                                                                          #  '
Line13Map		STR		'  #                                                                          #  '
Line14Map		STR		'  #                                                                          #  '
Line15Map		STR		'  #                                                                          #  '
Line16Map		STR		'  #                                                                          #  '
Line17Map		STR		'  #                                                                          #  '
Line18Map		STR		'  #                                                                          #  '
Line19Map		STR		'  #                                                                          #  '
Line20Map		STR		'  #                                                                          #  '
Line21Map		STR		'  #                                                                          #  '
Line22Map		STR		'  #                                                                          #  '
Line23Map		STR		'  ############################################################################  ', FIM_TEXTO

PrintLineMapLine WORD 0d
PrintLineMapLineNumber WORD 0d




				ORIG    0000h
                JMP     Main
;----------------------------------------------------------------
; Rotina: EsqueletoRotina                                          
;----------------------------------------------------------------
EsqueletoRotina: PUSH R1
				 PUSH R2
				 PUSH R3

				 POP R3
				 POP R2
				 POP R1

				 RET

;----------------------------------------------------------------
; Rotina: PrintLineMap                                          
;----------------------------------------------------------------
PrintLineMap:   PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				MOV R4, M[ PrintLineMapLine ] ;endereço inicio str

CicloPrintLineMap:MOV R2, 0d ; coluna

CicloPrintColMap: MOV R1, M[ PrintLineMapLineNumber ] ; linha

				MOV R3, M[ R4 ] ;r3 agr guarda o caracter a ser printado
				SHL R1, 8d
				OR  R1, R2 ;posiçao do cursor 
				MOV M[ CURSOR ], R1
				MOV M[ IO_WRITE ], R3
				INC R2
				INC R4
				CMP R2, LINE_SIZE
				JMP.NZ CicloPrintColMap 
				MOV R1, M[ PrintLineMapLineNumber ] ;incrementa a linha
				INC R1
				MOV M[ PrintLineMapLineNumber ], R1
				CMP R1, COLUMN_SIZE
				JMP.NZ CicloPrintLineMap ;volta pro primeiro loop

				POP R4
				POP R3
				POP R2
				POP R1

				RET

;----------------------------------------------------------------
; Rotina: PrintMap                                          
;----------------------------------------------------------------
PrintMap: PUSH R1
		  PUSH R2
		  PUSH R3

		  MOV  R1, Line1Map 
		  MOV  M[ PrintLineMapLine ], R1
		  MOV  R1, 0d
   		  MOV  M[ PrintLineMapLineNumber ], R1
		  CALL PrintLineMap

		  POP R3
		  POP R2
		  POP R1

		  RET

Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

				CALL PrintMap


				

Cycle: 			BR		Cycle	
Halt:           BR		Halt



