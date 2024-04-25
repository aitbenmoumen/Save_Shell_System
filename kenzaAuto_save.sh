#!/bin/bash

#colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' #no color
#styles
BOLD='\033[1m'
UNDERLINE='\033[4m'


figlet Sauvegarde
echo "Bienvenue dans le script de sauvegarde"

LOG_FILE="/home/raihan/journal.log"


#gestionnaire de signal pour SIGINT (CTRL+C ) et SIGTERM
trap 'echo "${RED}sauvegarde interrompue${NC}"; exit' SIGINT SIGTERM

# charger les configurations 
source backup_config.cfg

choisir_planification_sauvegarde() {
  read -p "Êtes-vous sûr de vouloir commencer la planification de la sauvegarde maintenant ? (oui/non) " confirmation_planif
  if [[ "$confirmation_planif" =~ ^[oO](ui|UI)$ ]]; then
    echo -e "   ${BLUE}Choisissez la planification de la sauvegarde : ${NC}"
    echo "           1) Quotidiennement à une heure spécifique"
    echo "           2) Hebdomadairement à un jour et heures spécifiques"
    echo "           3) Mensuellement à un jour, une heure et une minute spécifiques"
    read -p "           Entrez le numéro correspondant à votre choix : " choix_planification                         
      
    case "$choix_planification" in 
      1)
        read -p "          Entrez l'heure de la sauvegarde (format HH): " heure_sauvegarde
        cron_expression="0 $heure_sauvegarde * * *"
        echo "   La sauvegarde sera planifiée tous les jours à $heure_sauvegarde:00"
      ;;
      2)
        read -p "         Entrez le jour de la semaine pour la sauvegarde (1 pour Dimanche, 2 pour Lundi, etc.): " jour_sauvegarde
        read -p "         Entrez l'heure de la sauvegarde (format HH): " heure_sauvegarde
        cron_expression="0 $heure_sauvegarde * * $jour_sauvegarde"
        echo "   La sauvegarde sera planifiée tous les $jour_sauvegarde èmes jours de la semaine à $heure_sauvegarde:00."
      ;;
      3)
        read -p "         Entrez le jour du mois pour la sauvegarde (1-31): " jour_sauvegarde
        read -p "         Entrez l'heure de la sauvegarde (format HH): " heure_sauvegarde
        read -p "         Entrez la minute de la sauvegarde (format MM): " minute_sauvegarde
        cron_expression="$minute_sauvegarde $heure_sauvegarde $jour_sauvegarde * *"
        echo "   La sauvegarde sera planifiée le $jour_sauvegarde ème jour de chaque mois à $heure_sauvegarde:$minute_sauvegarde."
      ;;
      *)
        echo -e "${RED}${BOLD}Choix invalide. La sauvegarde ne sera pas planifiée.${NC}"
      ;;
    esac

    # Ajout à crontab du script 
    (crontab -l 2>/dev/null; echo "$cron_expression /home/raihan/backup_script2.sh") | crontab -
  else
    echo -e "${YELLOW}Planification de la sauvegarde annulée.${NC}"
  fi
}


#fonction pour resoudre les chemins relatifs en absolus
resoudre_chemin() {
local chemin="$1"
#verifier si le chemin est relatif 
if [[ "${chemin:0:1}" != "/" ]]; then
    chemin="$(pwd)/$chemin"
fi
echo -e "$chemin"
}


# Fonction pour lister les documents dans le répertoire source
lister_documents() {
    echo "Liste des documents dans votre repertoire personel $source_dir :"
    # Utilisation de ls -l pour obtenir les détails des fichiers avec la date de création
    ls -l --time-style=long-iso "$source_dir" | awk '{print "- " $NF " (Créé le " $6 " à " $7 ")"}'
    echo ""
}


#fct pour selectionner les doc a sauvegarder

selectionner_documents() {
 echo "saisisser les noms des fichiers ou dossiers a sauvegarder "
  read -ra documents_to_backup

#verifier si des documents on été saisis 
if [ "${#documents_to_backup[@]}" -eq 0 ]; then 
echo -e "${RED}ERREUR: Aucun document saisi. ${NC}"
return 1
fi

echo "verification des chemins saisis ..."

for index in "${!documents_to_backup[@]}"; do
local item="${documents_to_backup[$index]}"
local resolved_path=$(resoudre_chemin "$item")
#echo "chemin resolu pour '$item':$resolved_path"

   if [ ! -e "$item" ]; then 
      echo "${RED}le fichier ou dossier '$item' n'existe pas dans '$source_dir'.${NC}"
        return 1
   else
documents_to_backup[$index]="$resolved_path"
echo -e "${GREEN}chemin'$item':$resolved_path choisit avec succes${NC}"
fi
done
}

