%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define STACK_SIZE 1000
#define TYPE_0_POPnPUSH     base_ptr = pop(); \
                            push(result, 0);

#define TYPE_1_POPnPUSH     base_ptr = pop(); \
                            push(result, 1);

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

struct identifier {
    int num_id;
    char* id_arr[STACK_SIZE];
    int* val_ptr_arr[STACK_SIZE];
    int val_bool_flag[STACK_SIZE];
};
struct identifier identifier;
int find_id_index(char *);

int base_ptr = 0;
int num_OP(int, int, char *);
int logic_OP(int, int, char *);

int check_type(char *);
void dump_stack();
%}

%union{
int ival;
char *str;
}

%token <str> define IF fun print_num print_bool 

%token <str> LPAREN RPAREN ID 
%token <str> ADD SUB MUL DIV MOD GRT SML EQL AND OR NOT 
%token <str> BOOL INUM 

%type <str> EXP NUM-OP PLUS MINUS MULTIPLY DIVIDE MODULUS GREATER SMALLER EQUAL VAR FUN-EXP FUN-CALL if-EXP TEST-EXP
%type <str> PROGRAM STMTs STMT PRINT-STMT DEF-STMT LOGICAL-OP and-OP or-OP not-OP
%type <ival> THEN-EXP ELSE-EXP

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
}       | VAR {
    $$ = $1;
    int index = find_id_index($1);
    if(identifier.val_bool_flag[index]) {
        push(* identifier.val_ptr_arr[index], 1);
    } else {
        push(* identifier.val_ptr_arr[index], 0);
    }
}       | NUM-OP { $$ = $1; } | LOGICAL-OP { $$ = $1; } | FUN-EXP {} | FUN-CALL {} | if-EXP {} ;
EXPs    : EXP EXPs {
    
}       | EXP {
    
};

NUM-OP  : PLUS { $$ = $1; } | MINUS { $$ = $1; } | MULTIPLY { $$ = $1; } | DIVIDE { $$ = $1; } | MODULUS { $$ = $1; } 
        | GREATER { $$ = $1; } | SMALLER { $$ = $1; } | EQUAL { $$ = $1; } ;

PLUS    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } ADD EXP EXPs RPAREN {
    $$ = "PLUS";
    int result = num_OP(stack.top, base_ptr, "PLUS");
    TYPE_0_POPnPUSH;
}          ;
MINUS   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } SUB EXP EXP RPAREN {
    $$ = "MINUS";
    int result = num_OP(stack.top, base_ptr, "MINUS");
    TYPE_0_POPnPUSH;
}          ;
MULTIPLY   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } MUL EXP EXPs RPAREN {
    $$ = "MULTIPLY";
    int result = num_OP(stack.top, base_ptr, "MULTIPLY");
    TYPE_0_POPnPUSH;
}          ;
DIVIDE     : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } DIV EXP EXP RPAREN {
    $$ = "DIVIDE";
    int result = num_OP(stack.top, base_ptr, "DIVIDE");
    TYPE_0_POPnPUSH;
}          ;
MODULUS    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } MOD EXP EXP RPAREN {
    $$ = "MODULUS";
    int result = num_OP(stack.top, base_ptr, "MODULUS");
    TYPE_0_POPnPUSH;
}          ;
GREATER    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } GRT EXP EXP RPAREN {
    $$ = "GREATER";
    int result = num_OP(stack.top, base_ptr, "GREATER");
    TYPE_1_POPnPUSH;
}          ;
SMALLER    : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } SML EXP EXP RPAREN {
    $$ = "SMALLER";
    int result = num_OP(stack.top, base_ptr, "SMALLER");
    TYPE_1_POPnPUSH;
}          ;
EQUAL      : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } EQL EXP EXPs RPAREN {
    $$ = "EQUAL";
    int result = num_OP(stack.top, base_ptr, "EQUAL");
    TYPE_1_POPnPUSH;
}          ;

LOGICAL-OP : and-OP { $$ = $1; } | or-OP { $$ = $1; } | not-OP { $$ = $1; } ;
and-OP  : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } AND EXP EXPs RPAREN {
    $$ = "and-OP";
    int result = logic_OP(stack.top, base_ptr, "AND");
    TYPE_1_POPnPUSH;
}       ;
or-OP   : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } OR EXP EXPs RPAREN {
    $$ = "or-OP";
    int result = logic_OP(stack.top, base_ptr, "OR");
    TYPE_1_POPnPUSH;
}       ;
not-OP  : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } NOT EXP RPAREN {
    $$ = "not-OP";
    int result = logic_OP(stack.top, base_ptr, "NOT");
    TYPE_1_POPnPUSH;
}       ;

DEF-STMT : LPAREN define ID EXP RPAREN {
    char* id_str = (char *) malloc(sizeof(char) * STACK_SIZE);
    id_str = $3;
    identifier.id_arr[identifier.num_id] = id_str;
    if(isBool(stack.top - 1)) {
        int* bool = (int *) malloc(sizeof(int));
        *bool = pop();
        identifier.val_ptr_arr[identifier.num_id] = bool;
        identifier.val_bool_flag[identifier.num_id] = 1;
    } else {
        int* num = (int *) malloc(sizeof(int));
        *num = pop();
        identifier.val_ptr_arr[identifier.num_id] = num;
        identifier.val_bool_flag[identifier.num_id] = 0;
    }
    identifier.num_id++;
    $$ = $3;
}       ;
VAR     : ID {
    $$ = $1;
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

if-EXP  : LPAREN { push(base_ptr, 0); base_ptr = stack.top; } IF TEST-EXP THEN-EXP ELSE-EXP RPAREN {
    int isElse_exp_bool = pop();
    int isThen_exp_bool = pop();
    int test_exp_val = pop();
    base_ptr = pop();
    if(test_exp_val) {
        if(isThen_exp_bool == 1)
            push($5, 1);
        else
            push($5, 0);
    } else {
        if(isElse_exp_bool == 1)
            push($6, 1);
        else
            push($6, 0);
    }
}        ;
TEST-EXP : EXP {
    if(isBool(stack.top - 1)) 
        ;
    else {
        printf("Type Error: Expect 'boolean' from TEST-EXP but got 'number'.\n");
        return -1;
    }
}        ;
THEN-EXP : EXP {
    if(isBool(stack.top - 1)) {
        $$ = pop();
        push(1, 1);
    }
    else {
        $$ = pop();
        push(0, 1);
    }
}        ;
ELSE-EXP : EXP {
    if(isBool(stack.top - 1)) {
        $$ = pop();
        push(1, 1);
    }
    else {
        $$ = pop();
        push(0, 1);
    }
}        ;

%%

void yyerror (const char *message) {
    fprintf (stderr, "%s\n",message);
}

int find_id_index(char * id_string) {
    for(int i=0; i<identifier.num_id; i++) {
        if(strcmp(id_string, identifier.id_arr[i]) == 0) {
            return i;
        }
    }
    printf("Error: Can't find a identifier named %s\n", id_string);
    return -1;
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
        printf("Runtime Error: STACK OVERFLOW! (The size of stack is of 4000 bytes. That is, 1000 integers)\n");
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
    stack.top = 0;
    identifier.num_id = 0;
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
