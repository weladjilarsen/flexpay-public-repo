#!/bin/bash
# ════════════════════════════════════════════════════════════════════════
# setup.sh — Installation complete CI/CD sur VM Ubuntu
#
# Ce script installe et configure :
#   1. Docker Registry local (port 5000)
#   2. Minikube (Kubernetes via driver Docker)
#   3. kubectl
#   4. Kubeconfig flatten pour Jenkins
#   5. Service systemd pour Minikube (demarrage auto)
#   6. Connexion reseau Jenkins <-> Minikube
#
# Usage :
#   chmod +x setup.sh
#   ./setup.sh
#
# Executer sur la VM Ubuntu (PAS sur le Mac).
# ════════════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[X]${NC} $1"; exit 1; }

CURRENT_USER=$(whoami)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─────────────── DETECTION IP HOTE ────────────────────────────────────
# Tailscale IP si disponible, sinon IP locale
if command -v tailscale >/dev/null 2>&1; then
    HOST_IP=$(tailscale ip -4 2>/dev/null || hostname -I | awk '{print $1}')
else
    HOST_IP=$(hostname -I | awk '{print $1}')
fi
log "IP de la VM detectee : ${HOST_IP}"

# ─────────────── 1. PREREQUIS ─────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 1 — Verification des prerequis"
echo "════════════════════════════════════════════════════════════"

command -v docker >/dev/null 2>&1 || err "Docker non installe. Installer Docker Engine d'abord."
log "Docker Engine OK"

if ! docker ps >/dev/null 2>&1; then
    warn "Docker necessite sudo. Ajout au groupe docker..."
    sudo usermod -aG docker "$CURRENT_USER"
    warn "Deconnecte-toi et reconnecte-toi, puis relance ce script."
    exit 1
fi

# ─────────────── 2. CONFIGURER DOCKER POUR REGISTRY INSECURE ─────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 2 — Configuration Docker (insecure registry)"
echo "════════════════════════════════════════════════════════════"

DAEMON_JSON="/etc/docker/daemon.json"
INSECURE_ENTRY="${HOST_IP}:5000"

if [ -f "$DAEMON_JSON" ] && grep -q "$INSECURE_ENTRY" "$DAEMON_JSON"; then
    log "Docker daemon deja configure pour ${INSECURE_ENTRY}"
else
    warn "Configuration de Docker pour accepter le registry local..."
    sudo mkdir -p /etc/docker

    if [ -f "$DAEMON_JSON" ]; then
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
    log "Docker redemarre avec insecure-registries: localhost:5000, ${INSECURE_ENTRY}"
fi

# ─────────────── 3. DEMARRER LE REGISTRY ──────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 3 — Registry Docker local (port 5000)"
echo "════════════════════════════════════════════════════════════"

if docker ps --format '{{.Names}}' | grep -q '^registry$'; then
    log "Registry deja en cours d'execution"
else
    docker rm -f registry 2>/dev/null || true
    docker run -d \
      --name registry \
      --restart unless-stopped \
      -p 5000:5000 \
      -v registry-data:/var/lib/registry \
      registry:2
    log "Registry demarre sur localhost:5000"
fi

sleep 2
if curl -sf http://localhost:5000/v2/ >/dev/null; then
    log "Registry accessible et fonctionnel"
else
    err "Registry non accessible sur localhost:5000"
fi

# ─────────────── 4. INSTALLER KUBECTL + MINIKUBE ─────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 4 — Installation kubectl + Minikube"
echo "════════════════════════════════════════════════════════════"

if ! command -v kubectl >/dev/null 2>&1; then
    warn "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log "kubectl installe"
else
    log "kubectl deja installe"
fi

if ! command -v minikube >/dev/null 2>&1; then
    warn "Installation de Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    log "Minikube installe"
else
    log "Minikube deja installe"
fi

# ─────────────── 5. DEMARRER MINIKUBE ─────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 5 — Demarrage du cluster Kubernetes (Minikube)"
echo "════════════════════════════════════════════════════════════"

MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [ "$MINIKUBE_STATUS" = "Running" ]; then
    log "Minikube deja en cours d'execution"
else
    warn "Demarrage de Minikube (driver Docker)..."
    minikube start \
      --driver=docker \
      --cpus=2 \
      --memory=4096 \
      --insecure-registry="${HOST_IP}:5000"
    log "Minikube demarre"
fi

kubectl get nodes
log "Cluster Kubernetes operationnel"

# ─────────────── 6. CONNECTER JENKINS AU RESEAU MINIKUBE ─────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 6 — Connexion Jenkins <-> Minikube"
echo "════════════════════════════════════════════════════════════"

if docker ps --format '{{.Names}}' | grep -q '^jenkins$'; then
    docker network connect minikube jenkins 2>/dev/null && \
      log "Jenkins connecte au reseau minikube" || \
      log "Jenkins deja connecte au reseau minikube"
else
    warn "Container Jenkins non trouve — connecter manuellement apres docker compose up"
fi

