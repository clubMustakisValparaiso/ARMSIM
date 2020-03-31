
Simulacion de arquitectura ARM en systemVerilog. Set de instrucciones reducido.


Instrucciones probadas:

-> ADD, SUB, AND, OR con inmediato y con registro. Valores sin corrimientos.
-> LDR, STR con inmediato y con registos. Valores sin corrimientos
-> Branches
-> Seteo de flags
-> Comprobacion de condiciones

Bugs

-> EN caso de escribir en el registro R15, agregar 2 instrucciones NOP antes si es que la instruccion previa es un LDR R15,XX,XX  o un branch.
-> En caso que la ultima o penultima instruccion del codigo sea un branch o una escritura en el registro R15, agregar 2 instrucciones NOP al final de la secuencia de intrucciones a subir.

Notas

-> Los MOV A,B se pueden escribir como: 
	SUB A,A,A 
	ADD A,B,#0  


---------------------------------------------------------------------------------
--------------- CODIGO DE EJEMPLO FACTORIAL -------------------------------------
---------------------------------------------------------------------------------
; Factorial de n. n se entrega como argumento en R0.

MAIN
	MOV R0,#4  
	MOV LR,PC  
	B FACT  
	B END  
  
FACT  
&nbsp;&nbsp;&nbsp;&nbsp;STR LR,SP,#4    
	ADD R3,R0,#0  
	SUB R0,R0,R0  
	SUB R1,R1,R1  
	ADD R0,R0,#1  
	ADD R1,R3,#0  
	MOV LR,PC  
	B MUL  
	SUBS R3,R3,,#1  
	BGE #-6  
	LDR LR,SP,#4  
	NOP  
	NOP  
	MOV PC,LR  
MUL  
	ADD R2,R0,#0  
	SUB R0.R0,R0  
	SUBS R1,R1,#1  
	ADDPL R0,R0,R2  
	BPL #-4  
	NOP  
	NOP  
	MOV PC,LR  
	NOP  
	NOP  

//------------------------ ML

e0400000  
e2800004  
e28fe000  
ea000000  
eafffffe  
e58de004  
e2803000  
e0400000  
e0411001  
e2800001  
e2831000  
e28fe000  
ea000005  
e2533001  
cafffffa  
e59de004  
e2888000  
e2888000  
e28ef000  
e2802000  
e0400000  
e2511001  
50800002  
5afffffc  
e2888000  
e2888000  
e28ef000  
e2888000  
e2888000  
  

---------------------------------------------------------------------------------
----------------- Codigo de ejemplo Fibonacci -----------------------------------
---------------------------------------------------------------------------------
; Para calcular el enesimo numero de la secuencia Fibonacci  
; El test utiliza ldr y str para comprobar su funcionamiento, aunque no seria necesario usarlos.  
; r0 = n, n>0  


MAIN  
	MOV R0,#6  
	MOV SP,#0  
	MOV LR,PC  
	B FIBO  
END B END  


FIBO  
	ADD R3,R0,#0	; valores iniciales de la secuencia  
	SUB R0,R0,R0  
	ADD R1,R1,R1  
	ADD R2,R2,r2  
	ADD R1,R1,#1  
	ADD R0,R1,R2 	; Comienza la secuencia  
	STR R0,[R13, #4]  
	STR R1,[R13, #8]  
	LDR R1,[R13, #4]  
	LDR R2,[R13, #8]  
	SUBS R3,R3,#1  
	BGT #-8  
	MOV PC,LR  
	NOP  
	NOP  


//------------------------ ML


e0400000  
e2800006  
e04dd00d  
e28fe000  
ea000000  
eafffffe  
e2803000  
e0400000  
e0411001  
e0422002  
e2811001  
e0810002  
e58d0004  
e58d1008  
e59d1004  
e59d2008  
e2533001  
cafffff8  
e2888000  
e2888000  
e28ef000  
e2888000  
e2888000  
