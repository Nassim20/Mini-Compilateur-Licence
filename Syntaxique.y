%{
int nb_ligne=1;
char saveOpr[20];
int saveVal;
int saveVal2;
float saveVal_float;
float saveVal_float2;
char saveVal_char [20];
int saveType;
int exist1=0;
int exist2=0;
char tmp[20];
int nbrIdfIO=0;
char* idfIo[30];
char tmp2[50];
int trouve=0;
float val;
char tmp3[30];


%}

%union {
int  entier;
char*   str;
float reel;
} 

%start S
%token 	mc_import bib_io bib_lang pvg err
	   	mc_class mc_private mc_public mc_protected <str>idf	
	   	<str>mc_entier <str>mc_reel <str>mc_chaine aco_ouv aco_ferm
		<entier>valeur <reel>valeur_reel <str>idf_tab crochet_ferm crochet_ouv vrgl mc_const 
		affect <str>mc_somme <str>mc_soust <str>mc_multi <str>mc_div
		mc_egal mc_inf mc_sup mc_inf_egal mc_sup_egal mc_not_egal mc_for
		parenth_ouv parenth_ferm mc_out mc_in mc_main  <str>mc_text <entier>cst

%left mc_somme mc_soust
%left mc_multi mc_div	

%type <reel> EXPRESSION 

%%

S:LISTE_BIB CLASS aco_ouv LISTE_DEC mc_main parenth_ouv parenth_ferm aco_ouv LISTE_INST aco_ferm aco_ferm{printf("syntaxe correcte");}
;

LISTE_BIB: BIB LISTE_BIB 
			|
;

BIB: mc_import NOM_BIB pvg 
;

NOM_BIB:bib_io {exist1=1;} 
	|bib_lang {exist2=1;}
;

CLASS: MODIFCATEUR mc_class idf
;

MODIFCATEUR:mc_private
			|mc_protected
			|mc_public
			|

;

LISTE_DEC: PARTIE_DEC LISTE_DEC
			|

;

PARTIE_DEC: TYPE_VARIABLE LISTE_IDF pvg 
			|TYPE_VARIABLE LISTE_IDF_TAB pvg 
			|mc_const TYPE_VARIABLE  idf affect{
			if(isDoubleDeclared($3)==0){
			constantInsert($3);
			typeInsert($3,saveType);
				}
			else{printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne); YYACCEPT;}
				} EXPRESSION pvg{ 
				insertTaille($3,1);
				cstAffect($3);
				if(saveType==0){						
				 sprintf(tmp,"%d",saveVal2);
				 insertVal($3,tmp);
				 }
				 
				 if(saveType==1){
				 sprintf(tmp,"%f",saveVal_float2);
				 insertVal($3,tmp);
				 }

				 if(saveType==-1){
				 insertVal($3,saveVal_char);
				 }
			}
			|mc_const TYPE_VARIABLE idf pvg {
					insertTaille($3,1);
					if(isDoubleDeclared($3)==0){
					constantInsert($3);
					typeInsert($3,saveType);}
					else{printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne); YYACCEPT;}
				}
;

LISTE_IDF: idf vrgl LISTE_IDF { insertTaille($1,1);
	                              if(isDoubleDeclared($1)==0)
                                     typeInsert($1,saveType);
							    else 
								{printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne); YYACCEPT;}
								}
			| idf { insertTaille($1,1);
							if(isDoubleDeclared($1)==0)
                                     {typeInsert($1,saveType);}
							    else
								{printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne);YYACCEPT;} 
								}
;

LISTE_IDF_TAB:idf_tab crochet_ouv EXPRESSION crochet_ferm vrgl LISTE_IDF_TAB {
									if(isDoubleDeclared($1)==0)
                                     {typeInsert($1,saveType);}
							    	else
									{printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne);
									}
										insertTaille($1,(int)$3);
										if(((int) $3) <= 0)
			                            {printf("erreur Semantique, la taille de tableau %s doit etre (>0) ,ligne : %d\n",$1,nb_ligne);
										YYACCEPT;}
										
										}
			|idf_tab crochet_ouv EXPRESSION crochet_ferm { 
									if(isDoubleDeclared($1)==0)
                                     {typeInsert($1,saveType);}
							    	else {printf("Erreur Semantique, double declaration de %s a la ligne %d\n",$1,nb_ligne);}	
										insertTaille($1,(int)$3);
										if(((int) $3) <= 0){
			                            printf("erreur Semantique, la taille de tableau %s doit etre (>0) ,ligne : %d\n",$1,nb_ligne);
										YYACCEPT;}
										}
;

TYPE_VARIABLE:mc_entier {saveType=0;}
    |mc_reel   {saveType=1;}
	|mc_chaine {saveType=-1;}
;

LISTE_INST: INSTRU LISTE_INST 
			|
;

INSTRU: LISTE_AFFECT
		|BOUCLE
		|IN
		|OUT
;

IN: mc_in parenth_ouv mc_text vrgl LISTE_IDF_IO parenth_ferm pvg {if (exist1==0) {printf("ISIL.io missing\n"); 
																	YYACCEPT;}		
																	verifFormatage($3,1,idfIo,nbrIdfIO);				
																	}
;

OUT: mc_out parenth_ouv mc_text vrgl LISTE_IDF_IO parenth_ferm pvg {
																if (exist1==0) {printf("ISIL.io missing\n"); 
																	YYACCEPT;}
																	verifFormatage($3,0,idfIo,nbrIdfIO);
																  
																	}
	|mc_out parenth_ouv mc_text parenth_ferm pvg {
													if (exist1==0) {printf("ISIL.io missing\n"); 
																	YYACCEPT;
																	}
																	verifFormatage($3,0,idfIo,nbrIdfIO);
													}