# ─────────────── 7. CREER LES NAMESPACES K8S ─────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 7 — Creation des namespaces Kubernetes"
echo "════════════════════════════════════════════════════════════"

kubectl create namespace flexpay-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace flexpay-prod    --dry-run=client -o yaml | kubectl apply -f -
log "Namespaces flexpay-staging et flexpay-prod crees"

# ─────────────── 8. GENERER KUBECONFIG POUR JENKINS ──────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 8 — Generation kubeconfig (certificats embarques)"
echo "════════════════════════════════════════════════════════════"

KUBECONFIG_PATH="${HOME}/.kube/config"
KUBECONFIG_JENKINS="${HOME}/kubeconfig-jenkins.txt"

if [ ! -f "$KUBECONFIG_PATH" ]; then
    err "Kubeconfig introuvable a ${KUBECONFIG_PATH}"
fi

kubectl config view --flatten > "$KUBECONFIG_JENKINS"
log "Kubeconfig flatten genere : ${KUBECONFIG_JENKINS}"
log "Uploader ce fichier dans Jenkins : Credentials -> Secret file -> ID: kubeconfig-file"

KUBECONFIG_B64=$(base64 -w 0 < "$KUBECONFIG_PATH")

# ─────────────── 9. SERVICE SYSTEMD MINIKUBE (DEMARRAGE AUTO) ────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 9 — Service systemd Minikube (demarrage auto)"
echo "════════════════════════════════════════════════════════════"

sudo tee /etc/systemd/system/minikube.service > /dev/null << EOF
[Unit]
Description=Minikube Kubernetes Cluster
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=${CURRENT_USER}
ExecStart=/usr/local/bin/minikube start --driver=docker --insecure-registry="${HOST_IP}:5000"
ExecStop=/usr/local/bin/minikube stop

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/minikube-jenkins.service > /dev/null << 'EOF'
[Unit]
Description=Connect Jenkins to Minikube network
After=minikube.service docker.service
Requires=minikube.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/docker network connect minikube jenkins

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable minikube minikube-jenkins
log "Services systemd crees et actives (minikube + minikube-jenkins)"

# ─────────────── 10. ECRIRE LE .env ──────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ETAPE 10 — Mise a jour du .env"
echo "════════════════════════════════════════════════════════════"

ENV_FILE="${SCRIPT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    sed -i "s|^KUBECONFIG_BASE64=.*|KUBECONFIG_BASE64=${KUBECONFIG_B64}|" "$ENV_FILE"
    sed -i "s|^KUBECONFIG_PATH=.*|KUBECONFIG_PATH=${KUBECONFIG_PATH}|" "$ENV_FILE"
    sed -i "s|^HOST_IP=.*|HOST_IP=${HOST_IP}|" "$ENV_FILE"
    log ".env mis a jour avec KUBECONFIG_BASE64 et HOST_IP"
else
    if [ -f "${SCRIPT_DIR}/.env.example" ]; then
        cp "${SCRIPT_DIR}/.env.example" "$ENV_FILE"
        sed -i "s|^KUBECONFIG_BASE64=.*|KUBECONFIG_BASE64=${KUBECONFIG_B64}|" "$ENV_FILE"
        sed -i "s|^KUBECONFIG_PATH=.*|KUBECONFIG_PATH=${KUBECONFIG_PATH}|" "$ENV_FILE"
        sed -i "s|^HOST_IP=.*|HOST_IP=${HOST_IP}|" "$ENV_FILE"
        log ".env cree — REMPLIR les valeurs manquantes : nano ${ENV_FILE}"
    else
        err ".env.example non trouve dans ${SCRIPT_DIR}"
    fi
fi

# ─────────────── 11. RESUME ──────────────────────────────────────────
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "N/A")

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  SETUP TERMINE"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  VM Ubuntu IP       : ${HOST_IP}"
echo "  Registry local     : http://${HOST_IP}:5000"
echo "  Minikube IP        : ${MINIKUBE_IP}"
echo "  Kubeconfig Jenkins : ${KUBECONFIG_JENKINS}"
echo ""
echo "  Services systemd   : minikube + minikube-jenkins (demarrage auto)"
echo ""
echo "  Prochaines etapes :"
echo "  1. Completer le .env :    nano ${ENV_FILE}"
echo "  2. Lancer la stack :      docker compose up -d"
echo "  3. Jenkins depuis Mac :   http://${HOST_IP}:8080"
echo "  4. Charger JCasC :        Manage Jenkins -> Configuration as Code"
echo "  5. Uploader kubeconfig :  ${KUBECONFIG_JENKINS} -> Credentials -> Secret file"
echo ""
echo "  Tester le registry :"
echo "    docker pull nginx:alpine"
echo "    docker tag nginx:alpine ${HOST_IP}:5000/test:latest"
echo "    docker push ${HOST_IP}:5000/test:latest"
echo "    minikube ssh -- curl -s http://${HOST_IP}:5000/v2/_catalog"
echo ""
echo "════════════════════════════════════════════════════════════"
