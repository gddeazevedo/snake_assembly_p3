;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR EQU 0Ah
FIM_TEXTO EQU '@'
IO_READ EQU FFFFh
IO_WRITE EQU FFFEh
IO_STATUS EQU FFFDh
INITIAL_SP EQU FDFFh
CURSOR EQU FFFCh
CURSOR_INIT EQU FFFFh

LINE_SIZE EQU 80d
COL_SIZE EQU 21d

RIGHT_BORDER EQU 79d
LEFT_BORDER EQU 0d
TOP_BORDER EQU 1d
BOTTOM_BORDER EQU 20d

TIMER_UNIT EQU FFF6h
TIMER_SET EQU FFF7h
TIME_TO_UPDATE EQU 3d

ON EQU 1d
OFF EQU 0d

UP_KEY EQU 0d
RIGHT_KEY EQU 1d 
DOWN_KEY EQU 2d
LEFT_KEY EQU 3d

COL_LIMIT EQU 77d
LINE_LIMIT EQU 18d

RND_MASK EQU 8016h	; 1000 0000 0001 0110b
LSB_MASK EQU 0001h	; Mascara para testar o bit menos significativo do Random_Var
PRIME_NUMBER_1 EQU 11d
PRIME_NUMBER_2 EQU 13d

SCORE_U EQU 11d ; Unidade da pontuacao
SCORE_D EQU 10d ; Dezena da pontuacao

SNAKE_BODY_CHAR EQU '0'
FOOD EQU '*'

EMPTY_SPACE EQU ' '

SCORE_ZERO EQU '0'
SCORE_NINE EQU '9'


;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------
           ORIG    8000h
ScoreBoard STR '   Score: 00 | Aluno: Gabriel D Azevedo                                         '
Line1Map   STR '################################################################################'
Line2Map   STR '#                                                                              #'
Line3Map   STR '#                                                                              #'
Line4Map   STR '#                                                                              #'
Line5Map   STR '#                                                                              #'
Line6Map   STR '#                                                                              #'
Line7Map   STR '#                                                                              #'
Line8Map   STR '#                                                                              #'
Line9Map   STR '#                                                                              #'
Line10Map  STR '#                                     0 *                                      #'
Line11Map  STR '#                                                                              #'
Line12Map  STR '#                                                                              #'
Line13Map  STR '#                                                                              #'
Line14Map  STR '#                                                                              #'
Line15Map  STR '#                                                                              #'
Line16Map  STR '#                                                                              #'
Line17Map  STR '#                                                                              #'
Line18Map  STR '#                                                                              #'
Line19Map  STR '#                                                                              #'
Line20Map  STR '################################################################################', FIM_TEXTO

LineYouLose STR '################################## YOU LOSE ####################################', FIM_TEXTO
LineYouWin  STR '################################### YOU WIN! ###################################', FIM_TEXTO

LineLose WORD 0d
LineWin  WORD 0d


ScoreU WORD '0' ; Unidade para pontuação
ScoreD WORD '0' ; Dezena para pontuação

; Parâmetros para a rotina PrintLine
NumberLineToPrintLine  WORD 0d
CharToPrintLine        WORD 0d

; Snake inital position
SnakeHeadLine WORD 10d
SnakeHeadCol  WORD 38d

; Food initial position
FoodLine  WORD 10d
FoodCol   WORD 41d

KeyPressed WORD 1d

DequeLineArg WORD 0d
DequeColArg  WORD 0d

Random_Var  WORD  BFBCh  ; 1010 0101 1010 0101
RandomState WORD  133d

; Arguments of PrintSnake routine
NewHeadLine WORD 0d
NewHeadCol  WORD 0d

; Variables to control the deque
DequeTailAddr WORD 0d ; Stores the address of the deque tail
DequeHead WORD 0d ; Points to one position aftet the actual head
DequeTail WORD 0d ; Stores the values in the last position of the deque


;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
     ORIG FE00h
INT0 WORD OnUpKeyPressed
INT1 WORD OnRightKeyPressed
INT2 WORD OnDownKeyPressed
INT3 WORD OnLeftKeyPressed

      ORIG    FE0Fh
INT15 WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
ORIG    0000h
JMP     Main

