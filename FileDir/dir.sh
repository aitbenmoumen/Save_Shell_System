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

  if [ ! -d "$chemain/$name" ]; then
    echo "Ce dossier n'existe pas !!!"
  else
    if zip -r "$name.zip" "$name" && mv "$name.zip" "$chemain/backups"; then
      success=1
      log_operation "Sauvegarde du dossier: $name"
    else
      echo "Erreur lors de la compression !"
    fi
  fi
}