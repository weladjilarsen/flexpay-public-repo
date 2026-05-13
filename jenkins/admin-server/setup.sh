#!/bin/bash
# ════════════════════════════════════════════════════════════════════════
# setup.sh — Installation complète CI/CD sur VM Ubuntu
#
# Ce script installe et configure :
#   1. Docker Registry local (port 5000)
#   2. Minikube (Kubernetes via driver Docker)
#   3. Jenkins (container Docker)
#   4. Génère le KUBECONFIG_BASE64
#
# Usage :
#   chmod +x setup.sh
#   ./setup.sh
#
# Exécuter sur la VM Ubuntu (PAS sur le Mac).
# ════════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ─────────────── DÉTECTION IP HÔTE ────────────────────────────────────
# L'IP de la VM est nécessaire car Minikube (container Docker) ne peut
# pas accéder à localhost de la VM. On utilise l'IP réelle à la place.
HOST_IP=$(hostname -I | awk '{print $1}')
log "IP de la VM détectée : ${HOST_IP}"

# ─────────────── 1. PRÉREQUIS ─────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 1 — Vérification des prérequis"
echo "════════════════════════════════════════════════════════════"

command -v docker >/dev/null 2>&1 || err "Docker non installé. Installer Docker Engine d'abord."
log "Docker Engine OK"

# Vérifier que l'utilisateur peut exécuter docker sans sudo
if ! docker ps >/dev/null 2>&1; then
    warn "Docker nécessite sudo. Ajout au groupe docker..."
    sudo usermod -aG docker "$USER"
    warn "Déconnecte-toi et reconnecte-toi, puis relance ce script."
    exit 1
fi

# ─────────────── 2. CONFIGURER DOCKER POUR REGISTRY INSECURE ─────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 2 — Configuration Docker (insecure registry)"
echo "════════════════════════════════════════════════════════════"

DAEMON_JSON="/etc/docker/daemon.json"
INSECURE_ENTRY="${HOST_IP}:5000"

if [ -f "$DAEMON_JSON" ] && grep -q "$INSECURE_ENTRY" "$DAEMON_JSON"; then
    log "Docker daemon déjà configuré pour ${INSECURE_ENTRY}"
else
    warn "Configuration de Docker pour accepter le registry local..."
    sudo mkdir -p /etc/docker

    if [ -f "$DAEMON_JSON" ]; then
        # Ajouter l'entrée au fichier existant
        sudo cp "$DAEMON_JSON" "${DAEMON_JSON}.bak"
        sudo python3 -c "
import json
with open('$DAEMON_JSON') as f:
    cfg = json.load(f)
registries = cfg.get('insecure-registries', [])
if '$INSECURE_ENTRY' not in registries:
    registries.append('$INSECURE_ENTRY')
if 'localhost:5000' not in registries:
    registries.append('localhost:5000')
cfg['insecure-registries'] = registries
with open('$DAEMON_JSON', 'w') as f:
    json.dump(cfg, f, indent=2)
"
    else
        echo '{
  "insecure-registries": ["localhost:5000", "'${INSECURE_ENTRY}'"]
}' | sudo tee "$DAEMON_JSON" > /dev/null
    fi

    sudo systemctl restart docker
    log "Docker redémarré avec insecure-registries: localhost:5000, ${INSECURE_ENTRY}"
fi

# ─────────────── 3. DÉMARRER LE REGISTRY ──────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 3 — Registry Docker local (port 5000)"
echo "════════════════════════════════════════════════════════════"

if docker ps --format '{{.Names}}' | grep -q '^registry$'; then
    log "Registry déjà en cours d'exécution"
else
    docker rm -f registry 2>/dev/null || true
    docker run -d \
      --name registry \
      --restart unless-stopped \
      -p 5000:5000 \
      -v registry-data:/var/lib/registry \
      registry:2
    log "Registry démarré sur localhost:5000"
fi

# Tester le registry
sleep 2
if curl -sf http://localhost:5000/v2/ >/dev/null; then
    log "Registry accessible et fonctionnel"
else
    err "Registry non accessible sur localhost:5000"
fi

# ─────────────── 4. INSTALLER MINIKUBE ────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 4 — Installation Minikube + kubectl"
echo "════════════════════════════════════════════════════════════"

# Installer kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    warn "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log "kubectl installé"
else
    log "kubectl déjà installé : $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
fi

# Installer minikube
if ! command -v minikube >/dev/null 2>&1; then
    warn "Installation de Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    log "Minikube installé"
else
    log "Minikube déjà installé : $(minikube version --short)"
fi

# ─────────────── 5. DÉMARRER MINIKUBE ─────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 5 — Démarrage du cluster Kubernetes (Minikube)"
echo "════════════════════════════════════════════════════════════"

MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [ "$MINIKUBE_STATUS" = "Running" ]; then
    log "Minikube déjà en cours d'exécution"
else
    warn "Démarrage de Minikube (driver Docker)..."
    minikube start \
      --driver=docker \
      --cpus=2 \
      --memory=4096 \
      --insecure-registry="${HOST_IP}:5000"

    log "Minikube démarré"
