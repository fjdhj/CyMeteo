#ifndef LISTE_CHAINEE
#define LISTE_CHAINEE

#include "masterlib.h"

// Definition des macros utilisé dans ce fichier
#define LISTE_VIDE printf("\nLa liste est vide")

//// Crée la structure du chainon
typedef struct chainon
{
    float* tab;
    struct chainon* suivant;
}Chainon;

typedef Chainon* pChainon;

//// Établie les définitions des fonctions
pChainon creationchainon(float* tab, int taille);
pChainon insertfin(pChainon pliste, float* tab, int taille);
pChainon tri_fusion(pChainon pliste, int sens);
pChainon milieu(pChainon pliste);
pChainon fusionner(pChainon left, pChainon right, int sens);
pChainon trier_listechainee(pChainon pliste, int sens);



bool condition_deTri(pChainon ptr, pChainon current, int sens);

void traiter(pChainon pliste, int taille);
void traiterListe(pChainon pliste, int taille);




#endif