;------------------------------------------------------------------------------------------------------------
; Rotina Timer: Checks from time to time which key the user has pressed and moves the snake to that direction
;------------------------------------------------------------------------------------------------------------
Timer: PUSH R1
	PUSH R2
	PUSH R3

	MOV R1, M[ KeyPressed ]

	CMP R1, UP_KEY
	CALL.Z MoveSnakeUp

	CMP R1, RIGHT_KEY
	CALL.Z MoveSnakeToRight

	CMP R1, DOWN_KEY
	CALL.Z MoveSnakeDown

	CMP R1, LEFT_KEY
	CALL.Z MoveSnakeToLeft


	CALL StartTimer

	POP R3
	POP R2
	POP R1
	RTI

;------------------------------------------------------------------------------
; Rotina UpdateScore: Updates the score when the snake eats a food
;------------------------------------------------------------------------------
UpdateScore: PUSH R1
	PUSH R2
	PUSH R3

	MOV R1, M[ ScoreU ]
	MOV R2, M[ ScoreD ]
	MOV R3, SCORE_NINE

	CMP R1, R3
	JMP.NZ UpdateUnity
	JMP.Z UpdateTen

	UpdateTen: MOV R1, SCORE_ZERO
		MOV M[ ScoreU ], R1
		MOV R3, SCORE_U
		MOV R2, R3
		MOV M[ CURSOR ], R2
		MOV M[ IO_WRITE ], R1

		INC M[ ScoreD ]
		MOV R1, M[ ScoreD ]
		MOV R3, SCORE_D
		MOV R2, R3
		MOV M[ CURSOR ], R2
		MOV M[ IO_WRITE ], R1
		MOV R3, SCORE_NINE
		CMP R1, R3
		JMP.Z CallPrintWin
		JMP UpdateScoreEnd

	UpdateUnity: INC M[ ScoreU ]
		MOV R1, M[ ScoreU ]
		MOV R2, SCORE_U
		MOV M[ CURSOR ], R2
		MOV M[ IO_WRITE ], R1
		JMP UpdateScoreEnd

	CallPrintWin: CALL PrintWin

	UpdateScoreEnd: POP R3
		POP R2
		POP R1
	RET

;------------------------------------------------------------------------------
; Rotina PrintWin: Prints the win screen
;------------------------------------------------------------------------------
PrintWin: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R1, LineYouWin
	MOV M[ LineWin ], R1
	MOV R4, M[ LineWin ]
	MOV R2, 0d

	PrintWinLoop: MOV R1, 12d
		MOV R3, M[ R4 ]
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV M[ IO_WRITE ], R3
		INC R2
		INC R4
		CMP R2, RIGHT_BORDER
		JMP.NZ PrintWinLoop

	PrintWinEnd: JMP PrintWinEnd
		POP R4
		POP R3
		POP R2
		POP R1

	RET


;------------------------------------------------------------------------------
; Rotina PrintLose: Print the lose screen
;------------------------------------------------------------------------------
PrintLose: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R1, LineYouLose
	MOV M[ LineLose ], R1
	MOV R4, M[ LineLose ]
	MOV R2, 0d

	PrintLoseLoop: MOV R1, 12d
		MOV R3, M[ R4 ]
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV M[ IO_WRITE ], R3
		INC R2
		INC R4
		CMP R2, RIGHT_BORDER
		JMP.NZ PrintLoseLoop

	PrintLoseEnd: JMP PrintLoseEnd
		POP R4
		POP R3
		POP R2
		POP R1

	RET

;------------------------------------------------------------------------------
; Rotina MoveSnakeToRight: Moves snake to the right
;------------------------------------------------------------------------------
MoveSnakeToRight: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R1, M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ]
	MOV R4, M[ SnakeHeadCol ]

	INC R4
	CMP R4, RIGHT_BORDER
	CALL.Z PrintLose

	MOV R1, M[ SnakeHeadLine ]
	INC M[ SnakeHeadCol ]
	MOV R2, M[ SnakeHeadCol ] 

	MOV M[ DequeLineArg ], R1
	MOV M[ DequeColArg ], R2

	CALL EraseTail
	CALL CheckSnakeCollision
	CALL PushHead
	CALL SnakeAteFood
	CALL PrintSnake

	POP R4
	POP R3
	POP R2
	POP R1

	RET

