
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								        ;
; 			Arquitetura de Computadores - MEEC	        ;
;								        ;
; 	FILE:    lab04.as					        ;
; 	VERSION: 1.0						        ;
; 	AUTHORS:  David Carvalho - 78469, Leonor Fermoselle - 78493     ;
;								        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;Constantes;;;;;;;;;

;Portos de I/O
DISP7S1         EQU     FFF0h
DISP7S2         EQU     FFF1h
DISP7S3         EQU     FFF2h
DISP7S4         EQU     FFF3h
LCD_CURSOR	EQU	FFF4h	
LCD_WRITE	EQU	FFF5h
COUNT_TIMER	EQU	FFF6h
PAUSE_TIMER	EQU	FFF7h
LEDS            EQU     FFF8h
INTERRUPTORES   EQU     FFF9h
INT_MASK_ADDR   EQU     FFFAh
IO_CURSOR       EQU     FFFCh
IO_CHECK	EQU	FFFDh
IO_WRITE        EQU     FFFEh
IO_READ        	EQU     FFFFh

;Stack pointer inicial
SP_INICIAL      EQU     FDFFh

;Constantes para as interrupções
TABLE_INT	EQU	FE00h
INT_MASK	EQU     1000010000000001b

;Declaração de Constante utilizadas para escrever na janela de texto
LIMPAR_JANELA   EQU     FFFFh
FIM_TEXTO       EQU     '$'

XY_GAMEOVER	EQU     0416h
XY_TEXTO	EQU     0614h

XY_LINHA1	EQU     0000h
XY_LINHA2	EQU     1700h
XY_COLUNA1	EQU	0100h
XY_COLUNA2	EQU	014Fh	

XY_INIC_COBRA	EQU     0B27h

MASC_COMIDA	EQU	1001110000010110b

;Origem
                ORIG    8000h




;;;;;;;;;Memória;;;;;;;;;

;Declaração de Strings utilizadas para escrever na janela de texto
vartexto1       STR     'Prima I0 para iniciar o jogo',FIM_TEXTO
vartexto2       STR     'GAME OVER',FIM_TEXTO
vartexto3       STR     'YOU WON',FIM_TEXTO
car_hifen	STR     '-'
car_barra	STR     '|'
car_comida	STR     '@',FIM_TEXTO
car_corpo	STR     'O',FIM_TEXTO
car_espaco	STR     ' ',FIM_TEXTO

FLAG_I0		TAB	1
FLAG_IA		TAB	1
FLAG_TIMER	TAB	1

posicao_cobra	TAB	10
comp_cobra	WORD	2

incremento	TAB	1
gameover	WORD	0
youwon		WORD	0

tempo		WORD	0
tempo_passou	WORD	0



XY_comida	WORD    1001110000010110b


;;;;;;;;;Codigo;;;;;;;;;
		ORIG    0000h
                JMP     Inicio




;;;;;;;;;Rotinas;;;;;;;;;

;===============================================================================
; Delay_timer: Rotina que permite gerar um atraso com base no temporizador
;               Entradas: ---
;               Saidas: ---
;               Efeitos: ---
;===============================================================================


Delay_timer:	PUSH	R1
		PUSH	R2
		MOV	R2, M[tempo]
		MOV	R1, 0001h
Loop_tempo:	MOV	M[COUNT_TIMER], R1
		MOV	M[PAUSE_TIMER], R1
Loop_timer:	CMP	M[FLAG_TIMER], R1
		BR.NZ	Loop_timer
		MOV	M[FLAG_TIMER], R0
		DEC	R2
		BR.NZ	Loop_tempo

		POP	R2
		POP	R1
		RET




;===============================================================================
; Aleat_Comida: Rotina que faz a cobra virar à direita.
;                Entradas: --
;                Saidas: ---
;                Efeitos: ---
;===============================================================================		



Aleat_Comida:	PUSH 	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4

		MOV 	R1, M[XY_comida]
		MOV	R2, R1
		AND	R2, 0001h		;Vẽ se o ultimo bit de Ni é 0 ou 1
		CMP	R2, R0
		BR.Z	rot_right

