#include "../include/listechainee.h"

// Fonction permetant de creer un chainon d'une liste
pChainon creationchainon(float* tab)
{
    pChainon new = malloc(sizeof(Chainon));
    if(PTR_NUL(new))
    {
        ERREUR_ALLOCATION;
        exit(3); // Code d'erreur interne
    }

    // Affecte toute les valeurs du tableau dans le chainon
    for(int i = 0; i < TAILLE; i++)
    {
        new->tab[i] = tab[i];
    }
    
    new->suivant = NULL;

    return new;
}

// Insert un nouveau chainon dans la liste passe en parametre
pChainon insertdebut(pChainon pliste, float* tab)
{
    if(PTR_NUL(pliste))
    {
        LISTE_VIDE;
        return NULL;
    }

    pChainon new = creationchainon(tab);
    new->suivant = pliste;
    return new;
}

// Insert un nouveau chainon à la fin de la liste en parametre
pChainon insertfin(pChainon pliste, float* tab)
{
    if(PTR_NUL(pliste))
    {
        LISTE_VIDE;
        return NULL;
    }

    pChainon current = pliste;
    pChainon new = creationchainon(tab);

    // Nous parcourons la liste tant qu'il y a des suivant
    while(!PTR_NUL(current->suivant))
    {
        current = current->suivant;
    }

    // S'il n'y en a plus nous en creons un
    current->suivant = new;
    return pliste;
}



// Trie la liste d'une methode de trie par insertion (En triant les chainons en eux meme)
pChainon trier_listechainee(pChainon pliste)
{
    pChainon sorted = NULL;
    pChainon current = pliste;
    
    while (!PTR_NUL(current)) 
    {
        pChainon next = current->suivant;

        // Trouver l'emplacement correct pour le chaînon courant dans la liste triée
        pChainon ptr = sorted; // Premier chainon de la liste trié
        pChainon prev = NULL;
        
        while (!PTR_NUL(ptr) && ptr->tab[0] < current->tab[0]) 
        {
            prev = ptr;
            ptr = ptr->suivant;
        }

        // Insérer le chaînon courant dans la liste triée
        if (PTR_NUL(prev)) 
        {
            current->suivant = sorted;
            sorted = current;
        }
        else 
        {
            current->suivant = ptr;
            prev->suivant = current;
        }

        current = next;
    } 

    // Retourner la référence à la tête de la liste triée
    return sorted;
}

// Trie la liste en triant ces valeurs par une methode de trie à bulle
pChainon triebulle(pChainon pliste)
{
    bool est_trie = false;
    pChainon current = pliste;
    float temp[TAILLE] = {0};

    while(est_trie == false)
    {
        est_trie = true;
        current = pliste;

        while(!PTR_NUL(current->suivant))
        {
            if(current->tab[0] > current->suivant->tab[0])
            {
                est_trie = false;
                
                // On intervertit la valeurs des deux chainons en compiant leurs valeur
                memcpy(temp, current->tab, sizeof(float) * TAILLE);
                memcpy(current->tab, current->suivant->tab, TAILLE * sizeof(float));
                memcpy(current->suivant->tab, temp, TAILLE * sizeof(float));
            }

            current = current->suivant;
        }

    }

    return pliste;
}

// Affiche un seul chainon de la liste
void traiter(pChainon pliste)
{
    if(PTR_NUL(pliste))
    {
        LISTE_VIDE;
    }


    printf("\n");
    
    for(int i = 0; i < TAILLE; i++)
    {
        printf("%f", pliste->tab[i]);
        if(i < TAILLE - 1)
        {
            printf("| ");
        }
    }
}

// Affiche tous les chainons de la liste
void traiterListe(pChainon pliste)
{
    pChainon current = pliste;
    while(!PTR_NUL(current))
    {
        traiter(current);
        printf("\n");

        current = current->suivant;
    }
}
