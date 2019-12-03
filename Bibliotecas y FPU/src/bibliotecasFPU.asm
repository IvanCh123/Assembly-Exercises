extern scanf
extern printf

section	.data
	
	SYS_EXIT equ 60
	EXIT_SUCCESS equ 0

	separadorDeLinea db "--------------------------------------------------", 0
	indicacionDelPrograma db "Para evaluar la ecuación, ingrese intervalos de signo opuesto: ", 0
	pedirA db "Inserte el punto A: ", 0
	pedirB db "Inserte el punto B: ", 0
	pedirEpsilon db "Inserte el valor del error maximo permitido: ", 0
    
    encontroCero db "Se encontró un cero aproximado, los intervalos usados fueron: ", 0
    
    formatoGenerico db "%s", 0
    formatoGenericoSaltaLinea db "%s", 10, 0
    formatoImprimeIntervaloA db "Intervalo A: %lf", 10, 0
    formatoImprimeIntervaloB db "Intervalo B: %lf", 10, 0
    formatoImprimePuntoInterior db "Punto a evaluar: %lf", 10, 0
    formatoImprimePuntoInteriorEvaluado db "Punto evaluado: %lf", 10, 0
    formatoImprimeEvaluaciones db "Cantidad de evaluaciones para llegar a cero: %ld", 10, 0
    formatoFloat db "%lf", 0
    
    vectorDePuntos dq 0.0, 0.0, 0.0
    vectorDePuntosEvaluados dq 0.0, 0.0, 0.0
    
    valorEpsilon dq 0.0
    
    valorParaOpAritmeticas dq 1.0
    valorCero dq 0.0
    valorTres dq 3.0
    valorCinco dq 5.0
	
section .bss

	valorSin resq 1
	valorLn resq 1
	valorNum resq 1
	valorDen resq 1
	valorTercerTermino resq 1
	valorFinal resq 1
	valorPuntoInterior resq 1
	
section .text

	global main
		
main:

	push rbp
	mov rbp, rsp
	mov	rdi, formatoGenericoSaltaLinea
	mov rsi, separadorDeLinea
	xor rax, rax
	call printf
	pop rbp
	
	push rbp
	mov rbp, rsp
	mov	rdi, formatoGenericoSaltaLinea
	mov rsi, indicacionDelPrograma
	xor rax, rax
	call printf
	pop rbp
	
	push rbp
	mov rbp, rsp
	mov	rdi, formatoGenerico
	mov rsi, pedirA
	xor rax, rax
	call printf
	pop rbp
    
    push rbp
    mov rbp, rsp
	mov rdi, formatoFloat
	mov rsi, vectorDePuntos
	xor rax, rax
	call scanf
    pop rbp
    
    push rbp
    mov rbp, rsp
	mov rdi, formatoGenerico
	mov rsi, pedirB
	xor rax, rax
	call printf
	pop rbp
	
	push rbp
    mov rbp, rsp
	mov rdi, formatoFloat
	mov rsi, vectorDePuntos+8
	xor rax, rax
	call scanf
    pop rbp
    
    push rbp
    mov rbp, rsp
	mov rdi, formatoGenerico
	mov rsi, pedirEpsilon
	xor rax, rax
	call printf
	pop rbp
	
	push rbp
    mov rbp, rsp
	mov rdi, formatoFloat
	mov rsi, valorEpsilon
	xor rax, rax
	call scanf
    pop rbp
    
    
    mov r14, 2
    xor r15, r15
    xor rcx, rcx
    
calcularSeno:
	
	fld qword[vectorDePuntos+r15*8]
	fsin
	fstp qword[valorSin]
	
calcularLogNat:

	fld qword[valorParaOpAritmeticas]
	fldl2e
	fdivp st1, st0
	
	fld qword[vectorDePuntos+r15*8]
	fmul st0, st0
	fld qword[valorParaOpAritmeticas]
	faddp st1, st0
	fyl2x
	fstp qword[valorLn]

calcularNumerador:

	fld qword[valorTres]
	fld qword[vectorDePuntos+r15*8]
	fmul st0, st0
	fmul qword[vectorDePuntos+r15*8]
	fmulp st1, st0
	
	fld qword[vectorDePuntos+r15*8]
	fmul st0, st0
	fld qword[valorCinco]
	fmulp st1, st0
	
	fsubp st1, st0
	
	fld qword[vectorDePuntos+r15*8]
	fsubp st1, st0
	
	fld qword[valorParaOpAritmeticas]
	faddp st1, st0
	
	fstp qword[valorNum]
	
