#!/bin/bash
#
# REFERENCE            : creer_fiche_version
#
# ROLE                 : cree une fiche version sur machine isolee 
#
# SYNTAXE              : creer_fiche_version [-h] [ version]
#
# EXEMPLES - TESTS OK  : creer_fiche_version 2.0 
#                        
#                        
#
# EXEMPLES - TESTS NOK : creer_fiche_version
#
# PARAMETRES           : version mercurial  
#                        <dossier_ctrl>    idem
#                        
#
# DONNEES RETOURNEES   : Affiche a l'ecran les differentes etapes franchies (outil verbeux)
#
# DONNEES ACCEDEES     : Fichier et sous repertoires
#
# PROCEDURES APPELLEES : commandes mercurial
#
# REMARQUES            :
#
# HISTORIQUE :
# VERSION : 2.7 : DM :  3383  : 09/06/2017 : Creation d'un script outils admin pour detecter les fiches versions manquantes sur les machines isolees
# FIN-HISTORIQUE
################################################################################
#
############################################################
# Envoi message usage sur la console
############################################################

# Gerer les interruptions
function clean_up()
{
    \rm -rf /tmp/*$$ > /dev/null 2>&1
    exit 1
}

trap clean_up SIGHUP SIGINT SIGTERM


Usage()
{
echo "
Ce script a pour objectif de :
  - creer une fiche version dans le dossier result suivant le numero de version specifie en parametre
  - la commande doit etre lancee depuis le dossier ctrl de la composante oubien dans un dossier en dessous
 " 
echo "Usage: creer_fiche_version [version] [-h]"
echo -e "\t [version] version mercurial a specifier en ligne de commande "
echo -e "\t [-h] Affiche cette aide en ligne"
echo -e "\t Exemple : creer_fiche_version 2.0"
exit 1
}


############################################################
if [ "$1" = "-h" ]
then
  Usage
fi

# calculer le nombre de parametres
if [ "$#" != "1" ]
then
  Usage
fi

# variable globales 
version=$1

# Se placer dans le repertoire ctrl de plus haut niveau
REPCTRL=$(echo "$PWD" | grep "/ctrl" | awk -F"/" '{ for(i=1;i<=NF && der!="ctrl";i++){ printf("%s/",$i);der=$i; }  }')
if [ "${REPCTRL}" = "" ]
   then
       echo "Impossible de trouver le repertoire de travail ctrl,"
       echo "il n'est donc pas possible d'executer cet outil."
       echo "Aucun changement n'a ete effectue"
       exit 1
fi

verif_version=`hg log -r $version`
result=$?
if [ "$result" != "0" ]
then
   echo "La version $version specifiee en parametre n'existe pas. "
   exit 1
fi

if [ ! -d "$REPCTRL../result/$version/" ]
then
   echo "Le dossier  $REPCTRL../result/$version/ n'existe pas."
   exit 1
fi

if [ -f "$REPCTRL../result/$version/fiche_version.txt" ]
then
   echo "Le fichier  $REPCTRL../result/$version/fiche_version.txt existe deja."
   exit 1
fi


fiche_version="$REPCTRL../result/$version/fiche_version.txt"

# recuprer le commentaire de commit
commentaire=`hg log -r $version --template "{desc}"`
# determiner s'il s'agit d'une version totale ou partielle
if  echo $commentaire | grep "Partielle" > /dev/null 2>&1
then
  type_liv="Partielle"
else
  type_liv="Totale"
fi

composante=`hg manifest -r $version | awk -F "/" '{ print $1 }' | sort -u`
 # Inserer Produit, Version, Type de livraison dans la fiche versions
echo "$commentaire" >> $fiche_version;
echo "Produit : $composante" >> $fiche_version;
echo "Version : $1" >> $fiche_version;
echo "Type de livraison : $type_liv" >> $fiche_version;