#fonction journalisation
log_message() {
local message="$1"
echo "$(date '+%Y-%m-%d %H:%M:%S' ) - $message" >> "$LOG_FILE"

}


#fct annuler sauvegarde 
annuler_sauvegarde() {
echo -e "${RED} Etes vous sur de vouloir annuler la sauvegarde? (oui/non) : ${NC}"
read reponse
if [[ "$reponse" == "oui" ]]; then 
    echo -e "${RED}Sauvegarde annulée.${NC}"
exit 1
fi
}
trap 'annuler_sauvegarde' SIGINT 




#fct pour effectuer la sauvegarde
sauvegarder() {

echo -e "${YELLOW} Vous etes sur le point de demarrer la sauvegarde . etes vous sur de continuer ? [oui/non] ${NC}"
read confirmation
case "$confirmation" in 
[oO][uU][iI]|[yY][eE][sS])
#logique de sauvegarde

if [ ${#documents_to_backup[@]} -eq 0 ]; then 
echo "ERREUR : aucun document selectionné pour la sauvegarde ."
 selectionner_documents
if [${#documents_to_backup[@]} -eq 0 ]; then 
echo -e "${RED} ERREUR: Aucun document selectionné . Annulation de la sauvegarde ; ${NC}"
return 1
fi
fi

local backup_file="${backup_dir}/backup_$(date +%Y%m%d_%H%M%S)${compression_ext}"
echo "demarrage de la sauvegarde vers $backup_file..."

if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir"
echo "repertoire cree : $backup_dir"
fi

local -a tar_args=("-czf" "$backup_file")

#ajouter les fichiers et dossier selectionnés a la commande e sauvegarde
for item in "${documents_to_backup[@]}"; do 
   tar_args+=("$item")
done

#affichage de la commande tar
echo "commande tar : tar ${tar_args[@]}"

#executer la commande 
tar "${tar_args[@]}"

if [ $? -eq 0 ]; then 
echo -e "${GREEN}sauvegarde terminée avec succes.${NC} "
log_message "sauvegarde reussie : $backup_file"
else
echo -e "${RED}erreur lors de la sauvegarde.${NC}"
log_message "echec de la sauvegarde : $backup_file"
fi

;;
#fin sauvegarde , suite case confirmation
*)
echo -e "${RED}Sauvegarde annulée.${NC}"
log_message "sauvegarde annulée par l'utilisateur. "
;;
esac





}




#fct pour afficher les options de compression 

afficher_options_compression(){
 echo "options de compression:"
echo " 1) gzip (.tar.gz)"
echo " 2) zip (.zip)"
echo " 3) rar (.rar)"
echo " option actuelle: ${compression_option}"

read -p "Choisissez une nouvelle option ou appuyer sue Entrée pour garder l'option actuelle " new_option
if [[ ! -z "$new_option" ]]; then 
compression_option=$new_option
update_compression_options
echo "Option de compression mise a jour ." 
fi

}

update_compression_options() {
case $compression_option in
1)
compression_ext=".tar.gz"
tar_options="-czf"
;;
2)
compression_ext=".zip"
tar_options="-a -c"
;;
3)
compression_ext=".rar"
tar_options="a -r"
;;
*)
echo "Option de compression invalide. Utilisation de gzip par defaut."
compression_ext=".tar.gz"
tar_options="-czf"
;;
esac
}
# Fonction de sauvegarde guidée
sauvegarde_guidee() {
    echo -e "       ${BLUE}Bienvenue dans l'assistant de sauvegarde guidée.${NC}"
    
    # Étape 1: Choix de la planification de la sauvegarde
    echo -e "${YELLOW}Étape 1: Choix de la planification de la sauvegarde.${NC}"
    choisir_planification_sauvegarde
    
    # Étape 2: Lister les documents disponibles pour la sauvegarde
    echo -e "${YELLOW}Étape 2: Liste des documents disponibles.${NC}"
    lister_documents
    
    # Étape 3: Sélectionner les documents à sauvegarder
    echo -e "${YELLOW}Étape 3: Veuillez sélectionner les documents à sauvegarder.${NC}"
    if ! selectionner_documents; then
        echo -e "${RED}Aucun document sélectionné ou erreur de saisie. Annulation de la sauvegarde.${NC}"
        return 1
    fi
    
    # Étape 4: Choix du mode de compression
    echo -e "${YELLOW}Étape 4: Choix du mode de compression.${NC}"
    afficher_options_compression
    echo "Mode de compression choisi : ${compression_option}"
    
    # Étape 5: Confirmation avant de démarrer la sauvegarde
    echo -e "${YELLOW}Étape 5: Confirmation avant de démarrer la sauvegarde.${NC}"
    echo "Vous avez sélectionné les documents suivants pour la sauvegarde :"
    for doc in "${documents_to_backup[@]}"; do
        echo "- $doc"
    done

    echo "Voulez-vous continuer avec la sauvegarde ? [oui/non]"
    read confirmation
    if [[ "$confirmation" =~ ^[oO][uU][iI]|[yY][eE][sS]$ ]]; then
        sauvegarder     
    else
        echo -e "${RED}Sauvegarde annulée.${NC}"
        return 1
    fi
echo -e "${YELLOW}Étape 6: Affichage de l'emplacement de la sauvegarde.${NC}"
   afficher_emplacement_sauvegarde "$backup_file"
# Appeler la fonction sauvegarder et vérifier si la sauvegarde est réussie
if sauvegarder; then
    # Appel de la fonction d'envoi d email après une sauvegarde réussie
    destinataire="raihankenza@email.com"
    sujet="Sauvegarde réussie"
    message="Votre sauvegarde a été effectuée avec succès."

    envoyer_email "$destinataire" "$sujet" "$message"
else
    echo "ERREUR: La sauvegarde a échoué, aucun email envoyé."
fi



}
afficher_emplacement_sauvegarde() {
    local file=$1
    echo "Vérification de la variable backup_file: $file" # Debug
    if [ -f "$file" ]; then
        echo "La sauvegarde a été effectuée avec succès à l'emplacement : $file"
        xdg-open "$(dirname "$file")"
    else
        echo "Aucune sauvegarde n'a été effectuée ou le fichier de sauvegarde n'existe pas."
        echo "Debug: vérification de l'existence du fichier $file" # Debug
    fi
}