rot_right_XOR: 	MOV 	R2, M[MASC_COMIDA]	;No caso de o último bit ser 1
		XOR	R1, R2
		ROR	R1, 1
		BR	verif_limites

rot_right:	ROR	R1, 1			;No caso de o último bit ser 0

		MOV	R4, R1
		
verif_limites:	MOV	R3, 004Dh
		MUL	R3, R1			;xx


		MOV	R2, R4
		AND	R2, 0001h		;Vẽ se o ultimo bit de Ni é 0 ou 1
		CMP	R2, R0
		BR.Z	rot_right_2

		MOV 	R2, M[MASC_COMIDA]	;No caso de o último bit ser 1
		XOR	R1, R2
		ROR	R1, 1
		BR	verif_limites_2

rot_right_2:	ROR	R1, 1			;No caso de o último bit ser 0


verif_limites_2:MOV	R2, 0015h
		MUL	R2, R1			;yy

		INC	R3
		
		INC	R2
		SHL	R2, 8

	
		ADD	R2, R3

		MOV 	M[XY_comida], R2

		POP	R4
		POP 	R3	
		POP 	R2
		POP	R1
		RET	

;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

LimpaJanela:    PUSH 	R1
                MOV     R1, LIMPAR_JANELA
		MOV     M[IO_CURSOR], R1
                POP 	R1
                RET


;===============================================================================
; Inic_perif: Rotina que inicializa os periféricos.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Inic_perif:	PUSH	R1	
		MOV	M[DISP7S1], R0
		MOV	M[DISP7S2], R0
		MOV	M[DISP7S3], R0
		MOV	M[LEDS], R0
		MOV 	R1, 1000000000100000b 	; Activa e limpa o LCD

		MOV 	R1, 1000000000000001b 	; Linha 0, Coluna 1
		MOV 	M[LCD_CURSOR], R1		
		MOV	R2, '0'
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV 	R1, 1000000000000110b 	; Linha 0, Coluna 6
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV 	R1, 1000000000000111b 	; Linha 0, Coluna 7
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter		
		MOV	R2, 'm'
		MOV 	R1, 1000000000000010b 	; Linha 0, Coluna 2
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV	R2, 'i'
		MOV 	R1, 1000000000000011b 	; Linha 0, Coluna 3
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV	R2, 'n'
		MOV 	R1, 1000000000000100b 	; Linha 0, Coluna 4
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV	R2, 's'
		MOV 	R1, 1000000000001000b 	; Linha 0, Coluna 8
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV	R2, 'e'
		MOV 	R1, 1000000000001001b 	; Linha 0, Coluna 8
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter
		MOV	R2, 'g'
		MOV 	R1, 1000000000001010b 	; Linha 0, Coluna 8
		MOV 	M[LCD_CURSOR], R1
		MOV 	M[LCD_WRITE], R2 	; Escreve caracter

		MOV 	M[LCD_CURSOR], R1
		POP	R1
		RET


;===============================================================================
; Pontos_7s: Rotina que escreve os pontos no Display de 7 segmentos.
;               Entradas: --
;               Saidas: --
;               Efeitos: ---
;===============================================================================
	       
Pontos_7s:     	PUSH	R1
		PUSH	R2			
		MOV	R1, M[comp_cobra]
		MOV	R2, 2
		DIV	R1, R2
		MOV 	M[DISP7S3], R1
		POP	R2
		POP	R1
                RET

;===============================================================================
; EscLeds: Rotina que liga as luzes dos leds.
;               Entradas: 
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
	       
EscLeds:      	PUSH 	R1
		PUSH	R2
		MOV	R1, M[comp_cobra]
		MOV	R2, 2
		DIV	R1, R2
		CMP 	R1, 1
		BR.Z	Led1
		CMP 	R1, 2
		BR.Z	Led2
		CMP 	R1, 3
		BR.Z	Led3
		CMP 	R1, 4
		BR.Z	Led4
		CMP 	R1, 5
		BR.Z	Led5
		BR 	End_EscLeds
