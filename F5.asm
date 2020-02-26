.include<m128def.inc>	

	.equ	Ready=0						// Configuração dos estados
	.equ	Running=1
	.equ	Stopped=2
	.equ	Piscar=3
	.equ	Next=4

	.equ	leA=0b10001000				// Configuração das várias letras
	.equ	leB=0b10000011
	.equ	leC=0b11000110
	.equ	leD=0b10100001
	.equ	leE=0b10000110
	.equ	leF=0b10001110
	.equ	leG=0b10010000
	.equ	leH=0b10001011
	.equ	leI=0b11111001
	.equ	leJ=0b11100001
	.equ	leL=0b11000111
	.equ	leM=0b11001000
	.equ	leN=0b10101011
	.equ	leO=0b11000000
	.equ	leP=0b10001100
	.equ	leQ=0b10011000
	.equ	leR=0b10101111
	.equ	leS=0b10010010
	.equ	leT=0b10000111
	.equ	leU=0b11100011
	.equ	leV=0b11000001
	.equ	leX=0b10001001
	.equ	leZ=0b10100100
	
	.equ	Disp1=0b00000000			// Configuração do Display de 7 segmentos a usar
	.equ	Disp2=0b01000000
	.equ	Disp3=0b10000000
	.equ	Disp4=0b11000000

	.def	temp=R16
	.def	AuxReg=R17
	.def	Contador=R18
	.def	Disp=R19
	.def	Contador3=R20
	.def	AR=R21
	.def	Contador2=R22
	.def	Estado=R23
	.def	AR2=R24
	.def	AR3=R25
	.def	Contador4=R26
	.def	temp2=R27
	
	.cseg
	.org	0x00
	jmp		StackPointer
	.org	0x02
	jmp		INT_0
	.org	0x04
	jmp		INT_1
	.org	0x08
	jmp		INT_2
	.org	0x1E
	jmp		TIM0

	.cseg
	.org	0x46


Funcionamento2:

	ldi		temp,   0b11000000				// Switches como entrada, Display como saída
	out		PORTD,  temp
	out		DDRD,   temp
	ser		temp
	out		PORTC,	temp
	out		DDRC,	temp					// Display 7 segmentos
	out		PORTA,	temp
	out		DDRA,	temp					// LEDs

	ldi		AR,	77					// Temporização base de 5 ms
	out		OCR0, 	AR					// Valor do registo do timer




	ldi		Contador, 0
	ldi		Contador2,3
	ldi		Estado, Ready					// Estado inicial
	ldi		AR,	40					// Define o tempo do timer  200 ms
	ldi		Contador3, 0
	ldi		Contador4, 0
	
	ser		temp
	out		PORTA,	temp					// Começa com os LEDs desligados

	ldi		temp,	0b00001111				// Definicao do PreScaler 
	out		TCCR0,	temp


	in		temp,	TIMSK					// Enable da interrupção do TC0
	ori		temp, 0b00000010
	out		TIMSK, temp


	ldi		temp,		0b11001111
	sts		EICRA,	temp					// configuramos como ascendente os interruptores 1,2 e 4
	ldi		temp,		0b00001011
	out		EIMSK,	temp					// definição do interruptor 1,2 e 4
	
	
	sei								// enable global das interrupções
	ret

StackPointer:
	
	ldi		temp, LOW(RAMEND)				// Configuração da parte baixa da stack
	out		SPL, temp
	ldi		temp, HIGH(RAMEND)				// Configuração da parte alta da stack
	out		SPH, temp
	call		Funcionamento2

/*******************************		Ciclo		*************************************/


Ciclo:

	jmp 	Ciclo		// Ciclo Principal
	
	
/********************		Temporizador 1		**********************/


TIM0:

	call	Displays			// Função com o Display a escrever
	out		PORTD,	temp
	cpi	Estado, Running
	brne	TSt0				// Subrotina que testa o estado "Stopped"
	call	Display				// Identifica a letra do abecedário
	out	PORTC, Disp			// Mostra a letra
	dec	AR				// Temporizador
	cpi	AR, 0
	brne	TIM2				// Função que incrementa 1 segundo, 20 vezes
	ldi	AR, 40
	inc	Contador
	cpi	Contador, 23			// Limite do abecedário
	breq	Reset
	jmp	TIM2
Reset:	ldi	Contador, 0
	jmp	TIM2

TSt0:

	cpi	Estado, Stopped
	brne	TSt1
	call 	Display				// Este ciclo serve para manter a letra contida no Display acesa durante 500 ms
	out	PORTC,	Disp
	dec	AR
	cpi	AR, 0
	brne 	TIM2
	ldi	Estado, Piscar
	ldi	AR2, 100

