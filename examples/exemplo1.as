; Programa aula1_1.as

;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
SP_INICIAL      EQU     FDFFh


;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
                ORIG    8000h
VarTexto1       STR     'LEIC !!', FIM_TEXTO
VarTexto2       STR     'Introducao a Arquitectura de Computadores', FIM_TEXTO
VarTexto3       STR     '1o Ano -  1o Semestre', FIM_TEXTO
VarMenu0        STR     '** Instrucoes para a utilizacao do programa Aula1_1.as **', FIM_TEXTO
VarMenu1        STR     'Visualizacao de uma mensagem - prima 1, 2 ou 3', FIM_TEXTO
VarMenu2        STR     'Fim de execucao - prima outra tecla', FIM_TEXTO
VarPrompt       STR     ' > ', FIM_TEXTO
TextoFim        STR     'Fim de execucao!', FIM_TEXTO
VarPalavra      WORD    1234h
Dummy           TAB     1


;------------------------------------------------------------------------------
; ZONA III: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas

                ORIG    0000h
                JMP     Inicio


; LeCar: Rotina que efectua a leitura de um caracter proveniente do teclado.
;               Entradas: ---
;               Saidas: R1 - caracter lido
;               Efeitos: alteracao do registo R1

LeCar:          CMP     R0, M[IO_STATUS]
                BR.Z    LeCar
                MOV     R1, M[IO_READ]
                RET


; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;       O caracter pode ser visualizado na janela de texto.
;               Entradas: pilha - caracter a escrever
;               Saidas: ---
;                       Efeitos: alteracao do registo R1
;                       alteracao da posicao de memoria M[IO]

EscCar:         MOV     R1, M[SP+2]
                MOV     M[IO_WRITE], R1
                RETN    1


; MudaLinha: Rotina que efectua a escrita de um caracter de mudanca de linha.
;               Entradas: ---
;               Saidas: ---
;               Efeitos: ---

MudaLinha:      PUSH    R1
                PUSH    CR
                CALL    EscCar
                POP     R1
                RET


; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;          pelo caracter FIM_TEXTO. Pode-se definir como terminador qualquer
;          caracter ASCII.
;               Entradas: R2 - apontador para o inicio da cadeia de caracteres
;               Saidas: ---
;               Efeitos: ---

EscString:      PUSH    R1
                PUSH    R2
Ciclo:          MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                PUSH    R1
                CALL    EscCar
                INC     R2
                BR      Ciclo
FimEsc:         CALL    MudaLinha
                POP     R2
                POP     R1
                RET

; EscMenu: Rotina que efectua a escrita do menu que contem as instrucoes de
;        utilizacao do programa.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
EscMenu:        PUSH    R2
                CALL    MudaLinha
                CALL    MudaLinha
                MOV     R2, VarMenu0
                CALL    EscString
                CALL    MudaLinha
                MOV     R2, VarMenu1
                CALL    EscString
                MOV     R2, VarMenu2
                CALL    EscString
                CALL    MudaLinha
                POP     R2
                RET

; EscPrompt: Rotina que efectua a escrita do prompt, que indica o inicio da
;          leitura
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
EscPrompt:      PUSH    R2
                CALL    MudaLinha
                MOV     R2, VarPrompt
                CALL    EscString
                POP     R2
                RET


; ProgramaPrincipal: programa que recebe um caracter do teclado e, de acordo
;       com o caracter recebido (1, 2 ou 3), imprime uma
;       de tres mensagens. Caso receba um caracter diferente,
;       termina a execucao.

Inicio:         MOV     R7, SP_INICIAL
                MOV     SP, R7
                CALL    EscMenu
Opcao:          CALL    EscPrompt
                CALL    LeCar
                CALL    MudaLinha
                CMP     R1, '1'
                BR.Z    Texto1
                CMP     R1, '2'
                BR.Z    Texto2
                CMP     R1, '3'
                BR.NZ   EscFim
Texto3:         MOV     R2, VarTexto3
                CALL    EscString
                BR      Opcao
Texto2:         MOV     R2, VarTexto2
                CALL    EscString
                BR      Opcao
Texto1:         MOV     R2, VarTexto1
                CALL    EscString
                BR      Opcao
EscFim:         MOV     R2, TextoFim
                CALL    EscString
Halt:           BR      Halt