Led1:		MOV 	R1, 0000000000000001b
		MOV 	M[LEDS], R1
		BR 	End_EscLeds
Led2:		MOV	R1, 0000000000000011b
		MOV 	M[LEDS], R1
		BR 	End_EscLeds
Led3:		MOV	R1, 0000000000000111b
		MOV 	M[LEDS], R1
		BR 	End_EscLeds
Led4:		MOV	R1, 0000000000001111b
		MOV 	M[LEDS], R1
		BR 	End_EscLeds
Led5:		MOV	R1, 0000000000011111b
		MOV 	M[LEDS], R1

End_EscLeds:	POP	R2		
		POP	R1
		RET






;===============================================================================
; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;         O caracter pode ser visualizado na janela de texto.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================

EscCar:         MOV     M[IO_WRITE], R1
                RET     

;===============================================================================
; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;            pelo caracter FIM_TEXTO, na janela de texto numa posicao 
;            especificada. Pode-se definir como terminador qualquer caracter 
;            ASCII. 
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

EscString:      PUSH    R1
                PUSH    R2
		PUSH    R3
                MOV     R2, M[SP+6]   		; Apontador para inicio da "string"
                MOV     R3, M[SP+5]   		; Localizacao do primeiro carater
Ciclo_esc:      MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                CALL    EscCar
                INC     R2
                INC     R3
                BR      Ciclo_esc
FimEsc:         POP     R3
                POP     R2
                POP     R1
                RETN    2                	; Actualiza STACK


;===============================================================================
; Interrupt_I0: Rotina faz a interrupção pelo I0.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Interrupt_I0:	PUSH	R1
		MOV	R1, 0001h
		MOV	M[FLAG_I0], R1
		POP	R1
		RTI


;===============================================================================
; Interrupt_IA: Rotina faz a interrupção pelo IA.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Interrupt_IA:	PUSH	R1
		CMP	M[FLAG_IA], R0
		BR.Z	pause
		MOV	M[FLAG_IA], R0
		BR	end_pause	

pause:		MOV	R1, 0001h
		MOV	M[FLAG_IA], R1
end_pause:	POP	R1
		RTI



;===============================================================================
; Interrupt_Timer: Rotina faz a interrupção pelo temporizador.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Interrupt_Timer:PUSH	R1
		PUSH	R2
		PUSH	R3
	
		MOV	R1, 0001h
		MOV	M[FLAG_TIMER], R1

		
		MOV	R2, M[tempo_passou]
		INC	R2
		MOV	M[tempo_passou], R2
		MOV	R3, 10
		DIV	R2, R3
		CMP	R2, R0
		BR.Z	naopassou1seg

		MOV	R3, 10
		DIV	R2, R3

		
passou1seg:	MOV 	R1, 1000000000000111b 	; Linha 0, Coluna 7
		MOV 	M[LCD_CURSOR], R1
		
		ADD	R3, '0'
		MOV 	M[LCD_WRITE], R3 	; Escreve caracter

		MOV	R3, 6
		DIV	R2, R3
		
		MOV 	R1, 1000000000000110b 	; Linha 0, Coluna 8
		MOV 	M[LCD_CURSOR], R1
		
		ADD	R3, '0'
		MOV 	M[LCD_WRITE], R3 	; Escreve caracter

		MOV 	R1, 1000000000000001b 	; Linha 0, Coluna 1
		MOV 	M[LCD_CURSOR], R1
		
		ADD	R2, '0'
		MOV 	M[LCD_WRITE], R2	; Escreve caracter
		
		

naopassou1seg:	POP	R3
		POP	R2
		POP	R1
		RTI



;===============================================================================
; Desenha_linha: Rotina faz a interrupção pelo I0.
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
	
Desenha_linha:  PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		
		MOV	R4, 0050h
		MOV     R2, M[SP+7]   		; Apontador para inicio da "string"
                MOV     R3, M[SP+6]   		; Localizacao do primeiro carater
