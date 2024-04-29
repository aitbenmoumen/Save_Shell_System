#!/bin/bash


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

# Function to handle folder backup
backup_folder() {
  local name="$1"

  if [ -d "$chemain/$name" ]; then
    if zip -r "$name.zip" "$name" && mv "$name.zip" "$chemain/backups"; then
      success=1
      log_operation "Sauvegarde du dossier: $name"
    else
      echo "Erreur lors de la compression !"
    fi
  else
    echo "Ce dossier n'existe pas !!!"
  fi
}


#!/bin/bash

# Fonction pour sauvegarder et compresser un dossier
sauvegarder_dossier() {
    # Obtenir le nom du dossier à sauvegarder
    nom_dossier=$1

    # Vérifier si le dossier existe à l'emplacement donné
    if [ ! -d "$emplacement/$nom_dossier" ]; then
        echo "Erreur : Le dossier '$nom_dossier' n'existe pas à l'emplacement '$emplacement'."
        return 1
    fi

    # Proposer les choix de compression
    echo "Choisissez un type de compression pour '$nom_dossier' :"
    echo "1) zip"
    echo "2) tar"
    echo "3) gzip"
    read -p "Votre choix (1, 2 ou 3) : " choix_compression

    # Obtenir l'extension de l'archive en fonction du choix
    case $choix_compression in
        1) extension="zip";;
        2) extension="tar";;
        3) extension="gz";;
        *) echo "Choix invalide. Abandon de la sauvegarde."; return 1;;
    esac

    # Générer le nom de l'archive compressée
    nom_archive="$nom_dossier.$extension"

    # Créer l'archive compressée
    echo "Compression de '$nom_dossier' en cours..."
    case $choix_compression in
        1) zip -r "$backups/$nom_archive" "$emplacement/$nom_dossier";;
        2) tar -cf "$backups/$nom_archive" "$emplacement/$nom_dossier";;
        3) gzip -c "$emplacement/$nom_dossier" > "$backups/$nom_archive";;
    esac

    if [ $? -eq 0 ]; then
        echo "Compression de '$nom_dossier' terminée avec succès."
        echo "Archive sauvegardée dans : $backups/$nom_archive"
    else
        echo "Erreur lors de la compression de '$nom_dossier'."
    fi
}

# Lire le nom du dossier à sauvegarder
read -p "Nom du dossier à sauvegarder : " nom_dossier

# Définir l'emplacement du dossier à sauvegarder
emplacement="/chemin/vers/le/dossier/à/sauvegarder"

# Définir le dossier de destination des sauvegardes
backups="/chemin/vers/le/dossier/de/sauvegardes"

# Appeler la fonction pour sauvegarder et compresser le dossier
sauvegarder_dossier "$nom_dossier"
