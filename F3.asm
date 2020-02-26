; Replace with your application code
	
	.include<m128def.inc>	

	.equ	sw1=0
	.equ	sw2=1
	.equ	sw3=2
	.equ	sw4=3
	.equ	sw5=4
	.equ	sw6=5

	.def	temp=R16
	.def	AuxReg =R17
	.def	temp1=R18
	.def	temp2=R19
	.def	temp3=R20
	.def	Contador=R21
	.def	Valor=R22
	.def	Disp=R23
	.def	Aux=R24
	
	.equ	d0=0xC0
	.equ	d1=0xF9
	.equ	d2=0xA4
	.equ	d3=0xB0
	.equ	d4=0x99
	.equ	d5=0x92
	.equ	d6=0x82
	.equ	d7=0xF8
	.equ	d8=0x80
	.equ	d9=0x90

	.cseg
	.org	0x00

	jmp		Funcionamento3

	.cseg
	.org	0x46

/*********************************************************************************************
									Funcionamento 3
*********************************************************************************************/
	

// a = a<<1		->	roda um bit pa esquerda, ex: 0011 -> 0110

Funcionamento3:

	ldi		Aux,	0x10		// Posi��o Inicial da Stack
	out		sph,	Aux
	ldi		Aux,	0xFF		// Posi��o Final da Stack
	out		spl,	Aux

	clr		temp
	out		DDRD, temp			// Switches
	ser		temp
	out		PORTC, temp			// Display
	out		DDRC, temp
	out		PORTA, temp			// Led's
	out		DDRA, temp			


/************************		Escolher o Bot�o		*************************************/

Escolher:
	
	ldi		Contador, 0			//Coloca o registo "Contador" a 0
	call	Display				//Chama o ciclo "Display" que, juntamente com a intru��o acima, ...
	out		PORTC,	Disp		//... ir� mostrar a primeira posi��o do vetor definido por DisplayTab (0)

Verifica1:

	ldi		Valor, 1			// Capacidade m�xima = 1  ... este "Valor" ser� posteriormente utilizado para comparar com o "Contador" no intuito de terminar o ciclo
	sbic	PIND, sw1			// Se n�o pressionarmos o Sw1, salta para o Sw2
	jmp		Verifica2	
	call	Delay1ms			// Confirma��o
	sbis	PIND, sw1			// Se pressinarmos inicia o processo de encher
	call	Encher

	;o Delay1ms � utilizado de maneira a que o pressionamento de um determinado switch n�o seja ocasional

Verifica2:

	ldi		Valor, 2			// Capacidade m�xima = 2  ... ""
	sbic	PIND, sw2
	jmp		Verifica4
	call	Delay1ms
	sbis	PIND, sw2
	call	Encher

Verifica4:

	ldi		Valor, 4			// Capacidade m�xima = 4 ... ""
	sbic	PIND, sw3
	jmp		Verifica8
	call	Delay1ms
	sbis	PIND, sw3
	call	Encher

Verifica8:

	ldi		Valor, 8			// Capacidade m�xima = 8 ... ""
	sbic	PIND, sw4
	jmp		Escolher
	call	Delay1ms
	sbis	PIND, sw4
	call	Encher

	jmp		Escolher

/************************		Delay de 1ms		*************************************/

Delay1ms:

//	delay * Fosc = 20 + 4z (1 + y + xy)		=>		x = 50, y = 50 , z = 2
			
			push	temp1				//coloca temp3,2,1 na stack
			push	temp2
			push	temp3

			ldi		temp3, 1			//z=z-1
delay_z1:	ldi		temp2, 50
delay_y1:	ldi		temp1, 50
delay_x1:	dec		temp1
			cpi		temp1, 0
			brne	delay_x1
			dec		temp2
			cpi		temp2, 0
			brne	delay_y1
			dec		temp3
			cpi		temp3, 0
			brne	delay_z1

			pop		temp3				//limpa os registos
			pop		temp2
			pop		temp1


			ret

