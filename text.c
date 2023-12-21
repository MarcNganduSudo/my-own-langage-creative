/* FICHIER GENERE PAR LE COMPILATEUR SIMPLE */

#include<stdlib.h>
#include<stdbool.h>
#include<stdio.h>
#include<string.h>

int main(void){
	printf("%s","---------------------------------TABLE DE MULTIPLICATION---------------------------------\n");
	printf("%s","|X\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t|\n");
	long Se_i=0;
	int i0;
	for(i0=0;i0<10;i0++){
	long Se_j=0;
	Se_i++;
	printf("%s","|");
	printf("%ld",Se_i);
	int i1;
	for(i1=0;i1<10;i1++){
	Se_j++;
	printf("%s","\t");
	printf("%ld",Se_i*Se_j);
	}
	printf("%s","\t|\n");
	}
	printf("%s","-----------------------------------------------------------------------------------------\n");
	return EXIT_SUCCESS;
}
