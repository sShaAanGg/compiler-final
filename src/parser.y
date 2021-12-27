%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define STACK_SIZE 1000

void yyerror(const char *message);
int reserve_check(char *);

struct stack {
    int top;
    int arr[STACK_SIZE];
};
struct stack stack;
void push(int);
int pop();
int isEmpty();
int isFull();
%}

%union{
char *str;
}

%token <str> define IF fun print_num print_bool 

%token <str> LPAREN RPAREN ID 
%token <str> ADD SUB MUL DIV MOD GRT SML EQL AND OR NOT 
%token <str> BOOL INUM 

%type <str> EXP

%nonassoc LPAREN RPAREN
%%
PROGRAM : STMTs 
        ;
STMTs   : STMT STMTs | STMT ;
STMT    : EXP 
        | DEF-STMT
        | PRINT-STMT
        ;
PRINT-STMT  : LPAREN print_num EXP RPAREN {

}
            | LPAREN print_bool EXP RPAREN {

}
            ;
EXP     : BOOL | INUM | VAR | NUM-OP | LOGICAL-OP | FUN-EXP | FUN-CALL | if-EXP ;
EXPs    : EXP EXPs | EXP ;
NUM-OP  : PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER | SMALLER | EQUAL ;
PLUS    : LPAREN ADD EXP EXPs RPAREN {

};
MINUS   : LPAREN SUB EXP EXP RPAREN {

};
MULTIPLY   : LPAREN MUL EXP EXPs RPAREN {

};
DIVIDE     : LPAREN DIV EXP EXP RPAREN {

};
MODULUS    : LPAREN MOD EXP EXP RPAREN {

};
GREATER    : LPAREN GRT EXP EXP RPAREN {

};
SMALLER    : LPAREN SML EXP EXP RPAREN {

};
EQUAL      : LPAREN EQL EXP EXPs RPAREN {

};
LOGICAL-OP : and-OP | or-OP | not-OP ;
and-OP  : LPAREN AND EXP EXPs RPAREN {

};
or-OP   : LPAREN OR EXP EXPs RPAREN {

};
not-OP  : LPAREN NOT EXP RPAREN {

};

DEF-STMT : LPAREN define ID EXP RPAREN {

};
VAR     : ID {

};

FUN-EXP : LPAREN fun FUN-IDs FUN-BODY RPAREN {

};
FUN-IDs : LPAREN IDs RPAREN {

};
IDs     : ID IDs | ;
FUN-BODY : EXP {

};
FUN-CALL : LPAREN FUN-EXP ARGs RPAREN {

}
         | LPAREN FUN-NAME ARGs RPAREN {

}
         ;
ARGs    : ARG ARGs | ;
ARG     : EXP {

};
LAST-EXP : EXP {

};
FUN-NAME : ID {

};

if-EXP  : LPAREN IF TEST-EXP THEN-EXP ELSE-EXP RPAREN {

};
TEST-EXP : EXP {

};
THEN-EXP : EXP {

};
ELSE-EXP : EXP {

};

%%

void yyerror (const char *message) {
    fprintf (stderr, "%s\n",message);
}
int reserve_check(char *id_str) {
    int syntax_err = 0;
    if(strcmp(id_str, "mod") == 0 || strcmp(id_str, "and") == 0 || strcmp(id_str, "or") == 0 || strcmp(id_str, "not") == 0) {
        syntax_err = 1;
    } else if(strcmp(id_str, "define") == 0 || strcmp(id_str, "if") == 0 || strcmp(id_str, "fun") == 0) {
        syntax_err = 1;
    } else if(strcmp(id_str, "print-num") == 0 || strcmp(id_str, "print-bool") == 0) {
        syntax_err = 1;
    }

    if(syntax_err == 1) {
        printf("Syntax Error: ID must not be the same as reserved words!\n");
    }
}

void push(int i) {
    if(!isFull()) {
        stack.arr[stack.top] = i;
        stack.top++;
    } else {
        printf("Runtime Error: STACK OVERFLOW! (The size of stack is of 4000 bytes. That is, 1000 int\n");
        return;
    }
}
int pop() {
    if(!isEmpty()) {
        stack.top--;
        int temp = stack.arr[stack.top];
        return temp;
    } else {
        printf("Error: STACK UNDERFLOW!\n");
        return -1;
    }
}
int isEmpty() {
    if(stack.top == 0)
        return 1;
    else
        return 0;
}
int isFull() {
    if(stack.top == STACK_SIZE)
        return 1;
    else
        return 0;
}
int main(int argc, char *argv[]) {
    yyparse();
    return(0);
}