Ciclo_linhas:   MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
		MOV     M[IO_WRITE], R1		; EscCar  
                INC	R3
		DEC	R4
                CMP     R4, R0
		BR.Z	FimEscL
                BR      Ciclo_linhas

FimEscL:        POP	R4
		POP     R3
                POP     R2
                POP     R1
                RETN    2                	; Actualiza STACK


;===============================================================================
; Desenha_coluna: Rotina faz a interrupção pelo I0.
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Desenha_coluna: PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		
		MOV	R4, 0016h
		MOV     R2, M[SP+7]   		; Apontador para inicio da "string"
                MOV     R3, M[SP+6]   		; Localizacao do primeiro carater
Ciclo_colunas:  MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
		MOV     M[IO_WRITE], R1		; EscCar  
                ADD	R3, 0100h
		DEC	R4
                CMP     R4, R0
		BR.Z	FimEscC
                BR      Ciclo_colunas

FimEscC:        POP	R4
		POP     R3
                POP     R2
                POP     R1
                RETN    2                	; Actualiza STACK







;===============================================================================
; Apaga_Cauda: Rotina que escreve um espaço na ultima posição da cobra.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Apaga_Cauda:	PUSH	R1
		PUSH	R2

		MOV 	R1, M[comp_cobra]		;Guarda tamanho da cobra
		DEC	R1
		MOV	R2, posicao_cobra
		ADD	R2, R1				;Soma o tamanho da cobra menos um, mais a primeira posição da cobra, isto de modo a encontrar a posição da cauda		
		MOV	R2, M[R2]			;Coordenadas da cauda	

		PUSH    car_espaco          	
                PUSH    R2       
                CALL    EscString			;Escreve um espaço na cauda
		
		POP	R2
		POP	R1
		RET


;===============================================================================
; Actualiza_XY: Rotina que actualiza as posições de memória da posição da cobra.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
	
Actualiza_XY:	PUSH	R1
		PUSH	R2
		PUSH	R3
		
		MOV	R1, posicao_cobra

		MOV	R2, M[R1+8]			;Coordenadas da nona posição da cobra
		MOV	M[R1+9], R2			;Escreve na décima posição da cobra

		MOV	R2, M[R1+7]			;Coordenadas da oitava posição da cobra
		MOV	M[R1+8], R2			;Escreve na nona posição da cobra

		MOV	R2, M[R1+6]			;Coordenadas da sétima posição da cobra
		MOV	M[R1+7], R2			;Escreve na oitava posição da cobra

		MOV	R2, M[R1+5]			;Coordenadas da sexta posição da cobra
		MOV	M[R1+6], R2			;Escreve na sétima posição da cobra

		MOV	R2, M[R1+4]			;Coordenadas da quinta posição da cobra
		MOV	M[R1+5], R2			;Escreve na sexta posição da cobra

		MOV	R2, M[R1+3]			;Coordenadas da quarta posição da cobra
		MOV	M[R1+4], R2			;Escreve na quinta posição da cobra

		MOV	R2, M[R1+2]			;Coordenadas da terceira posição da cobra
		MOV	M[R1+3], R2			;Escreve na quarta posição da cobra

		MOV	R2, M[R1+1]			;Coordenadas da segunda posição da cobra
		MOV	M[R1+2], R2			;Escreve na terceira posição da cobra

		MOV	R2, M[R1]			;Coordenadas da primeira posição da cobra
		MOV	M[R1+1], R2			;Escreve na segunda posição da cobra

		MOV	R3, M[incremento]		;Valor do incremento à primeira posição 
		ADD	R2, R3				;Incremento às coordenadas da primeira posição
		
		MOV	M[R1], R2			;Escreve na primeira posição da cobra

		POP	R3
		POP	R2
		POP	R1
		
		RET	

;===============================================================================
; Escreve_cabeca: Rotina que escreve um 'O' na primeira posição da cobra.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Escreve_cabeca:	PUSH	R1

		MOV	R1, M[posicao_cobra]	;Coordenadas da cabeça
		
		PUSH    car_corpo          	
                PUSH    R1       
                CALL    EscString		;Escreve um 'O' na primeira posição da cobra
		
		POP	R1
		RET

