#include "../include/listechainee.h"

// Fonction permetant de creer un chainon d'une liste
pChainon creationchainon(float* tab, int taille)
{
    pChainon nouveau = malloc(sizeof(Chainon));
    if(PTR_NUL(nouveau))
    {
        ERREUR_ALLOCATION;
        exit(3); // Code d'erreur interne
    }

    // Declare dynamiquement le tableau car les tailles peuvent varrier d'une execution à l'autre
    nouveau->tab = malloc(sizeof(float) * taille);
    
    // Affecte toute les valeurs du tableau dans le chainon
    for(int i = 0; i < taille; i++)
    {
        nouveau->tab[i] = tab[i];
    }
    
    nouveau->suivant = NULL;

    return nouveau;
}

bool condition_deTri(pChainon ptr, pChainon current, int sens)
{
    return (sens <= 0) ? (ptr->tab[0] < current->tab[0]) : (ptr->tab[0] > current->tab[0]);
}

pChainon trier_listechainee(pChainon pliste, int sens)
{
    pChainon sorted = NULL;
    pChainon current = pliste;
    
    while (!PTR_NUL(current)) 
    {
        pChainon next = current->suivant;

        // Trouver l'emplacement correct pour le chaînon courant dans la liste triée
        pChainon ptr = sorted; // Premier chainon de la liste trié
        pChainon prev = NULL;
        
        while (!PTR_NUL(ptr) && condition_deTri(ptr, current, sens)) 
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





// Insert un nouveau chainon à la fin de la liste en parametre
pChainon insertfin(pChainon pliste, float* tab, int taille)
{
    if(PTR_NUL(pliste))
    {
        pliste = creationchainon(tab, taille);
        return pliste;
    }

    pChainon current = pliste;
    pChainon new = creationchainon(tab, taille);

    // Nous parcourons la liste tant qu'il y a des suivant
    while(!PTR_NUL(current->suivant))
    {
        current = current->suivant;
    }

    // S'il n'y en a plus nous en creons un
    current->suivant = new;
    return pliste;
}


// Trie la liste chainée en suivant la methode du trie fusion
pChainon tri_fusion(pChainon pliste, int sens)
{
    if(PTR_NUL(pliste) || PTR_NUL(pliste->suivant))
    {
        return pliste;
    }

    // Casse la liste en deux
    pChainon gauche = pliste;
    pChainon droite = milieu(pliste);
    pChainon temp = droite->suivant;


    droite->suivant = NULL;
    droite = temp;

    gauche = tri_fusion(gauche, sens);
    droite = tri_fusion(droite, sens);

    return fusionner(gauche, droite, sens);
}

pChainon milieu(pChainon pliste)
{
    pChainon courant = pliste;
    pChainon suivant = pliste->suivant;

    while(!PTR_NUL(suivant) && !PTR_NUL(suivant->suivant))
    {
        courant = courant->suivant;
        suivant = suivant->suivant->suivant;
    }

    return courant;

}

pChainon fusionner(pChainon gauche, pChainon droite, int sens) 
{
    pChainon result = NULL;

    if (!gauche) 
    {
        return droite;
    }
    else if (!droite) 
    {
        return gauche;
    }

    bool condition_trie = (sens <= 0) ? gauche->tab[0] <= droite->tab[0] : gauche->tab[0] >= droite->tab[0];

    // Le trie se base sur la comparaison entre les valeurs de tab[0]
    if (condition_trie)
    {
        result = gauche;
        result->suivant = fusionner(gauche->suivant, droite, sens);
    }
    else 
    {
        result = droite;
        result->suivant = fusionner(gauche, droite->suivant, sens);
    }

}



void traiter(pChainon pliste, int taille)
{
    if(PTR_NUL(pliste))
    {
        LISTE_VIDE;
    }


    printf("\n");
    
    for(int i = 0; i < taille; i++)
    {
        printf("%f", pliste->tab[i]);
        if(i < TAILLE - 1)
        {
            printf("| ");
        }
    }
}

// Affiche tous les chainons de la liste
void traiterListe(pChainon pliste, int taille)
{
    pChainon current = pliste;
    while(!PTR_NUL(current))
    {
        traiter(current, taille);
        printf("\n");

        current = current->suivant;
    }
}


/*
void main()
{
    float tab[TAILLE] = {0, 1, 1, 1, 1};
    float tab2[TAILLE] = {1, 0, 1, 1, 10};
    float tab3[TAILLE] = {1, 4, 1, 1, 1};
    float tab4[TAILLE] = {2, 1, 1, 1, 100};
    pChainon a = creationchainon(tab3, TAILLE);
    insertfin(a, tab, TAILLE);
    insertfin(a, tab2, TAILLE);
    insertfin(a, tab3, TAILLE);
    insertfin(a, tab4, TAILLE);

    for(int i = 0; i < (25); i++)
    {
        insertfin(a, tab, TAILLE);
        insertfin(a, tab2, TAILLE);
        insertfin(a, tab3, TAILLE);
        insertfin(a, tab4, TAILLE);
    }
    a =  tri_fusion(a);
    traiterListe(a);
}*/












