/**
 * Ivan Chavarría Vega, B72097
 * Cuarta Tarea Programada: Llamado recursivo
 * Lunes 01 de Julio
*/

extern void fun(int n);

#include <stdio.h>

/*void fun(int n)
{
	if(n > 0){
		fun(n-1);
		printf("%d ", n);
		fun(n-1);
	}
}*/

int main()
{
	fun(4);
	printf("\n");
	return 0;
}
