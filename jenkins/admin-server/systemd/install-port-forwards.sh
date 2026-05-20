#!/bin/bash
# ════════════════════════════════════════════════════════════════════════
# install-port-forwards.sh
#
# Installe les services systemd de port-forward FlexPay sur la VM Ubuntu.
# Rend les microservices Minikube accessibles sur 0.0.0.0 (accès externe).
#
# Usage : sudo ./install-port-forwards.sh
# ════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICES=(admin-server gateway user-service kyc-service messaging-service payment-service)

if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR : ce script doit être exécuté en root (sudo)"
    exit 1
fi

echo "═══ Installation des port-forwards FlexPay ═══"

# 1. Copier les fichiers d'environnement
mkdir -p /etc/flexpay/port-forward
cp "$SCRIPT_DIR/env/"*.conf /etc/flexpay/port-forward/
echo "  ✓ Fichiers d'environnement copiés dans /etc/flexpay/port-forward/"

# 2. Copier le template systemd
cp "$SCRIPT_DIR/flexpay-port-forward@.service" /etc/systemd/system/
systemctl daemon-reload
echo "  ✓ Template systemd installé"

# 3. Tuer les port-forwards Jenkins éventuels (éviter les conflits)
pkill -f 'kubectl.*port-forward.*flexpay' 2>/dev/null || true
sleep 1

# 4. Activer et démarrer chaque service
for svc in "${SERVICES[@]}"; do
    systemctl enable --now "flexpay-port-forward@${svc}" 2>/dev/null
    echo "  ✓ flexpay-port-forward@${svc} activé"
done

echo ""
echo "═══ Vérification ═══"
sleep 3

ALL_OK=true
for svc in "${SERVICES[@]}"; do
    PORT=$(grep LOCAL_PORT "/etc/flexpay/port-forward/${svc}.conf" | cut -d= -f2)
    if curl -sf -o /dev/null --max-time 3 "http://localhost:${PORT}/actuator/health" 2>/dev/null; then
        echo "  ✓ ${svc} — port ${PORT} OK"
    else
        echo "  ✗ ${svc} — port ${PORT} pas encore prêt (le service peut prendre quelques secondes)"
        ALL_OK=false
    fi
done

echo ""
if $ALL_OK; then
    echo "Tous les port-forwards sont actifs."
else
    echo "Certains services démarrent encore. Vérifier avec :"
    echo "  systemctl status 'flexpay-port-forward@*'"
fi

echo ""
echo "Commandes utiles :"
echo "  systemctl status flexpay-port-forward@admin-server"
echo "  systemctl restart flexpay-port-forward@gateway"
echo "  journalctl -u flexpay-port-forward@user-service -f"