/************************		Delay de 500 ms		*************************************/

Delay500ms:

//	delay * Fosc = 20 + 4z (1 + y + xy)		=>	Fosc = , x = 255 (0 decrementado), y = 255 , z = 30
			push	temp1				
			push	temp2
			push	temp3

			ldi		temp3, 29			//z=z-1
delay_z2:	ldi		temp2, 0
delay_y2:	ldi		temp1, 0
delay_x2:	dec		temp1
			cpi		temp1, 0
			brne	delay_x2
			dec		temp2
			cpi		temp2, 0
			brne	delay_y2
			dec		temp3
			cpi		temp3, 0
			brne	delay_z2

			pop		temp3
			pop		temp2
			pop		temp1

			ret

/************************		Ciclo de Encher		*************************************/

Encher:

	call	Display						// Fun��o que possui o c�digo de identifica��o do numero de litros
	out		PORTC,		Disp			// Mostra o n�mero de litros
	call	SWI6						// Este ciclo � chamado para que a etapa de enchimento seja ativada
	call	SWI5						// Este ciclo � chamado para que a etapa de desvaziamento seja ativada
	inc		Contador					// Ap�s a conclus�o dos dois ciclos acima, � incrementado o "Contador"
	cpse	Contador,	Valor			// Aqui � comparado o valor do Contador com o Valor definido aquando do pressionamento da switch (ciclo Escolher)
	jmp		Encher						// Se n�o forem iguais, o ciclo Encher � efetuado novamente	
	call	Piscar						// Se forem iguais � chamado o ciclo Piscar
	
	ret


SWI5:
	sbic	PIND,	sw5					// Neste ciclo, obrigamos a que a sw5 seja pressionado. De outra forma o funcionamento n�o prossegue
	jmp		SWI5						// Se sw5 n�o for pressionado, esta etapa faz com que o "programa" salta para o in�cio do ciclo
	ldi		temp,	0b10111111
	out		PORTA,	temp
	ret

SWI6:
	sbic	PIND,	sw6					// O princ�pio de funcionamento � semelhante ao do ciclo SWI5
	jmp		SWI6
	ldi		temp,	0b01111111			// LED B � aceso no caso da sw5 ser pressionado
	out		PORTA,	temp

	ret


/************************		Ciclo de Piscar		*************************************/


Piscar:
	
	call Display						// Este ciclo consiste em fazer o n�mero final "piscar" 4 vezes com intervalo de 1s. Para isso o Display ter� que estar ativo metade desse tempo e apagado na outra metade.
	out	 PORTC,	Disp
	call Delay500ms
	ser	 temp							// Mete o registo temp todo a 1, que ser� escrito no PORTC de maneira a apagar os led's.
	out	 PORTC, temp
	call Delay500ms

	call Display
	out	 PORTC,	Disp
	call Delay500ms
	ser	 temp
	out	 PORTC, temp
	call Delay500ms

	call Display
	out	 PORTC,	Disp
	call Delay500ms
	ser	 temp
	out	 PORTC, temp
	call Delay500ms
	
	call Display
	out	 PORTC,	Disp
	call Delay500ms
	ser	 temp
	out	 PORTC, temp
	call Delay500ms

	ldi		Contador,	0				// Estas �ltimas instru��es s�o usadas de forma a garantir que ap�s a conclus�o do pretendido acima, o Display volte a mostrar "0".
	call	Display
	out		PORTC,	Disp

	ser		temp						// Desligar os LED's
	out		PORTA,	temp	


	ret
		

/************************		Ciclo de Display		*************************************/

Display:

	ldi ZL, LOW(DisplayTab<<1)
	ldi ZH, HIGH(DisplayTab<<1)
	clr AuxReg
	add ZL, Contador
	adc ZH, AuxReg
	lpm Disp, Z

	ret


.cseg
	DisplayTab:											// Defini��o de uma tabela onde se encontram os digitos a serem mostrados pelo Display
	.db d0, d1, d2, d3, d4, d5, d6, d7, d8, d9
