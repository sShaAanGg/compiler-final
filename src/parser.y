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
    int arr_bool_flag[STACK_SIZE];
};
struct stack stack;
void push(int, int);
int pop();
int isEmpty();
int isFull();
int isBool(int);

/*int args_stack[STACK_SIZE];*/

int base_ptr = 0;
int num_args = 0;

int check_type(char *);
void dump_stack();
%}

%union{
char *str;
}

%token <str> define IF fun print_num print_bool 

%token <str> LPAREN RPAREN ID 
%token <str> ADD SUB MUL DIV MOD GRT SML EQL AND OR NOT 
%token <str> BOOL INUM 

%type <str> EXP NUM-OP PLUS MINUS MULTIPLY DIVIDE MODULUS GREATER SMALLER EQUAL VAR FUN-EXP FUN-CALL if-EXP
%type <str> LOGICAL-OP and-OP or-OP not-OP

%nonassoc LPAREN RPAREN
%%
PROGRAM : STMTs ;
STMTs   : STMT STMTs | STMT ;
STMT    : EXP 
        | DEF-STMT
        | PRINT-STMT ;
PRINT-STMT  : LPAREN print_num EXP RPAREN {

    if(check_type("number") == 1) { /* type correct */
        int tmp = pop();
        printf("%d\n", tmp);
    } else { /* type error */
        printf("Type Error: Expect 'number' but got 'boolean'.\n");
    }
}
            | LPAREN print_bool EXP RPAREN {

    if(check_type("boolean") == 1) { /* type correct */
        char * bool;
        int tmp = pop();
        if(tmp == 1) {
            bool = "#t";
        } else {
            bool = "#f";
        }
        printf("%s\n", bool);
    } else { /* type error */
        printf("Type Error: Expect 'boolean' but got 'number'.\n");
    }
};

EXP     : INUM {
    $$ = $1;
    int num = atoi($1);
    push(num, 0);
    
}       | BOOL {
    $$ = $1;
    if(strcmp($1, "#t") == 0) {
        push(1, 1);
    } else {
        push(0, 1);
    }

}       | VAR | NUM-OP { $$ = $1; } | LOGICAL-OP {} | FUN-EXP {} | FUN-CALL {} | if-EXP {} ;
EXPs    : EXP EXPs {
    
}       | EXP {
    
};

NUM-OP  : PLUS { $$ = $1; } | MINUS { $$ = $1; } | MULTIPLY { $$ = $1; } | DIVIDE { $$ = $1; } | MODULUS { $$ = $1; } 
        | GREATER { $$ = $1; } | SMALLER { $$ = $1; } | EQUAL { $$ = $1; } ;

PLUS    : LPAREN { base_ptr = stack.top; } ADD EXP EXPs RPAREN {
    $$ = "PLUS";
    num_args = stack.top - base_ptr;
    int result = 0;
    for(int i=0; i<num_args; i++) {
        if(check_type("number") == 1) {
            result += pop();
        } else {    /* type error */
            printf("Expect 'number' but got 'boolean'\n");
        }
    }
    push(result, 0);
    dump_stack();
}          ;
MINUS   : LPAREN SUB EXP EXP RPAREN {
    $$ = "MINUS";

}          ;
MULTIPLY   : LPAREN MUL EXP EXPs RPAREN {
    $$ = "MULTIPLY";

}          ;
DIVIDE     : LPAREN DIV EXP EXP RPAREN {
    $$ = "DIVIDE";

}          ;
MODULUS    : LPAREN MOD EXP EXP RPAREN {
    $$ = "MODULUS";

}          ;
GREATER    : LPAREN GRT EXP EXP RPAREN {
    $$ = "GREATER";

}          ;
SMALLER    : LPAREN SML EXP EXP RPAREN {
    $$ = "SMALLER";

}          ;
EQUAL      : LPAREN EQL EXP EXPs RPAREN {
    $$ = "EQUAL";

}          ;

LOGICAL-OP : and-OP { $$ = $1; } | or-OP { $$ = $1; } | not-OP { $$ = $1; } ;
and-OP  : LPAREN AND EXP EXPs RPAREN {
    $$ = "and-OP";

}       ;
or-OP   : LPAREN OR EXP EXPs RPAREN {
    $$ = "or-OP";

}       ;
not-OP  : LPAREN NOT EXP RPAREN {
    $$ = "not-OP";

}       ;

DEF-STMT : LPAREN define ID EXP RPAREN {

}       ;
VAR     : ID {

}       ;

FUN-EXP : LPAREN fun FUN-IDs FUN-BODY RPAREN {

}       ;
FUN-IDs : LPAREN IDs RPAREN {

};
IDs     : ID IDs | ;
FUN-BODY : EXP {

}        ;
FUN-CALL : LPAREN FUN-EXP ARGs RPAREN {

}
         | LPAREN FUN-NAME ARGs RPAREN {

}       ;
ARGs    : ARG ARGs | ;
ARG     : EXP {

}        ;
LAST-EXP : EXP {

}        ;
FUN-NAME : ID {

}       ;

if-EXP  : LPAREN IF TEST-EXP THEN-EXP ELSE-EXP RPAREN {

}        ;
TEST-EXP : EXP {

}        ;
THEN-EXP : EXP {

}        ;
ELSE-EXP : EXP {

}        ;

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

void push(int i, int bool_flag) {   /* i is either INUM or BOOL, which depends on bool_flag */
    if(!isFull()) {
        if(bool_flag == 1) {
            stack.arr_bool_flag[stack.top] = 1;
            stack.arr[stack.top] = i;
            stack.top++;
        } else {
            stack.arr_bool_flag[stack.top] == 0;
            stack.arr[stack.top] = i;
            stack.top++;
        }
    } else {
        printf("Runtime Error: STACK OVERFLOW! (The size of stack is of 4000 bytes. That is, 1000 int\n");
        return;
    }
}
int pop() {
    if(!isEmpty()) {
        int temp;
        if(stack.arr_bool_flag[stack.top - 1] == 1) {
            stack.top--;
            temp = stack.arr[stack.top];
        } else {
            stack.top--;
            temp = stack.arr[stack.top];
        }
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
int isBool(int index) {
    if(stack.arr_bool_flag[index] == 1) {
        return 1;
    }
    else {
        return 0;
    }
}

int check_type(char *str) {
    if(strcmp(str,"boolean") == 0) {
        if(isBool(stack.top -1) == 1) { /* type correct */
            return 1;
        } else {
            return 0;
        }
    } else if(strcmp(str, "number") == 0) {
        if(isBool(stack.top -1) == 0) { /* type correct */
            return 1;
        } else {
            return 0;
        }
    } else if(strcmp(str, "function") == 0) {

    }
}

int main(int argc, char *argv[]) {
    yyparse();
    return(0);
}

void dump_stack() {
    printf("Stack content(from bottom to top) is: ");
    int i = 0;
    while(i < stack.top) {
        printf("%d ",stack.arr[i]);
        i++;
    }
    printf("\n");
}
