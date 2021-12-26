%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void yyerror(const char *message);
%}

%union{
int ival;
char *str;
}

%token <str> LParen RParen ID 
%token <str> define if fun print-num print-bool 
%token <str> ADD SUB MUL DIV MOD GRT SML EQL AND OR NOT
%token <str> FUNC
%token <str> BOOL
%token <ival> INUM

%left ADD SUB
%left MUL DIV MOD

%%
PROGRAM : STMTs 
        ;
STMTs   : STMT STMTs 
        ;
STMT    : EXP 
        | DEF-STMT
        | PRINT-STMT
        ;
PRINT-STMT  : LParen print-num EXP RParen {

}
            | LParen print-bool EXP RParen {

}
            ;
EXP     : BOOL | INUM | VAR | NUM-OP | LOGICAL-OP | FUN-EXP | FUN-CALL | IF-EXP ;
NUM-OP  : PLUS | MINUS | MULTIPLY | DIVIDE | MODULUS | GREATER | SMALLER | EQUAL ;
LOGICAL-OP : AND-OP | OR-OP | NOT-OP ;

DEF-STMT : LParen define ID EXP RParen
VAR     : ID 

FUN-EXP : LParen fun FUN-IDs FUN-BODY RParen 
FUN-IDs : LParen IDs RParen
IDs     : ID IDs | 
        ;
FUN-BODY : EXP ;
FUN-CALL : LParen FUN-EXP ARGs RParen
         | LParen FUN-NAME ARGs RParen
         ;
ARGs    : ARG ARGs | 
        ;
ARG     : EXP
LAST-EXP : EXP
FUN-NAME : ID

IF-EXP  : LParen if TEST-EXP THEN-EXP ELSE-EXP RParen 
TEST-EXP : EXP
THEN-EXP : EXP
ELSE-EXP : EXP

%%

void yyerror (const char *message) {
    fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[]) {
    yyparse();
    return(0);
}