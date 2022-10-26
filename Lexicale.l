%{
#include "Syntaxique.tab.h"
extern nb_ligne;
extern YYSTYPE yylval;
#include "semantique.h"
%}

LETTRE [a-zA-Z]
NOMBRE [0-9]
IDF "$"{LETTRE}({LETTRE}|{NOMBRE})*(((_)({LETTRE}|{NOMBRE})*)|({LETTRE}|{NOMBRE})*)*
IDF_TAB "@"{LETTRE}({LETTRE})*(((_)({LETTRE})*({NOMBRE})*)|(({LETTRE})*({NOMBRE})*))
TEXT \"[^"]*\"

VALEUR {NOMBRE}+
VALEUR_REEL ({NOMBRE}+)(".")({NOMBRE}+)
%%
import      return mc_import;
ISIL.io    return bib_io;
ISIL.lang   return bib_lang;
";"         return pvg;

class       return mc_class;
private     return mc_private;
public      return mc_public;
protected   return mc_protected;

{IDF}  {if (yyleng<=20) {yylval.str=strdup(yytext);

                        inserer(yytext,"idf");
 						 return idf;}
          else printf("erreur lexicale : idf trop long a la ligne    %d sur %s\n",nb_ligne, yytext); 
		 } 

Entier      {yylval.str=strdup("Entier"); return mc_entier;}
Reel        {yylval.str=strdup("Reel"); return mc_reel;}
Chaine      {yylval.str=strdup("Chaine"); return mc_chaine;}

CONST       return mc_const;

{VALEUR}     {yylval.entier=atoi(yytext); return valeur;}

{VALEUR_REEL} {yylval.reel=atof(yytext); return valeur_reel;}

{IDF_TAB}   {yylval.str=strdup(yytext);
            inserer(yytext,"tab");
            return idf_tab;}
"{"         return aco_ouv;
"}"         return aco_ferm;
"]"         return crochet_ferm;
"["         return crochet_ouv;
","         return vrgl;


":="        return affect;
"+"         {yylval.str=strdup(yytext); return mc_somme;}
"/"         {yylval.str=strdup(yytext); return mc_div;}
"*"         {yylval.str=strdup(yytext); return mc_multi;}
"-"         {yylval.str=strdup(yytext); return mc_soust;}



"="         return mc_egal;
"<"         return mc_inf;
">"         return mc_sup;
"<="        return mc_inf_egal;
">="        return mc_sup_egal;
"!="        return mc_not_egal;
for         return mc_for;
"("         return parenth_ouv;
")"         return parenth_ferm;

{TEXT}      {yylval.str=strdup(yytext); return mc_text;}

IN          return mc_in;
OUT         return mc_out;
main        return mc_main;



"##"[^#]*"##"


[  \t]      ;
[\n] nb_ligne++;


. {printf("erreur lexicale a la ligne %d :%s \n",nb_ligne,yytext);
    return err;}

%%