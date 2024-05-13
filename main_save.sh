#!/bin/bash

source fun.sh
source automatedSave.sh

# Main script execution flow
while true; do
  # Prompt the user with the question
  read -p "Voulez-vous effectuer une opération de sauvegarde ? (Oui/Non) : " answer

  # Convert the answer to lowercase for easier comparison
  answer=${answer,,}

  if [ "$answer" = "oui" ]; then
    # If the answer is "oui", proceed with the backup operations
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
        read -p "Donner le chemin du fichier a sauvegarder à partir d'espace personnel: " name
        backup_file "/home/$USER/$name"
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
  elif [ "$answer" = "non" ]; then
    # If the answer is "non", exit the loop and the script
    echo -e "${GREEN}Au revoir !${NC}"
    break
  else
    # If the answer is invalid, prompt the user again
    echo "Réponse invalide. Veuillez saisir 'Oui' ou 'Non'."
  fi
done

exit 0
