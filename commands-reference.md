# Commandes utiles — FlexPay Platform

> VM Ubuntu + Docker Engine + Registry local + Minikube + Jenkins
>
> Acces depuis Mac via Tailscale : `100.67.178.90`

---

## 1. Docker Engine

### Gestion des containers

```bash
# Voir les containers en cours
docker ps

# Voir tous les containers (y compris arretes)
docker ps -a

# Logs d'un container (temps reel)
docker logs -f jenkins
docker logs -f registry
docker logs --tail=100 jenkins

# Entrer dans un container
docker exec -it jenkins bash
docker exec -it redis redis-cli

# Redemarrer un container
docker restart jenkins

# Arreter / supprimer un container
docker stop jenkins
docker rm jenkins
docker rm -f jenkins
```

### Gestion des images

```bash
# Lister les images locales
docker images

# Supprimer une image
docker rmi <image_id>

# Supprimer les images non utilisees
docker image prune -a

# Builder une image (depuis le dossier du microservice)
cd ~/flexpay-admin-server-service
docker build -t 100.67.178.90:5000/flexpay-admin-server:latest .

# Taguer une image pour le registry local
docker tag flexpay-admin-server:latest 100.67.178.90:5000/flexpay-admin-server:latest
```

### Registry local (port 5000)

```bash
# Verifier que le registry fonctionne
curl -s http://localhost:5000/v2/

# Lister les images dans le registry
curl -s http://localhost:5000/v2/_catalog

# Lister les tags d'une image
curl -s http://localhost:5000/v2/flexpay-admin-server/tags/list

# Pousser une image vers le registry
docker push 100.67.178.90:5000/flexpay-admin-server:latest

# Tirer une image depuis le registry
docker pull 100.67.178.90:5000/flexpay-admin-server:latest

# Tester le registry avec nginx
docker pull nginx:alpine
docker tag nginx:alpine 100.67.178.90:5000/test:latest
docker push 100.67.178.90:5000/test:latest
```

### Reseaux Docker

```bash
# Lister les reseaux
docker network ls

# Inspecter un reseau (voir les containers connectes)
docker network inspect minikube
docker network inspect prod-stack_backend

# Connecter Jenkins au reseau minikube
docker network connect minikube jenkins

# Deconnecter Jenkins du reseau minikube
docker network disconnect minikube jenkins

# Supprimer un reseau (aucun container ne doit y etre connecte)
docker network rm minikube

# Voir les subnets utilises
docker network ls -q | xargs -I {} docker network inspect {} --format '{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}'
```

### Volumes Docker

```bash
# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect jenkins_data

# Supprimer les volumes non utilises
docker volume prune
```

### Nettoyage global

```bash
# Supprimer containers arretes + images non utilisees + reseaux orphelins
docker system prune

# Idem + volumes non utilises (ATTENTION : perte de donnees)
docker system prune --volumes

# Voir l'espace disque utilise par Docker
docker system df
```

---

## 2. Docker Compose (stack de production)

### Demarrage / arret

```bash
# Se placer dans le dossier de la stack
cd ~/prod-stack
# OU
cd ~/flexpay-public-repo/jenkins/admin-server

# Demarrer toute la stack en arriere-plan
docker compose up -d

# Demarrer uniquement Jenkins
docker compose up -d jenkins

# Arreter un service
docker compose down jenkins

# Arreter toute la stack
docker compose down

# Arreter + supprimer les volumes (ATTENTION : perte de donnees)
docker compose down -v

# Reconstruire et redemarrer un service
docker compose up -d --build jenkins

# Voir les logs de la stack
docker compose logs -f
docker compose logs -f jenkins

# Voir le statut des services
docker compose ps
```

### Variables d'environnement

```bash
# Verifier les variables resolues
docker compose config

# Editer le .env
nano .env
```

---

## 3. Minikube (Kubernetes local)

### Cycle de vie du cluster

```bash
# Demarrer Minikube (sans subnet fixe)
minikube start --driver=docker --cpus=2 --memory=4096 --insecure-registry="100.67.178.90:5000"

# Voir le statut
minikube status

# Arreter Minikube
minikube stop

# Supprimer completement le cluster (repart de zero)
minikube delete

# IP interne de Minikube
minikube ip

# Dashboard Kubernetes (ouvre un navigateur)
minikube dashboard

# SSH dans la VM Minikube
minikube ssh

# Tester l'acces au registry depuis Minikube
minikube ssh -- curl -s http://100.67.178.90:5000/v2/_catalog
```

### Services systemd (demarrage automatique)

