#ifndef LISTE_CHAINEE
#define LISTE_CHAINEE

#include "masterlib.h"

// Definition des macros utilisé dans ce fichier
#define LISTE_VIDE printf("\nLa liste est vide")

//// Crée la structure du chainon
typedef struct chainon
{
    float tab[TAILLE];
    struct chainon* suivant;
}Chainon;

typedef Chainon* pChainon;

//// Établie les définitions des fonctions
pChainon creationchainon(float* tab);

pChainon insertdebut(pChainon pliste, float* tab);
pChainon insertfin(pChainon pliste, float* tab);
pChainon trier_listechainee(pChainon pliste);
pChainon triebulle(pChainon pliste);

void traiter(pChainon pliste);
void traiterListe(pChainon pliste);




#endif