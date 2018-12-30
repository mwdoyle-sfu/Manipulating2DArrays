SFLAGS = -S -O2
OFLAGS = -g -c
CFLAGS = -o ma

all: ma 

ma: main.o matrix.o
	gcc $(CFLAGS) main.o matrix.o

main.o:	main.s
	gcc $(OFLAGS) main.s

main.s:	main.c
	gcc $(SFLAGS) main.c

matrix.o:	matrix.s
	gcc $(OFLAGS) matrix.s

clean:	
	rm -f ma *.o 
