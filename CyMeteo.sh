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
	echo "Restriction temporel (ne spécifier qu'un fois par execution) :"
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
	echo "Valeur de retour :"
	echo "  0: pas de problème lors de l'execution"
	echo "  1: erreur avec les arguments du script"
	echo "  2: probleme avec le fichier (ouverture/lecture impossible, mauvais format de données, ..."
	echo "	3: "
	echo "	4: Un erreur grave lors du déroulement du programme" 
	echo
}


if [ $# -eq 0 ] ; then
	echo "Pas assez d'argument, utilisez --help pour voir comment utiliser le script" >&2
	exit 1;
fi

enteteFichier="ID OMM station;Date;Pression au niveau mer;Direction du vent moyen 10 mn;Vitesse du vent moyen 10 mn;Humidité;Pression station;Variation de pression en 24 heures;Précipitations dans les 24 dernières heures;Coordonnees;Température (°C);Température minimale sur 24 heures (°C);Température maximale sur 24 heures (°C);Altitude;communes (code)"
nomProgrammeTri="exec"
nomDossierC="PROJET-INFO CY-METEO-C"

donneBrute=""

typeDonne=""
position=""
algoTri=""
tempsMin=""
tempsMax=""
cheminFichier=""

#Variable utilisé pour passer le case et traiter les argument autrement
#Si la variable est positive, on récupère les arguments complémentaire de l'option -d
#Si la variable est négative, on récupère l'argument complémentaire de l'option -f
passerCase=0

for arg in $(seq 1 $#) ; do

	#Valeur <min> de l'option -d
	if [ $passerCase -eq 2 ] ; then
		# [0-9] : indique l'ensemble des charactère de 0 à 9 (donc les chiffres)
		# {n} : indique le l'expression presedente est répété n fois
		# $ : indique la fin de la ligne (necessaire)
		# ^ ; indique le début de la ligne (necessaire)
		# source  : https://fr.wikipedia.org/wiki/Expression_r%C3%A9guli%C3%A8re 
		if [[ ! "${!arg}" =~ ^[0-9]{4}-[0-1][0-9]-[0-3][0-9]$ ]] ; then
			echo "La valeur <min> de l'option -d est incorrecte. Utilisez --help pour voir comment utiliser le script" >&2
			exit 1;
		fi
		tempsMin=${!arg}
		passerCase=$(( passerCase - 1 ))

	#valeur <max> de l'option -d
	elif [ $passerCase -eq 1 ] ; then
		if [[ ! "${!arg}" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ; then
			echo "La valeur <max> de l'option -d est incorrecte. Utilisez --help pour voir comment utiliser le script" >&2
			exit 1;
		fi
		tempsMax=${!arg}
		passerCase=$(( passerCase - 1 ))
	
	#valeur <cheminFichierDonnee> de l'option -f
	elif [ $passerCase -eq -1 ] ; then
		if [ ! -f "${!arg}" ] ; then
			echo "${!arg} n'est pas un fichier. Utillisez --help pour voir comment utiliser le script" >&2
			exit 1;
		fi
		cheminFichier=${!arg}
		passerCase=$((passerCase + 1))
	
	else
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

			#Restriction temporelle
			-d)
				if [ "$tempsMin" != "" ] ; then
					echo "Mauvais argument, le parametre -d ne peux être spécifié deux fois. Utilisez --help pour voir comment utiliser le script" >&2
				fi
				passerCase=2 ;;

			-f)
				if [ "$cheminFichier" != "" ] ; then
					echo "Le chemin vers le fichier ne peut pas être spécifié deux fois. Utilisez --help pour voir comment utiliser le script" >&2
				fi
				passerCase=-1 ;;

			#L'argument n'existe pas
			*)
				echo "Mauvais argument, utilisez --help pour voir comment utiliser le script" >&2 
				exit 1 ;;
		esac
	fi
done

if [ $passerCase -gt 0 ] ; then
	echo "Argument -d incomplet, utilisez --help pour voir comment utiliser le script" >&2
	exit 1
fi

if [ $passerCase -lt 0 ] ; then
	echo "Argument -f incomplet, utilisez --help pour voir comment utiliser le script" >&2
	exit 1
fi

#Vérification argument obligatoire
if [ "$cheminFichier" == "" ] ; then
	echo "Le chemin vers le fichier n'as pas été spécifié. Utilisez --help pour voir comment utiliser le script" >&2
	exit 1
fi

if [ "$typeDonne" == "" ] ; then 
	echo "Aucun type de donnée n'a été spécifié. Utilisez --help pour voir comment marche le script" >&2
	exit 1
fi

#Ajout valeur par défaut
if [ "$algoTri" == "" ] ; then 
	algoTri="--avl"
fi

#Vérification du fichier de donnée
if [ ! -r "$cheminFichier" ] ; then
	echo "Impossible de lire le fichier $cheminFichier. Vérifier les permissions associés."
	exit 2
fi

if [ "$enteteFichier" != "$(head -n1 "$cheminFichier")" ] ; then
	echo "Le fichier n'est pas au bon format."
	exit 2
fi

#Vérification du fichier C
echo "ATTENTION: vérification du fichier C compilé impossible, ca a pas été codé"
if [ ! -f "$nomProgrammeTri" ] ; then
	make -C "$nomDossierC" 
	mv "$nomDossierC/$nomProgrammeTri" .
fi

#Traitement restriction geographique
case  $position in
	"")
		donneBrute=$(tail -n+2 "$cheminFichier") ;;
	
	#France : code postal
	-F) donneBrute=$(grep ";[0-8][0-9abAB][0-9][0-9][0-9]$\|;9[0-5][0-9][0-9][0-9]$" "$cheminFichier") ;;

	#Guyane : code postal
	-G) donneBrute=$(grep ";973[0-9][0-9]$" "$cheminFichier");;

	#St Pierre et Miquelon : code postal + coord. géo (ile sans code postal a proximité)
	-S) donneBrute=$(grep ";975[0-9][0-9]$" "$cheminFichier")
		donneBrute="$donneBrute"$'\n'"$(grep ";$" "$cheminFichier" | grep -E ";(46\.(7[4-9]|[8-9])([0-9])*|47\.(0|1[0-3])([0-9])*|47\.14(0)*),-56\.(1[3-9]([0-9])*|[2-3]([0-9])*|40(0)*);")" ;;
	
	#Antilles : code postal + coord. géo (ile sans code postal)
	-A) donneBrute=$(grep ";97[127][0-9][0-9]$" "$cheminFichier")
		donneBrute="$donneBrute"$'\n'"$(grep ";$" "$cheminFichier" | grep -E ";(10\.[8-9]([0-9])*|1[1-8](\.([0-9])*)?|19(\.(0)*)?),-(59\.[4-9]([0-9])*|6[0-6](\.([0-9])*)?|67(\.([0-2]([0-9])*|3(0)*))?);")" ;;

	#Océan indien : code postal + coord. Geo (iles sans code postal)
	-O) donneBrute=$(grep ";97[46][0-9][0-9]$\|9841[25]" "$cheminFichier")
		donneBrute="$donneBrute"$'\n'"$(grep ";$" "$cheminFichier" | grep -E ";(-60(\.(0)*)?|-[0-5][0-9](\.([0-9])*)?|0(\.(0)*)?),([3-9][0-9](\.([0-9])*)?|10[0-9](\.([0-9])*)?|110(\.(0)*)?);")" ;;

	#Antartique : coord. geo inf. ou egal 60° sud
	-Q) donneBrute=$(grep ";$" "$cheminFichier" | grep -E ";-([6-9][0-9](\.([0-9])*)?|1[0-8][0-9](\.([0-9])*)?),.*;") ;;

	*)
		echo "Erreur grave, le cas $position n'est pas traité (restriction geographique)."
		exit 4 ;;
esac

#Traitement de chaque type de donnée
for type in $typeDonne ; do
	echo "$type"

	case $type in
		
	
		*)
			echo "Erreur grave, le cas $type n'est pas traiter (type de donnée)." 
			exit 4 ;;

	esac
done