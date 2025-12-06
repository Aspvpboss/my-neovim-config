
#include <stdio.h>
#include <stdlib.h>



int main(){
 
    int array_len = 10;
    int *array = malloc(sizeof(int) * array_len);
    
    for(int i = 0; i < array_len; i++){
        array[i] = i;
        printf("%d\n", array[i]);
    }

    

    free(array);
    array = NULL;

    return 0;
}
