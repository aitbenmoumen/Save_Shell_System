#!/bin/bash
source fun.sh

# Function to set up a cron job
setup_cron_job() {
    local hour=$1
    local minute=$2
    local script_path=$3
    local target=$4
    
    # Add the cron job to the user's crontab
    (crontab -l ; echo "$minute $hour * * * bash $script_path \"$target\" && log_operation \"Cron job pour $target à $hour:$minute\"") | crontab -
    
    echo "Cron job set to execute the script at $hour:$minute for $target"
}


schedule_backup() {
  read -p "Enter the hour (0-23): " hour
  read -p "Enter the minute (0-59): " minute
  read -p "Enter the file or directory path to save: " target
  echo -e "Il s'agit d'un dossier ou un fichier ${RED}(1-Dossier   2-Fichier )${NC}:"
  read pick
  case $pick in
    1)
      script_path="./FileDir/dir.sh"
      ;;
    2)
      script_path="./FileDir/file.sh"
      ;;
    *)
      echo "Choix invalide !!"
      exit
      ;;
  esac
  setup_cron_job "$hour" "$minute" "$script_path" "$target"
}