TSt1:

	cpi	Estado, Piscar			// Criamos um estado "Piscar" de modo a ser mais fácil trabalhar o ciclo piscar.
	brne	TIM2
	ser	temp				// Mete o registo temp todo a 1, que será escrito no PORTC de maneira a apagar os led.
	out	PORTC, temp
	dec	AR2
	cpi	AR2, 0
	brne 	TIM2
	ldi	AR, 100
	ldi	Estado,	Stopped
	dec	Contador2
	cpi	Contador2, 0
	brne	TIM2
	
	inc 	Contador3
	cpi	Contador3, 4			// Se estivermos no ultimo display de 7 segmentos, reiniciará o funcionamento
	breq	StackPointer
	ldi	Estado, Running	

TIM2:

        cpi	Estado, Ready			// Subrotina usada para contar os segundos passados e posteriormente ligar os LEDs
	breq	TIM0_FIM
	dec	AR3
	cpi	AR3, 0
	brne	TIM0_FIM
	ldi	AR3, 200
	
	inc	Contador4			// Incrementa o numero de segundos passados

LED1:
	cpi	Contador4, 6			// Caso tenham passado 6 segundos, ligará o primeiro LED
	brne	LED2
	ldi	temp2,	0b11111110
	out	PORTA, temp2
	
LED2:
	cpi	Contador4, 8
	brne	LED3
	ldi	temp2,	0b11111100
	out	PORTA, temp2
	
LED3:
	cpi	Contador4, 10
	brne	LED4
	ldi	temp2,	0b11111000
	out	PORTA, temp2
	
LED4:
	cpi	Contador4, 12
	brne	LED5
	ldi	temp2,	0b11110000
	out	PORTA, temp2
	
LED5:
	cpi	Contador4, 14
	brne	LED6
	ldi	temp2,	0b11100000
	out	PORTA, temp2
	
LED6:
	cpi	Contador4, 16
	brne	LED7
	ldi	temp2,	0b11000000
	out	PORTA, temp2
	
LED7:
	cpi	Contador4, 18
	brne	LED8
	ldi	temp2,	0b10000000
	out	PORTA, temp2
	
LED8:
	cpi	Contador4, 20
	brne	TIM0_FIM
	ldi	temp2,	0b00000000		// Caso chegue aos 20 segundos, acabará o funcionamento
	out	PORTA,	temp2
	ser	temp2
	out	PORTA, temp2
	out	PORTC, temp2
	ldi	Estado, Ready
	ldi	Contador4, 0

	reti


TIM0_FIM:
	reti
	
	
	

/************************		Configuração das Interrupções		*************************************/



/***********	1ª Interrupção		***************/

INT_0:
	cpi	Estado, Ready
	brne	FimInt0
	ldi	Contador, 0
	ldi	Contador3, 0
	ldi	Estado, Running
	ldi	AR, 40
	reti

FimInt0:
	reti

/***********	2ª Interrupção		***************/

INT_1:

	cpi 	Estado,Running
	brne	FimInt1
	ldi	Estado,Stopped
	ldi	Contador2, 3
	ldi	AR, 	100
	ldi	AR2,	100
	reti

FimInt1:
	cpi	Estado, Stopped 	// para caso esteja em stop passar para Running
	brne	FIMfim
	ldi	Estado,Running
	ldi	AR, 40
	reti

FIMfim:
	cpi	Estado, Piscar
	brne	FIM_INT
	ldi	Estado, Running
	ldi	AR,40
	reti

FIM_INT:
	reti	
	
/***********	3ª Interrupção		***************/	

INT_2:
	cpi	Estado,	Running
	brne	FimInt2
	cpi	Contador3,	3
	breq	FimInt2
	inc	Contador3
	reti

FimInt2: 
	reti


/************************		Display		*************************************/

Display:

	ldi		ZL, LOW(DisplayTab<<1)
	ldi		ZH, HIGH(DisplayTab<<1)
	clr		AuxReg
	add		ZL, Contador
	adc		ZH, AuxReg
	lpm		Disp, Z

	ret
	

Displays:

// Ciclo usado para identificar qual dos displays a ser usado

	 Dis0:
	 cpi		Contador3, 0
	 brne		Dis1
	 ldi		temp,	Disp1
	
	 ret
	 

	 Dis1:
	 cpi		Contador3, 1
	 brne		Dis2
	 ldi		temp, 	Disp2
	 out		PORTD,	temp
	 ret
	 

	 Dis2:
	 cpi		Contador3, 2
	 brne		Dis3
	 ldi		temp, 	Disp3
	 out		PORTD,	temp
	 ret
	 

	 Dis3:
	 cpi		Contador3, 3
	 brne		Dis0
	 ldi		temp, 	Disp4
	 out		PORTD,	temp
	 ret
	

.cseg
	DisplayTab:			// Definição de uma tabela onde se encontram as letras a serem mostrados pelo Display
	.db  leA, leB, leC, leD, leE, leF, leG, leH, leI, leJ, leL, leM, leN, leO, leP, leQ, leR, leS, leT, leU, leV, leX, leZ