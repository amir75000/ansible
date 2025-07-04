#!/bin/bash

# Vérification GLPI

echo "=== Vérification GLPI ==="

# Test serveur
if ping -c 1 192.168.1.226 > /dev/null 2>&1; then
    echo "✅ Serveur accessible"
else
    echo "❌ Serveur inaccessible"
    exit 1
fi

# Test GLPI
if curl -s http://192.168.1.226/glpi > /dev/null; then
    echo "✅ GLPI accessible"
    echo ""
    echo "URL : http://192.168.1.226/glpi"
    echo "Admin : admin/admin"
else
    echo "❌ GLPI inaccessible"
fi
