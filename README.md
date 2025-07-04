# 🚀 Installation GLPI avec Ansible

Ce projet permet d'installer et configurer automatiquement GLPI (Gestionnaire Libre de Parc Informatique) sur un serveur Debian en utilisant Ansible.

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Installation d'Ansible](#installation-dansible)
3. [Configuration du projet](#configuration-du-projet)
4. [Structure du projet](#structure-du-projet)
5. [Détail des rôles Ansible](#détail-des-rôles-ansible)
6. [Utilisation](#utilisation)
7. [Vérifications](#vérifications)
8. [Nettoyage](#nettoyage)
9. [Post-installation](#post-installation)
10. [Dépannage](#dépannage)
11. [Sécurité](#sécurité)

## 🔧 Prérequis

### Sur votre machine de contrôle (où vous lancez Ansible)

- **Système d'exploitation** : Linux (Ubuntu/Debian recommandé)
- **Python** : Version 3.8 ou supérieure
- **Ansible** : Version 2.9 ou supérieure
- **SSH** : Client SSH configuré
- **Accès réseau** : Connexion au serveur cible

### Sur le serveur cible

- **Système d'exploitation** : Debian 11/12 (Bullseye/Bookworm)
- **RAM** : Minimum 2 GB (4 GB recommandé)
- **Espace disque** : Minimum 10 GB d'espace libre
- **Utilisateur** : avec privilèges sudo
- **SSH** : Service SSH activé et accessible

## 📥 Installation d'Ansible

### Sur Ubuntu/Debian

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation d'Ansible
sudo apt install -y ansible python3-pip

# Vérification de l'installation
ansible --version
```

### Sur CentOS/RHEL

```bash
# Installation d'EPEL
sudo yum install -y epel-release

# Installation d'Ansible
sudo yum install -y ansible python3-pip

# Vérification
ansible --version
```

### Via pip (méthode universelle)

```bash
# Installation via pip
pip3 install ansible

# Ajout au PATH si nécessaire
export PATH=$PATH:$HOME/.local/bin

# Vérification
ansible --version
```

## ⚙️ Configuration du projet

### 1. Téléchargement du projet

```bash
# Cloner ou télécharger le projet
cd /home/linus/ansible_amir
```

### 2. Vérification de la structure

```bash
# Vérifier que tous les fichiers sont présents
find . -type f -name "*.yml" -o -name "*.cfg" -o -name "*.sh" | sort
```

### 3. Configuration de l'inventaire

Le fichier `inv/hosts.yml` contient la configuration du serveur cible :

```yaml
all:
  children:
    glpi_servers:
      hosts:
        glpi-server:
          ansible_host: 192.168.1.226
          ansible_user: debian
          ansible_password: Epsi2022!
          ansible_become: yes
```

**🔒 Important** : Modifiez les valeurs selon votre configuration !

## 📁 Structure du projet

```
ansible_amir/
├── README.md              # Ce fichier
├── ansible.cfg            # Configuration Ansible
├── launch.sh             # Script de lancement
├── verify.sh             # Script de vérification
├── clean.sh              # Script de nettoyage
├── inv/                  # Inventaire
│   └── hosts.yml         # Définition des serveurs
└── play/                 # Playbooks et rôles
    ├── playbook.yml      # Playbook principal
    ├── clean_all.yml     # Playbook de nettoyage
    ├── group_vars/       # Variables globales
    │   └── all.yml       # Variables pour tous les serveurs
    └── roles/            # Rôles Ansible
        ├── system_preparation/
        │   └── tasks/
        │       └── main.yml
        ├── mysql/
        │   └── tasks/
        │       └── main.yml
        ├── apache/
        │   ├── tasks/
        │   │   └── main.yml
        │   ├── templates/
        │   │   └── glpi-vhost.conf.j2
        │   └── handlers/
        │       └── main.yml
        ├── php/
        │   └── tasks/
        │       └── main.yml
        └── glpi/
            └── tasks/
                └── main.yml
```

## 🔧 Détail des rôles Ansible

Le projet utilise une architecture en rôles pour organiser les tâches d'installation. Chaque rôle a une responsabilité spécifique :

### 1. 🛠️ system_preparation
**Objectif** : Préparer le système pour l'installation GLPI

**Tâches réalisées** :
- Installation des paquets système essentiels (`curl`, `wget`, `unzip`)
- Création des répertoires nécessaires :
  - `/var/www` et `/var/www/html` pour les fichiers web
  - `/tmp/glpi_install` pour les fichiers temporaires d'installation
- Configuration des permissions appropriées (propriétaire `www-data`)

**Pourquoi ce rôle** : Assure que toutes les dépendances de base sont installées et que l'arborescence des dossiers est correcte avant l'installation des autres composants.

### 2. 🗃️ mysql
**Objectif** : Installer et configurer MariaDB pour GLPI

**Tâches réalisées** :
- Installation du serveur MariaDB
- Démarrage et activation du service MariaDB
- Création de la base de données GLPI
- Création de l'utilisateur GLPI avec les permissions appropriées
- Configuration des accès pour l'application

**Variables utilisées** :
- `glpi_db_name` : nom de la base de données (défaut: `glpi`)
- `glpi_db_user` : utilisateur de la base de données (défaut: `glpi`)
- `glpi_db_password` : mot de passe de la base de données (défaut: `glpi123`)

**Pourquoi ce rôle** : GLPI nécessite une base de données pour stocker toutes les informations de l'inventaire, les utilisateurs, les tickets, etc.

### 3. 🌐 apache
**Objectif** : Installer et configurer Apache pour servir GLPI

**Tâches réalisées** :
- Installation du serveur web Apache2
- Activation des modules Apache nécessaires (`rewrite`, `headers`)
- Configuration du virtual host pour GLPI
- Création de la configuration depuis le template `glpi-vhost.conf.j2`
- Activation du site GLPI
- Redémarrage d'Apache pour appliquer les changements

**Template inclus** :
- `glpi-vhost.conf.j2` : Configuration du virtual host Apache pour GLPI

**Handlers** :
- Redémarrage automatique d'Apache lors des changements de configuration

**Pourquoi ce rôle** : Apache sert l'interface web de GLPI et gère les requêtes HTTP des utilisateurs.

### 4. 🐘 php
**Objectif** : Installer PHP et les extensions nécessaires pour GLPI

**Tâches réalisées** :
- Installation de PHP et des extensions requises :
  - `php` : interpréteur PHP de base
  - `php-mysql` : connexion à MariaDB
  - `php-xml` : traitement des fichiers XML
  - `php-curl` : requêtes HTTP
  - `php-gd` : traitement d'images
  - `php-mbstring` : gestion des chaînes multioctets
  - `php-zip` : extraction d'archives
  - `php-intl` : internationalisation
  - `libapache2-mod-php` : module Apache pour PHP
- Redémarrage d'Apache après installation

**Pourquoi ce rôle** : GLPI est développé en PHP et nécessite ces extensions pour fonctionner correctement (base de données, fichiers, images, etc.).

### 5. 📦 glpi
**Objectif** : Télécharger, installer et configurer GLPI

**Tâches réalisées** :
- Création du répertoire de téléchargement (`/tmp/glpi_install`)
- Téléchargement de l'archive GLPI depuis GitHub
- Extraction de l'archive dans `/var/www/html/`
- Configuration des permissions (propriétaire `www-data`)
- Installation de GLPI via l'interface en ligne de commande
- Configuration de la base de données
- Redémarrage final d'Apache

**Variables utilisées** :
- `glpi_version` : version de GLPI à installer (défaut: `10.0.10`)
- `glpi_url` : URL de téléchargement de GLPI
- Variables de base de données du rôle `mysql`

**Pourquoi ce rôle** : C'est le cœur de l'installation, qui déploie l'application GLPI elle-même et la configure pour être utilisable.

## 🔄 Ordre d'exécution

Les rôles sont exécutés dans cet ordre précis pour respecter les dépendances :

1. **system_preparation** → Prépare l'environnement
2. **mysql** → Installe la base de données
3. **apache** → Installe le serveur web
4. **php** → Installe le langage et ses extensions
5. **glpi** → Installe l'application finale

Chaque rôle dépend des précédents, c'est pourquoi l'ordre est important.

## 🎯 Variables globales

Les variables communes à tous les rôles sont définies dans `play/group_vars/all.yml` :

```yaml
# Version GLPI
glpi_version: "10.0.10"
glpi_url: "https://github.com/glpi-project/glpi/releases/download/{{ glpi_version }}/glpi-{{ glpi_version }}.tgz"

# Base de données
glpi_db_name: "glpi"
glpi_db_user: "glpi"
glpi_db_password: "glpi123"
```

Ces variables permettent de personnaliser l'installation facilement.

## 🚀 Utilisation

### Méthode 1 : Script automatique (Recommandée)

```bash
# Rendre les scripts exécutables
chmod +x launch.sh verify.sh clean.sh

# Lancer l'installation
./launch.sh

# Vérifier l'installation
./verify.sh
```

### Méthode 2 : Commandes manuelles

```bash
# Test de connectivité
ansible all -m ping

# Lancement du playbook
ansible-playbook play/playbook.yml

# Avec plus de détails
ansible-playbook play/playbook.yml -v
```

## ✅ Vérifications

### 1. Vérification de la connectivité

```bash
# Test de connectivité
ansible all -m ping

# Test de connexion SSH
ssh [utilisateur]@[ip_serveur]
```

### 2. Vérification des services

```bash
# Vérifier les services sur le serveur
ansible all -a "systemctl status mysql apache2"

# Vérifier les ports ouverts
ansible all -a "netstat -tlnp | grep -E '80|443|3306'"
```

### 3. Vérification de l'installation

```bash
# Utiliser le script de vérification
./verify.sh

# Vérifier l'accès web manuellement
curl -I http://192.168.1.226/glpi

# Vérifier les logs Apache
ansible all -a "tail -5 /var/log/apache2/error.log"
```

## 🧹 Nettoyage

### Nettoyage simple (recommandé)

Pour supprimer GLPI et permettre une réinstallation propre :

```bash
# Nettoyage avec le script
./clean.sh

# Ou manuellement
ansible-playbook play/clean_all.yml
```

Cette commande supprime :
- Les fichiers GLPI dans `/var/www/html/glpi`
- La base de données GLPI
- Les fichiers temporaires
- Les configurations Apache spécifiques à GLPI

### Après le nettoyage

Une fois le nettoyage terminé, vous pouvez relancer l'installation :

```bash
./launch.sh
```

## 🔧 Post-installation

### 1. Première connexion à GLPI

1. Ouvrez votre navigateur
2. Allez à : `http://192.168.1.226/glpi`
3. Utilisez les identifiants par défaut :
   - **Utilisateur** : `glpi`
   - **Mot de passe** : `glpi`

### 2. Configuration initiale recommandée

1. **Changez le mot de passe par défaut** 
   - Administration → Utilisateurs → glpi → Modifier

2. **Configurez les paramètres généraux**
   - Configuration → Générale → Configuration générale

3. **Configurez les notifications (optionnel)**
   - Configuration → Notifications

### 3. Optimisations recommandées

```bash
# Vérification des permissions
ansible all -a "ls -la /var/www/html/glpi"

# Redémarrage des services
ansible all -a "systemctl restart apache2 mariadb"
```

## 🛠️ Dépannage

### Problèmes de connectivité

**Erreur** : `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"`

**Solutions** :
1. Vérifiez l'adresse IP : `ping 192.168.1.226`
2. Vérifiez SSH : `ssh debian@192.168.1.226`
3. Vérifiez les identifiants dans `inv/hosts.yml`

### Problèmes d'authentification

**Erreur** : `FAILED! => {"msg": "Invalid/incorrect password"}`

**Solutions** :
1. Vérifiez le mot de passe dans `inv/hosts.yml`
2. Testez manuellement : `ssh debian@192.168.1.226`
3. Vérifiez les privilèges sudo : `sudo -l`

### Problèmes d'installation

**Erreur** : `FAILED! => {"msg": "Unable to install package"}`

**Solutions** :
```bash
# Connexion au serveur
ssh debian@192.168.1.226

# Mise à jour manuelle
sudo apt update
sudo apt upgrade -y

# Vérification de l'espace disque
df -h

# Vérification des sources
sudo apt-cache policy
```

### Problèmes de base de données

**Erreur** : `Can't connect to MySQL server`

**Solutions** :
```bash
# Vérifier le service MariaDB
ansible all -a "systemctl status mariadb"

# Redémarrer MariaDB
ansible all -a "systemctl restart mariadb"

# Vérifier les logs
ansible all -a "tail -5 /var/log/mysql/error.log"
```

### Problèmes d'accès web

**Erreur** : `404 Not Found` ou `403 Forbidden`

**Solutions** :
```bash
# Vérifier Apache
ansible all -a "systemctl status apache2"

# Vérifier les permissions
ansible all -a "ls -la /var/www/html/glpi"

# Vérifier les logs Apache
ansible all -a "tail -5 /var/log/apache2/error.log"
```

## 🔒 Sécurité

### Recommandations post-installation

1. **Changez le mot de passe GLPI par défaut**
2. **Configurez un certificat SSL (optionnel)** :
   ```bash
   # Installation de Let's Encrypt
   sudo apt install certbot python3-certbot-apache
   
   # Obtention du certificat
   sudo certbot --apache -d votre-domaine.com
   ```

3. **Mise à jour automatique** :
   ```bash
   # Installation d'unattended-upgrades
   sudo apt install unattended-upgrades
   sudo dpkg-reconfigure unattended-upgrades
   ```

### Durcissement des mots de passe

Éditez le fichier `play/group_vars/all.yml` pour utiliser des mots de passe plus sécurisés :

```yaml
# Remplacez les mots de passe par défaut
glpi_db_password: "VotreMotDePasseSecurise123!"
```

## 📞 Support

### Logs utiles

```bash
# Logs Apache
ansible all -a "tail -10 /var/log/apache2/error.log"

# Logs MariaDB
ansible all -a "tail -10 /var/log/mysql/error.log"

# Logs système
ansible all -a "tail -10 /var/log/syslog"
```

### Commandes de diagnostic

```bash
# Vérifier la configuration Ansible
ansible-config dump --only-changed

# Vérifier l'inventaire
ansible-inventory --list

# Tester la connectivité
ansible all -m ping
```

### Ressources supplémentaires

- [Documentation officielle GLPI](https://glpi-project.org/documentation/)
- [Documentation Ansible](https://docs.ansible.com/)
- [Guide d'installation GLPI](https://glpi-install.readthedocs.io/)

---

## 🎯 Résumé des étapes

1. **Installer Ansible** sur votre machine
2. **Modifier** le fichier `inv/hosts.yml` avec vos paramètres
3. **Vérifier la connectivité** avec `ansible all -m ping`
4. **Lancer l'installation** avec `./launch.sh`
5. **Vérifier l'installation** avec `./verify.sh`
6. **Accéder à GLPI** via `http://192.168.1.226/glpi`
7. **Configurer GLPI** selon vos besoins

**Temps d'installation estimé** : 5-10 minutes

**🎉 Félicitations ! Votre installation GLPI est maintenant prête !**
# ansible
