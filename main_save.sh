#!/bin/bash
source fun.sh
source automatedSave.sh
# Main script execution flow
if [ ! -f "./flag_file" ]; then
    bash ./requirements
    touch "./flag_file"
fi

logo
echo -e "${BLUE}${BOLD}------------BIENVENUE DANS SAVESHELL-------------${NC}"
get_backup_location

get_backup_choice_main
case $choix in

  1)
    list_files_and_folders
    ;;
  2)
  ls ~
  read -p "Donner le chemin du dossier à partir d'espace personnel (sans inclure le nom du dossier) : " emplacement
  read -p "Donner le nom du dossier à sauvegarder : " name
  backup_folder "/home/$USER/$emplacement" "$name"
    ;;
  3)
    ls ~
    read -p "Donner le chemin absolu du fichier a sauvegarder: " name
    backup_file "$name"
    ;;
  4)
    schedule_backup
  ;;
  5)
    tuto
    ;;
  0)
    echo -e "${GREEN}Good Bye !!${NC}"
    exit 0
    ;;
  *)
    echo "Choix invalid !!"
    ;;
esac
exit 0
