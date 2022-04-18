%{
#include <stdlib.h>       /* For malloc in symbol table */
#include <string.h>       /* For strcmp in symbol table */
#include <stdio.h>        /* For error messages         */

#define YYDEBUG 1         /* For debugging              */


/* start of AST */

typedef enum Node
{
    rootNode,
    structNode,
    functionNode,
    declarationNode,
    assignmentNode,
    ifNode,
    elseNode,
    returnNode,
    assignNode,
    boolNode,
    intNode,
    strNode,
    stmtNode
} Node;

typedef struct NODEtop {
  enum { structStmt, pgmStmt } kind;

} NODEtop;

// type id lookup
#define MAX_TYPEIDS 5
char typeIDs[MAX_TYPEIDS][10] =
{
   "int",
   "struct",
   "str",
   "void",
   "bool"
};

/* AST */

/* Symbol Table */
#define MAX_SYMBOL_LENGTH 100
struct symbol {
    char name [MAX_SYMBOL_LENGTH];
    char type [100];
    char typeId;
    char vartype [100];
    int scope;
    struct symbol * next;
    struct symbol * vars;
};

/* Symbol Table */


/* Scope */
int current_scope = 0;


/* Scope */


/* globals */
char currentType [100];

#define MAX_SYMBOLS 256
struct symbol symboltable [MAX_SYMBOLS];

char currentID [100];

int struct_no = 0;

int proc_no = 0;

char currentDeclaration[100];

char currentStructName [MAX_SYMBOLS];

char currentProcName [MAX_SYMBOLS];

struct symbol currentStruct [MAX_SYMBOLS];

struct symbol * currentExpr;

/* globals */

void init2 () {
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        struct symbol new;
        strcpy(new.name , "");
        strcpy(new.type , " ");
        currentStruct[i] = new;
    }
}

void insert_symbol2 (char * name, char * id) {
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (strcmp(currentStruct[i].type, " ") ==  0) {
            strcpy(currentStruct[i].name , name);
            strcpy(currentStruct[i].type , id);
            currentStruct[i].typeId = '\0';
            currentStruct[i].scope = -1;
            break;
        }
    }
}

void init () {
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        struct symbol new;
        strcpy(new.name , "");
        strcpy(new.type , " ");
        strcpy(new.vartype , " ");
        new.typeId = -1;
        new.scope = -1;
        new.next = NULL;
        new.vars = NULL;
        symboltable[i] = new;
    }
}

void insert_symbol (char * name, char * id, char * vartype) {
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (strcmp(symboltable[i].type, " ") ==  0) {
            strcpy(symboltable[i].name , name);
            strcpy(symboltable[i].type , id);
            strcpy(symboltable[i].vartype, vartype);
/*
            int idn;
            for (idn=0;idn<MAX_TYPEIDS;idn++) {
                if (!strcmp(typeIDs[idn], id))
                   symboltable[i].typeId = idn;

            }
            if (symboltable[i].typeId == -1) {
               printf("Invalid type : '%s'\n", id);
            }
*/
            symboltable[i].scope = current_scope;
            break;
        }
    }
}

struct symbol * lookup (char * name) {
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (strcmp(symboltable[i].name, name) == 0) {
            return &symboltable[i];
        }
    }
    return NULL ;
}

void print_table2 () {
    int i;
   printf("*****************************************************\n");
    printf("          Current Struct\n");
    printf("ID  Name                 Type       ID Scope    vartype\n");
    printf("--- -------------------- ---------- -- -------- -------\n");
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (strcmp(currentStruct[i].type, " ") == 0) {
            break;
        }
        printf("%-20s %-20s\n", currentStruct[i].name, currentStruct[i].type);
    }
    printf("\n");
}

void print_symbols () {
    printf("***********************************************************\n");
    printf("          Symbol Table\n");
    printf("ID  Name                 Type       ID Scope  vartype    next\n");
    printf("--- -------------------- ---------- -- ------ -------  -------\n");
    int i;
    for (i = 0; i < MAX_SYMBOLS; i++) {
        if (!strcmp(symboltable[i].name,"")) {
            break;
        }
        printf("%-3d %-20s %-10s %c  %5d   %-20s  %-20s\n", i, symboltable[i].name, symboltable[i].type,
                                symboltable[i].typeId, symboltable[i].scope, symboltable[i].vartype, symboltable[i].next);
    }
    printf("***********************************************************\n");
    printf("\n");
}

