CFLAGS= -g -std=c99
all: main

main: sha256.o main.o
	gcc main.o sha256.o -o main
clean:
	rm -f *.o
	rm -f main
	rm -f sha256
