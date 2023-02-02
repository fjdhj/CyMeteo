#include "include/masterlib.h"
#include "include/listechainee.h"
#include "include/ABR.h"
#include "include/AVL.h"


int main(int argc, char** argv)
{
    // Declare les chemin des flux
    char* chemin_entree = NULL;
    char* chemin_sortie = NULL;

    // Declare les flux
    FILE* mon_fichier = NULL;
    FILE* ma_sortie = NULL;

    // 0:listechainee - 1:ABR - 2:AVL 
    int type_trie;
    int sens_trie = 0;

    // Definie des variables pour controller le flux
    char lettre;
    int taille_tab = 1;
    int i = 0;

    // Cette variable va stocker la valeur de la ligne actuelle avant de l'affecter à un chainon
    float *tab_temp = malloc(sizeof(float) * taille_tab);
    
    // Definie les variable des chainons
    pArbre a = NULL;
    pArbre a_courant = NULL;
    pChainon pliste = NULL;
    pChainon chainon_courant = NULL;
    int h = 0;


    // Traite les arguments du programme
    for(i = 1; i < argc; i++)
    {
        //////// Ajuste les chemin
        if(strcmp("-f", argv[i]) == 0)
        {
            chemin_entree = argv[i+1];
        }

        else if(strcmp("-o", argv[i]) == 0)
        {
            chemin_sortie = argv[i+1];
        }


        //////// Regarde le trie demande
        else if(strcmp("--tab", argv[i]) == 0)
        {
            type_trie = 0;
        }
        else if(strcmp("--ABR", argv[i]) == 0)
        {
            type_trie = 1;
        }
        else if(strcmp("--AVL", argv[i]) == 0)
        {
            type_trie = 2;
        }


        //////// Etablie le sens
        else if(strcmp("-r", argv[i]) == 0)
        {
            sens_trie = 1;
        }
    }


    // Ouvre le fichier cible
    mon_fichier = fopen(chemin_entree, "r+");
    if(PTR_NUL(mon_fichier))
    {
        return 1;
    }


    // On établie de nombre de colonnes grace au séparateur
    while(lettre != '\n')
    {
        lettre = fgetc(mon_fichier);
        if(lettre == ' ')
        {
            printf("%c ", lettre);
            taille_tab++;
        }
    }


    printf("TAILLE FICHIER LIGNE = %d\n", taille_tab);
    rewind(mon_fichier);


    while (lettre != EOF)
    {
        // Parcour de la ligne
        for(int i = 0; i < taille_tab; i++)
        {
            if(fscanf(mon_fichier, "%f", &tab_temp[i]) <= 0)
            {
                // Erreur dans le fichier data
                return 1;
            }
        }

        
        // Creer un chainon avec les valeurs associées puis trie les valeurs
        switch(type_trie)
        {
            case 0:
            pliste = insertfin(pliste, tab_temp, taille_tab); 
            pliste = tri_fusion(pliste); break;
            case 1:
            a = insertion_ABR(a, tab_temp, taille_tab); break;
            case 2:
            a = insertion_AVL(a, tab_temp, &h, taille_tab); break;
        }
        // Check si le charactère actuel n'est pas la fin du fichier
        lettre = ungetc(fgetc(mon_fichier), mon_fichier);
    }

    // On ferme le flux d'entrée
    fclose(mon_fichier);

    // Une fois toutes les valeurs trié en les réecrit dans le fichier de sortie
    ma_sortie = fopen(chemin_sortie, "r+");
    if(PTR_NUL(ma_sortie))
    {
        return 1;
    }
    
    if(type_trie == 0)
    {
        chainon_courant = pliste;
        while(!PTR_NUL(chainon_courant))
        {
            for(i = 0; i < taille_tab; i++)
            {
                fprintf(ma_sortie, "%f", chainon_courant->tab[i]);
                fputc(' ', ma_sortie);                
            }
            fprintf(ma_sortie, "%s", "\n");
            chainon_courant = chainon_courant->suivant;
        }
    }

    // Pour retrouner les valeurs de l'arbre on éffectue un parcour infixe
    else
    {
        parcour_infixe(a, ma_sortie, taille_tab);
    }
}