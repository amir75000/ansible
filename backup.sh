#!/bin/bash

# Script de sauvegarde GLPI
# Usage: ./backup.sh [backup|restore] [backup_file]

SERVER_IP="192.168.1.226"
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="glpi_backup_${DATE}.tar.gz"

# Création du répertoire de sauvegarde
mkdir -p $BACKUP_DIR

case "$1" in
    backup)
        echo "=========================================="
        echo "   Sauvegarde GLPI - $DATE"
        echo "=========================================="
        
        # Sauvegarde de la base de données
        echo "Sauvegarde de la base de données..."
        ssh debian@${SERVER_IP} "mysqldump -u glpi -pglpi_password_secure glpi > /tmp/glpi_db_backup.sql"
        
        # Sauvegarde des fichiers
        echo "Sauvegarde des fichiers GLPI..."
        ssh debian@${SERVER_IP} "tar -czf /tmp/glpi_files_backup.tar.gz -C /var/www/html glpi"
        
        # Récupération des sauvegardes
        echo "Récupération des sauvegardes..."
        scp debian@${SERVER_IP}:/tmp/glpi_db_backup.sql $BACKUP_DIR/
        scp debian@${SERVER_IP}:/tmp/glpi_files_backup.tar.gz $BACKUP_DIR/
        
        # Création de l'archive complète
        echo "Création de l'archive complète..."
        cd $BACKUP_DIR
        tar -czf $BACKUP_FILE glpi_db_backup.sql glpi_files_backup.tar.gz
        
        # Nettoyage
        rm glpi_db_backup.sql glpi_files_backup.tar.gz
        ssh debian@${SERVER_IP} "rm /tmp/glpi_db_backup.sql /tmp/glpi_files_backup.tar.gz"
        
        echo "✅ Sauvegarde terminée: $BACKUP_DIR/$BACKUP_FILE"
        ;;
        
    restore)
        if [ -z "$2" ]; then
            echo "Usage: $0 restore <backup_file>"
            exit 1
        fi
        
        if [ ! -f "$2" ]; then
            echo "❌ Fichier de sauvegarde non trouvé: $2"
            exit 1
        fi
        
        echo "=========================================="
        echo "   Restauration GLPI"
        echo "=========================================="
        
        # Extraction de la sauvegarde
        echo "Extraction de la sauvegarde..."
        cd $BACKUP_DIR
        tar -xzf $2
        
        # Envoi des fichiers sur le serveur
        echo "Envoi des fichiers sur le serveur..."
        scp glpi_db_backup.sql debian@${SERVER_IP}:/tmp/
        scp glpi_files_backup.tar.gz debian@${SERVER_IP}:/tmp/
        
        # Arrêt des services
        echo "Arrêt des services..."
        ssh debian@${SERVER_IP} "sudo systemctl stop apache2"
        
        # Restauration de la base de données
        echo "Restauration de la base de données..."
        ssh debian@${SERVER_IP} "mysql -u glpi -pglpi_password_secure glpi < /tmp/glpi_db_backup.sql"
        
        # Restauration des fichiers
        echo "Restauration des fichiers..."
        ssh debian@${SERVER_IP} "
            sudo rm -rf /var/www/html/glpi_old
            sudo mv /var/www/html/glpi /var/www/html/glpi_old
            sudo tar -xzf /tmp/glpi_files_backup.tar.gz -C /var/www/html
            sudo chown -R www-data:www-data /var/www/html/glpi
        "
        
        # Redémarrage des services
        echo "Redémarrage des services..."
        ssh debian@${SERVER_IP} "sudo systemctl start apache2"
        
        # Nettoyage
        ssh debian@${SERVER_IP} "rm /tmp/glpi_db_backup.sql /tmp/glpi_files_backup.tar.gz"
        rm glpi_db_backup.sql glpi_files_backup.tar.gz
        
        echo "✅ Restauration terminée"
        ;;
        
    *)
        echo "Usage: $0 {backup|restore} [backup_file]"
        echo ""
        echo "Exemples:"
        echo "  $0 backup                    # Créer une sauvegarde"
        echo "  $0 restore backup_file.tar.gz  # Restaurer une sauvegarde"
        exit 1
        ;;
esac
