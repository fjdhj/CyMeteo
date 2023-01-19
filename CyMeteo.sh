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
donnee=""

#Fichier de sortie du programme C
fichierSortie="sortie.csv"
#Fichier de donnée a trié (pour le programme C)
fichierEntree="entree.csv"
#Fichier de donnée de plot
fichierPlot="fichierPlot.cymeteo"

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
		if [[ ! "${!arg}" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]] ; then
			echo "La valeur <min> de l'option -d est incorrecte. Utilisez --help pour voir comment utiliser le script" >&2
			exit 1;
		fi
		tempsMin=${!arg}
		passerCase=$(( passerCase - 1 ))

	#valeur <max> de l'option -d
	elif [ $passerCase -eq 1 ] ; then
		if [[ ! "${!arg}" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]] ; then
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
	echo "Impossible de lire le fichier $cheminFichier. Vérifier les permissions associés." >&2
	exit 2
fi

if [ "$enteteFichier" != "$(head -n1 "$cheminFichier")" ] ; then
	echo "Le fichier n'est pas au bon format." >&2
	exit 2
fi

#Vérification ordre parametre valeur min max de l'argument -d
if [ "$tempsMin" \> "$tempsMax" ] ; then
	echo "La valeur min de l'argument -d est supèrieur a celle de max. Utilisez --help pour voir comment marche le script" >&2
	exit 1
fi

#Vérification du fichier C
echo "ATTENTION: vérification du fichier C compilé impossible, ca a pas été codé"
if [ ! -f "$nomProgrammeTri" ] ; then
	make -C "$nomDossierC" 
	mv "$nomDossierC/$nomProgrammeTri" .
fi

#Traitement restriction geographique
if [ "$position" != "" ] ; then
	case $position in
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

		#Antartique : coo	rd. geo inf. ou egal 60° sud
		-Q) donneBrute=$(grep ";$" "$cheminFichier" | grep -E ";-([6-9][0-9](\.([0-9])*)?|1[0-8][0-9](\.([0-9])*)?),.*;") ;;

		*)
			echo "Erreur grave, le cas $position n'est pas traité (restriction geographique)."
			exit 4 ;;
	esac

	#Application restriction temporel
	if [ "$tempsMax" != "" ] ; then
		donneBrute="$(echo "$donneBrute" | awk -v tempsMin="$tempsMin" -v tempsMax="$tempsMax" -F";" '{ date=substr($2,1,10) ; if(tempsMin <= date && date <= tempsMax){ print } }')"
	fi
else
	#Application restriction temporel ou mise de valeur par defaut
	if [ "$tempsMax" != "" ] ; then
		donneBrute=$(tail -n+2 "$cheminFichier" | awk -v tempsMin="$tempsMin" -v tempsMax="$tempsMax" -F";" '{ date=substr($2,1,10) ; if(tempsMin <= date && date <= tempsMax){ print } }')
	else
		donneBrute=$(tail -n+2 "$cheminFichier")
	fi
fi

