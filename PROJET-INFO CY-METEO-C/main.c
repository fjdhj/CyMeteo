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

    //
    bool ligne_valide = true;

    // 0:listechainee - 1:ABR - 2:AVL 
    int type_trie;
    int sens_trie = 0;

    // Definie des variables pour controller le flux
    int lettre;
    int lettre_suivante;
    int taille_tab = 0;
    int i = 0;
    
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
        return 2;
    }

    // On établie de nombre de colonnes grace au séparateur
    do
    {
        lettre = fgetc(mon_fichier);
        lettre_suivante = fgetc(mon_fichier);
        fseek(mon_fichier, -1, SEEK_CUR);

        if(((lettre != ' ' && lettre != '\n') && (lettre_suivante == ' ' || lettre_suivante == '\n')))
        {
            taille_tab++;
        }

    }while(!BORD_DE_LIGNE(lettre));

    if(taille_tab <= 0)
    {
        return 4;
    }
    

    printf("TAILLE FICHIER LIGNE = %d\n", taille_tab);

    // Cette variable va stocker la valeur de la ligne actuelle avant de l'affecter à un chainon
    float *tab_temp = malloc(sizeof(float) * taille_tab);

    rewind(mon_fichier);    
    while (lettre != EOF)
    {
        // On initialise toutes les valeurs des chainons à 0
        memset(tab_temp, 0, taille_tab * sizeof(float));
        ligne_valide = true;

        for(int i = 0; i < taille_tab; i++)
        {
            if(fscanf(mon_fichier, "%f", &tab_temp[i]) <= 0)
            {
                // Erreur dans le fichier data
                ligne_valide = false; 
            }

            // On verifie la valeur de l'emplacement actuel du curseur
            do
            {
                lettre = fgetc(mon_fichier);

            } while (!BORD_DE_LIGNE(lettre) && lettre == ' ');
            

            if(BORD_DE_LIGNE(lettre))
            {
                break;
            }

            else
            {
                fseek(mon_fichier, -1, SEEK_CUR);                
            }
        }
        

        // On s'assure qu'on est bien sur la finde la ligne
        if(!BORD_DE_LIGNE(lettre))
        {
            while(lettre != '\n' && lettre != EOF)
            {
                lettre = fgetc(mon_fichier);
                printf("%c ", lettre);
            }         
        }   
        

        // Creer un chainon avec les valeurs associées puis trie les valeurs
        if(ligne_valide)
        {
            switch(type_trie)
            {
                case 0:
                pliste = insertfin(pliste, tab_temp, taille_tab); break;
                case 1:
                a = insertion_ABR(a, tab_temp, taille_tab); break;
                case 2:
                a = insertion_AVL(a, tab_temp, &h, taille_tab); break;
            }
        }

        // Regarde si le charactère actuel n'est pas la fin du fichier
    }

    // On ferme le flux d'entrée
    fclose(mon_fichier);
    printf("Fin de la lecture !\n");
    // Une fois toutes les valeurs trié en les réecrit dans le fichier de sortie
    ma_sortie = fopen(chemin_sortie, "w+");
    if(PTR_NUL(ma_sortie))
    {
        return 3;
    }
    
    if(type_trie == 0)
    {
        pliste = trier_listechainee(pliste, sens_trie);
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

    // Pour retrouner les valeurs de l'arbre on éffectue un parcour infixe ou decroissant en fonction du sens du trie
    else
    {
        (sens_trie <= 0) ? parcour_infixe(a, ma_sortie, taille_tab) : parcour_decroissant(a, ma_sortie, taille_tab);
    }

    fclose(ma_sortie);

    // On vide la memoire en free-ant chaque noeud
    switch (type_trie)
    {
    case 0:
        while(!PTR_NUL(pliste))
        {
            chainon_courant = pliste;
            pliste = pliste->suivant;
            free(chainon_courant);
        }
        break;
    
    default:
        supprimer_arbre(a);
        break;
    }


    printf("\nC'EST FINI !");
    return 0;
}