%}

%union
{
    char    name[100];
    int     val;
    char *id;
}


%token COMMA STRTYPE BOOL INT VOID RETURN FOR IF STRUCT PRINTF STR STOP AND OR NOT MOD EQ NEQ BL BR CBL CBR ERROR BOOLTYPE NUM IDENTIFIER

%left ADD MIN MUL DIV DOT 
%nonassoc LESS LEQ GREQ MORE EQU EQ NEQ NOT CBL BL CBR BR 
%right AND OR THEN ELSE 
%type <id> IDENTIFIER id

%start program

%% 

program :
    pgm
; 

pgm : 
      | proc pgm 
      | struct pgm
;

if : IF BL bool_expr {current_scope++;}
;

if_stmt: 
     if BR THEN stmt ELSE stmt {current_scope--;
                                 struct symbol * current = lookup(currentProcName);
                                 while (current->vars != (struct symbol *) NULL) {
                                    if (current->vars->scope > current_scope) {
                                        	current->vars = NULL;
                                    }
                                    if (current->vars != (struct symbol *) NULL) {
                                        current = current->vars;
                                    }
                                }}
    | if BR THEN stmt {current_scope--;}
;

for: FOR {current_scope++;}

stmt : for BL assignment STOP bool_expr STOP statement BR stmt {printf("endof\n");
                                                                current_scope--;
                                                                struct symbol * current = lookup(currentProcName);
                                                                while (current->vars != (struct symbol *) NULL) {
                                                                    if (current->vars->scope > current_scope) {
                                                                        current->vars = NULL;
                                                                    }
                                                                    if (current->vars != (struct symbol *) NULL) {
                                                                        current = current->vars;
                                                                    }
                                                                }
                                                            }
| if_stmt {}
| PRINTF  BL expr BR STOP {if (strcmp(currentType, "str") != 0) {
                                printf("not printing a string\n");
                                return 1;
                            }printf("print stmt\n");}
| RETURN expr STOP {struct symbol * current =  lookup(currentProcName);
                    if (strcmp(current->type, currentType) != 0) {
                        printf("not the right return type");
                        return 1;
                    }}
| declaration STOP {}
| assignment STOP {}
| CBL statement_seq CBR {printf("compstate\n")}
| proc_call STOP {struct symbol * proc = lookup(currentDeclaration);
                if (strcmp(proc->type, "void") != 0 && strcmp(proc->vartype, "proc") !=0){
                    printf("a non void function called in a void way\n");
                    return 1;
                }}
| ERROR {return 1;}
;

statement :  | PRINTF  BL STR BR {}
| assignment {}
| ERROR {return 1;}
;

assignment : l_exp EQ expr {struct symbol * currentProc = lookup(currentProcName);
                                        struct symbol * current = currentProc;

                                        if (struct_no) {
                                            printf("%s is a %s and compared w %s\n", currentExpr->name, current->type, currentType);
                                            if (strcmp(currentExpr->type, currentType) == 0) {
                                                printf("Yay\n");
                                            } else {
                                                printf("Wrong type :(\n");
                                                return 1;
                                            }

                                        } else {
                                            while (strcmp(current->name, yylval.id) != 0) {
                                                printf("got here! %s\n", current->vars);
                                                if (current->vars == (struct symbol *) NULL) {
                                                    printf("undeclared var %s\n", yylval.id);
                                                    printf("yea");
                                                    return 1;
                                                }
                                                current = current->vars;
                                            }
                                            printf("%s is a %s and compared w %s\n", current->name, current->type, currentType);
                                            if (strcmp(current->type, currentType) == 0) {
                                                printf("Yay\n");
                                            } else {
                                                printf("Wrong type :(\n");
                                                return 1;
                                            }
                                        }
                                    
                                            struct_no = 0;}
