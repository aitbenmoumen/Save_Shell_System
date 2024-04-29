#!/bin/bash
source menu
source logo.sh # This will print the logo 
source FileDir/file.sh
source FileDir/dir.sh
CONFIG_FILE="config.txt"

#colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' #no color
#styles
BOLD='\033[1m'
UNDERLINE='\033[4m'

success=0

# Function to get user input for backup location
get_backup_location() {
  read -p "Nom d'utilisateur :" user
  chemain="/home/$user/"

  check_and_create_backup_dir "$chemain"  # Call function to check and create dir
}

# Function to check and create backup directory
check_and_create_backup_dir() {
  local dir="$1"  # Local variable for directory path

  if [ ! -d "$dir/backups" ]; then
    mkdir -p "$dir/backups"  # Create backups directory with parents if needed
    touch "$dir/backups/operations_history"
  fi
}

# Function to display directory listing
list_files_and_folders() {
  echo -e "${BLUE}${BOLD}--------Les dossiers/fichiers dans votre espace personelle--------- ${NC}"
  tree $chemain
  echo -e "${BLUE}${BOLD}------------------------------------------------------------------- ${NC}"
}

# Function to get user choice for treatment type in the main func
get_backup_choice_main() {
  echo -e "${GREEN}${BOLD}Que vous voulez Faire ?${NC}"
  echo "      1-Lister les elements de votre espace personnel"
  echo "      2-Sauvegarder un dossier"
  echo "      3-Sauvegarder un fichier"
  echo "      4-Automatiser une sauvegarde"
  echo "      5-Tutoriel"
  echo "      0-Quitter"
  read -p "       Saisir votre choix: " choix
}





# Function to log operation to history file
log_operation() {
  local message="$1"
  echo "$(date)------------------------------" >> "$chemain/backups/operations_history"
  echo "$message" >> "$chemain/backups/operations_history"
  if [ "$success" -eq 1 ]; then
    echo "Done with success !" >> "$chemain/backups/operations_history"
  else
    echo "Failed !!" >> "$chemain/backups/operations_history"
  fi
}

# Function to get user choice for backup type
get_backup_choice() {
  echo "Que vous voulez sauvegarder ?"
  echo "1-Dossier"
  echo "2-Fichier"
  echo "0-Retour"
  read -p "Saisir votre choix: " x
}
tuto(){
  echo -e "${RED}${BOLD}--------Bienvenue dans le tuto de SaveShell--------${NC}"
echo -e "${BLUE}${BOLD}Ceci est un petit tuto pour vous familiariser avec l'utilisation de SaveShell${NC}"
echo -e "${YELLOW} Premierement vous devez saisir votre username: ${NC}"
read use
echo -e "${YELLOW} Ensuite vous devez choisir ce que vous voulez faire ! ${NC}"
get_backup_choice_main
while [ $choix != '0' ]; do
case $choix in

  1)
    echo -e "\033[37;44m Cette option vas lister toutes les dossiers et fichiers dans votre rep personelle                                                                      ${NC}"
    ;;
  2)
    echo -e "\033[37;44m Cette option vas te permetrre de choisir un dossier a compresser et le sauvegarder avec ses elements, ensuite le deplacer vers le dossier de sauvegarde${NC}"
    ;;
  3)
    echo -e "\033[37;44m Cette option vas te permetrre de choisir un ficher a compresser et le sauvegarder, ensuite le deplacer vers le dossier de sauvegarde                   ${NC}"
    ;;
  4)
    echo -e "\033[37;44m Cette option vas te permetrre de automatiser la tache de sauvegarde soit de dossier ou fichier                                                         ${NC}"
    ;;
  5)
    echo -e "\033[37;44m Cette option vas te prendre a un tuto sur comment utiliser le script                                                                                   ${NC}"
    ;;
  0)
    echo -e "${GREEN}Good Bye !!${NC}"
    exit 0
    ;;
  *)
    echo "Choix invalid !!"
    ;;
esac
read -p "Choisir une autre option pour savoir plus :" choix
done
}