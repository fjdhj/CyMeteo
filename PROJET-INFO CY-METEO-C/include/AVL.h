#ifndef AVL_H
#define AVL_H

#include "masterlib.h"
#include "ABR.h"

// Declare des Macro nous permetant de savoir le minimum ou le maximum des deux parametre
// Je sais qu'elle sont probablement deja presente nativement mais mon compilateur ne semblait pas les trouver
#define MIN(a, b) a < b ? a : b
#define MAX(a, b) a > b ? a : b

pArbre insertion_AVL(pArbre a, float* tab, int* h);
pArbre rotationDroite(pArbre a);
pArbre rotationGauche(pArbre a);
pArbre doubleRotationGauge(pArbre a);
pArbre doubleRotationDroite(pArbre a);
pArbre equilibrageAVL(pArbre a);

#endif