| l_exp EQ proc_call {printf("assignment\n"); 
                                        struct symbol * currentProc = lookup(currentProcName);
                                        struct symbol * current = currentProc;
                                        
                                        while (strcmp(current->name, currentID) != 0) {
                                            printf("got here! %s\n", current->vars);
                                            if (current->vars == (struct symbol *) NULL) {
                                                printf("undeclared var %s\n", currentID);
                                                printf("yea");
                                                return 1;
                                            }
                                            current = current->vars;
                                        }
                                        struct symbol * call = lookup(currentDeclaration);
                                        printf("%s is a %s and compared w %s\n", current->name, current->type,  call->type);
                                        if (strcmp(call->vartype, "proc") != 0) {
                                                printf("Not a proc\n");
                                                return 1;
                                        }
                                        if (strcmp(current->type, call->type) == 0) {
                                            printf("Yay\n");
                                            if (current->scope > current_scope) {
                                                printf("Not in scope!") ;
                                                return 1;
                                            }
                                        } else {
                                            printf("Wrong type :(\n");
                                            return 1;
                                        }}
;

proc_call: proc_id BL expr_list BR {}
;

proc_id : IDENTIFIER { currentExpr = lookup(yylval.id);
                                        if (currentExpr != (struct symbol *) NULL) {
                                            printf("Discovered\n");
                                            strcpy(currentDeclaration, yylval.id);
                                        } else {
                                            printf("Not declared: %s\n", yylval.id);
                                            return 1;
                                        } currentExpr = currentExpr->next;}
;


proc : proc_line BR CBL statement_seq CBR {current_scope--;
                                            proc_no = 0;
                                            printf("End of %s\n", currentProcName);
                                            }
;

proc_line : proc_declaration BL declist {proc_no = 0;}
;

proc_declaration: proc_dec | VOID IDENTIFIER {printf("declaration of : %s\n",yylval.id ); 
                                        if (lookup(yylval.id) != (struct symbol *) NULL) {
                                            printf("redeclaration of %s\n", yylval.id);
                                            return 1;
                                        } else {
                                            printf("got here\n");
                                            insert_symbol(yylval.id, "void", "proc");
                                        }current_scope++;
                                        proc_no = 1;
                                        printf("Proc  Start %s\n", yylval.id);
                                        strcpy(currentProcName, yylval.id);}
;        

proc_dec : type IDENTIFIER {printf("declaration of : %s\n",yylval.id ); 
                                        if (lookup(yylval.id) != (struct symbol *) NULL) {
                                            printf("redeclaration\n");
                                            return 1;
                                        } else {
                                            printf("got here %s\n", yylval.id);
                                            insert_symbol(yylval.id, currentType, "proc");
                                            strcpy(currentDeclaration, yylval.id);
                                        }current_scope++;
                                        proc_no = 1;
                                        printf("Proc  Start %s\n", yylval.id);
                                        strcpy(currentProcName, yylval.id);}
;

struct_declaration: STRUCT IDENTIFIER {printf("declaration of : %s\n",yylval.id ); 
                                        if (lookup(yylval.id) != (struct symbol *) NULL) {
                                            printf("redeclaration of %s\n", yylval.id);
                                            return 1;
                                        } else {
                                            printf("got here\n");
                                            insert_symbol(yylval.id, "struct", "struct");
                                        }
                                        struct_no = 1;
                                        printf("Struct Start %s\n", yylval.id);
                                        strcpy(currentStructName, yylval.id);
                                        printf("Current Struct: %s\n", currentStructName);}
;

struct : struct_declaration CBL declist CBR {struct_no = 0;}
;