```bash
# Verifier le statut du service minikube
sudo systemctl status minikube

# Demarrer / arreter manuellement
sudo systemctl start minikube
sudo systemctl stop minikube

# Activer / desactiver le demarrage auto
sudo systemctl enable minikube
sudo systemctl disable minikube

# Verifier le service de connexion Jenkins <-> Minikube
sudo systemctl status minikube-jenkins

# Voir les logs systemd
journalctl -u minikube --no-pager -n 50
journalctl -u minikube-jenkins --no-pager -n 50

# Recharger les services apres modification
sudo systemctl daemon-reload
```

### Tunnels et acces externe

```bash
# Exposer un service NodePort via l'IP de Minikube
# (le service flexpay-admin-server est sur NodePort 30090)
# Depuis la VM :
curl http://$(minikube ip):30090/actuator/health

# Depuis le Mac (via Tailscale) — tunnel kubectl :
kubectl port-forward svc/flexpay-admin-server 9090:9090 -n flexpay-prod --address=0.0.0.0

# Depuis le Mac (via Tailscale) — tunnel minikube :
minikube service flexpay-admin-server -n flexpay-prod --url
```

---

## 4. kubectl (Kubernetes)

### Configuration

```bash
# Voir le contexte actuel
kubectl config current-context

# Lister les contextes
kubectl config get-contexts

# Generer un kubeconfig avec certificats embarques (pour Jenkins)
kubectl config view --flatten > ~/kubeconfig-jenkins.txt

# Utiliser un kubeconfig specifique
kubectl --kubeconfig=/path/to/kubeconfig get pods
```

### Namespaces

```bash
# Lister les namespaces
kubectl get namespaces

# Creer les namespaces FlexPay
kubectl create namespace flexpay-staging
kubectl create namespace flexpay-prod

# Definir le namespace par defaut
kubectl config set-context --current --namespace=flexpay-prod
```

### Pods

```bash
# Lister les pods (namespace courant)
kubectl get pods
kubectl get pods -n flexpay-prod
kubectl get pods -n flexpay-staging

# Lister les pods avec plus de details
kubectl get pods -n flexpay-prod -o wide

# Voir les evenements d'un pod (utile pour debug)
kubectl describe pod <pod-name> -n flexpay-prod

# Logs d'un pod
kubectl logs <pod-name> -n flexpay-prod
kubectl logs -f <pod-name> -n flexpay-prod          # temps reel
kubectl logs <pod-name> -n flexpay-prod --tail=100   # 100 dernieres lignes
kubectl logs <pod-name> -n flexpay-prod --previous   # logs du container precedent (crash)

# Logs via le deployment (pas besoin du nom exact du pod)
kubectl logs deployment/flexpay-admin-server -n flexpay-prod --tail=50

# Entrer dans un pod
kubectl exec -it <pod-name> -n flexpay-prod -- sh

# Supprimer un pod (il sera recree par le deployment)
kubectl delete pod <pod-name> -n flexpay-prod
```

### Deployments

```bash
# Lister les deployments
kubectl get deployments -n flexpay-prod

# Details d'un deployment
kubectl describe deployment flexpay-admin-server -n flexpay-prod

# Mettre a jour l'image d'un deployment
kubectl set image deployment/flexpay-admin-server \
  flexpay-admin-server=100.67.178.90:5000/flexpay-admin-server:42 \
  -n flexpay-prod

# Suivre le rollout (attendre que le deploiement soit termine)
kubectl rollout status deployment/flexpay-admin-server -n flexpay-prod --timeout=300s

# Historique des rollouts
kubectl rollout history deployment/flexpay-admin-server -n flexpay-prod

# Rollback au deploiement precedent
kubectl rollout undo deployment/flexpay-admin-server -n flexpay-prod

# Scaler le nombre de replicas
kubectl scale deployment flexpay-admin-server --replicas=2 -n flexpay-prod

# Redemarrer un deployment (recreer les pods)
kubectl rollout restart deployment/flexpay-admin-server -n flexpay-prod
```

### Services

```bash
# Lister les services
kubectl get svc -n flexpay-prod

# Details d'un service (voir NodePort, ClusterIP, etc.)
kubectl describe svc flexpay-admin-server -n flexpay-prod

# Recuperer le NodePort
kubectl get svc flexpay-admin-server -n flexpay-prod -o jsonpath='{.spec.ports[0].nodePort}'

# Recuperer l'IP du node
kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'
```

### ConfigMaps et Secrets

```bash
# Lister les configmaps
kubectl get configmap -n flexpay-prod

# Voir le contenu d'un configmap
kubectl describe configmap flexpay-admin-server-config -n flexpay-prod

# Lister les secrets
kubectl get secrets -n flexpay-prod

# Voir un secret (encode en base64)
kubectl get secret flexpay-admin-server-secrets -n flexpay-prod -o yaml

# Decoder une valeur de secret
kubectl get secret flexpay-admin-server-secrets -n flexpay-prod \
  -o jsonpath='{.data.ADMIN_PASSWORD}' | base64 -d
```

