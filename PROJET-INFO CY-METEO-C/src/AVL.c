#include "../include/AVL.h"


// Insert un nouveau noeud en requillibrant l'arbre
pArbre insertion_AVL(pArbre a, float* tab, int* h, int taille)
{
    if(PTR_NUL(a))
    {
        *h = 1;
        return creerArbre(tab, taille);
    }

    else if(tab[0] <= a->tab[0])
    {
        a->fg = insertion_AVL(a->fg, tab, h, taille);
        *h = -*h;
    }

    else if(tab[0] > a->tab[0])
    {
        a->fd = insertion_AVL(a->fd, tab, h, taille);
    }

    // Remplace la valeur d'equilibre du noeud
    if(PTR_NUL(a))
    {
        *h = 0;
    }

    else if(*h != 0)
    {
        a->equilibre += *h;
        a = equilibrageAVL(a);
        *h = (a->equilibre != 0);
    }

    return a;
}

/////
////////////////////////////// FONCTION DE ROTATIONS D'AVL

pArbre rotationDroite(pArbre a)
{
    pArbre pivot = a->fg;
    int eq_a = 0, eq_p = 0;

    a->fg = pivot->fd;
    pivot->fd = a;

    // Ajustage de l'equilibre
    eq_a = a->equilibre;
    eq_p = pivot->equilibre;

    a->equilibre = eq_a - MIN(eq_p, 0) + 1;
    pivot->equilibre = MAX(MAX(eq_a + 2, eq_a + eq_p + 2), eq_p + 1);

    return pivot;
}

pArbre rotationGauche(pArbre a)
{
    pArbre pivot = a->fd;
    int eq_a = 0, eq_p = 0;

    a->fd = pivot->fg;
    pivot->fg = a;

    // Ajustage de l'equilibre
    eq_a = a->equilibre;
    eq_p = pivot->equilibre;

    a->equilibre = eq_a - MAX(eq_p, 0) - 1;
    pivot->equilibre = MIN(MIN(eq_a - 2, eq_a + eq_p - 2), eq_p - 1);


    return pivot;

}

pArbre doubleRotationGauge(pArbre a)
{
    a->fd = rotationDroite(a->fd);
    return rotationGauche(a);
}

pArbre doubleRotationDroite(pArbre a)
{
    a->fg = rotationGauche(a->fg);
    return rotationDroite(a);
}

/////
//////////////////////////////


pArbre equilibrageAVL(pArbre a)
{
    if(a->equilibre >= 2)
    {
        if(a->fd->equilibre >= 0)
        {
            return rotationGauche(a);
        }

        return doubleRotationGauge(a);
    }

    else if(a->equilibre <= -2)
    {
        if(a->fg->equilibre <= 0)
        {
            return rotationDroite(a);
        }

        return doubleRotationDroite(a);
    }

    return a;
}



/*
void main()
{
    float tab[TAILLE] = {10, 1, 1, 1, 10};
    float tab2[TAILLE] = {7, 1, 1, 1, 1};
    float tab3[TAILLE] = {11, 3};
    float tab4[TAILLE] = {4, 2};

    pArbre a = creerArbre(tab, TAILLE);
    int h = 0;
    a = insertion_AVL(a, tab2, &h, TAILLE);
    a = insertion_AVL(a, tab3, &h, TAILLE);
    a = insertion_AVL(a, tab, &h, TAILLE);
    a = insertion_AVL(a, tab2, &h, TAILLE);
    a = insertion_AVL(a, tab3, &h, TAILLE);
    a = insertion_AVL(a, tab4, &h, TAILLE);
    a = insertion_AVL(a, tab2, &h, TAILLE);
    a = insertion_AVL(a, tab3, &h, TAILLE);
    a = insertion_AVL(a, tab2, &h, TAILLE);
    a = insertion_AVL(a, tab4, &h, TAILLE);

    for(int i = 0; i < 2732342; i++)
    {
        a = insertion_AVL(a, tab, &h, TAILLE);
    }

    parcour_infixe(a);
}*/