;===============================================================================
; Esc_comida: Rotina que escreve um '@' na posição da comida.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Esc_comida:	PUSH	R1

		MOV	R1, M[XY_comida]	;Coordenadas da comida
		
		PUSH    car_comida          	
                PUSH    R1       
                CALL    EscString		;Escreve um '@' na posição da comida.
		
		POP	R1
		RET
		

;===============================================================================
; Verif_Comida: Rotina que verifica se a cobra bateu contra a parede.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Verif_Comida:	PUSH	R1
		PUSH	R2

		MOV	R1, M[posicao_cobra]
		MOV	R2, M[XY_comida]
		CMP	R1, R2
		BR.NZ	end_comida

		CALL	Aleat_Comida
		CALL	Esc_comida
		CALL	Pontos_7s
		CALL	EscLeds

		MOV	R1, M[comp_cobra]
		CMP	R1, 10
		BR.Z	Win
		ADD	R1, 0002h
		MOV	M[comp_cobra], R1
		BR	end_comida

Win:		MOV	R1, 0001h
		MOV	M[gameover], R1
		MOV	M[youwon], R1


end_comida:	POP	R2
		POP	R1
		RET		
	
;===============================================================================
; Verif_Parede: Rotina que verifica se a cobra bateu contra a parede.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Verif_Parede: 	PUSH	R1
		PUSH	R2

		MOV	R1, M[posicao_cobra]	;Coordenadas da cabeça
		MOV	R2, R1
		
		AND	R1, 00FFh		
		AND	R2, FF00h
		
		CMP	R1, 0000h
		BR.Z	over
		CMP	R1, 004Fh
		BR.Z	over
		CMP	R2, 0000h
		BR.Z	over
		CMP	R2, 1700h
		BR.Z	over		

		BR	not_over
	
over:		MOV	R1, 0001h
		MOV	M[gameover], R1

not_over:	POP	R2
		POP	R1
		RET

;===============================================================================
; Verif_Corpo: Rotina que verifica se a cobra bateu contra a ela própria.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Verif_Corpo:	PUSH	R1
		PUSH	R2
		PUSH	R3
		
		MOV 	R1, M[comp_cobra]		;Guarda tamanho da cobra
		DEC	R1
		MOV	R2, posicao_cobra
		MOV	R3, R2
		MOV	R3, M[R3]
		
		CMP	R1, 5
		BR.N	end_corpo

		CMP	R3, M[R2+4]
		BR.Z	c_over 
		CMP	R3, M[R2+5]
		BR.Z	c_over 

		CMP	R1, 7
		BR.N	end_corpo

		CMP	R3, M[R2+6]
		BR.Z	c_over 
		CMP	R3, M[R2+7]
		BR.Z	c_over

		CMP	R1, 9
		BR.N	end_corpo

		CMP	R3, M[R2+8]
		BR.Z	c_over 
		CMP	R3, M[R2+9]
		BR.Z	c_over

		BR	end_corpo
		
c_over:		MOV	R1, 0001h
		MOV	M[gameover], R1
		

end_corpo:	POP 	R3
		POP	R2
		POP	R1
		RET


;===============================================================================
; Verif_Interrupt: Rotina que verifica se os interruptores mudaram.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Verif_Interrupt:PUSH	R1
		MOV	R1, M[INTERRUPTORES]
		CMP	R1, R0
		BR.Z	Int_1
		CMP	R1, 0001h
		BR.Z	Int_2	
		CMP	R1, 0002h
		BR.Z	Int_3
		BR	end_verif_int

Int_1:		MOV	R1, 1
		MOV	M[tempo], R1
		BR	end_verif_int
Int_2:		MOV	R1, 2
		MOV	M[tempo], R1
		BR	end_verif_int
Int_3:		MOV	R1, 3
		MOV	M[tempo], R1

end_verif_int:	POP	R1
		RET