calcularDenominador:
	
	fld qword[vectorDePuntos+r15*8]
	fmul st0, st0
	fmul st0, st0
	
	fld qword[valorParaOpAritmeticas]
	faddp st1, st0
	
	fstp qword[valorDen]
	
calcularTercerTermino:

	fld qword[valorNum]
	fld qword[valorDen]
	
	fdivp st1, st0
	fstp qword[valorTercerTermino]
	
calcularFuncionFinal:

	fld qword[valorSin]
	fld qword[valorLn]
	fmulp st1, st0
	
	fld qword[valorTercerTermino]
	faddp st1, st0
	
	fstp qword[vectorDePuntosEvaluados+r15*8]
	
	;movsd xmm0, qword[valorFinal]
	;movsd [vectorDePuntosEvaluados+r15*8], xmm0
	
    ;Para imprimir el primer valor instertado y revisar que esté bien
    
    ;push rbp
    ;mov rbp, rsp
	;mov rdi, fmt2
	;movsd xmm0, qword[vectorDePuntosEvaluados+r15*8]
	;mov rax, 1
	;call printf
    ;pop rbp
    
revisaSiHayQueEvaluar:

	dec r14
	inc r15
	cmp r14, 0
	jne calcularSeno
    
revisarSiSeEstaEvaluandoPuntoInterior:
	
	cmp rbx, 0
	jne comparoConEpsilon
	
evaluarPuntoInterior:

	fld qword[vectorDePuntosEvaluados+8]
	fld qword[vectorDePuntos]
	fmulp st1, st0
	
	fld qword[vectorDePuntosEvaluados]
	fld qword[vectorDePuntos+8]
	fmulp st1, st0
	
	fsubp st1, st0
	
	fld qword[vectorDePuntosEvaluados+8]
	fld qword[vectorDePuntosEvaluados]
	fsubp st1, st0
	
	fdivp st1, st0
	fstp qword[valorPuntoInterior]
	
	movsd xmm0, qword[valorPuntoInterior]
	movsd [vectorDePuntos+16], xmm0
	mov r14, 1
	mov rbx, 1
	jmp calcularSeno
	
comparoConEpsilon:

	dec rbx
	inc rcx
	
	fld qword[vectorDePuntosEvaluados+16]
	fabs
	fstp qword[vectorDePuntosEvaluados+16]
	
	movsd xmm0, qword[vectorDePuntosEvaluados+16]
	ucomisd xmm0, qword[valorEpsilon]
	
	jb seEncontroCero
	
	jmp prepararNuevoIntervalo
	
seEncontroCero:

	mov r14, rcx
	
	push rbp
	mov rbp, rsp
	mov	rdi, formatoGenericoSaltaLinea
	mov rsi, separadorDeLinea
	xor rax, rax
	call printf
	pop rbp
	
	push rbp
	mov rbp, rsp
	mov	rdi, formatoGenericoSaltaLinea
	mov rsi, encontroCero
	xor rax, rax
	call printf
	pop rbp
	
    push rbp
    mov rbp, rsp
	mov rdi, formatoImprimePuntoInterior
	movsd xmm0, qword[vectorDePuntos+16]
	mov rax, 1
	call printf
    pop rbp
    
    push rbp
    mov rbp, rsp
	mov rdi, formatoImprimePuntoInteriorEvaluado
	movsd xmm0, qword[vectorDePuntosEvaluados+16]
	mov rax, 1
	call printf
    pop rbp
    
    push rbp
    mov rbp, rsp
	mov rdi, formatoImprimeEvaluaciones
	mov rsi, r14
	xor rax, rax
	call printf
    pop rbp
    
    push rbp
	mov rbp, rsp
	mov	rdi, formatoGenericoSaltaLinea
	mov rsi, separadorDeLinea
	xor rax, rax
	call printf
	pop rbp
    
    jmp last

prepararNuevoIntervalo:

	movsd xmm0, qword[vectorDePuntosEvaluados]
	movsd xmm1, qword[vectorDePuntosEvaluados+16]
	mulsd xmm0, xmm1
	
	ucomisd xmm0, qword[valorCero]
	jb puntoInteriorNegativo

puntoInteriorPositivo:
	
	movsd xmm0, qword[vectorDePuntos+16]
	movsd [vectorDePuntos], xmm0
	
	mov r14, 2
	mov r15, 0
	jmp calcularSeno

puntoInteriorNegativo:
	
	movsd xmm0, qword[vectorDePuntos+16]
	movsd [vectorDePuntos+8], xmm0
	
	mov r14, 2
	mov r15, 0
	jmp calcularSeno
	
last:

	mov rax, SYS_EXIT
	mov rdi, EXIT_SUCCESS
	syscall	
