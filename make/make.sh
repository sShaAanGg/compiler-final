#!/bin/bash
bison -d -o parser.tab.c ../src/parser.y
gcc -c parser.tab.c
flex -o lex.yy.c ../src/scanner.l
gcc -c lex.yy.c
gcc -o ../bin/interpreter lex.yy.o parser.tab.o -lfl
