#ifndef MASTER_LIB
#define MASTER_LIB

// Importation des libraries utilisées
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

// Creation de macro et de constantes utiliser dans tous les fichiers
#define PTR_NUL(ptr) (ptr == NULL)
#define BORD_DE_LIGNE(lettre)(lettre == '\n' || lettre == EOF)
#define ERREUR_ALLOCATION printf("\nErreur d'allocation")
#define TAILLE 5
#endif