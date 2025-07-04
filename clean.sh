#!/bin/bash

# Nettoyage GLPI en profondeur

echo "=== Nettoyage GLPI en profondeur ==="
echo "Cette opération va :"
echo "- Supprimer complètement GLPI"
echo "- Supprimer la base de données"
echo "- Nettoyer les configurations Apache"
echo "- Nettoyer les fichiers temporaires"
echo "- Nettoyer les caches"
echo "- Nettoyer les logs"
echo ""
echo "⚠️  ATTENTION : Cette opération est irréversible !"
echo ""
read -p "Continuer ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Nettoyage en cours..."
    echo ""
    
    # Test de connectivité avant nettoyage
    echo "📡 Test de connectivité..."
    ansible all -m ping > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Connexion OK"
    else
        echo "❌ Erreur de connexion"
        exit 1
    fi
    
    # Lancement du nettoyage
    ansible-playbook play/clean_all.yml
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Nettoyage complet terminé !"
        echo "📝 Vous pouvez maintenant relancer : ./launch.sh"
    else
        echo ""
        echo "❌ Erreur durant le nettoyage"
        echo "📝 Vérifiez les logs ci-dessus"
        exit 1
    fi
else
    echo "❌ Nettoyage annulé"
    exit 0
fi
