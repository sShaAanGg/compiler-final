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

int base_ptr = 0;
int num_OP(int, int, char *);
int logic_OP(int, int, char *);

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
%type <str> PROGRAM STMTs STMT PRINT-STMT DEF-STMT LOGICAL-OP and-OP or-OP not-OP

%nonassoc LPAREN RPAREN
%%
PROGRAM : STMTs  { $$ = $1; } ;
STMTs   : STMT STMTs { $$ = $1; } | STMT { $$ = $1; } ;
STMT    : EXP { $$ = $1; }
        | DEF-STMT { $$ = $1; }
        | PRINT-STMT { $$ = $1; } ;
PRINT-STMT  : LPAREN print_num EXP RPAREN {
    $$ = $3;
    if(check_type("number") == 1) { /* type correct */
        int tmp = pop();
        printf("%d\n", tmp);
    } else { /* type error */
        printf("Type Error: Expect 'number' but got 'boolean'.\n");
    }
}
            | LPAREN print_bool EXP RPAREN {
    $$ = $3;
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

PLUS    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } ADD EXP EXPs RPAREN {
    $$ = "PLUS";
    int result = num_OP(stack.top, base_ptr, "PLUS");
    base_ptr = pop();
    push(result, 0);
}          ;
MINUS   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } SUB EXP EXP RPAREN {
    $$ = "MINUS";
    int result = num_OP(stack.top, base_ptr, "MINUS");
    base_ptr = pop();
    push(result, 0);
}          ;
MULTIPLY   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } MUL EXP EXPs RPAREN {
    $$ = "MULTIPLY";
    int result = num_OP(stack.top, base_ptr, "MULTIPLY");
    base_ptr = pop();
    push(result, 0);
}          ;
DIVIDE     : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } DIV EXP EXP RPAREN {
    $$ = "DIVIDE";
    int result = num_OP(stack.top, base_ptr, "DIVIDE");
    base_ptr = pop();
    push(result, 0);
}          ;
MODULUS    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } MOD EXP EXP RPAREN {
    $$ = "MODULUS";
    int result = num_OP(stack.top, base_ptr, "MODULUS");
    base_ptr = pop();
    push(result, 0);
}          ;
GREATER    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } GRT EXP EXP RPAREN {
    $$ = "GREATER";
    int result = num_OP(stack.top, base_ptr, "GREATER");
    base_ptr = pop();
    push(result, 1);
}          ;
SMALLER    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } SML EXP EXP RPAREN {
    $$ = "SMALLER";
    int result = num_OP(stack.top, base_ptr, "SMALLER");
    base_ptr = pop();
    push(result, 1);
}          ;
EQUAL      : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } EQL EXP EXPs RPAREN {
    $$ = "EQUAL";
    int result = num_OP(stack.top, base_ptr, "EQUAL");
    base_ptr = pop();
    push(result, 1);
}          ;

LOGICAL-OP : and-OP { $$ = $1; } | or-OP { $$ = $1; } | not-OP { $$ = $1; } ;
and-OP  : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } AND EXP EXPs RPAREN {
    $$ = "and-OP";
    int result = logic_OP(stack.top, base_ptr, "AND");
    base_ptr = pop();
    push(result, 1);
}       ;
or-OP   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } OR EXP EXPs RPAREN {
    $$ = "or-OP";
    int result = logic_OP(stack.top, base_ptr, "OR");
    base_ptr = pop();
    push(result, 1);
}       ;
not-OP  : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } NOT EXP RPAREN {
    $$ = "not-OP";
    int result = logic_OP(stack.top, base_ptr, "NOT");
    base_ptr = pop();
    push(result, 1);
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
            stack.arr_bool_flag[stack.top] = 0;
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

int num_OP(int stack_p, int base_p, char *operator) {
    int num_args = stack_p - base_p;
    int result = 0, tmp = 0;
    if(operator == "MULTIPLY")
        result = 1;
    else if(operator == "EQUAL")
        result = stack.arr[stack.top - 1];

    if(operator == "MINUS" || operator == "DIVIDE" || operator == "MODULUS" || operator == "GREATER" || operator == "SMALLER") {
        if(check_type("number") == 1)
            tmp = pop();
        else {
            printf("Type Error: Expect 'number' but got 'boolean'.\n");
            return -1;
        }
        if(check_type("number") == 1)
            result = pop();
        else {
            printf("Type Error: Expect 'number' but got 'boolean'.\n");
            return -1;
        }
        
        if(operator == "MINUS")
            result = result - tmp;
        else if(operator == "DIVIDE")
            result = result / tmp;
        else if(operator == "MODULUS")
            result = result % tmp;
        else if(operator == "GREATER") {
            if(result > tmp)
                result = 1;
            else
                result = 0;
        }
        else if(operator == "SMALLER") {
            if(result < tmp)
                result = 1;
            else
                result = 0;
        }
        return result;
    }
    tmp = 1;
    for(int i=0; i<num_args; i++) {
        if(check_type("number") == 1) {
            if(operator == "PLUS")
                result += pop();
            else if(operator == "MULTIPLY")
                result *= pop();
            else if(operator == "EQUAL") {
                if(result != pop()) {
                    tmp = 0;
                    break;
                }
            }
        } else {    /* type error */
            printf("Type Error: Expect 'number' but got 'boolean'.\n");
            return -1;
        }
    }
    if(operator == "EQUAL")
        return tmp;
    else
        return result;
}

int logic_OP(int stack_p, int base_p, char *operator) {
    int num_args = stack_p - base_p;
    int result = 0, tmp = 0;
    
    if(operator == "NOT") {
        if(check_type("boolean") == 1) { /* type correct */
            if(pop() == 1)
                result = 0;
            else /* pop() == 0 */
                result = 1;
        } else {
            printf("Expect 'boolean' but got 'number'\n");
            return -1;
        }
        return result;

    } else if(operator == "AND") {
        result = 1;
    } else if(operator == "OR") {
        result = 0;
    }

    for(int i=0; i<num_args; i++) {
        if(check_type("boolean") == 1) {
            if(operator == "AND") {
                if(pop() == 0) {
                    result = 0;
                    break;
                }
            }
            else if(operator == "OR") {
                if(pop() == 1) {
                    result = 1;
                    break;
                }
            }
        } else {    /* type error */
            printf("Expect 'boolean' but got 'number'\n");
            return -1;
        }
    }
    return result;
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
    int i = yyparse();
    //printf("returned value of yyparse() is %d\n", i);
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
