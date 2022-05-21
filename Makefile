CC := gcc
CFLAGS := -W -g -lfl

parser := parser.y
parser_c := parser.tab.c
parser_h := parser.tab.h
parser_o := parser.tab.o

scanner := scanner.l
scanner_c := scanner.yy.c
scanner_o := scanner.yy.o

target := ./bin/interpreter

build: $(target)

clean:
	-rm ./bin/*
	-rm *.o
	-rm $(parser_c)
	-rm $(parser_h)
	-rm $(scanner_c)
	-rm $(target)

$(parser_c): $(parser)
	bison -d -o $(parser_c) $(parser)

$(parser_o): $(parser_c)
	$(CC) -c -o $(parser_o) $(parser_c)

$(scanner_c): $(parser_h)
	flex -o $(scanner_c) $(scanner)

$(scanner_o): $(scanner_c)
	$(CC) -c -o $(scanner_o) $(scanner_c)

$(target): $(parser_o) $(scanner_o)
	$(CC) $(CFLAGS) ./*.o -o $(target)
