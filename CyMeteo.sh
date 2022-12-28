#!/bin/bash

aide() {
    #Affiche l'aide
    echo "CyMeteo - Creer des graphique métérologique"
    echo
    echo "Syntax: CyMeteo <typeDonnee> [argOptionel] -f <cheminFichierDonnee>"
    echo "Option des types de données, créer un graphique avec :"
    echo "  -t<mode>: la température avec le mode choisi"
    echo "  -p<mode>: la pression avec le mode choisi"
    echo "  -w: la direction et vitesse moyenne du vent par rapport a sa position"
    echo "  -h: la hauteur des station pas rapport a leur position"
    echo "  -m: l'humidité maximal pour chaque station par rapport a leur position"
    echo "Mode (pour -t et -p), créer un graphique avec :"
    echo "  Mode 1: la température/pression moyenne, minimal et maximal par station"
    echo "  Mode 2: la température/pression moyenne par ordre chronologique"
    echo "  Mode 3: la température/pression par ordre chronologique"
    echo "Chemin vers le fichier de donnée :"
    echo "  -f <cheminFichierDonnee>: le fichier de donnée a utiliser"
    echo
    echo "Argument optionnel"
    echo "Restriction géographique (argument exclusive)"
    echo "	-F: France: France métropolitaine + Corse"
    echo "	-G: Guyane française"
    echo "	-S: Saint-Pierre et Miquelon: ile située à l’Est du Canada"
    echo "	-A: Antilles"
    echo "	-O: Océan indien"
    echo "	-Q: Antarctique"
    echo "Restriction temporel :"
    echo "  -d <min> <max>: le prend que les données dans l'intervalle [<min>, <max>]"
    echo "  Les valeurs <min> et <max> sont des dates au format YYYY-MM-DD (année, mois, jour)"
    echo "Mode de tri :"
    echo "  --tab: réalise un tri avec un tableau"
    echo "  --abr: réalise un tri avec un ABR"
    echo "  --avl: réalise un tri avec un AVL"
    echo "  Si aucun mode de tri n'est spécifié, le tri AVL seras fait par défaut"
    echo "Affichage de l'aide :"
    echo "  --help: affiche cette aide"
    echo
}


if [ $# -eq 0 ] ; then
    echo "Pas assez d'argument, utilisez --help pour voir comment utiliser le script" >&2
    exit 1;
fi

typeDonne=""
position=""
algoTri=""


for arg in $(seq 1 $#) ; do
    echo "${!arg}"
    case "${!arg}" in
        
        #Aide (--help)
        --help)
            aide
            exit 0 ;;

        #Type de donnee
        -[tp][1-3] | -[whm])
            typeDonne="$typeDonne ${!arg}" ;;

        #Restriction geographique 
        -[FGSAOQ])
            if [ "$position" != "" ] ; then
                echo "Mauvais argument, $position et ${!arg} sont exclusive. Utilisez --help pour voir comment utiliser le script" >&2
                exit 1;
            fi
            position=${!arg} ;;

        #Algorithme de tri
        --tab | --abr | --avl)
            if [ "$algoTri" != "" ] ; then
                echo "Mauvais argument, $algoTri et ${!arg} sont exclusive. Utilisez --help pour voir comment utiliser le script" >&2
                exit 1;
            fi
            algoTri=${!arg} ;;

        #L'argument n'existe pas
        *)
            echo "Mauvais argument, utilisez --help pour voir comment utiliser le script" >&2 
            exit 1 ;;
    esac
done
