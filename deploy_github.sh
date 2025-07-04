#!/bin/bash

# Script de déploiement GitHub pour le projet Ansible GLPI

echo "=== Déploiement GitHub ==="
echo "🚀 Préparation du projet pour GitHub..."

# Configuration Git
echo "⚙️ Configuration Git..."
git config --global user.name "amir75000"
git config --global user.email "amir75000@users.noreply.github.com"

# Vérification si c'est déjà un repo Git
if [ ! -d ".git" ]; then
    echo "📁 Initialisation du repository Git..."
    git init
else
    echo "📁 Repository Git déjà existant"
fi

# Vérification des fichiers à ajouter
echo "📋 Fichiers à ajouter :"
find . -name "*.yml" -o -name "*.cfg" -o -name "*.sh" -o -name "*.md" | grep -v ".git" | sort

# Ajout des fichiers
echo "➕ Ajout des fichiers..."
git add .
git add README.md
git add ansible.cfg
git add launch.sh
git add verify.sh
git add clean.sh
git add inv/hosts.yml
git add play/

# Vérification du statut
echo "📊 Statut Git :"
git status --short

# Commit
echo "💾 Création du commit..."
git commit -m "🎉 Projet Ansible GLPI complet avec installation automatisée

✨ Fonctionnalités :
- Installation automatique de GLPI sur Debian
- Structure en rôles Ansible (system, mysql, apache, php, glpi)
- Scripts de lancement, vérification et nettoyage
- Nettoyage en profondeur avec clean.sh
- Documentation complète pour débutants

📁 Structure :
- inv/hosts.yml : Configuration des serveurs
- play/ : Playbooks et rôles
- launch.sh : Script d'installation
- verify.sh : Script de vérification
- clean.sh : Script de nettoyage complet
- README.md : Documentation détaillée

🔧 Testé et fonctionnel sur Debian 11/12"

# Configuration de la branche principale
echo "🌿 Configuration de la branche main..."
git branch -M main

# Vérification de la remote
if git remote get-url origin > /dev/null 2>&1; then
    echo "🔗 Remote origin déjà configurée"
    git remote set-url origin https://github.com/amir75000/ansible.git
else
    echo "🔗 Ajout de la remote origin..."
    git remote add origin https://github.com/amir75000/ansible.git
fi

# Push vers GitHub
echo "🚀 Envoi vers GitHub..."
echo "📝 Utilisateur : amir75000"
echo "🔑 Authentification requise..."

# Demander le token de manière sécurisée
echo -n "🔐 Entrez votre token GitHub : "
read -s GITHUB_TOKEN
echo ""

# Configuration du token
git remote set-url origin https://amir75000:$GITHUB_TOKEN@github.com/amir75000/ansible.git

# Push
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Déploiement GitHub réussi !"
    echo "🌐 Repository : https://github.com/amir75000/ansible"
    echo "📖 README visible sur : https://github.com/amir75000/ansible/blob/main/README.md"
    echo ""
    echo "🎉 Votre projet Ansible GLPI est maintenant public !"
else
    echo ""
    echo "❌ Erreur lors du push"
    echo "📝 Vérifiez vos droits d'accès au repository"
    exit 1
fi