declaration :  type IDENTIFIER {printf("declaration of : %s\n",yylval.id ); 
                                        int dec = 0;
                                        struct symbol * currentFunc = lookup(currentProcName);
                                        struct symbol * check = currentFunc->vars;
                                        while(check != (struct symbol *) NULL) {
                                            if (strcmp(yylval.id, check->name) == 0) {
                                                dec = 1;
                                            }
                                            check = check->vars;
                                        }
                                        if (dec) {
                                            printf("redeclaration\n");
                                            return 1;
                                        } else {
                                            if (struct_no) {
                                                    printf("Current Struct: %s\n", currentStructName);
                                                    struct symbol * current =  lookup(currentStructName);
                                                    printf("%s and %s in %s\n", yylval.id, currentType, currentStructName);
                                                    struct symbol * i = current;
                                                    printf("what is next %s\n", i->next);
                                                    while(i->next != (struct symbol *) NULL) {
                                                            i = i->next;
                                                            printf("what is next %s\n", i->next);
                                                    }
                                                    struct symbol * new;
                                                    new = malloc(sizeof(*new));
                                                    strcpy(new->name , yylval.id);
                                                    strcpy(new->type , currentType);
                                                    strcpy(new->vartype , "struct");
                                                    new->typeId = -1;
                                                    new->scope = current_scope;
                                                    new->next = NULL;
                                                    new->vars = NULL;
                                                    struct symbol * name = lookup(currentType);
                                                    if (name != (struct symbol *) NULL) {
                                                        new->next = name->next;
                                                        printf("morpn %s\n", name->next);
                                                    }
                                                    printf("%s noooo\n", i->name);
                                                    i->next = new;
                                                    printf("yes lets check this %s, %s, %s\n", i->name, i->next, i->next->next);
                                            } else if (proc_no) {
                                                
                                                    struct symbol * current =  lookup(currentProcName);
                                                    printf("%s and %s in %s\n", yylval.id, currentType, currentProcName);
                                                    struct symbol * i = current;
                                                    printf("what is next %s\n", i->next);
                                                    while(i->next != (struct symbol *) NULL) {
                                                            i = i->next;
                                                            printf("what is next %s\n", i->next);
                                                    }
                                                    struct symbol * new;
                                                    new = malloc(sizeof(*new));
                                                    strcpy(new->name , yylval.id);
                                                    strcpy(new->type , currentType);
                                                    strcpy(new->vartype , "var");
                                                    new->typeId = -1;
                                                    new->scope = current_scope;
                                                    new->next = NULL;
                                                    new->vars = NULL;
                                                    i->next = new;                                                        
                                                    printf("got here %s\n", yylval.id);
                                                    i = current;
                                                    while(i->vars != (struct symbol *) NULL) {
                                                        i = i->vars;
                                                        printf("what is next %s\n", i->next);
                                                    }
                                                     new = malloc(sizeof(*new));
                                                    strcpy(new->name , yylval.id);
                                                    strcpy(new->type , currentType);
                                                    strcpy(new->vartype , "var");
                                                    new->typeId = -1;
                                                    new->scope = current_scope;
                                                    new->next = NULL;
                                                    new->vars = NULL;
                                                    i->vars = new;
                                            }
                                            else {
                                                printf("Current Proc: %s\n", currentProcName);
                                                struct symbol * i = lookup(currentProcName);
                                                struct symbol * struct_check = lookup(currentType);
                                                struct symbol * new;
                                                new = malloc(sizeof(*new));
                                                while(i->vars != (struct symbol *) NULL) {
                                                        i = i->vars;
                                                        printf("what is next %s\n", i->next);
                                                    }
                                                
                                                    strcpy(new->name , yylval.id);
                                                    strcpy(new->type , currentType);
                                                    strcpy(new->vartype , "var");
                                                    new->typeId = -1;
                                                    new->scope = current_scope;
                                                    new->next = NULL;
                                                    new->vars = NULL;
                                                if (struct_check != (struct symbol *) NULL) {
                                                    printf("struct check %s", struct_check->next);
                                                    new->next = struct_check->next;
                                                }
                                                
                                                i->vars = new;
                                                printf("got here %s is type %s\n", yylval.id, currentType);
                                                strcpy(currentDeclaration, yylval.id);
                                            }
                                        }insert_symbol2 (yylval.id, currentType);}
;


expr_list : {
            if (currentExpr != (struct symbol *) NULL) {
                if (currentExpr->vars != (struct symbol *) NULL) {
            printf("not enough params\n");
            return 1;
    }
            }
            }
    | expr {
            if (strcmp(currentExpr->type, currentType) != 0) {
            printf("wrong expr type1 %s %s\n", currentType, currentExpr->type);
            return 1;
    } if (currentExpr->vars != (struct symbol *) NULL) {
            printf("not enough params\n");
            return 1;
    }}
    | ex COMMA expr_list {}
;

ex: expr {if (strcmp(currentExpr->type, currentType) != 0) {
            printf("wrong expr type %s\n", currentType);
            return 1;
    } if (currentExpr->next ==  (struct symbol *) NULL) {
        printf("too many params\n");
        return 1;
    }
    currentExpr = currentExpr->next;}
;

declist : 
| declaration 
|   declaration COMMA declist 
;

