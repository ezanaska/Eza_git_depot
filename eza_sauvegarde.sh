#!/bin/bash

## EZA: Template bash de sauvegarde /home avec rsync
# bash distingue les caractères majuscules des caractères minuscules
# chmod +x du fichier sh

# Organisation repertoire destination
# /client
#	/date
#		/backup
#		/tar backup
#		/gpg backup

## Variables
REPERTOIRE_SOURCE="/home/ezanaska"
REPERTOIRE_DESTINATION="/media/ezanaska/Backup_Linux"
JOUR=$(date +%g%j%H%M)
CLIENT=$"ezanaska"
IDENTITE=$"zanaska"
REPERTOIRE_REGLES="/home/ezanaska/Documents/Boulot/IT_Security/2_Technos_SI/1_Linux/Scripts_shell"

## Nettoyage avant sauvegarde
echo -e "Nettoyage avant sauvegarde\n" 
rm -r -f -v /home/ezanaska/.local/share/Trash/{*,.*} # poubelle
find ~/.cache/thumbnails -type f -mtime +2 -delete # images miniatures
# rm -rf ~/.cache/mozilla/firefox/* --> pas sûr comment vider le cache de firefox

while true
do
## Menu choix entre backup local ou cloud
echo -e "1) rsync local\n2) archivage local\n3)rsync cloud\n4) api cloud\n5) exit"

# -s pour ne pas afficher l'input, -n pour définir la longueur de l'input
read -n 1 -s choix

# commande conditionnelle "case" comme pour sql!!
case $choix in

1) echo -e "Choix: $choix\n" #traitement du choix 1

	# Détection de la présence du disque local de destination
	# -e --> true if it exists, but "!" checks for the opposite
  	if [ ! -e "$REPERTOIRE_DESTINATION" ]
  	then
  	echo -e "Le disque de sauvegarde n'est pas présent\nTraitement arrêté\n"
  	exit
  	fi

	echo -e "Demarrage de la sauvegarde\n"
	# synopsis : rsync [OPTION...] SRC... [DEST]
	rsync -r -t -p -g -o -v --progress --delete -l -D -s --stats --exclude={'.cache/**','.mozilla/**','Trash/**'} --delete-excluded $REPERTOIRE_SOURCE $REPERTOIRE_DESTINATION >>$REPERTOIRE_REGLES/rsyncerrors.log 2>&1

	echo -e "Code exit rsync : $?\n" # get exit code from last command
	# traitement du code exit rsync
	if [ $? -eq 0 ]
	then
	echo -e "\nLa sauvegarde est terminée...\n"
  	else
  	echo -e "\nLa sauvegarde failed\n"
	exit
  	fi
;;
2) echo -e "Choix: $choix\n"
	read -p "Taper entrée pour l'archivage ..." -n 1 -s 
	# synopsis tar [OPTION...] [DEST ARCHIVE] SRC
	tar cvf $REPERTOIRE_DESTINATION/$CLIENT.tar $REPERTOIRE_DESTINATION/$CLIENT >>$REPERTOIRE_REGLES/tarerrors.log 2>&1
	# traitement du code exit tar
        if [ $? -eq 0 ]
	then
	echo -e "L'archivage est terminé...\n"
	else
	echo -e "L'archivage failed\n"
	exit
	fi
	read -p "Taper entrée pour compresser l'archive ..." -n 1 -s
	gzip $REPERTOIRE_DESTINATION/$CLIENT.tar >>$REPERTOIRE_REGLES/gziperrors.log 2>&1
	if [ $? -eq 0 ]
	then
        echo -e "La compression est terminé...\n"
	else
	echo -e "La compression failed\n"
	exit
	fi
;;
esac
done
exit

# Pb: la valeur $JOUR risque de ne va pas être la même, donc j'ai enlevé les secondes !!
# Pb: j'archive l'archive, il faut faire un répertoire différent pour les fichiers tar


# ajouter le traitement de la valeur retournée par tar

read -p "Taper entrée pour encrypter ..." -n 1 -s
cd /$REPERTOIRE_DESTINATION/$JOUR/$CLIENT
gpg -e -r $IDENTITE $CLIENT.tar.gz
# ajouter le traitement de la valeur retournée par gpg
echo -e "L'encryption est terminée...\n"
date  
exit

;; #  means “Break out of the case statement"

3) echo -e "Choix: $choix\n"
date
exit
;;

4) echo -e "Choix: $choix\n"
exit
;;

*) echo -e "An unknown number of\n"
exit
;; 

