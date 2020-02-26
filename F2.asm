;
; AssemblerApplication1.asm
;
; Created: 19/03/2017 19:07:53
; Author : Bruno
;


; Replace with your application code


	.include <m128def.inc>	

	.equ	sw6 = 5				// Configura��o do Switch 6
 	.equ	sw5 = 4				// Configura��o do Switch 5
	.equ	sw4 = 3				// Configura��o do Switch 4
	.equ	sw3 = 2				// Configura��o do Switch 3
	.equ	sw2 = 1				// Configura��o do Switch 2
	.equ	sw1 = 0				// Configura��o do Switch 1

	.def	temp=R16			// Defini��o da vari�vel temp
	.def	Aux = R17			// Defini��o da vari�vel Aux
	.def	temp1 = R18			// Defini��o da vari�vel temp1
	.def	temp2 = R19			// Defini��o da vari�vel temp2
	.def	temp3 = R20			// Defini��o da vari�vel temp3

	.cseg						// Indica o come�o do c�digo
	.org	0x46				// Indica a posi��o de mem�ria onde se inicia o c�digo


/********************************************************************************************
									Funcionamento 2
********************************************************************************************/

Funcionamento2:

	ldi		Aux, LOW(RAMEND)	// Configura��o	da parte baixa da mem�ria
	out		SPL, Aux			// Escreve esse registo na parte baixa da stack
	ldi		Aux, HIGH(RAMEND)	// Configura��o da parte alta da mem�ria
	out		SPH, Aux			// Escreve esse registo na parte alta da stack

	ser		temp
	out		PORTC, temp
	out		DDRC, temp
	clr		temp
	out		DDRA, temp

	sbis	PINA, sw1			// Caso	seja ativado o bot�o sw1, passar� ao ciclo SWI1 ...
	jmp		SWI1

	jmp		Funcionamento2		// ... Se n�o fica em ciclo


/*******************************			Ciclo Delay				*********************************/

delay:
			sbis	PINA, sw6	// Caso	seja ativado o bot�o sw6, passar� ao ciclo SWI6 ...
			jmp		SWI6

//	delay * Fosc= 20 + 4z (1 + y + xy)		<=>		x = 256 (0 decrementado), y = 256 (0 decrementado), z = 16


			push	temp1
			push	temp2
			push	temp3

			ldi		temp3, 15		// z = z-1 = 15
delay_z:	ldi		temp2, 0
delay_y:	ldi		temp1, 0
delay_x:	dec		temp1
			cpi		temp1, 0
			brne	delay_x
			
			dec		temp2
			cpi		temp2, 0
			brne	delay_y

			dec		temp3
			cpi		temp3, 0
			brne	delay_z

			pop		temp3
			pop		temp2
			pop		temp1

			ret						// salta para o endere�o que segue ao call



SWI1:

	ldi		temp, 0b11111111
	out		PORTC, temp
	call	delay					// regista o endere�o que vai retornar na stack, e salta para o ciclo "delay"

	ldi		temp, 0b11111110
	out		PORTC, temp
	call	delay

	ldi		temp, 0b11111100
	out		PORTC, temp
	call	delay

	ldi		temp, 0b11111000
	out		PORTC, temp
	call	delay

	ldi		temp, 0b11110000
	out		PORTC, temp
	call	delay

	ldi		temp, 0b11100000
	out		PORTC, temp
	call	delay

	ldi		temp, 0b11000000
	out		PORTC, temp
	call	delay

	ldi		temp, 0b10000000
	out		PORTC, temp
	call	delay

	ldi		temp, 0b00000000
	out		PORTC, temp
	call	delay
	jmp		SWI1


SWI6:	

	ldi		temp, 0b11111111
	out		PORTC, temp
	jmp		Funcionamento2