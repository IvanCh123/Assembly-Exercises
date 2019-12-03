; yasm -f elf64 fun.asm -o fun.o
; gcc -no-pie -o funxd fun.o main.c

extern printf				
section .data
	formato db "%d ",0

section .text

global fun			; "global" permita que este programa sea leído por otros
fun:
	push rbp		; guardamos rsp en la pila para crear el stack frame
	mov rbp,rsp		; movemos la dirección de retorno a rbp
	push r12
	xor r12,r12		; limpiamos r12
	
	cmp rdi,0		; si rdi no es 0, significa que aun no hemos terminado
	jle last		; si es lower or equal a 0, brtincamos a last para terminar el programa
	
	mov r12,rdi		; movemos el dato que se pasa como parámetro en 0
	sub rdi,1		; le restamos uno, porque asi nos lo dicen en la función en C
	call fun		; llamamos a fun, aquí es donde se hace lo recursivo de llamarse a si mismo
	
	mov rax,r12		; movemos a rax el valor actual de r12, que sería el "resultado" de  los llamados

	push rbp			; creamos el stackframe para imprimir
	mov rbp, rsp		; guardamos la dirección de retorno a rbp
	mov rdi, formato	; movemos a rsi el formado a imprimir "%d "
	mov rsi, rax		; movemos a rsi rax el cual tiene el "resultado"
	xor rax, rax		; limpiamos rax
	call printf			; llamamos a printf, aquí printf imprime lo que le pasemos por rdi y rsi respectivamente
	pop rbp				; sacamos a rbp, la pos de retorno vuelve donde estaba

	mov rdi,r12		; movemos a rdi el valor de r12, el cual es 
	sub rdi,1		; restamos 1 a rdi
	call fun  		; hacemos el llamado recursivo con rdi - 1

	pop r12			; sacamos de la pila el registro que preservamos
	pop rbp			; lo mismo, con esto volvemos a tener la variable de retorno en la dirección esperada
	ret				; retornamos 

last:
	pop r12			; recuperamos registros
	pop rbp			; 			|| 
	ret				; nos salimos del programa