#Traitement de chaque type de donnée
for type in $typeDonne ; do
	echo "$type"
	case $type in
		-[tp]1)
			#Colone température : 11
			if [ "$type" == "-t1" ] ; then
				#Le dernier grep permet de ne pas prendre ceux qui non pas de valeur
				donnee="$(echo "$donneBrute" | cut -d";" -f1,11 | grep -v ";$")"
			#Cas -p1
			#Colone pression : 7
			else
				#Le dernier grep permet de ne pas prendre ceux qui non pas de valeur
				donnee="$(echo "$donneBrute" | cut -d";" -f1,7 | grep -v ";$")"
			fi

			#Tri des donnée
			echo "Appel fonction C pas encore implémenté"
			echo "$donnee" > "$fichierEntree"
			sort "$fichierEntree" > "$fichierSortie"

			#Calcule moyenne, min et max
			awk -F ';' 'BEGIN { num="" ; n=0 ; m=0 } { if(num!=$1){ if(n!=0){print m";"sum/n";"min";"max";"num} num=$1 ; min=$2 ; max=$2 ; n=0 ; sum=0 ; m+=1 } sum+=$2 ; n+=1 ; if($2<min){min=$2} if($2>max){max=$2} } END {print m";"sum/n";"min";"max";"num}' "$fichierSortie" > "$fichierPlot"
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Pression en fonction de la station"
			set xlabel "ID Station"
			set ylabel "Pression (Pa)"
			set datafile separator ";"
			Shadecolor = "#80E0A080"
			set xtics rotate by 45 offset -2,-1.5
			plot "$fichierPlot" using 1:4:3 with filledcurve fc rgb Shadecolor title "Plage des pressions", ''using 1:2:xtic(5) lw 2 with linespoints title "Pression moyenne"
			EOFMarker

		;;

		-[tp]2)
			if [ "$type" == "-t2" ] ; then
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | awk -F ";" '{ if($11 != "") {"date -d\""$2"\" -u +%Y%m%d%H"|getline out ; print out";"$11} }')"
			
			#Cas -p2
			else
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | awk -F ";" '{ if($7 != "") {"date -d\""$2"\" -u +%Y%m%d%H"|getline out ; print out";"$7} }')"
			fi

			#Tri des donnée
			echo "Appel fonction C pas encore implémenté"
			echo "$donnee" > "$fichierEntree"
			sort "$fichierEntree" > "$fichierSortie"

			#Calcule moyenne
			awk -F ';' 'BEGIN { date="" ; n=0 } { if(date!=$1){ if(n!=0){print date";"sum/n} date=$1 ; n=0 ; sum=0 } sum+=$2 ; n+=1 } END {print date";"sum/n}' "$fichierSortie" > "$fichierPlot"
			
			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Pression en fonction du jour"
			set xlabel "Jour"
			set ylabel "Pression (Pa)"
			set datafile separator ";"
			set xdata time
			set timefmt '%Y%m%d%H'
			set xtics rotate by 45 offset -2,-1.5
			plot "$fichierPlot" using 1:2 lw 2 smooth acsplines title "Pression moyenne"
			EOFMarker
			;;
			

		-[tp]3)
			echo "Marche PAS"
			#Il faut trier en fonction de la date PUIS du numéro de station, donc le format seras particulier : 
			#on met la date PUIS le numéro de station coller l'un a l'autre
			if [ "$type" == "-t3" ] ; then
				#Récupèration date et station avec heure et pression
				donnee="$(echo "$donneBrute" | awk -F';' '{ if($11!=""){ print substr($2, 1, 4) substr($2, 6, 2) substr($2, 9, 2) $1";"substr($2,12,2)-substr($2,20,3)";"$11 } }')"
			
			#Cas -p2
			else
				#Récupèration date et station avec heure et température
				donnee="$(echo "$donneBrute" | awk -F';' '{ if($7!=""){ print substr($2, 1, 4) substr($2, 6, 2) substr($2, 9, 2) $1";"substr($2,12,2)-substr($2,20,3)";"$7 } }')"
			fi

			#Tri des donnée
			echo "Appel fonction C pas encore implémenté"
			echo "$donnee" > "$fichierEntree"
			sort "$fichierEntree" > "$fichierSortie"

			#Opération poste trie : on met chaque heure dans une case differente
			awk -F';' 'BEGIN { for(i = 0; i < 24; i++) {heure[i]=""} } \
						     { heure[$2]=heure[$2] substr($1,1,8)";"substr($1,9)";"$2";"$3"\n" } \
					   END   { for(i = 0; i < 24; i++) { if(heure[i] != "") { printf heure[i] "\n\n" } } }' "$fichierSortie" > "$fichierPlot"

			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Graphique sans nom"
			set xlabel "Jour"
			set ylabel "Pression (Pa)"
			set datafile separator ";"
			set xdata time
			set timefmt '%Y%m%d'
			set xtics rotate by 45 offset -2,-1.5
			set style line 2  lc rgb '#0025ad' lt 1 lw 1.5 # --- blue
			set style line 3  lc rgb '#0042ad' lt 1 lw 1.5 #      .
			set style line 4  lc rgb '#0060ad' lt 1 lw 1.5 #      .
			set style line 5  lc rgb '#007cad' lt 1 lw 1.5 #      .
			set style line 6  lc rgb '#0099ad' lt 1 lw 1.5 #      .
			set style line 7  lc rgb '#00ada4' lt 1 lw 1.5 #      .
			set style line 8  lc rgb '#00ad88' lt 1 lw 1.5 #      .
			set style line 9  lc rgb '#00ad6b' lt 1 lw 1.5 #      .
			set style line 10 lc rgb '#00ad4e' lt 1 lw 1.5 #      .
			set style line 11 lc rgb '#00ad31' lt 1 lw 1.5 #      .
			set style line 12 lc rgb '#00ad14' lt 1 lw 1.5 #      .
			set style line 13 lc rgb '#09ad00' lt 1 lw 1.5 # --- green
			plot "$fichierPlot" using 1:4 with lines ls 2 lw 2 title "aza"
			EOFMarker

		;;

		-w)
			#Formatage des données
			donnee="$(echo "$donneBrute" | awk -F';' '{ if( $4 != "" && $5 != "" ){split($10, coord, ",") ; print $1";"coord[1]";"coord[2]";"$4";"$5} }')"
			
			#Tri des donnée
			echo "Appel fonction C pas encore implémenté"
			echo "$donnee" > "$fichierEntree"
			sort "$fichierEntree" > "$fichierSortie"

			#Calcule moyenne
			awk -F ';' 'BEGIN { num="" ; force=0 ; direction=0 ; n=0 } { if(num!=$1){ if(n!=0){print num";"$2";"$3";"direction/n";"force/n} num=$1 ; n=0 ; direction=0 ; force = 0 } direction+=$4 ; force+=$5 ; n+=1 } END {print num";"$2";"$3";"direction/n";"force/n}' "$fichierSortie" > "$fichierPlot"

			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Moyenne force et direction moyen du vent"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator ";"
			set angles degrees
			set xrange [-180:180]
			set yrange [-90:90]
			plot "Ressources/Carte.png" binary filetype=png origin=(-180,-90) dx=0.2093 dy=0.2093 w rgbimage, "$fichierPlot" using 3:2:(sin(\$4)/\$5)*30:(cos(\$4)/\$5)*30 w vec title "Direction et force moyenne du vent" lc rgbcolor "red"
			EOFMarker
			;;
		*)
			echo "Erreur grave, le cas $type n'est pas traiter (type de donnée)." 
			exit 4 ;;

	esac
done