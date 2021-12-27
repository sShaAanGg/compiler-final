#!/bin/bash
bison -d -o ./make/parser.tab.c ./src/parser.y
gcc -c -o ./make/parser.tab.o ./make/parser.tab.c
flex -o ./make/lex.yy.c ./src/scanner.l
gcc -c -o ./make/lex.yy.o ./make/lex.yy.c
gcc -o ./bin/interpreter ./make/lex.yy.o ./make/parser.tab.o -lfl
