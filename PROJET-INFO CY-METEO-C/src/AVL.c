#include "../include/AVL.h"


// Insert un nouveau noeud en requillibrant l'arbre
pArbre insertion_AVL(pArbre a, float* tab, int* h)
{
    if(PTR_NUL(a))
    {
        printf("HELLOuhsekufchsdku ");
        *h = 1;
        return creerArbre(tab);
    }

    else if(tab[0] < a->tab[0])
    {
        a->fg = insertion_AVL(a->fg, tab, h);
        *h = -*h;
    }

    else if(tab[0] > a->tab[0])
    {
        a->fd = insertion_AVL(a->fd, tab, h);
    }

    else if(tab[0] == a->tab[0])// Si la valeur est egale on compare celle du prochain champ tout comme l'ABR
    {
        if(tab[1] < a->tab[1])
        {
            a->fg = insertion_AVL(a->fg, tab, h);
            *h = -*h;
        }

        else if(tab[1] > a->tab[1])
        {
            a->fd = insertion_AVL(a->fd, tab, h);
        }
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
    a->fd = rotationGauche(a);
    return rotationGauche(a);
}

pArbre doubleRotationDroite(pArbre a)
{
    a->fg = rotationDroite(a);
    return rotationGauche(a);
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





void main()
{
    float tab[TAILLE] = {1, 1};
    float tab2[TAILLE] = {2, 2};
    float tab3[TAILLE] = {3, 2};
    float tab4[TAILLE] = {4, 2};

    pArbre a = creerArbre(tab4);
    int h = 0;
    a = insertion_AVL(a, tab2, &h);
    a = insertion_AVL(a, tab, &h);
    a = insertion_AVL(a, tab3, &h);

    printf("%d ", a->equilibre);
    printf("%f , ", a->tab[0]);
}