
default: json_build build run 

json_build:
	compiledb -n -- make build 

build:
	gcc main.c -o main.exe -IC:\\msys64\\mingw64\\include -Iinclude


run:
	main.exe

clean:
	rm -f main.exe
