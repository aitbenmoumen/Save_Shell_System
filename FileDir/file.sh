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



# Function to handle file backup
backup_file() {
  local name="$1"

  if [ ! -f "$name" ]; then
    echo "Cet fichier n'existe pas !!!"
  else
    if zip "$name.zip" "$name" && mv "$name.zip" "$chemain/backups"; then
      success=1
      log_operation "Sauvegarde du fichier: $name"
    else
      echo "Erreur lors de la compression !"
    fi
  fi
}