;------------------------------------------------------------------------------
; Rotina MoveSnakeToLeft: Moves the snake to the left
;------------------------------------------------------------------------------
MoveSnakeToLeft: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R4, M[ SnakeHeadCol ]

	DEC R4
	CMP R4, LEFT_BORDER
	CALL.Z PrintLose

	MOV R1, M[ SnakeHeadLine ]
	DEC M[ SnakeHeadCol ]
	MOV R2, M[ SnakeHeadCol ] 

	MOV M[ DequeLineArg ], R1
	MOV M[ DequeColArg ], R2

	CALL EraseTail
	CALL CheckSnakeCollision
	CALL PushHead
	CALL SnakeAteFood
	CALL PrintSnake

	POP R4
	POP R3
	POP R2
	POP R1

	RET

;------------------------------------------------------------------------------
; Rotina MoveSnakeUp: Moves the snake up
;------------------------------------------------------------------------------
MoveSnakeUp: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R1, M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ]
	MOV R4, M[ SnakeHeadLine ]

	DEC R4
	CMP R4, TOP_BORDER
	CALL.Z PrintLose

	MOV R1, M[ SnakeHeadLine ]
	DEC M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ] 

	MOV M[ DequeLineArg ], R1
	MOV M[ DequeColArg ], R2

	CALL EraseTail
	CALL CheckSnakeCollision
	CALL PushHead
	CALL SnakeAteFood
	CALL PrintSnake

	POP R4
	POP R3
	POP R2
	POP R1

	RET


;------------------------------------------------------------------------------
; Rotina MoveSnakeDown: Moves the snake down
;------------------------------------------------------------------------------
MoveSnakeDown: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R1, M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ]
	MOV R4, M[ SnakeHeadLine ]

	INC R4
	CMP R4, BOTTOM_BORDER
	CALL.Z PrintLose

	MOV R1, M[ SnakeHeadLine ]
	INC M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ] 

	MOV M[ DequeLineArg ], R1
	MOV M[ DequeColArg ], R2

	CALL EraseTail
	CALL CheckSnakeCollision
	CALL PushHead
	CALL SnakeAteFood
	CALL PrintSnake

	POP R4
	POP R3
	POP R2
	POP R1

	RET


;------------------------------------------------------------------------------
; Rotina OnUpKeyPressed: Sets the KeyPressed variable to be UP_KEY
;------------------------------------------------------------------------------
OnUpKeyPressed: PUSH R1
	PUSH R2

	MOV R2, M[ KeyPressed ]
	CMP R2, DOWN_KEY
	JMP.Z OnUpKeyPressedEnd

	MOV R1, UP_KEY
	MOV M[ KeyPressed ], R1

	OnUpKeyPressedEnd: POP R2
		POP R1

	RTI

;------------------------------------------------------------------------------
; Rotina OnRightKeyPressed: Sets the KeyPressed variable to be RIGHT_KEY
;------------------------------------------------------------------------------
OnRightKeyPressed: PUSH R1
	PUSH R2

	MOV R2, M[ KeyPressed ]
	CMP R2, LEFT_KEY
	JMP.Z OnRightKeyPressedEnd

	MOV R1, RIGHT_KEY
	MOV M[ KeyPressed ], R1

	OnRightKeyPressedEnd: POP R2
		POP R1
	RTI

;------------------------------------------------------------------------------
; Rotina OnDownKeyPressed: Sets the KeyPressed variable to be DOWN_KEY
;------------------------------------------------------------------------------
OnDownKeyPressed: PUSH R1
	PUSH R2

	MOV R2, M[ KeyPressed ]
	CMP R2, UP_KEY
	JMP.Z OnDownKeyPressedEnd

	MOV R1, DOWN_KEY
	MOV M[ KeyPressed ], R1

	OnDownKeyPressedEnd: POP R2
		POP R1
				
	RTI

;------------------------------------------------------------------------------
; Rotina OnLeftKeyPressed: Sets the KeyPressed variable to be LEFT_KEY
;------------------------------------------------------------------------------
OnLeftKeyPressed: PUSH R1
	PUSH R2

	MOV R2, M[ KeyPressed ]
	CMP R2, RIGHT_KEY
	JMP.Z OnLeftKeyPressedEnd

	MOV R1, LEFT_KEY
	MOV M[ KeyPressed ], R1

	OnLeftKeyPressedEnd: POP R2
		POP R1

	RTI

