;
; AssemblerApplication1.asm
;
; Created: 02/03/2017 08:14:39
; Author : DEE
;

	
	.include<m128def.inc>

	.equ	sw6 = 5				// Configura��o do Switch 6
// 	.equ	sw5 = 4				Configura��o do Switch 5
	.equ	sw4 = 3				// Configura��o do Switch 4
	.equ	sw3 = 2				// Configura��o do Switch 3
	.equ	sw2 = 1				// Configura��o do Switch 2
	.equ	sw1 = 0				// Configura��o do Switch 1
	.def	temp=R16			// Defini��o da vari�vel temp


/*	Outra maneira de configurar os LED's, um a um.

	.equ	D1=0b11111110
	.equ	D2=0b11111101
	.equ	D3=0b11111011
	.equ	D4=0b11110111
	.equ	D5=0b11101111
	.equ	D6=0b11011111
	.equ	D7=0b10111111
	.equ	D8=0b01111111	*/

	.cseg						// Indica o in�cio do c�digo
	.org	0x46				// Indica o endere�o de mem�ria em que come�a o c�digo


/********************************************************************************************
									Funcionamento 1
********************************************************************************************/

Funcionamento1:
	ser		temp				// Coloca a vari�vel temp s� com 1's
	out		PORTC,	temp		// Escreve na sa�da
	out		DDRC,	temp		// Configura como sa�da
	clr		temp				// Coloca a vari�vel temp s� com 0's
	out		DDRA,	temp		// Configura como entradas

/***************************			Configura��o dos Bot�es			********************/

SWI1:
	sbic	PINA,	sw1			// Se pressionar o bot�o sw1...
	jmp		SWI2
	ldi		temp,	0b01111110	// ... salta para aqui
	out		PORTC,	temp		// Escreve na sa�da a vari�vel temp

SWI2:
	sbic	PINA,	sw2		
	jmp		SWI3				// Se n�o for pressionado o bot�o sw2, passar� para o pr�ximo ciclo
	ldi		temp,	0b01100110	// L� imediatamente para a vari�vel temp a configura��o dos LED's
	out		PORTC,	temp

SWI3:
	sbic	PINA,	sw3
	jmp		SWI4
	ldi		temp,	0b01000010
	out		PORTC,	temp
	
SWI4:
	sbic	PINA,	sw4
	jmp		SWI6
	ldi		temp,	0b00000000
	out		PORTC,	temp

SWI6:
	sbic	PINA,	sw6
	jmp		SWI1
	ldi		temp,	0b11111111
	out		PORTC,	temp
	jmp		SWI1					// Salta para o ciclo SWI1
