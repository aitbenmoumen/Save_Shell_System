#!/bin/bash
source fun.sh
source automatedSave.sh
# Main script execution flow
get_backup_location

list_files_and_folders

get_backup_choice_main

case $choix in
  1)
    read -p "Donner le nom du dossier a sauvegarder: " name
    backup_folder "$name"
    ;;
  2)
    read -p "Donner le nom du fichier a sauvegarder: " name
    backup_file "$name"
    ;;
  3)
    auto_save
    ;;
  0)
    exit 0
    echo "Good Bye !!"
    ;;
  *)
    echo "Choix invalid !!"
    ;;
esac

exit 0
