; Programa que revisa si una hilera es palindromo o no
; Filip Sobejko B77382
; Ivan Chavarria B72097

section .data

; constante para la salida del programa
SYS_exit equ 60

; hileras a revisar
hilera1 db "adannocallaconnada",0
hilera2 db "anitalagordalagartonanotragaladrogalatina",0
hilera3 db "davidanadaeresmiamadanavidad",0
hilera4 db "secortasaritaatirasatroces",0
hilera5 db "asimaloirasorrosariolamisa",0
hilera6 db "saritasosaesidoneaenodiseasosatiras",0
hilera7 db "sorrebecahiceberror",0
hilera8 db "olamoromoramalo",0

; vector de hileras
drstring dq hilera1, hilera2, hilera3, hilera4, hilera5, hilera6, hilera7, hilera8

; seccion de codigo
section .text
global _start
_start:

mov rcx, 8				; rcx tiene la cantidad de palabras

mov r8, 0 				; contador para startStringLoop
mov r9, 0				; contador para el ciclo getStringLength
mov r10, 0				; contador tamaño de la palabra

mov rsi, 0 				; puntero al inicio de la palabra 
mov rdi, 0 				; puntero al final de la palabra, lo obtenemos con el ciclo getStringLength

mov al, 128				; registro que contiene el mayor numero a sumar y que se ira dividiendo conforme iteremos
xor r11b, r11b			; registro que tendra el resultado
						
startStringLoop:
	xor r13, r13			; registro que contendra el caracter inicial a comparar
	xor r14, r14			; reigstro que contendra el caracter final a comparar
	xor rsi, rsi			; puntero al caracter inicial
	xor rdi, rdi			; puntero al caracter final
	xor rbx, rbx			; registro que guardara cada palabra
	xor r9, r9				; registro que servira como puntero para movernos de caracter en caracter
	xor r10, r10			; registro que tendra el tamano de cada palabra
	mov rbx, qword [drstring+(r8*8)]		; movemos de palabra en palabra al rbx
	jmp getStringLength

endPalabraLoop:
	inc r8				
	loop startStringLoop 		; la instruccion loop decrementa rcx y si no es 0 brinca a startStringLoop

jmp last						; saltara a last cuando ya se hayan revisado todas las palabras

getStringLength:
	cmp [rbx+r9], byte 0   	; comparo si caracter actual es 0, o sea, si ya se llego al nulo
	jz setPunteroFinal		; si es 0, es porque llego al final de la palabra

	inc r9					; para movernos de caracter en caracter
	inc r10					; tamano palabra++
		
	jmp getStringLength
	
setPunteroFinal:
	cmp r10, 1			; caso especial de que la palabra solo tenga una letra 		
	je isPalindrome		; salta inmediatamente a que es palindromo
	
	mov rdi, r10		; el tamano de la palabra se va a establecer como el valor del puntero del caracter final

palindromeLoop:
	mov r13b, byte [rbx+rsi]			; muevo el primer caracter al registro, luego el segundo, etc
	mov r14b, byte [rbx+rdi-1]			; muevo el ultimo caracter al registro, luego el penultimo, etc
	
	cmp r13b, r14b						; si el primer caracter es diferente del ultimo caracter
	jne notPalindrome   				; sálgase del ciclo, funciona como un return, ya que no va a ser palindromo
	
	inc rsi								; incremento al puntero inicio
	dec rdi								; decremento el puntero final
	
	cmp rdi, rsi						; comparacion para impares
	jl isPalindrome						; salgase del ciclo, es palindromo, explicacion mas detallada en el documento 

	cmp rsi, rdi						; comparacion para pares			
	je isPalindrome  					; salgase del ciclo, es decir, se termino de comparar todos los caracteres	
	
	jmp palindromeLoop

notPalindrome:			
	shr al, 1							; si no es palindromo hacemos un shr para dividir nuestro valor en el registro entre dos...
	jmp endPalabraLoop					; ...ya que no lo ocupamos sumar
	
isPalindrome:
	or r11b, al							; si es palindromo hacemos un or para "sumar" el resultado a nuestro registro que tiene el resultado
	shr al, 1 							; hacemos un shr para dividir nuestro valor en el registro
	jmp endPalabraLoop
	
; ************************************************************
; ultima ejecucion del programa

last:
	mov rax, SYS_exit 					; llama a la salida del programa
	mov dil, r11b 						; se pasa nuestro registro resultado al dil para poder usar la variable de ambiente...
	syscall								; ...y de esa manera obtener el resultado
