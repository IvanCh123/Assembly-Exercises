; Programa que revisa si una hilera es palindromo o no
; Filip Sobejko B77382
; Ivan Chavarria B72097

; Funcion que simula la ejecucion de instrucciones 
; Las instrucciones a simular seran add y sub

; ------

; HLL call:
; instr( cod Op, t1, Op1, t2, Op2, t3, Op3, memarray, registers)

; ------

; Argumentos:
; cod Op ---- 4 para el add, 8 para el sub ---- dil
; t1 ---- tipo: registro o rreglo de memoria ---- rsi
; Op1 ---- operando, ya sea el registro o un numero ----rdx
; t2 ---- tipo: registro o rreglo de memoria ---- rcx
; Op2 ---- operando, ya sea el registro o un numero ----r8
; t3 ---- tipo: registro o arreglo de memoria ---- r9
; Op3 ---- operando, ya sea el registro o un numero ---- ubicado en +16 en pila
; memarray ---- puntero al inicio del arreglo de memoria --- ubicado en +24 en pila
; registros ---- puntero al primer registro ---- ubicado en +32 en pila

instr:

esNegativo:
	
	push rbp				; registro que va a tener el puntero al stack frame
	mov rbp, rsp			; se mueve el puntero de rsp que tiene el stack frame a rbp
	push r11				; registro donde se va a guardar la direccion de Op3
	push r12				; registro donde se va a guardar el Op2
	push r13				; registro donde se va a guardar el Op3
	push r14				; registro que va a tener el puntero a los registros
	push r15				; registro que va a tener el puntero al memarray
	push rbx				; registro que va a tener la direccion de Op3
	
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	xor rbx, rbx
	
	mov r11, [rbp+16]		; r11 se convierte en el puntero al Op3
	mov r14, [rbp+32]		; r14 se convierte en el puntero al incio del vector de registros
	mov r15, [rbp+24]		; r15 se convierte en el puntero al inicio del vecotr de memoria
	
	cmp dil,  8				; compara dil con 8, para ver si es el codigo de operacion es resta
	je invertirSigno		; si es 8, salta a la etiqueta invertirSigno, donde posteriormente se invertira el Op3
		
	cmp rcx, 1				; compara rcx (t2) con un 1, para ver si es de tipo reigstro
	jne esMemoria2			; si no es, lo manda a revisar si es memoria
	mov rbx, [r14+r8*8]		; si es registro, entonces mueve a rbx la direccion del registro deseado del vector de registros
	mov r12, rbx			; muevo a r12 el valor que esta en ese registro
	jmp esRegistro3			; salta a revisar el Op3
	
esMemoria2:
	cmp rcx, 2				; revisa rcx (t2) con un 2, para ver si es de tipo memoria
	jne esInmediato2		; si no es, lo manda a revisar si es inmediato
	mov r12, [r15+r8]		; si es memoria, entonces mueve a r12 la direccion de memoria que esta en r8 (indica que posicion de memoria)
	jmp esRegistro3			; salta a revisar el Op3
	
esInmediato2:
	mov r12, r8				; si no fue registro, ni memoria, es inmediato, entonces mueve a r12, el inmediato que esta en r8
	
esRegistro3:
	cmp r9, 1				; compara r9 (t3) con un 1, para ver si es de tipo registro
	jne esMemoria3			; si no es, lo manda a revisar si es memoria
	mov rbx, [r14+r11*8]	; si es registro, entonces mueve a rbx la direccion del registro deseado del vector de registros
	mov r13, rbx			; posteriormente, si es registro, entonces movemos a r13 el registro deseado (rbx) recorriendo r14
	jmp sumarRegistro		; salto a sumar registro
	
esMemoria3:
	cmp r9, 2				; compara r9 (t3) con un 2, para ver si es de tipo memoria
	jne esInmediato3		; si no es, lo manda a revisar si es inmediato
	mov r13, [r15+r11]		; posteriormente, si es memoria, entonces movemos a r13 la direccion de memoria (rbx) recorriendo r15
	jmp sumarRegistro		; salto a sumar reigstro
	
esInmediato3:
	mov r13, r11			; si no fue registro, ni memoria, significa que el Op3 es un inmediato, enntonces accedemos a la pila y lo movemos a r13
	
