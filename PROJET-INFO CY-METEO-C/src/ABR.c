#include "../include/ABR.h"


// Fonction permetant de creer le noeud d'un arbre et de retourner son adresse
pArbre creerArbre(float* tab)
{
    pArbre new = malloc(sizeof(Arbre));
    if(PTR_NUL(new))
    {
        ERREUR_ALLOCATION;
        exit(1);
    }

    // Affecte toute les valeurs du tableau dans le noeud
    for(int i = 0; i < TAILLE; i++)
    {
        new->tab[i] = tab[i];
    }

    new->equilibre = 0; // Initialise l'equilibre pour les AVL
    new->fg = NULL;
    new->fd = NULL;
}

// Ajoute un fils gauche au chainon mis en parametre
void ajouter_fg(pArbre a, float* tab)
{
    if(PTR_NUL(a))
    {
        ARBRE_VIDE;
    }

    pArbre new = creerArbre(tab);
    a->fg = new;    
}

// Ajoute un fils droit au chainon mis en parametre
void ajouter_fd(pArbre a, float* tab)
{
    if(PTR_NUL(a))
    {
        ARBRE_VIDE;
    }

    if(!existe_fd(a))
    {
        pArbre new = creerArbre(tab);
        a->fd = new;
    }
}

// Insert une ligne dans l'ABR en parametre en evaluant la valeur tab[0]
pArbre insertion_ABR(pArbre a, float* tab)
{
    if(PTR_NUL(a))
    {
        return creerArbre(tab);
    }

    else if(tab[0] < a->tab[0])
    {
        a->fg = insertion_ABR(a->fg, tab);
    }

    else if(tab[0] > a->tab[0])
    {
        a->fd = insertion_ABR(a->fd, tab);
    }

    
    // Si l'on a un doublon on verifie la prochaine valeur du tableau pour le trier
    else if (tab[0] == a->tab[0])
    {
        if(tab[1] < a->tab[1])
        {
            a->fg = insertion_ABR(a->fg, tab);
        } 

        else if(tab[1] > a->tab[1])
        {
            a->fd = insertion_ABR(a->fd, tab);
        }
    }
    
    return a;
}


// Retourne l'existance d'un fils gauche
bool existe_fg(pArbre a)
{
    return PTR_NUL(a) && PTR_NUL(a->fg);
}

// Retourne l'existance d'un fils droit
bool existe_fd(pArbre a)
{
    return PTR_NUL(a) && PTR_NUL(a->fd);
}

// Affiche un noeud specifique de l'arbre de la meme maniere qu'une liste
void traiter_noeud(pArbre a)
{
    if(PTR_NUL(a))
    {
        ARBRE_VIDE;
    }

    printf("\n");

    for(int i = 0; i < TAILLE; i++)
    {
        printf("%f", a->tab[i]);
        if(i < TAILLE - 1)
        {
            printf("| ");
        }
    }
    
}



// Fonction permetant de retourner les valeurs de l'arbre de façon croissante
void parcour_infixe(pArbre a)
{
    if(!PTR_NUL(a))
    {
        parcour_infixe(a->fg);
        traiter_noeud(a);
        parcour_infixe(a->fd);
    }
}


