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
	echo "  3x: probleme avec le programme C, x correspond a un chiffre 1, 2 ou 3 qui sont les valeurs de retour possible du programme C, a savoir"
	echo "      31 : il y a un problème avec les arguments donnée au programme C"
	echo "      32 : il y a un problème avec les fichiers donnée au programme C (lecture/ecriture/acces)"
	echo "      33 : il y a une autre erreur interne au programme C"
	echo "  4: Un erreur grave lors du déroulement du programme" 
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

for ((arg = 1 ; arg <= $# ; arg++)) ; do
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

				if [ $arg == $# ] ; then
					echo "Argument -d incomplet (il manque la valeur min), utilisez --help pour voir comment utiliser le script" >&2
					exit 1
				fi

				arg=$((arg + 1))
				
				#Valeur <min> de l'option -d
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

				if [ $arg == $# ] ; then
					echo "Argument -d incomplet (il manque la valeur max), utilisez --help pour voir comment utiliser le script" >&2
					exit 1
				fi

				arg=$((arg + 1))

				#valeur <max> de l'option -d
				if [[ ! "${!arg}" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]] ; then
					echo "La valeur <max> de l'option -d est incorrecte. Utilisez --help pour voir comment utiliser le script" >&2
					exit 1;
				fi
				tempsMax=${!arg}

				if [ "$tempsMin" \> "$tempsMax" ] ; then
					echo "La valeur <min> de l'option -d est plus grande que la valeur <max>. Utilisez --help pour voir comment utiliser le script" >&2
					exit 1;
				fi
				;;

			-f)
				if [ "$cheminFichier" != "" ] ; then
					echo "Le chemin vers le fichier ne peut pas être spécifié deux fois. Utilisez --help pour voir comment utiliser le script" >&2
				fi

				if [ $arg == $# ] ; then
					echo "Argument -f incomplet, utilisez --help pour voir comment utiliser le script" >&2
					exit 1
				fi

				arg=$((arg + 1))

				if [ ! -f "${!arg}" ] ; then
					echo "${!arg} n'est pas un fichier. Utillisez --help pour voir comment utiliser le script" >&2
					exit 1;
				fi
				cheminFichier=${!arg}

				;;

			#L'argument n'existe pas
			*)
				echo "Mauvais argument, utilisez --help pour voir comment utiliser le script" >&2 
				exit 1 ;;
		esac
done

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
			echo "Erreur grave, le cas $position n'est pas traité (restriction geographique)." >&2
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
	echo "Option : $type"
	case $type in
		-[tp]1)
			echo "    Traitement donnée"
			#Colone température : 11
			if [ "$type" == "-t1" ] ; then
				#Le dernier grep permet de ne pas prendre ceux qui non pas de valeur
				donnee="$(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f1,11 | grep -v " $")"
				nomValeur="Température"
				unite="°C"
			#Cas -p1
			#Colone pression : 7
			else
				#Le dernier grep permet de ne pas prendre ceux qui non pas de valeur
				donnee="$(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f1,7 | grep -v " $")"
				nomValeur="Pression"
				unite="Pa"
			fi

			#Tri des donnée
			echo "    Trie donnée"
			echo "$donnee" > "$fichierEntree"
			touch "$fichierSortie"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" > "/dev/null"

			#Calcule moyenne, min et max
			echo "    Traitement post trie donnée"
			awk -F ' ' 'BEGIN { num="" ; n=0 } { if(num!=$1){ if(n!=0){print sum/n" "min" "max" "int(num)} num=$1 ; min=$2 ; max=$2 ; n=0 ; sum=0 } sum+=$2 ; n+=1 ; if($2<min){min=$2} if($2>max){max=$2} } END {print sum/n" "min" "max" "int(num)}' "$fichierSortie" > "$fichierPlot"
			
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "$nomValeur en fonction de la station"
			set xlabel "ID Station"
			set ylabel "$nomValeur ($unite)"
			set datafile separator " "
			Shadecolor = "#80E0A080"
			set xtics rotate by 45 offset -2,-1.5
			plot "$fichierPlot" using 0:3:2 with filledcurve fc rgb Shadecolor title "Plage de $nomValeur", ''using 0:1:xtic(4) lw 2 with linespoints title "$nomValeur moyenne"
			EOFMarker

		;;

		-[tp]2)
			echo "    Traitement donnée"
			if [ "$type" == "-t2" ] ; then
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | cut -d';' -f2 | date -u -f - '+%Y%m%d' | pr -mts' ' - <(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f11))"
				nomValeur="Température"
				unite="°C"
				couleur="#ff3333"
			#Cas -p2
			else
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | cut -d';' -f2 | date -u -f - '+%Y%m%d' | pr -mts' ' - <(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f7))"
				nomValeur="Pression"
				unite="Pa"
				couleur="#1a75ff"

			fi

			donnee="$(echo "$donnee" | grep -Ev "[[:space:]]$")"

			#Tri des donnée
			echo "    Trie donnée"
			echo "$donnee" > "$fichierEntree"
			touch "$fichierSortie"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" > "/dev/null"

			#Calcule moyenne
			echo "    Traitement post trie donnée"
			awk -F ' ' 'BEGIN { date="" ; n=0 } { if(date!=$1){ if(n!=0){print int(date)" "sum/n} date=$1 ; n=0 ; sum=0 } sum+=$2 ; n+=1 } END {print int(date)" "sum/n}' "$fichierSortie" > "$fichierPlot"
			
			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "$nomValeur en fonction du jour"
			set xlabel "Jour"
			set ylabel "$nomValeur ($unite)"
			set datafile separator " "
			set xdata time
			set timefmt '%Y%m%d%H'

			set xrang [*:*] noextend
			set yrang [*:*] noextend

			Couleur = "$couleur"
			plot "$fichierPlot" using 1:2 with lines lw 2 lc rgbcolor "$couleur" title "$nomValeur moyenne"
			EOFMarker
			;; 
			

		-[tp]3)
			echo "    Traitement donnée"
			if [ "$type" == "-t3" ] ; then
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | cut -d';' -f2 | date -u -f - '+%Y%m%d %H' | pr -mts' ' - <(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f11))"
				nomValeur="Température"
				unite="°C"
			#Cas -p3
			else
				#Récupèration date et heure convertie et pression
				donnee="$(echo "$donneBrute" | cut -d';' -f2 | date -u -f - '+%Y%m%d %H' | pr -mts' ' - <(echo "$donneBrute" | cut -d";" --output-delimiter=" " -f7))"
				nomValeur="Pression"
				unite="Pa"

			fi

			

			donnee=$( echo "$donneBrute" | cut -d";" --output-delimiter=" " -f1 | pr -mts' ' - <(echo "$donnee")) 

			#Tri des donnée
			echo "$donnee" | awk -F" " '{ if($4 != "") { print $0} }' > "$fichierEntree"
			touch "$fichierSortie"
			echo "    Trie donnée"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" > "/dev/null"

			awk -F' ' 'BEGIN { data = "" ; num = ""}
						     { if(num!=$1) { if(data!="") { print data > "tmp"num".csv" } data = "" ; num=$1} data=data $2" "$3" "$1" "$4"\n"}
					    END  { print data > "tmp"num".csv"}' "$fichierSortie"

			echo "    Traitement post trie donnée"
			i=0
			for fichier in tmp*.csv ; do
				./exec -f "$fichier" -o "$fichierSortie" "$algoTri" > "/dev/null"
				#Opération poste trie : on met chaque heure dans une case differente
				awk -F' ' 'BEGIN { for(i = 0; i < 24; i++) {heure[i]=""} } \
								 { $2 = int($2); $1 = int($1) ; $3 = int($3) ; if($1 != "0") {heure[$2]=heure[$2] $1" "$2" "$3" "$4"\n" } } \
						   END   { for(i = 0; i < 24; i++) { if(heure[i] != "") { printf heure[i] "\n\n" } } }' "$fichier" > "${i}$fichierPlot"
				i=$((i+1))
			done
			i=$((i-1))

			echo "Génération graphique"
			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Evoltion $nomValeur en fonction de l'heure et du jour"
			set xlabel "Jour"
			set ylabel "$nomValeur ($unite)"
			set datafile separator " "
			set xdata time
			set timefmt '%Y%m%d'

			set palette rgb 33,13,10

			plot for[i=0:$i] "".i."$fichierPlot" using 1:4:2 with lines palette notitle
			EOFMarker

			for elem in tmp*.csv ; do
				rm $elem 2>"/dev/null"
			done

		;;

		-w)
			echo "    Traitement donnée"
			#Formatage des données
			donnee="$(echo "$donneBrute" | awk -F';' '{ if( $4 != "" && $5 != "" ){split($10, coord, ",") ; print $1" "coord[1]" "coord[2]" "$4" "$5} }')"
			
			#Tri des donnée
			echo "    Trie donnée"
			echo "$donnee" > "$fichierEntree"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" > "/dev/null"
			

			#Calcule moyenne
			echo "    Traitement post trie donnée"
			awk -F ' ' 'BEGIN { num="" ; force=0 ; direction=0 ; n=0 ; ns=0 ; eo=0 } { $1=int($1); $2=int($2); $3=int($3) ; if(num!=$1){ if(n!=0){print num" "ns" "eo" "direction/n" "force/n} num=$1 ; n=0 ; direction=0 ; force = 0 ; ns=$2 ; eo=$3 } direction+=$4 ; force+=$5 ; n+=1 } END {print num" "ns" "eo" "direction/n" "force/n}' "$fichierSortie" > "$fichierPlot"

			#Récupèration x et y min/max en fonction de la zone géographique
			case $position in
				#Rien
				"")
					xmin=-180
					xmax=180
					ymin=-90
					ymax=90
					nom=Ressources/Carte.png
				;;

				#France
				-F)
					xmin=-14
					xmax=18
					ymin=38
					ymax=54
					nom=Ressources/CarteFrance.png
				;;

				#Guyane
				-G)
					xmin=-70
					xmax=-36
					ymin=-5
					ymax=12
					nom=Ressources/CarteGuyane.png
				;;

				#St Pierre et Miquelon
				-S)
					xmin=-71
					xmax=-41
					ymin=38
					ymax=53
					nom=Ressources/CarteStPierre.png
				;;
				
				#Antilles
				-A) 
					xmin=-72
					xmax=-48
					ymin=8
					ymax=20
					nom=Ressources/CarteAntilles.png
				;;

				#Océan indien
				-O)
					xmin=30
					xmax=124
					ymin=-56
					ymax=-9
					nom=Ressources/CarteOceanIndien.png
				;;

				#Antartique
				-Q)
					xmin=56
					xmax=180
					ymin=-90
					ymax=-28
					nom=Ressources/CarteAntartique.png
				;;

				#Erreur
				*)
					echo "Erreur grave, le cas $position n'est pas traité (restriction geographique mode -w)."
					echo "Utilisation valeur par défaut"
					xmin=-180
					xmax=180
					ymin=-90
					ymax=90
					nom=Ressources/Carte.png
				;;
			esac

			scalaire=$(echo "($xmax - $xmin)/1720" | bc -l)

			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Moyenne force et direction moyen du vent"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator " "
			set angles degrees
			set xrange [$xmin:$xmax]
			set yrange [$ymin:$ymax]
			plot "$nom" binary filetype=png origin=($xmin,$ymin) dx=$scalaire dy=$scalaire w rgbimage, "$fichierPlot" using 3:2:(sin(\$4)/\$5)*$scalaire*300:(cos(\$4)/\$5)*$scalaire*300 w vec title "Direction et force moyenne du vent" lc rgbcolor "red"
			EOFMarker
			;;
		
		-h)
			#Formatage des données
			echo "    Traitement donnée"
			donnee="$(echo "$donneBrute" | awk -F';' '{ if( $14 != "" ){split($10, coord, ",") ; print $14" "coord[1]" "coord[2]} }')"

			#Tri des donnée
			echo "    Trie donnée"
			echo "$donnee" > "$fichierEntree"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" -r > "/dev/null"

			echo "    Traitement post trie donnée"
			uniq "$fichierSortie" > "$fichierPlot"

			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Altitude Station"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator " "
			
			set xrang [*:*] noextend
			set yrang [*:*] noextend

			set view map
			set pm3d interpolate 5,5
			set dgrid3d
			splot "$fichierPlot" using 3:2:1 with pm3d title "Hauteur (mètre)"
			EOFMarker
			;;

		-m)
			echo "    Traitement donnée"
			donnee="$(echo "$donneBrute" | awk -F';' '{ if( $6 != "" ){split($10, coord, ",") ; print $1" "$6" "coord[1]" "coord[2]} }')"
		
			#Tri des donnée
			echo "    Trie donnée"
			echo "$donnee" > "$fichierEntree"
			./exec -f "$fichierEntree" -o "$fichierSortie" "$algoTri" -r > "/dev/null"

			echo "    Traitement post trie donnée"
			awk -F ' ' 'BEGIN { num="" } { if(num!=$1){ if(num!=""){print num" "max" "x" "y} x=$3 ; y=$4 ; max=$2 ; num=$1 } if($2>max){max=$2} } END {print num" "max" "x" "y}' "$fichierSortie" > "$fichierPlot"

			#Generation graphique via gnuplot
			gnuplot <<-EOFMarker
			set terminal png size 1920,1080
			set output "out.png"
			set title "Humidité max Station"
			set xlabel "Coord. Nord"
			set ylabel "Coord. Est"
			set datafile separator " "
			
			set xrang [*:*] noextend
			set yrang [*:*] noextend

			set view map
			set pm3d interpolate 7,7
			set dgrid3d
			splot "$fichierPlot" using 4:3:2 with pm3d title "Humidité (%)"
			EOFMarker
			;;

		*)
			echo "Erreur grave, le cas $type n'est pas traiter (type de donnée)." 
			exit 4 ;;
	esac

	#for elem in *$fichierPlot ; do
	#	rm $elem 2>"/dev/null"
	#done
done

#rm $fichierEntree $fichierSortie 2>"/dev/null"