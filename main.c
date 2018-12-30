/*
 * Filename: main.c
 * Description: Main driver for matrix manipulating functions
 * Date: Oct. 2018
 * Name: Matt Doyle
 */

#include <stdio.h>   // printf()

#define N 4

void copy(void *, void *, int);
void transpose(void *, int );
void reverseColumns(void *, int);
void multiply(void *, void *, void *, int);
void printMatrixByRow(void *, int);

/* Test Case 1 */
char A[N][N] = { 1,  -2,   3,  -4,
                -4,   3,  -2,   1,
                -1,   2,  -3,   4,
                 4,  -3,   2,  -1};

/* Expected results
char C[N][N] = { -10,  10, -10,  10,
                 -10,  10, -10,  10,
                  10, -10,  10, -10,
                  10, -10,  10, -10};
*/

char B[N][N];
char C[N][N];

void main() {
    int i = 0;
    int j = 0;

    printf("Matrix A: \n");
    printMatrixByRow(A, N);  

    printf("Matrix B where B is transpose of A: \n");
    copy(A, B, N);
    transpose(B, N);
    printMatrixByRow(B, N); 

    // printf("Rotating the matrix by 90 degrees clockwise: \n");
    // transpose(B, N);
    // reverseColumns(B, N);
    // printMatrixByRow(B, N);

    printf("Multiplying matrices A and B - their product is matrix C: \n");
    multiply(A, B, C, N);
    printMatrixByRow(C, N);

    return;
}

void printMatrixByRow(void *D, int n) {
    int i, j;

    for (i = 0; i < n; i++) {
        printf("%4d %4d %4d %4d", *((char*)(D + i*n + 0)), *((char*)(D + i*n + 1)), *((char*)(D + i*n + 2)), *((char*)(D + i*n + 3)));
        printf("\n");
    }
    printf("\n");
}