;===============================================================================
; Movimento: Rotina que faz a cobra andar.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

 Movimento:	CALL	Apaga_Cauda
		CALL	Actualiza_XY
		CALL	Escreve_cabeca
		CALL	Verif_Parede
		CALL	Verif_Corpo
		CALL	Verif_Comida
		CALL	Esc_comida
		CALL	Verif_Interrupt
		RET

;===============================================================================
; Dir_cima: Rotina que faz a cobra virar para cima.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Dir_cima:	PUSH	R1
		MOV	R1, 0100h
		NEG	R1
		MOV	M[incremento], R1

Loop_cima:	CALL	Movimento
		CALL	Delay_timer		

		MOV	R1, M[FLAG_IA]
		CMP	R1, 0001h
		BR.Z    End_cima		

		MOV	R1, M[gameover]
		CMP	R1, 0001h
		BR.Z    End_cima
		
		MOV	R1, M[IO_CHECK]
		CMP	R1, 0001h
		BR.Z	Ve_AD_w
		
		BR	Loop_cima

Ve_AD_w:	MOV	R7, M[IO_READ]
		CMP     R7, 'a'
		BR.Z    End_cima
		CMP     R7, 'd'
		BR.Z    End_cima
		
		BR	Loop_cima

End_cima:	POP	R1	
		RET





;===============================================================================
; Dir_baixo: Rotina que faz a cobra virar para baixo.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Dir_baixo:	PUSH	R1
		MOV	R1, 0100h
		MOV	M[incremento], R1

Loop_baixo:	CALL	Movimento
		CALL	Delay_timer	

		MOV	R1, M[FLAG_IA]
		CMP	R1, 0001h
		BR.Z    End_baixo

		MOV	R1, M[gameover]
		CMP	R1, 0001h
		BR.Z    End_baixo

		MOV	R1, M[IO_CHECK]
		CMP	R1, 0001h
		BR.Z	Ve_AD_s

		BR	Loop_baixo

Ve_AD_s:	MOV	R7, M[IO_READ]
		CMP     R7, 'a'
		BR.Z    End_baixo
		CMP     R7, 'd'
		BR.Z    End_baixo
		
		BR	Loop_baixo

End_baixo:	POP	R1	
		RET






;===============================================================================
; Dir_esquerda: Rotina que faz a cobra virar para a esquerda.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Dir_esquerda:	PUSH	R1
		MOV	R1, 0001h
		NEG	R1
		MOV	M[incremento], R1

Loop_esquerda:	CALL	Movimento
		CALL	Delay_timer	

		MOV	R1, M[FLAG_IA]
		CMP	R1, 0001h
		BR.Z    End_esquerda		

		MOV	R1, M[gameover]
		CMP	R1, 0001h
		BR.Z    End_esquerda

		MOV	R1, M[IO_CHECK]
		CMP	R1, 0001h
		BR.Z	Ve_WS_a

		BR	Loop_esquerda

Ve_WS_a:	MOV	R7, M[IO_READ]
		CMP     R7, 'w'
		BR.Z    End_esquerda
		CMP     R7, 's'
		BR.Z    End_esquerda
		
		BR	Loop_esquerda

End_esquerda:	POP	R1	
		RET





;===============================================================================
; Dir_direita: Rotina que faz a cobra virar à direita.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================

Dir_direita:	PUSH	R1
		MOV	R1, 0001h
		MOV	M[incremento], R1

Loop_direita:	CALL	Movimento
		CALL	Delay_timer		

		MOV	R1, M[FLAG_IA]
		CMP	R1, 0001h
		BR.Z    End_direita

		MOV	R1, M[gameover]
		CMP	R1, 0001h
		BR.Z    End_direita

		MOV	R1, M[IO_CHECK]
		CMP	R1, 0001h
		BR.Z	Ve_WS_d

		BR	Loop_direita

Ve_WS_d:	MOV	R7, M[IO_READ]
		CMP     R7, 'w'
		BR.Z    End_direita
		CMP     R7, 's'
		BR.Z    End_direita
				
		BR	Loop_direita

