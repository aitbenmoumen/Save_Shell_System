#!/bin/bash

log_operation() {
  local message="$1"
  echo "$(date)------------------------------" >> ~/backups/operations_history
  echo "$message" >> ~/backups/operations_history
  if [ "$success" -eq 1 ]; then
    echo "Compression du fichier terminée avec succès." >> ~/backups/operations_history
    echo "Archive sauvegardée dans : ~/backups/$nom_archive"
  else
    echo "Erreur lors de la compression du fichier." >> ~/backups/operations_history
  fi
}

backup_file() {
  local filepath="$1"
  local filename="$(basename "$filepath")"

  if [ ! -f "$filepath" ]; then
    echo "Erreur: Le fichier spécifié n'existe pas."
    return 1
  fi

  echo "Choisissez un type de compression pour '$filename' :"
  echo "1) zip"
  echo "2) tar"
  echo "3) gzip"
  read -p "Votre choix (1, 2 ou 3) : " choix_compression
  
  case $choix_compression in
      1) extension="zip";;
      2) extension="tar";;
      3) extension="gz";;
      *) echo "Choix invalide. Abandon de la sauvegarde."; return 1;;
  esac

  nom_archive="$filename.$extension"

  echo -e "${BLUE}Compression de '$filename' en cours...${NC}"
  case $choix_compression in
      1) zip "$nom_archive" "$filepath" && mv "$nom_archive" ~/backups && success=1 && echo -e "${BLUE}Faite !!${NC}";;
      2) tar -cf "$nom_archive" "$filepath" && mv "$nom_archive" ~/backups && success=1 && echo -e "${BLUE}Faite !!${NC}";;
      3) tar -cvf - "$filepath" | gzip > ~/backups/"$nom_archive".tar.gz && success=1 && echo -e "${BLUE}Faite !!${NC}";;
  esac

  if [ "$success" -eq 1 ]; then
    log_operation "Sauvegarde du fichier: $filename"
  else
    log_operation "Sauvegarde du fichier: $filename"
    echo "Erreur lors de la compression !"
  fi
}

# Example usage: backup_file "/path/to/file.txt"
