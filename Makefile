.PHONY: all run clean

all: snake
	./snake

snake: snake.c
	cc snake.c -lcurses -o snake

run: snake
	./snake

clean:
	rm -f snake
