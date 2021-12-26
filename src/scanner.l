%{
#include "parser.tab.h"
%}

SEPARATOR   [\t]|[\n]|[\r]|[ ]
DIGIT   [0-9]
LETTER  [a-z]
RESEVE  mod|and|or|not|define|fun|if
%%

{SEPARATOR}     {}
0|[1-9]{DIGIT}*|-[1-9]{DIGIT}*  { yylval.str = strdup(yytext); return(INUM); }
{LETTER}({LETTER}|{DIGIT}|-)*   { yylval.str = strdup(yytext); return(ID); }
#t|#f   { yylval.str = strdup(yytext); return(BOOL); }

"+"     { yylval.str = strdup(yytext); return(ADD); }
"-"     { yylval.str = strdup(yytext); return(SUB); }
"*"     { yylval.str = strdup(yytext); return(MUL); }
"/"     { yylval.str = strdup(yytext); return(DIV); }
mod     { yylval.str = strdup(yytext); return(MOD); }
">"     { yylval.str = strdup(yytext); return(GRT); }
"<"     { yylval.str = strdup(yytext); return(SML); }
"="     { yylval.str = strdup(yytext); return(EQL); }
and     { yylval.str = strdup(yytext); return(AND); }
or      { yylval.str = strdup(yytext); return(OR); }
not     { yylval.str = strdup(yytext); return(NOT); }

%%