End_direita:	POP	R1	
		RET



;===============================================================================
;===============================================================================
; 				Rotina principal
;===============================================================================
;===============================================================================
Inicio:         MOV     R1, SP_INICIAL
                MOV     SP, R1
                MOV     R1, INT_MASK
                MOV     M[INT_MASK_ADDR], R1
		MOV	R2, TABLE_INT
		MOV	R1, Interrupt_I0
		MOV	M[R2+0], R1
		MOV	R1, Interrupt_IA
		MOV	M[R2+10], R1
		MOV	R1, Interrupt_Timer
		MOV	M[R2+15], R1
                ENI

		CALL    LimpaJanela
                PUSH    vartexto1           	; pilha - apontador para o inicio da "string
                PUSH    XY_TEXTO        	; pilha - posicao do cursor para escrita do primeiro carater
                CALL    EscString

Tryagain:	MOV	M[FLAG_I0], R0
Loopi0:		MOV	R1, M[FLAG_I0]
		CMP	R1, 0001h
		BR.NZ	Loopi0

;Inicializa periféricos

		CALL	Inic_perif

		
;Desenha perimetro
		CALL    LimpaJanela

		PUSH	car_hifen		; pilha - primeiro carater
		PUSH	XY_LINHA1		; pilha - posicao do cursor para escrita do carater
		CALL	Desenha_linha

		PUSH	car_barra 
		PUSH	XY_COLUNA1
		CALL	Desenha_coluna

		PUSH	car_barra
		PUSH	XY_COLUNA2
		CALL	Desenha_coluna

		PUSH	car_hifen
		PUSH	XY_LINHA2
		CALL	Desenha_linha

;Define comprimento da cobra inicial

		MOV	R1, 0002h
		MOV	M[comp_cobra], R1

;Desenha cobra inicial
		MOV	R1, XY_INIC_COBRA
		MOV	R2, posicao_cobra
		MOV	M[R2], R1
		PUSH    car_corpo          	
                PUSH    M[R2]       
                CALL    EscString
		DEC	R1
		MOV	M[R2+1], R1
		PUSH    car_corpo          	
                PUSH    M[R2+1]       
                CALL    EscString

;Desenha comida inicial
		
		CALL	Aleat_Comida
		CALL	Esc_comida

;Cobra começa a andar
		CALL    Dir_direita

;Escolhe a rotina 

Loop_dir:	MOV	R1, M[gameover]
		CMP	R1, 0001h
		JMP.Z	GameOver
		MOV	R1, M[FLAG_IA]
		CMP	R1, 0001h
		BR.Z	Pausa
Unpausa:	CMP     R7, 'w'
		BR.Z    go_cima
		CMP     R7, 'a'
		BR.Z    go_esquerda
		CMP     R7, 's'
		BR.Z    go_baixo
		CMP     R7, 'd'
		BR.Z    go_direita
		JMP	Loop_dir

go_cima:	CALL	Dir_cima	
		JMP	Loop_dir
go_esquerda:	CALL	Dir_esquerda
		JMP	Loop_dir
go_baixo:	CALL	Dir_baixo
		JMP	Loop_dir
go_direita:	CALL	Dir_direita
		JMP	Loop_dir

Pausa:		MOV	R1, M[FLAG_IA]
		CMP	R1, R0
		BR.NZ	Pausa
		JMP	Unpausa

;Gameover
GameOver:	MOV	R1, M[youwon]
		CMP	R1, 0001h
		BR.Z	YouWon
		
		CALL    LimpaJanela
                PUSH    vartexto2           	
                PUSH    XY_GAMEOVER        	
                CALL    EscString
		BR	cont_over

YouWon:		CALL    LimpaJanela
                PUSH    vartexto3           	
                PUSH    XY_GAMEOVER        	
                CALL    EscString

cont_over:      PUSH    vartexto1           	
                PUSH    XY_TEXTO        	
                CALL    EscString

		MOV	M[gameover], R0
		MOV	M[youwon], R0
		MOV	M[tempo_passou], R0

		JMP	Tryagain

