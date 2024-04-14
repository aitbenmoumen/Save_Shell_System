#!/bin/bash
source fun.sh

# Function to make a backup auto 
get_cron_details() {
  echo "Programmer une sauvegarde avec cron:"
  read -p "Entrer a quelle minute (0-59): " minute
  while [[ "$minute" -lt 0 || "$minute" -gt 59 ]]; do
    echo "Non valide !!. Svp enter une valeur entre 0 et 59."
    read -p "Entrer a quelle minute (0-59): " minute
  done

  read -p "Entrer a quelle heure (0-23): " hour
  while [[ "$hour" -lt 0 || "$hour" -gt 23 ]]; do
    echo "Non valide !!. Svp enter une valeur entre 0 et 23."
    read -p "Entrer a quelle heure (0-23): " hour
  done
}



auto_save(){
    get_cron_details
    get_backup_choice
    case $x in 
1)        
    read -p "Donner le nom du dossier a sauvegarder: " name
    echo "$m $h * * * ./FileDir/dir.sh ; backup_folder $name" > temp_crontab   # a temp file that holds the job () how to pass the name of the folder ?
    crontab temp_crontab  #install the job from the temp file
    rm temp_crontab  # delete the temp file
    log_operation "Auto sauvegarde du dossier : $name"
    ;;
2)
    read -p "Donner le nom du fichier a sauvegarder: " name

    # Write cron job entry to temporary file with ampersand for concurrent execution
    echo "$minute $hour * * * /bin/bash ./FileDir/file.sh & backup_file $name" > temp_crontab

    # Install cron job and handle potential errors
    if crontab temp_crontab; then
      echo "Cron job successfully installed."
      rm temp_crontab
    else
      echo "Failed to install cron job. Check for errors."
      cat temp_crontab  # Optionally display the cron job entry for debugging
    fi

    log_operation "Auto sauvegarde du fichier : $name"
    ;;
3)
    echo "Good Bye !!"
    exit
    ;;
*)
    echo "Choix invalide !!"
    exit
esac
}

# Call the function if script is executed directly (for testing)
if [[ $0 == /* ]]; then
  auto_save
fi