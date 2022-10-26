#include<string.h>
#include<stdio.h>
#include<stdlib.h>
 
		typedef struct
		{
		char NomEntite[20];
		char CodeEntite[20];
		char TypeEntite[20];
		char isConst[20];
		int tailleTable;
		char val[20];
		int aff;
		} TypeTS;
		//initiation d'un tableau qui va contenir les elements de la table de symbole
        TypeTS ts[100]; 
		// un compteur global pour la table de symbole
        int CpTabSym=0;


		
  //Fonction recherche
		int recherche(char entite[])
		{
		int i=0;
		while(i<CpTabSym)
		{
		if (strcmp(entite,ts[i].NomEntite)==0) return i;
		i++;
		}
		return -1;
		}
		
  //insertion dans la TS
  void inserer(char entite[], char code[])
	{

	if ( recherche(entite)==-1)
	{
	strcpy(ts[CpTabSym].NomEntite,entite); 
	strcpy(ts[CpTabSym].CodeEntite,code);
	strcpy(ts[CpTabSym].isConst,"nonConst");
	CpTabSym++;
	}
	}
  //Affichage de la Table des Symboles
	  void afficher ()
	{
	printf("\n/***************Table des symboles ******************/\n");
	printf("____________________________________________________________________________________________________\n");
	printf("\t| NomEntite |  CodeEntite | TypeEntite |  Constant  |        valeur         |   Taille    |\n");
	printf("----------------------------------------------------------------------------------------------------\n"); 
	//printf("_____________________________________________________________________________________________________\n");
	int i=0;
	  while(i<CpTabSym)
	  {
		printf("\t|%10s |%12s | %10s | %10s |  %19s  |  %10d | \n",ts[i].NomEntite,ts[i].CodeEntite,ts[i].TypeEntite,ts[i].isConst,ts[i].val,ts[i].tailleTable);
		printf("----------------------------------------------------------------------------------------------------\n"); 
		 i++;
	   }
	}

	
	//inseration du Type de variables
	
	 void typeInsert(char entite[], int type)
	{
       int pos;
	   pos=recherche(entite);
	if(pos!=-1){
	   if(type==0)strcpy(ts[pos].TypeEntite,"Entier");
	   if(type==1)strcpy(ts[pos].TypeEntite,"Reel");
	   if(type==-1)strcpy(ts[pos].TypeEntite,"Chaine");   
	}
	}
	/* void typeInsert2(char entite[], char type[])
	{
       int pos;
	   pos=recherche(entite);
	if(pos!=-1)
	   strcpy(ts[pos].TypeEntite,type);   
	}*/

	//Verification si constante ou Non

	void constantInsert(char entite[])
	{
       int pos;
	   pos=recherche(entite);
	if(pos!=-1)
	   strcpy(ts[pos].isConst,"const");
	}

    //Fonction Verification Double Declaration

	int isDoubleDeclared(char entite[])
	{
	int pos;
	pos=recherche(entite);
	if(strcmp(ts[pos].TypeEntite,"")==0) return 0;
	   else return -1;
	}

//-------------------------------------------------------------------
	//insertion de la taille d'une table

	void insertTaille(char entite[],int taille)
	{
		int pos;
	    pos=recherche(entite);
	if(pos!=-1) {ts[pos].tailleTable=taille;}
	}

	int verifierTailleTableau(char entite[],int nombre){
if(nombre>=ts[recherche(entite)].tailleTable){ printf("error, index out of bounds."); return 0;}
	return -1;
	}
	

	void cstAffect(char entite[]){
     int pos;
	pos=recherche(entite);
	if(pos!=-1) {ts[pos].aff=1;}
	}
	
	int verifSiConstAff(char entite[]){
		int pos;
	    pos=recherche(entite);
		if(ts[pos].aff==1)return -1;
		if(ts[pos].aff==0)return 1;
		return 0;
	}

	void affectCST(char entite[]){
  if(strcmp(ts[recherche(entite)].isConst,"const")==0) ts[recherche(entite)].aff=1;
	}
	
