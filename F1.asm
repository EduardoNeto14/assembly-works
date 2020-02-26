;
; AssemblerApplication1.asm
;
; Created: 02/03/2017 08:14:39
; Author : DEE
;

	
	.include<m128def.inc>

	.equ	sw6 = 5				// Configuração do Switch 6
// 	.equ	sw5 = 4				Configuração do Switch 5
	.equ	sw4 = 3				// Configuração do Switch 4
	.equ	sw3 = 2				// Configuração do Switch 3
	.equ	sw2 = 1				// Configuração do Switch 2
	.equ	sw1 = 0				// Configuração do Switch 1
	.def	temp=R16			// Definição da variável temp


/*	Outra maneira de configurar os LED's, um a um.

	.equ	D1=0b11111110
	.equ	D2=0b11111101
	.equ	D3=0b11111011
	.equ	D4=0b11110111
	.equ	D5=0b11101111
	.equ	D6=0b11011111
	.equ	D7=0b10111111
	.equ	D8=0b01111111	*/

	.cseg						// Indica o início do código
	.org	0x46				// Indica o endereço de memória em que começa o código


/********************************************************************************************
									Funcionamento 1
********************************************************************************************/

Funcionamento1:
	ser		temp				// Coloca a variável temp só com 1's
	out		PORTC,	temp		// Escreve na saída
	out		DDRC,	temp		// Configura como saída
	clr		temp				// Coloca a variável temp só com 0's
	out		DDRA,	temp		// Configura como entradas

/***************************			Configuração dos Botões			********************/

SWI1:
	sbic	PINA,	sw1			// Se pressionar o botão sw1...
	jmp		SWI2
	ldi		temp,	0b01111110	// ... salta para aqui
	out		PORTC,	temp		// Escreve na saída a variável temp

SWI2:
	sbic	PINA,	sw2		
	jmp		SWI3				// Se não for pressionado o botão sw2, passará para o próximo ciclo
	ldi		temp,	0b01100110	// Lê imediatamente para a variável temp a configuração dos LED's
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
