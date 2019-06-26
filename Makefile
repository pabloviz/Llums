llums.x: llums.c
	gcc llums.c -o llums.x -lm
clean:
	rm llums.x
	rm .*.c.swp
	rm .*.swp
