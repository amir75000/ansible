#!/bin/bash

# Installation GLPI

echo "=== Installation GLPI ==="

# Test connexion
echo "Test connexion..."
if ansible all -m ping > /dev/null 2>&1; then
    echo "✅ Connexion OK"
else
    echo "❌ Problème connexion - Vérifiez inv/hosts.yml"
    exit 1
fi

# Installation
echo "Installation..."
ansible-playbook play/playbook.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation terminée !"
    echo "URL : http://192.168.1.226/glpi"
    echo "Admin : admin/admin"
else
    echo "❌ Erreur installation"
fi
