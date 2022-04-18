%option noyywrap
%option yylineno


%{  
  #include <string.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include "Toy.tab.h"
%}



LineTerminator  \r|\n|\r\n
InputCharacter  [^\r\n]
WhiteSpace   {LineTerminator} | [ \t\f]
string  "[^\"]" 
SChar  [^\"\\\n\r] | {EscChar}
EscChar  \\[ntbrf\\\'\"] | {OctalEscape}
OctalEscape  \\[0-7] | \\[0-7][0-7] | \\[0-3][0-7][0-7]



%%

-?0*([12]?[0-9]{1,4}|3(2(7(6[0-7]|[0-5][0-9])|[0-6][0-9]{2})|[0-1][0-9]{3}))                               {return NUM;}

"string"                           { return STRTYPE;}
"bool"                              { return BOOL;}
"int"                              { return INT; }
"void"                              { return VOID; }
(true|false)                    { return BOOLTYPE; }
"return"                            { return RETURN; }
"for"                              { return FOR; }
"if"                                { return IF; }
"then"                              { return THEN; }
"else"                              { return ELSE; }
"struct"                            { return STRUCT; }
"printf"                            { return PRINTF; }


"//".*                            {/* ignore */}
"##".*                            {/* ignore */}


"and"                               { return AND; }
"or"                                { return OR; }
"mod"                              { return MOD; }
"=="                              { return EQU; }
"="                               { return EQ; }

"!="                              { return NEQ; }
"!"                               { return NOT; }
">="                              { return GREQ; }
"<="                              { return LEQ; }
"- "                                { return MIN; }
"+"                               { return ADD; }
"/"                               { return DIV; }
"*"                               { return MUL; }
"<"                               { return LESS; }
">"                               { return MORE; }
"."                               { return DOT; }
","                               { return COMMA; }


[_a-zA-Z][_0-9a-zA-Z]*                    { yylval.id = (char *) strdup(yytext); printf("L says we're on %s ,\n", yylval.id);
      return IDENTIFIER; }


"("                               { return BL; }
")"                               { return BR; }
"{"                               { return CBL; }
"}"                               { return CBR; }


";"                               { return STOP; }
\"[^\n\""]*\"                      { return STR;}



([\t\f])+       { printf("ERRORSSS"), exit(0);}
[ \r\t\n]+      { /* whitespace */}

%%