#menu principal
menu_principal(){
echo -e "${BLUE}${BOLD}------------MENU DE SAUVEGARDE-------------${NC}"
echo "      1) Lister les documents à sauvegarder "
echo "      2) Selectionner les documents à sauvegarder "
echo "      3) Effectuer la sauvegarde "
echo "      4) Afficher les options de compression"
echo "      5) Planifier la sauvegarde"
echo "      6) Sauvegarde guidée "
echo "      7) QUITTER"
read -p "Entrez votre choix : " choix
case "$choix" in 
1) lister_documents ;;
2) selectionner_documents ;;
3) update_compression_options; sauvegarder ;;
4) afficher_options_compression ;; 
5) choisir_planification_sauvegarde ;;
6) sauvegarde_guidee ;;
7) exit 0 ;;
*) echo -e "${RED}choix invalide.${NC}" ;;
esac 
}


#boucle menu principal
while true; do 
menu_principal
echo ""
done



# Fonction pour envoyer un email
envoyer_email() {
    local destinataire="$1"
    local sujet="$2"
    local message="$3"

    # Vérifier que le destinataire est spécifié
    if [ -z "$destinataire" ]; then
        echo "ERREUR: Aucun destinataire spécifié pour l'email."
        return 1
    fi

    # Vérifier que le sujet et le message sont non vides
    if [ -z "$sujet" ] || [ -z "$message" ]; then
        echo "ERREUR: Le sujet ou le message de l'email est vide."
        return 1
    fi

    # Envoyer l'email
    echo "$message" | mail -s "$sujet" "$destinataire"

    if [ $? -eq 0 ]; then
        echo "Email envoyé avec succès à $destinataire."
    else
        echo "ERREUR: Échec de l'envoi de l'email à $destinataire."
    fi