sumarRegistro:
	cmp rsi, 1				; si rsi (t1) es igual a uno, entonces significa que vamos a guardar nuestra suma del Op2 y Op3 en un registro
	jne sumarMemoria		; si no es igual uno, significa que vamos a guardar dicha suma en el arreglo de memoria
	add r12, r13			; sumamos lo que haya en el registro r12 y r13
	mov [r14+rdx*8], r12	; la suma que se hizo, se va a guardar en el registro indicado por rdx, recorriendo r14 para acceder a dicho reigstro 
	jmp final				; salto a last para terminar la ejecucion de instr
	
sumarMemoria:
	add r12, r13			; si llegamos a este punto, significa que nuestra suma se va a guardar en el arreglo de memoria
	mov [r15+rdx], r12		; movemos el resultado que quedo en r12 a la posicion del arreglo de memoria indicado por rdx, recorriendo r15
	jmp final				; salto a last para terminar la ejecucion de instr
	
invertirSigno:
	cmp r9, 1				; en este punto se compara r9 (t3) con un uno para ver si es de tipo reigstro
	jne esMemoriaNe			; si no es, salta a la comparacion de memoria
	mov rbx, [r14+r11*8]	; muevo a rbx el contenido del registro deseado
	not rbx					; invierto Op3
	inc rbx					; incremento en uno, complemento a 2
	mov [r14+r11*8], rbx	; muevo al registro el valor invertido
	mov dil, 4				; muevo a dil (cod de operacion) un 4, para indicar que ahora quiero realizar una suma 
	push r14				; push para el llamado recursivo
	push r15				; push para el llamado recursivo
	push r11				; push para el llamado recursivo
	call instr				; llamo a instr recursivamente, con el cod op en 4 para realizar la suma, y el Op3 inveritdo el signo

pop r11
pop r15
pop r14
jmp final
	
esMemoriaNe:
	cmp r9, 2				; se compara r9 (t3) con un dos para ver si es de tipo memoria
	jne esInmediatoNe		; si no es, salta al inmediato
	mov rbx, [r15+r11]		; muevo a rbx el contenido de la posicion de memoria deseada
	not rbx					; invierto Op3
	inc rbx					; incremento en uno, complemento a 2
	mov [r15+r11], rbx		; muevo a la posicion de memoria el valor invertido
	mov dil, 4				; muevo a dil (cod de operacion) un 4, para indicar que ahora quiero realizar una suma
	push r14				; push para el llamado recursivo
	push r15				; push para el llamado recursivo
	push r11				; push para el llamado recursivo
	call instr				; llamo a instr recursivamente, con el cod op en 4 para realizar la suma, y el Op3 invertido el signo

pop r11
pop r15
pop r14
jmp final

esInmediatoNe:
	mov rbx, r11			; se mueve a rbx el Op3
	not rbx					; invierto Op3
	inc rbx					; incremento en uno, complemento a 2
	mov [r11], rbx			; muevo al contenido del Op3, el valor ya invertido
	mov dil, 4				; muevo a dil (cod de operacion) un 4, para indicar que ahora quiero realizar una suma
	push r14				; push para el llamado recursivo
	push r15				; push para el llamado recursivo
	push r11				; push para el llamado recursivo
	call instr				; llamo a instr recursivamente, con el cod op en 4 para realizar la suma, y el Op3 invertido el signo
	
pop r11
pop r15
pop r14

final:						; limpio los registros de la pila en el orden que se  metieron	
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop rbp
	ret

section .data

; constante para la salida del programa
SYS_exit equ 60
EXIT_SUCCESS equ 0

; registros de 64 bits
r0 dq 0
r1 dq 0
r2 dq 0
r3 dq 0

; vector de registros
registers dq r0, r1, r2, r3

; memarray
memarray times 1024 db 0

; seccion de codigo
section .text
global _start
_start:

mov r10, 0

push registers
push memarray
push r10

mov r9, 3
mov r8, 100
mov rcx, 3
mov rdx, 0
mov rsi, 1
mov rdi, 4
call instr

pop r10
mov r10, 50
push r10

mov r9, 3
mov r8, 0
mov rcx, 1
mov rdx, 200
mov rsi, 2
mov rdi, 4
call instr

pop r10
mov r10, 200
push r10

mov r9, 2
mov r8, 1000
mov rcx, 3
mov rdx, 40
mov rsi, 2
mov rdi, 8
call instr

; ************************************************************
; ultima ejecucion del programa

last:
	mov rax, SYS_exit
	mov rdi, EXIT_SUCCESS
	syscall								; llama a la salida del programa