;

LISTE_IDF_IO: idf vrgl LISTE_IDF_IO {
	int i=0;
	idfIo[nbrIdfIO]=strdup($1);
	nbrIdfIO++;
}

			| idf {
	int i=0;
	idfIo[nbrIdfIO]=strdup($1);
	nbrIdfIO++;}
;

LISTE_AFFECT: idf affect {
	if (exist2==0) {printf("ISIL.lang missing\n"); YYACCEPT;}
	saveType=getType($1); 
	if(isDoubleDeclared($1)==0){
	printf("Erreur,La variable est non Declaree. ligne :%d",nb_ligne);YYACCEPT;}} EXPRESSION pvg  {
			  if(verifSiConstAff($1)==-1){printf("erreur, Modification d une valeur d une constante.");
									YYACCEPT;}
				 affectCST($1);
				 if(saveType==0){
				
				 sprintf(tmp,"%d",saveVal2);
				 insertVal($1,tmp);
				 }
				 
				 if(saveType==1){
				
				 sprintf(tmp,"%f",saveVal_float2);
				 insertVal($1,tmp);
				 }

				 if(saveType==-1){

				 insertVal($1,saveVal_char);
				 }
				 }
			|idf_tab crochet_ouv{saveType=getType($1);} EXPRESSION crochet_ferm affect {
				if (exist2==0) {printf("ISIL.lang missing\n");YYACCEPT;}
			saveType=getType($1);
			if(isDoubleDeclared($1)==0){
			  printf("Erreur,La variable est non Declaree.Ligne: %d",nb_ligne);
			  YYACCEPT;
			  }
			  if(trouve!=1){
				if(verifierTailleTableau($1,saveVal2)==0) {YYACCEPT;}
				trouve=0;
			 
			 }else{
			 printf("erreur, type incompatible. ligne : %d",nb_ligne); YYACCEPT;
			 }

			} EXPRESSION pvg 
			 		
;
	
EXPRESSION:	valeur{ 

				if(saveType!=0){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}
				saveVal2=$1;
				$$=$1;
				
				}
			|valeur_reel {
				if(saveType!=1){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}
				saveVal_float2=$1;
				$$=$1;
				trouve=1;
				
				}
			|mc_text {
				if(saveType!=-1){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}
				strcpy(saveVal_char,$1);
				trouve=1;

				}
			|EXPRESSION mc_div EXPRESSION {
				if (exist2==0) {printf("ISIL.lang missing\n"); 
																	YYACCEPT;}
				if($3 == 0){printf("Erreur semantique a la ligne %d : division par zero\n", nb_ligne);exit(1);}
				$$=$1/$3;
				if(saveType==0)saveVal2=$$;
				if(saveType==1)saveVal_float2=$$;
				
				
				
			}
			|EXPRESSION mc_multi EXPRESSION {
				if (exist2==0) {printf("ISIL.lang missing\n"); 
																	YYACCEPT;}
				$$=$1*$3;
				if(saveType==0)saveVal2=$$;
				if(saveType==1)saveVal_float2=$$;
				
				
			}
			|EXPRESSION mc_soust EXPRESSION {
				if (exist2==0) {printf("ISIL.lang missing\n"); 
																	YYACCEPT;}
				$$=$1-$3;
				if(saveType==0)saveVal2=$$;
				if(saveType==1)saveVal_float2=$$;
				
			}
			|EXPRESSION mc_somme EXPRESSION {
				if (exist2==0) {printf("ISIL.lang missing\n"); 
																	YYACCEPT;}
				$$=$1+$3;
				if(saveType==0)saveVal2=$$;
				if(saveType==1)saveVal_float2=$$;
			}
			| parenth_ouv EXPRESSION parenth_ferm{$$ = $2;}
			|idf {	if(isDoubleDeclared($1)==0){
			  printf("Erreur,La variable est non Declaree.Ligne: %d",nb_ligne);
			  YYACCEPT;
			  }

					if(getType($1)==-1 && saveType!=-1){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}
			 	  	if(getType($1)==1 && saveType!=1){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}
				   	if(getType($1)==0 && saveType!=0){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}

				   	if(getType($1)==0){$$=getValINT($1); }
				   	if(getType($1)==1){getValFloat(tmp3,$1); sscanf(tmp3,"%f",&val); $$=val;  }

				   	if(getType($1)==0){
				   	getString(tmp2,$1);
					strcpy(saveVal_char,tmp2);
					}

				   }
			|idf_tab crochet_ouv EXPRESSION crochet_ferm {
													if(verifierTailleTableau($1,(int)$3)==0) YYACCEPT;
													if(getType($1)!=saveType){printf("erreur,Non compatibilitee de type.Ligne: %d",nb_ligne); YYACCEPT;}		
																}
;

BOUCLE:mc_for parenth_ouv INIT pvg CONDITION pvg INCREMENT parenth_ferm aco_ouv LISTE_INST aco_ferm
;

INIT:idf affect valeur
;

CONDITION:idf LISTE_CONDITION valeur
			|idf LISTE_CONDITION idf

;

INCREMENT:idf mc_somme mc_somme
;

LISTE_CONDITION:mc_egal
				|mc_inf
				|mc_sup
				|mc_inf_egal
				|mc_sup_egal
				|mc_not_egal

;
	
%%
main(){
yyparse();
afficher();
}

yywrap()
{}
int yyerror(char*msg)
{
printf("erreur syntaxique a ligne %d!!",nb_ligne);
}