fi

# Vérifier le cluster
kubectl get nodes
log "Cluster Kubernetes opérationnel"

# ─────────────── 6. CONFIGURER MINIKUBE → REGISTRY ────────────────────
# Minikube (container) doit pouvoir pull depuis le registry de la VM.
# On configure containerd à l'intérieur de Minikube pour utiliser l'IP
# de la VM au lieu de localhost.
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 6 — Lien Minikube ↔ Registry local"
echo "════════════════════════════════════════════════════════════"

# Tester la connectivité depuis Minikube
if minikube ssh -- curl -sf "http://${HOST_IP}:5000/v2/" >/dev/null 2>&1; then
    log "Minikube peut accéder au registry via ${HOST_IP}:5000"
else
    warn "Configuration de la route Minikube → Registry..."
    # Ajouter une entrée hosts si nécessaire
    minikube ssh -- "echo '${HOST_IP} host-registry' | sudo tee -a /etc/hosts"
fi

# Configurer containerd dans Minikube pour le registry insecure
minikube ssh -- "sudo mkdir -p /etc/containerd/certs.d/${HOST_IP}:5000"
minikube ssh -- "echo '[host.\"http://${HOST_IP}:5000\"]
  capabilities = [\"pull\", \"resolve\", \"push\"]
  skip_verify = true' | sudo tee /etc/containerd/certs.d/${HOST_IP}:5000/hosts.toml > /dev/null"

log "Minikube configuré pour pull depuis ${HOST_IP}:5000"

# ─────────────── 7. CRÉER LES NAMESPACES K8S ─────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 7 — Création des namespaces Kubernetes"
echo "════════════════════════════════════════════════════════════"

kubectl create namespace flexpay-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace flexpay-prod    --dry-run=client -o yaml | kubectl apply -f -
log "Namespaces flexpay-staging et flexpay-prod créés"

# ─────────────── 8. GÉNÉRER KUBECONFIG_BASE64 ─────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 8 — Génération du KUBECONFIG_BASE64"
echo "════════════════════════════════════════════════════════════"

KUBECONFIG_PATH="${HOME}/.kube/config"

if [ ! -f "$KUBECONFIG_PATH" ]; then
    err "Kubeconfig introuvable à ${KUBECONFIG_PATH}"
fi

KUBECONFIG_B64=$(cat "$KUBECONFIG_PATH" | base64 -w 0)
log "KUBECONFIG_BASE64 généré (${#KUBECONFIG_B64} caractères)"

# ─────────────── 9. ÉCRIRE LE .env ────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ÉTAPE 9 — Mise à jour du .env"
echo "════════════════════════════════════════════════════════════"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    # Mettre à jour les valeurs auto-générées
    sed -i "s|^KUBECONFIG_BASE64=.*|KUBECONFIG_BASE64=${KUBECONFIG_B64}|" "$ENV_FILE"
    sed -i "s|^KUBECONFIG_PATH=.*|KUBECONFIG_PATH=${KUBECONFIG_PATH}|" "$ENV_FILE"
    sed -i "s|^HOST_IP=.*|HOST_IP=${HOST_IP}|" "$ENV_FILE"
    log ".env mis à jour avec KUBECONFIG_BASE64 et HOST_IP"
else
    warn "Fichier .env non trouvé. Création depuis le template..."
    if [ -f "${SCRIPT_DIR}/.env.example" ]; then
        cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE"
        sed -i "s|^KUBECONFIG_BASE64=.*|KUBECONFIG_BASE64=${KUBECONFIG_B64}|" "$ENV_FILE"
        sed -i "s|^KUBECONFIG_PATH=.*|KUBECONFIG_PATH=${KUBECONFIG_PATH}|" "$ENV_FILE"
        log ".env créé — REMPLIR les valeurs manquantes avec : nano ${ENV_FILE}"
    else
        err ".env.example non trouvé dans ${SCRIPT_DIR}"
    fi
fi

# ─────────────── 10. RÉSUMÉ ───────────────────────────────────────────
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "N/A")
KUBECTL_PATH=$(which kubectl)

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  SETUP TERMINÉ"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  VM Ubuntu IP       : ${HOST_IP}"
echo "  Registry local     : http://${HOST_IP}:5000"
echo "  Minikube IP        : ${MINIKUBE_IP}"
echo "  kubectl            : ${KUBECTL_PATH}"
echo "  Kubeconfig         : ${KUBECONFIG_PATH}"
echo ""
echo "  Prochaines étapes :"
echo "  1. Compléter le .env :  nano ${ENV_FILE}"
echo "  2. Lancer Jenkins :     docker compose up -d jenkins"
echo "  3. Depuis le Mac :      http://${HOST_IP}:8080"
echo ""
echo "  Tester le registry :"
echo "    docker pull nginx:alpine"
echo "    docker tag nginx:alpine ${HOST_IP}:5000/test:latest"
echo "    docker push ${HOST_IP}:5000/test:latest"
echo "    kubectl run test --image=${HOST_IP}:5000/test:latest"
echo ""
echo "════════════════════════════════════════════════════════════"
