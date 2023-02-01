#include "include/masterlib.h"
#include "include/listechainee.h"
#include "include/ABR.h"
#include "include/AVL.h"

/*
int main(int argc, char** argv)
{
    // Declare les chemin des flux
    char* chemin_entree = NULL;
    char* chemin_sortie = NULL;

    // 0:listechainee - 1:ABR - 2:AVL 
    int type_trie[3] = {0};
    int sens_trie = 0;

    // Traite les arguments du programme
    for(int i = 1; i < argc; i++)
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
            type_trie[0] = 1;
        }
        else if(strcmp("--ABR", argv[i]) == 0)
        {
            type_trie[1] = 1;
        }
        else if(strcmp("--AVL", argv[i]) == 0)
        {
            type_trie[2] = 1;
        }

        //////// Etablie le sens
        else if(strcmp("-r", argv[i]) == 0)
        {
            sens_trie = 1;
        }
    }



    // Ouvre le fichier cible
    FILE* mon_fichier = fopen(chemin_entree, "r+");
    if(PTR_NUL(mon_fichier))
    {
        printf("Y'a pas de panneau !");
        return 1;
    }

    ////// Trie listechainnee
}
*/