#ifndef ABRE_BR
#define ABRE_BR

#include "masterlib.h"

// Definition des macros utilisé dans ce fichier
#define ARBRE_VIDE printf("\nL'arbre est vide !")

//// Creation de la structure de l'Abre utilise pour les ABR et aussi les AVL
typedef struct arbre
{
    float tab[TAILLE];
    int equilibre;
    struct arbre* fg;
    struct arbre* fd;
}Arbre;

typedef Arbre* pArbre;


// Déclaration des fonctions
pArbre creerArbre(float* tab);
pArbre insertion_ABR(pArbre a, float* tab);

bool existe_fg(pArbre a);
bool existe_fd(pArbre a);

void ajouter_fg(pArbre a, float* tab);
void ajouter_fd(pArbre a, float* tab);
void traiter_noeud(pArbre a);
void parcour_infixe(pArbre a);

#endif