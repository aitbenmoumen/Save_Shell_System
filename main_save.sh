#!/bin/bash
source fun.sh
source automatedSave.sh
# Main script execution flow
echo -e "${BLUE}${BOLD}------------BIENVENUE DANS SAVESHELL-------------${NC}"
get_backup_location

get_backup_choice_main

case $choix in

  1)
    list_files_and_folders
    ;;
  2)
    read -p "Donner le nom du dossier a sauvegarder: " name
    backup_folder "$name"
    ;;
  3)
    read -p "Donner le nom du fichier a sauvegarder: " name
    backup_file "$name"
    ;;
  4)
    auto_save
    ;;
  0)
    echo "Good Bye !!"
    exit 0
    ;;
  *)
    echo "Choix invalid !!"
    ;;
esac
exit 0