id : IDENTIFIER { struct symbol * currentProc = lookup(currentProcName);
                                        char symb [MAX_SYMBOLS];
                                        struct symbol * current = currentProc;
                                        strcpy(symb, $1);
                                        if (struct_no) {
                                            printf("it is a struct\n");
                                            current = currentExpr;
                                            printf("%s gg\n", currentExpr->next);
                                            while (strcmp(current->name, symb) != 0) {
                                                printf("current variable %s\n", current->name);
                                                printf("%s", current->next);
                                                if (current->next == (struct symbol *) NULL) {
                                                    printf("undeclared var %s\n", symb);
                                                    return 1;
                                                } else {
                                                    current = current->next;
                                                }
                                            }
                                        } else {
                                            while (strcmp(current->name, symb) != 0) {
                                                if (current->vars == (struct symbol *) NULL) {
                                                    printf("undeclared var %s\n", symb);
                                                    return 1;
                                                } else {
                                                    current = current->vars;
                                                }
                                            }
                                        }
                                        printf("Discovered %s\n", current->name);
                                        strcpy(currentID, current->name);
                                        currentExpr = current;}
;

l_exp : id 
| id DOT {struct_no = 1;
                if (currentExpr != (struct symbol *) NULL ) {
                    printf("structtttt\n");
                    printf("%s %s\n", currentExpr, currentExpr->next);
                }}
    l_exp 
;

statement_seq : {printf("empty\n")}
            | stmt statement_seq {printf("comp\n")}
;

type : INT {strcpy(currentType, "int");} 
| BOOL {strcpy(currentType, "bool");} 
| STRTYPE {strcpy(currentType, "str");} 
| IDENTIFIER {
            strcpy(currentType, $1);
            printf("dunnno %s\n", $1);
            struct symbol * current = lookup(currentType);
            printf("%s\n", yylval.id);
            if (current != (struct symbol *) NULL) {
                                            if (strcmp(current->vartype, "struct") == 0) {
                                                printf("Discovered\n");
                                                printf("THE CURRENT TYPE IS %s\n",currentType);
                                            } else {
                                                printf("not a struct\n");
                                                return 1;
                                            }
                                            
                                        } else {
                                            printf("Not declared %s\n", yylval.id);
                                            return 1;
                                        }}
;

expr: 
IDENTIFIER 
{struct symbol * currentProc = lookup(currentProcName);
                                        struct symbol * current = currentProc;
                                        
                                        while (strcmp(current->name, yylval.id) != 0) {
                                            printf("got here! %s\n", current->vars);
                                            if (current->vars == (struct symbol *) NULL) {
                                                printf("undeclared var %s\n", yylval.id);
                                                return 1;
                                            }
                                            current = current->vars;
                                        }
                                        printf("Discovered\n");
                                        strcpy(currentType, current->type);
                                        if (current->scope > current_scope) {
                                            printf("Not in scope!") ;
                                            return 1;
                                        }
                                    }

| bool_expr {printf("bool_expr\n");
            printf("bool: %s", currentID);
            strcpy(currentType, "bool");}
| int_expr {printf("num\n"); 
            printf("int: %s\n", currentID);
            strcpy(currentType, "int"); }
| str_expr  {printf("string expression\n"); 
            printf("str: %s", currentID);
            strcpy(currentType, "str"); }
;

int_expr: NUM 
    | MIN NUM
    | NUM int_op NUM {}
    |  BL int_expr BR {printf("intsss")}
    ;


bool_expr:
    BOOLTYPE  
    | NOT bool_expr
    | NUM bool_op NUM {printf("rel op bool_expr\n");}
    | BL bool_expr BR {printf("nested bools")}
    ;

str_expr: STR 
    | STR ADD str_expr 
    | BL str_expr BR {printf("strsss")}
    ;

int_op : MIN | ADD | MUL | DIV | MOD
;

bool_op: EQU | AND | OR | LESS | LEQ | GREQ | MORE | NEQ
;

%%

int main()
{
    init();
    init2();
    int parse = yyparse();
    print_symbols();
    printf("\n");
    print_table2();
    if(parse == 0) printf("\nParsing result:  SUCCESS\n\n"); 
    else printf("\nParsing result:  ERROR\n\n");
    return 0;
}

int yyerror(const char *msg){
    fprintf(stderr, "%s\n ERROR\n", msg);
  return 0;
}