;--------------------------------------------------------------------------------
; Rotina CheckSnakeCollision: Checks if the snake has collided with its own body
;--------------------------------------------------------------------------------
CheckSnakeCollision: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6

	MOV R3, M[ DequeHead ] ; Contador
	MOV R4, M[ DequeTailAddr ]
	DEC R3
	DEC R3
	DEC R4

	MOV R1, M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ]

	CheckSnakeCollisionLoop: DEC R3
		CMP R3, R4
		JMP.Z CheckSnakeCollisionEnd
		MOV R5, M[ R3 ]
		DEC R3
		CMP R5, R1 ; Compara linha do corpo com a da head
		JMP.NZ CheckSnakeCollisionLoop
		MOV R6, M[ R3 ]
		CMP R6, R2 ; Compara coluna do corpo com a da head

		CALL.Z PrintLose
		JMP CheckSnakeCollisionLoop

	CheckSnakeCollisionEnd:	POP R6
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1

	RET

;---------------------------------------------------------------------------------------------------------
; Rotina SnakeAteFood: Checks if the snake ate a food and prints the food in a random position of the grid
;---------------------------------------------------------------------------------------------------------
SnakeAteFood: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5

	MOV R1, M[ FoodLine ]
	MOV R2, M[ SnakeHeadLine ]
	CMP R1, R2
	JMP.NZ SnakeDidntEat

	MOV R1, M[ FoodCol ]
	MOV R2, M[ SnakeHeadCol ]
	CMP R1, R2
	JMP.NZ SnakeDidntEat

	CALL UpdateScore

	RecalculateFoodPosition: CALL RandomV1
		INC M[ Random_Var ]
		MOV R1, M[ Random_Var ]
		MOV R2, LINE_LIMIT
		DIV R1, R2
		ADD R2, 2
		MOV M[ FoodLine ], R2

		CALL RandomV1
		INC M[ Random_Var ]
		MOV R1, M[ Random_Var ]
		MOV R2, COL_LIMIT
		DIV R1, R2
		ADD R2, 1
		MOV M[ FoodCol ], R2

		MOV R1, M[ FoodLine ]
		MOV R2, M[ FoodCol ]

		MOV R4, M[ SnakeHeadLine ]
		MOV R5, M[ SnakeHeadCol ]

		CMP R1, R4
		JMP.NZ EndIf

		CMP R2, R5
		JMP.Z RecalculateFoodPosition

	EndIf: SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV R3, FOOD
		MOV M[ IO_WRITE ], R3

	JMP SnakeAteFoodEnd

	SnakeDidntEat: CALL PopTail

	SnakeAteFoodEnd: POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		
	RET


;------------------------------------------------------------------------------
; Rotina PushHead: Inserts at the head of the deque
;------------------------------------------------------------------------------
PushHead: PUSH R1
	PUSH R2
	PUSH R3

	MOV R1, M[ DequeColArg ]
	MOV R2, M[ DequeLineArg ]
	MOV R3, M[ DequeHead ]
	MOV M[ R3 ], R1
	INC R3
	MOV M[ R3 ], R2
	INC R3
	MOV M[ DequeHead ], R3

	POP R3
	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
; Rotina PopBack: Removes the end of the deque
;------------------------------------------------------------------------------
PopTail: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6

	MOV R1, M[ DequeTailAddr ]
	MOV R2, M[ DequeTailAddr ]

	INC R1
	INC R1
	INC R1
	INC R2
	INC R2

	; MOV R3, M[ R1 ]
	; MOV R4, M[ R2 ]
	; MOV R5, M[ DequeTailAddr ]
	; MOV R5, M[ R5 ]


	PopTailLoop: CMP R2, M[ DequeHead ]
		JMP.Z EndPopTailLoop
		MOV R3, M[ R1 ]
		MOV R4, M[ R2 ]
		
		MOV R5, R1
		MOV R6, R2
		
		DEC R5
		DEC R5
		DEC R6
		DEC R6

		MOV M[ R5 ], R3
		MOV M[ R6 ], R4


		INC R1
		INC R1

		INC R2
		INC R2
		JMP PopTailLoop

	EndPopTailLoop: NOP

	DEC M[ DequeHead ]
	DEC M[ DequeHead ]

	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET


;------------------------------------------------------------------------------
; Rotina EraseTail: Erases the tail of the snake
;------------------------------------------------------------------------------
EraseTail: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R4, M[ DequeTailAddr ]
	MOV R2, M[ R4 ] ; Col
	INC R4
	MOV R1, M[ R4 ] ; Line

	SHL R1, 8d
	OR R1, R2
	MOV M[ CURSOR ], R1
	MOV R3, EMPTY_SPACE
	MOV M[ IO_WRITE ], R3

	POP R4
	POP R3
	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
