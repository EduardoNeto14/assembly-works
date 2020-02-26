.include<m128def.inc>	

	.equ	Ready=0					// Configuração dos estados
	.equ	Running=1
	.equ	Stopped=2
	.equ	Piscar=3

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

	.def	temp=R16
	.def	AuxReg=R17
	.def	Contador=R18
	.def	Disp=R19
	.def	Aux=R20
	.def	AR=R21
	.def	Contador2=R22
	.def	Estado=R23
	.def	MAXC=R24
	.def	AR2=R25
	
	.cseg
	.org	0x00
	jmp		StackPointer
	.org	0x02
	jmp		INT_0
	.org	0x04
	jmp		INT_1
	.org	0x1E
	jmp		TIM0

	.cseg
	.org	0x46


Funcionamento1:

	clr		temp
	out		DDRD,	temp				// Switches
	ser		temp
	out		PORTC,	temp
	out		DDRC,	temp				// Display 7 segmentos

	ldi		AR,	77				// Temporização base de 5 ms
	out		OCR0, 	AR				// Valor do registo do timer


	ldi		Contador, 0
	ldi		Contador2,3
	ldi		MAXC,	23				// "Limite" do abecedário
	ldi		Estado, Ready				// Estado inicial
	ldi		AR,	40				// Define o tempo do timer com 200 ms
	
	ldi		temp,	0b00001111			// Definicao do PreScaler 
	out		TCCR0,	temp

	in		temp,	TIMSK				// Enable da interrupção do TC0
	ori		temp, 0b00000010
	out		TIMSK, temp

	ldi		temp,		0b00001111
	sts		EICRA,	temp				// configuramos como ascendente os interruptores 1 e 2
	ldi		temp,		0b00000011
	out		EIMSK,	temp				// definição do interruptor 1 e 2

	sei							// enable global das interrupções
	ret

StackPointer:
	
	ldi		Aux, LOW(RAMEND)			// Configuração da parte baixa da stack
	out		SPL, Aux
	ldi		Aux, HIGH(RAMEND)			// Configuração da parte alta da stack
	out		SPH, Aux
	call	Funcionamento1

/*******************************		Ciclo		*************************************/


Ciclo:

	jmp 	Ciclo						// Ciclo Principal

TIM0:
	
	cpi	Estado, Running
	brne	TSt0
	call	Display
	out	PORTC, Disp	
	dec	AR
	cpi	AR, 0
	brne	TIM0_FIM
	ldi	AR, 40
	inc	Contador
	cpse	Contador, MAXC
	jmp	TIM0_FIM
	ldi	Contador, 0
	jmp	TIM0_FIM

TSt0:

	cpi	Estado, Stopped
	brne	TSt1
	call 	Display			// Este ciclo serve para manter a letra contida no Display acesa durante 500 ms
	out	PORTC,	Disp
	dec	AR
	cpi	AR, 0
	brne 	TIM0_FIM
	ldi	Estado, Piscar
	ldi	AR2, 100

TSt1:

	cpi	Estado, Piscar		// Criamos um estado "Piscar" de modo a ser mais fácil trabalhar o ciclo piscar.
	brne	TIM0_FIM
	ser	temp				// Mete o registo temp todo a 1, que será escrito no PORTC de maneira a apagar os led.
	out	PORTC, temp
	dec	AR2
	cpi	AR2, 0
	brne 	TIM0_FIM
	ldi	AR, 100
	ldi	Estado,	Stopped
	dec	Contador2
	cpi	Contador2, 0
	brne	TIM0_FIM
	out	PORTC, Disp
	ldi	Estado, Ready

	reti
		
TIM0_FIM:
	reti
	



/************************		Configuração das Interrupções		*************************************/



/***********	1ª Interrupção		***************/

INT_0:
	cpi	Estado, Ready
	brne	FimInt0
	ldi	Estado, Running
	ldi	AR, 40
	ldi	Contador,	0
	reti

FimInt0:
	reti

/***********	2ª Interrupção		***************/

INT_1:

	cpi 	Estado,Running
	brne	FimInt1
	ldi	Estado,Stopped
	ldi	Contador2, 3
	ldi	AR, 100
	ldi	AR2,100
	reti

FimInt1:
	cpi	Estado, Stopped		// para caso esteja em stop passar para RUNNING
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


/************************		Display		*************************************/

Display:

	ldi		ZL, LOW(DisplayTab<<1)
	ldi		ZH, HIGH(DisplayTab<<1)
	clr		AuxReg
	add		ZL, Contador
	adc		ZH, AuxReg
	lpm		Disp, Z

	ret


.cseg
	DisplayTab:						// Definição de uma tabela onde se encontram as letras a serem mostrados pelo Display
	.db  leA, leB, leC, leD, leE, leF, leG, leH, leI, leJ, leL, leM, leN, leO, leP, leQ, leR, leS, leT, leU, leV, leX, leZ