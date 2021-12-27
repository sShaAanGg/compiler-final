%{
#include "parser.tab.h"
%}

SEPARATOR   [\t]|[\n]|[\r]|[ ]
DIGIT   [0-9]
LETTER  [a-z]
RESERVE  mod|and|or|not|define|if|fun|print-num|print-bool
%%

#t|#f   { yylval.str = strdup(yytext); return(BOOL); }

"("     { yylval.str = strdup(yytext); return(LPAREN); }
")"     { yylval.str = strdup(yytext); return(RPAREN); }
"+"      { yylval.str = strdup(yytext); return(ADD); }
"-"       { yylval.str = strdup(yytext); return(SUB); }
"*"      { yylval.str = strdup(yytext); return(MUL); }
"/"      { yylval.str = strdup(yytext); return(DIV); }
mod     { yylval.str = strdup(yytext); return(MOD); }
">"       { yylval.str = strdup(yytext); return(GRT); }
"<"      { yylval.str = strdup(yytext); return(SML); }
"="       { yylval.str = strdup(yytext); return(EQL); }
and     { yylval.str = strdup(yytext); return(AND); }
or      { yylval.str = strdup(yytext); return(OR); }
not     { yylval.str = strdup(yytext); return(NOT); }
define  { yylval.str = strdup(yytext); return(define); }
if      { yylval.str = strdup(yytext); return(IF); }
fun     { yylval.str = strdup(yytext); return(fun); }
print-num   { yylval.str = strdup(yytext); return(print_num); }
print-bool  { yylval.str = strdup(yytext); return(print_bool); }

0|[1-9]{DIGIT}*|-[1-9]{DIGIT}*  { yylval.str = strdup(yytext); return(INUM); }
{LETTER}({LETTER}|{DIGIT}|-)*   { yylval.str = strdup(yytext); return(ID); }

{SEPARATOR}     {}
.	{ return(yytext[0]); }
%%
