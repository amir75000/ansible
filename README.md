# 🚀 Installation GLPI avec Ansible

Ce projet permet d'installer et configurer automatiquement GLPI (Gestionnaire Libre de Parc Informatique) sur un serveur Debian en utilisant Ansible.

## 📋 Table des matières

1. [Prérequis](#prérequis)
2. [Installation d'Ansible](#installation-dansible)
3. [Configuration du projet](#configuration-du-projet)
4. [Structure du projet](#structure-du-projet)
5. [Utilisation](#utilisation)
6. [Vérifications](#vérifications)
7. [Nettoyage](#nettoyage)
8. [Post-installation](#post-installation)
9. [Dépannage](#dépannage)
10. [Sécurité](#sécurité)

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