//--------------------------------------------------------------------

//insertion de la valeur dans la table:

void insertVal(char entite[],char valeur[]){
	int pos;
	pos=recherche(entite);
	if(pos!=-1)
	{
		strcpy(ts[pos].val,valeur);
	}
}


//Verification du Type de la Variable

int getType(char entite[]){
	int pos;
	pos=recherche(entite);
	if(strcmp(ts[pos].TypeEntite,"")==0) return 2;
	if(strcmp(ts[pos].TypeEntite,"Entier")==0) return 0;
	if(strcmp(ts[pos].TypeEntite,"Reel")==0) return 1 ;
	if(strcmp(ts[pos].TypeEntite,"Chaine")==0) return -1;
}


//Fonctions de IN/OUT


int verifFormatage(char* text,int lecture,char* idfs[],int nbrIdfIO){
		int i;
	if(lecture==1){
		for (i = 0; i < strlen(text)-1; i++)
		{
			if(text[i]=='%' && i != strlen(text)-1 && (text[i+1] =='d' || text[i+1] =='f' || text[i+1] =='s' ))  i++;
			else if (text[i] != '"' && text[i] != ' '){
				printf("Erreur Semantique,ligne: %d Lecture n'accepte que les signes de formattages\n",nb_ligne);
				exit(-1);
				return;
			} 	
		}
	}

	int nbrSignForma=0;

		for (i = 0; i < strlen(text)-1; i++)
		{
			if(text[i]=='\\') i++;
			else if(text[i] == '%' && (text[i+1]== 'd' || text[i+1]== 'f' || text[i+1]== 's')) nbrSignForma++;
		}

		if (nbrIdfIO != nbrSignForma)
		{
			printf("Erreur semantique a la ligne %d :nbr de signes format different de nombre de parametres\n",nb_ligne);
			exit(-1);
			return;
		}

		int posIdf=nbrIdfIO-1;

		for (i = 0; i < strlen(text)-1; i++)
		{
			if(text[i] == '%' && (text[i+1]== 'd' || text[i+1]== 'f' || text[i+1]== 's')){
				char format = text[i+1];
				int type = getType(idfs[posIdf]);
				if (type==2)
				{
					printf("Erreur semantique ,ligne: %d la variable %s n'est pas declaree",nb_ligne,idfs[posIdf]);
					exit(-1);
					return;
				}
				if (type!=0 && format=='d')
				{
					printf("Erreur semantique, ligne %d , la variables %s n'est pas un entier\n",nb_ligne,idfs[posIdf]);
					exit(-1);
					return;
				}
				else if (type!=1 && format=='f')
				{
					printf("Erreur semantique, ligne %d , la variables %s n'est pas un Reel\n",nb_ligne,idfs[posIdf]);
					exit(-1);
					return;
				}
				else if (type!=-1 && format=='s')
				{
					printf("Erreur semantique, ligne %d , la variables %s n'est pas une Chaine\n",nb_ligne,idfs[posIdf]);
					exit(-1);
					return;
				}
				else posIdf--;
			}
		}
	}

	int getValINT(char entite[]){
        int pos;
        pos= recherche(entite);
        int val;
        if(pos!=-1){
            sscanf(ts[pos].val,"%d",&val);
            return val;
        }
    }

    void getValFloat(char* str,char entite[]){
        int pos;
        pos= recherche(entite);
        float val;
        if(pos!=-1){
        	
            strcpy(str,ts[pos].val);
        }
    }

    void getString(char* str,char entite[]){

    	int pos;
        pos= recherche(entite);
        if(pos!=-1){
        	strcpy(str,ts[pos].val);
        }


    }

    int TAB(char entite[]){
    	int pos;
        pos= recherche(entite);
        if(pos!=-1){
        	if(strcmp("tab",ts[pos].CodeEntite)==0)return 1;
        	return 0;
        }
    }

