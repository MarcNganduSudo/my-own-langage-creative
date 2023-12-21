%{

#include "sudo_head.h"
unsigned int lineno=1;
bool error_lexical=false;
bool begin_code=true;

void* concat(char*,char*);

%}

%option noyywrap

nombre 0|[1-9][[:digit:]]*
variable_booleenne Sb_([[:alnum:]])*
variable_arithmetique Se_([[:alnum:]])*
variable_texte Sc_(_|[[:alnum:]])*

/* regex de commentaire d'une seule ligne */
commentaire ((\/\/).*)

/* pour les commentaires de plusieurs lignes, on declare nos deux lexemes en tant que conditions de demarrage exclusives (%x) dans Flex */
%x  commentaire_1
%x  commentaire_2

/* chaine de caractere */
%x  chaine

%x code_c

%%

"/*"    {
            /* un marqueur de debut de commentaire trouve -> on lui dit que le lexeme commentaire_1 commence */
            BEGIN(commentaire_1);
            /*printf("Commentaire detecte en ligne %i\n",lineno);*/
        }

<commentaire_1>"\n"     {
                            /* si on trouve des retours chariots et que la condition de demarrage est commentaire_1, alors on incremente la variable lineno. sans cela, on serait en decalage pour la suite de l'analyse */
                            lineno++;
                        }

<commentaire_1>"*"+"/"      {
                                /* si on au moins une fois "*" suivi de "/" et que la condition de demarrage est commentaire_1, alors on lui dit que le lexeme commentaire_1 est fini */
                                BEGIN(INITIAL);
                                /*printf("Fin du commentaire en ligne %i\n",lineno);*/
                                return TOK_COMMENT;
                            }

<commentaire_1>.    {/* les autres caracteres suivants la conditions de demarrage sont absorbes par l'analyse est donc ingores */}

<commentaire_2>.            {}

"\""         {
                /* debut de la chaine de texte (premier guillemet) */
                BEGIN(chaine);
                yylval.texte=malloc(sizeof(char)*strlen(yytext));
                if(yylval.texte==NULL){
                    fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                    exit(-1);
                }
                yylval.texte=strdup(yytext);
                /*printf("Chaine de texte detectee en ligne %i\n",lineno);*/
            }

<chaine>"\n"    {
                    /* on prend en compte les sauts de ligne que l'on traduira par "\n" */
                    lineno++;
                    yylval.texte=(char*)concat(yylval.texte,"\\n");
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\t"    {
                    /* on prend en compte les tabulations que l'on traduira par "\t" */
                    yylval.texte=(char*)concat(yylval.texte,"\\t");
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\\\""    {
                    /* pour echapper le guillemet dans la chaine \" */
                    yylval.texte=(char*)concat(yylval.texte,yytext);
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\""     {
                    /* fin de la chaine (deuxieme guillemet non echappe) */
                    BEGIN(INITIAL);
                    yylval.texte=(char*)concat(yylval.texte,yytext);
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                    /*printf("Fin de la chaine en ligne %i\n",lineno);*/
                    return TOK_TEXTE;
                }

<chaine>.  {
                /* les caracteres de la chaine */
                yylval.texte=(char*)concat(yylval.texte,yytext);
                if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                }
            }


"<S$" {    
                BEGIN(code_c);
                /*printf("Code c detectee en ligne %i\n",lineno);*/
                lineno++;
        }
<code_c>"$S>" {
                    BEGIN(INITIAL);
                    /*printf("Fin du code C en ligne %i\n",lineno);*/
                    lineno++;
                    begin_code=true;
                    return TOK_CODE_C;

               }

<code_c>"\n"    {lineno++;}

                
<code_c>.      {    
                    if(begin_code){
                        yylval.texte=malloc(sizeof(char)*strlen(yytext));
                        if(yylval.texte==NULL){
                            fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                            exit(-1);
                        }
                        yylval.texte=strdup(yytext);
                        begin_code=false;
                            }else{ 

                            yylval.texte=(char*)concat(yylval.texte,yytext);
                            if(yylval.texte==NULL){
                                    fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                                    exit(-1);
                        }
                    }
}



{nombre} {
    sscanf(yytext, "%ld", &yylval.nombre);
    return TOK_NOMBRE;
}

"if"    {return TOK_SI;}

"else" {return TOK_SINON;}

"?" {return TOK_POINT_INTERROGATION;}

"++"    {return TOK_INCREMENTATION;}

"--"    {return TOK_DECREMENTATION;}

"+="    {return TOK_AFFECT_PLUS;}

"-="    {return TOK_AFFECT_MOINS;}

"*="    {return TOK_AFFECT_MUL;}

"/="    {return TOK_AFFECT_DIV;}

"%="    {return TOK_AFFECT_MOD;}

"&="    {return TOK_AFFECT_ET;}

"|="    {return TOK_AFFECT_OU;}

"=="        {return TOK_EQU;}

"!="            {return TOK_DIFF;}

">"  {return TOK_SUP;}

"<"  {return TOK_INF;}

">="          {return TOK_SUPEQU;}

"<="          {return TOK_INFEQU;}

"in"               {return TOK_IN;}

"s_a"      {return TOK_AFFICHER;}

"s_free"     {return TOK_SUPPR;}

"for"             {return TOK_FOR;}

"while"           {return TOK_WHILE;}

"tq"           {return TOK_WHILE_tq;}

"do"           {return TOK_DO_WHILE;}

"="             {return TOK_AFFECT;}

"+"             {return TOK_PLUS;}

"-"             {return TOK_MOINS;}

"*"             {return TOK_MUL;}

"/"             {return TOK_DIV;}

"%"             {return TOK_MOD;}

"^"             {return TOK_PUISSANCE;}

"("             {return TOK_PARG;}

")"             {return TOK_PARD;}

"["             {return TOK_CROG;}

"]"             {return TOK_CROD;}

"{"             {return TOK_ACG;}

"}"             {return TOK_ACD;}

":"             {return TOK_DOUBLE_POINT;}

"et"            {return TOK_ET;}

"ou"            {return TOK_OU;}

"non"|"!"           {return TOK_NON;}

";"             {return TOK_FINSTR;}

"vrai"         {return TOK_VRAI;}

"faux"        {return TOK_FAUX;}

"\n"            {lineno++;}

{variable_booleenne} {
    yylval.texte = yytext;
    return TOK_VARB;
}


{variable_arithmetique} {
    yylval.texte = yytext;
    return TOK_VARE;
}

{variable_texte} {
    yylval.texte = yytext;
    return TOK_VART;
}

{commentaire}   {
    /*printf("Commentaire detecte en ligne %i\n",lineno);*/
    /*printf("Fin du commentaire en ligne %i\n",lineno);*/
    return TOK_COMMENT;
}

" "|"\t" {}

. {
    fprintf(stderr,"\tERREUR : Erreur a la ligne %d\n",lineno);
    error_lexical=true;
    return yytext[0];
}

%%

void* concat(char* texte, char* ajout){
    void* p=NULL;
    if((p=realloc(texte,sizeof(char)*(strlen(texte)+strlen(ajout)+1)))){
        texte=p;
        return strcat(texte,ajout);
    }else{
        FREE(texte);
        return NULL;
    }
}