### Appliquer des manifestes K8s

```bash
# Appliquer tous les fichiers du dossier k8s
kubectl apply -f k8s/ -n flexpay-prod

# Appliquer un fichier specifique
kubectl apply -f k8s/deployment.yaml -n flexpay-prod
kubectl apply -f k8s/service.yaml -n flexpay-prod
kubectl apply -f k8s/configmap.yaml -n flexpay-prod
kubectl apply -f k8s/secret.yaml -n flexpay-prod

# Appliquer avec remplacement du REGISTRY_HOST (comme le Jenkinsfile)
sed "s|REGISTRY_HOST|100.67.178.90|g" k8s/deployment.yaml | kubectl apply -f - -n flexpay-prod

# Supprimer des ressources
kubectl delete -f k8s/ -n flexpay-prod
kubectl delete deployment flexpay-admin-server -n flexpay-prod
```

### Debug et diagnostic

```bash
# Evenements recents du cluster
kubectl get events -n flexpay-prod --sort-by='.lastTimestamp'

# Etat de sante d'un pod (probes)
kubectl describe pod <pod-name> -n flexpay-prod | grep -A5 "Conditions"

# Ressources consommees par les pods
kubectl top pods -n flexpay-prod
kubectl top nodes

# Verifier l'acces au registry depuis un pod
kubectl run test --rm -it --image=busybox --restart=Never -- \
  wget -qO- http://100.67.178.90:5000/v2/_catalog

# Voir toutes les ressources d'un namespace
kubectl get all -n flexpay-prod
```

---

## 5. Jenkins (CI/CD)

### Acces

```bash
# Depuis le Mac via Tailscale
# Jenkins UI : http://100.67.178.90:8080

# Mot de passe admin initial (si premier lancement sans JCasC)
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Jenkins CLI (depuis la VM)

```bash
# Telecharger le CLI
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Lister les jobs
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD list-jobs

# Declencher un build
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD build flexpay-admin-server

# Recharger la config Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD reload-configuration

# Installer un plugin
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD install-plugin role-strategy

# Redemarrer Jenkins proprement
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD safe-restart
```

### JCasC (Configuration as Code)

```bash
# Appliquer le JCasC depuis l'UI :
#   Manage Jenkins -> Configuration as Code -> Replace configuration
#   Coller le contenu de jenkins-casc.yaml

# Exporter la config actuelle (utile pour debug) :
#   Manage Jenkins -> Configuration as Code -> View Configuration
```

---

## 6. Tailscale (reseau VPN)

```bash
# Voir l'IP Tailscale de la VM
tailscale ip -4

# Statut de la connexion
tailscale status

# Ping depuis le Mac vers la VM
ping 100.67.178.90
```

---

## 7. Commandes de diagnostic rapide

### Verification complete de la stack

```bash
# 1. Docker Engine
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Registry
curl -s http://localhost:5000/v2/_catalog | python3 -m json.tool

# 3. Minikube
minikube status

# 4. Kubernetes — pods
kubectl get pods -n flexpay-prod -o wide
kubectl get pods -n flexpay-staging -o wide

# 5. Kubernetes — services
kubectl get svc -n flexpay-prod
kubectl get svc -n flexpay-staging

# 6. Jenkins
curl -sf http://localhost:8080/login && echo "Jenkins OK" || echo "Jenkins DOWN"

# 7. Health du microservice (via NodePort)
curl -s http://$(minikube ip):30090/actuator/health | python3 -m json.tool
```

### Script de verification rapide (one-liner)

```bash
echo "=== DOCKER ===" && docker ps --format "{{.Names}}: {{.Status}}" && \
echo "=== REGISTRY ===" && curl -sf http://localhost:5000/v2/_catalog && \
echo "" && echo "=== MINIKUBE ===" && minikube status --format='Host: {{.Host}} | Kubelet: {{.Kubelet}}' && \
echo "=== K8S PODS ===" && kubectl get pods -A --no-headers 2>/dev/null | grep flexpay && \
echo "=== JENKINS ===" && curl -sf http://localhost:8080/login > /dev/null && echo "UP" || echo "DOWN"
```

---

## 8. Raccourcis utiles

| Action | Commande |
|--------|----------|
| Jenkins UI | `http://100.67.178.90:8080` |
| Portainer UI | `https://100.67.178.90:9443` |
| Grafana UI | `http://100.67.178.90:3000` |
| Prometheus UI | `http://100.67.178.90:9090` |
| PgAdmin UI | `http://100.67.178.90:5050` |
| RabbitMQ UI | `http://100.67.178.90:15672` |
| Registry catalog | `http://100.67.178.90:5000/v2/_catalog` |
| Admin Server health | `http://$(minikube ip):30090/actuator/health` |
| Swagger Admin Server | `http://$(minikube ip):30090/swagger-ui.html` |