; Rotina PrintLine: Print the lines of the grid
;------------------------------------------------------------------------------
PrintLine:	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV R4, M[ CharToPrintLine ] ; R4 armazena a posição inicial da string a ser printada

	PrintLineLoop1: MOV R2, 0d ; controla colunas
					
		PrintLineLoop2: MOV R1, M[ NumberLineToPrintLine ] ; Linha para printar a string
			MOV R3, M[ R4 ] ; caracter a ser printado
			SHL R1, 8d
			OR R1, R2 ; Posição do cursor
			MOV M[ CURSOR ], R1
			MOV M[ IO_WRITE ], R3
			INC R2
			INC R4
			CMP R2, LINE_SIZE
			JMP.NZ PrintLineLoop2
			MOV R1, M[ NumberLineToPrintLine ]
			INC R1
			MOV M[ NumberLineToPrintLine ], R1
			CMP R1, COL_SIZE
			JMP.NZ PrintLineLoop1

	POP R4
	POP R3
	POP R2
	POP R1
	RET


;------------------------------------------------------------------------------
; Rotina PrintMap: Prints the game grid
;------------------------------------------------------------------------------
PrintMap: PUSH R1
	MOV R1, ScoreBoard
	MOV M[ CharToPrintLine ], R1
	MOV R1, 0d
	MOV M[ NumberLineToPrintLine ], R1
	CALL PrintLine

	POP R1
	RET

;------------------------------------------------------------------------------
; Rotina PrintSnake: Prints the snake in screen
;------------------------------------------------------------------------------
PrintSnake: PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5

	MOV R4, M[ DequeHead ] ; Address where deque head points
	MOV R5, M[ DequeTailAddr ] ; Address where deque tail points

	DEC R4
	DEC R5

	PrintSnakeLoop: CMP R4, R5
		JMP.Z PrintSnakeEnd
		MOV R1, M[ R4 ] ; Value stored within the address where deque head points Line
		DEC R4
		MOV R2, M[ R4 ] ; Col
		DEC R4
		SHL R1, 8d
		OR R1, R2
		MOV M[ CURSOR ], R1
		MOV R3, SNAKE_BODY_CHAR
		MOV M[ IO_WRITE ], R3
		JMP PrintSnakeLoop

	PrintSnakeEnd: POP R5 
		POP R4
		POP R3
		POP R2
		POP R1
		
	RET



;------------------------------------------------------------------------------
; Rotina StartTimer: Init the timer
;------------------------------------------------------------------------------
StartTimer:	PUSH R1
	MOV R1, TIME_TO_UPDATE
	MOV M[ TIMER_UNIT ], R1
	MOV R1, ON
	MOV M[ TIMER_SET ], R1

	POP R1
	RET


;------------------------------------------------------------------------------
; Função: RandomV1 (versão 1)
;
; Random: Rotina que gera um valor aleatório - guardado em M[Random_Var]
; Entradas: M[Random_Var]
; Saidas:   M[Random_Var]
;------------------------------------------------------------------------------

RandomV1: PUSH	R1
	MOV	R1, LSB_MASK
	AND	R1, M[Random_Var] ; R1 = bit menos significativo de M[Random_Var]
	BR.Z	Rnd_Rotate
	MOV	R1, RND_MASK
	XOR	M[Random_Var], R1

	Rnd_Rotate:	ROR	M[Random_Var], 1	
		POP	R1
	
	RET

;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main: ENI
	MOV		R1, INITIAL_SP
	MOV		SP, R1		 		; We need to initialize the stack
	MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
	MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

	; Init snake head
	MOV R1, DequeTail
	MOV M[ DequeHead ], R1

	; Init Snake Tail
	MOV R2, DequeTail
	MOV M[ DequeTailAddr ], R2

	; Insert head in deque
	MOV R1, M[ SnakeHeadLine ]
	MOV R2, M[ SnakeHeadCol ]
	MOV M[ DequeLineArg ], R1
	MOV M[ DequeColArg ], R2
	CALL PushHead

	; Start Mapper and print the grid
	CALL StartTimer
	CALL PrintMap


Cycle: BR Cycle	
Halt: BR Halt
