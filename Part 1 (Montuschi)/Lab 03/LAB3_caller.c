// Lab 03
// Code by Martino Mensio
#include <stdio.h>
#include <stdlib.h>
extern unsigned int countweeks(char* date);

int main() {
    int result = 0;
    char param[256];// = "12/02/04";
    int yy, mm, dd, n;

    printf("Please insert a date in the format dd/mm/yy: ");
    scanf("%s", param);
    n = sscanf(param, "%d/%d/%d", &dd, &mm, &yy);
    if (strlen(param) != 8 || n !=3 || dd < 1 || dd > 31 || mm < 1 || mm > 12 || yy < 0 || yy > 99)
    {
        printf("Format not valid.");
        return 1;
    }
    result = countweeks(param);
    printf("The number of weeks from 01/01/00 is: %d",result);
    return 0;
}