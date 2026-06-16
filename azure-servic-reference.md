# Catalogue des Services Microsoft Azure — Avec Coûts
## Guide de référence — Cloud Solutions Architect

> **Note sur les prix** : Les tarifs indiqués sont basés sur la région East US en pay-as-you-go (PAYG). Les prix varient selon la région, les engagements (Reserved Instances : -30% à -72%, Savings Plans : -35%), et l'Azure Hybrid Benefit (-40% avec licences existantes). Consultez le [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) pour des estimations précises.

---

## 1. Compute (Calcul)

### Azure Virtual Machines (VMs)
**Besoin :** Héberger des workloads nécessitant un contrôle total sur l'OS.
**Utilité :** IaaS Windows/Linux pour le lift-and-shift, dev/test, HPC.
**Coût :** Linux dès ~$3.80/mois (B1ls), Windows dès ~$10/mois. Production D2s_v3 : ~$70/mois. VMs GPU/HPC : jusqu'à $125k+/mois. Reserved Instances (1 an) : -30%, (3 ans) : -60%.

### Azure Virtual Machine Scale Sets (VMSS)
**Besoin :** Autoscaling horizontal de groupes de VMs identiques.
**Utilité :** Scaling basé sur métriques. Applications stateless à fort trafic.
**Coût :** Même tarif que les VMs sous-jacentes. Pas de surcoût pour le service VMSS lui-même.

### Azure App Service
**Besoin :** Déployer des web apps / APIs sans gérer l'infrastructure.
**Utilité :** PaaS managé (.NET, Java, Node.js, Python, PHP). CI/CD, SSL, slots.
**Coût :** Free tier (60 CPU min/jour). Basic : $13–$49/mois. Standard : $70–$280/mois. Premium : $57–$2200/mois. Isolated (ASE) : $950+/mois.

### Azure Functions
**Besoin :** Exécuter du code événementiel serverless.
**Utilité :** Facturé à la consommation. HTTP, timer, queue, blob triggers.
**Coût :** Consumption plan : 1M exécutions gratuites/mois + 400k GB-s. Au-delà : $0.20/million d'exécutions + $0.000016/GB-s. Premium plan dès ~$175/mois.

### Azure Container Instances (ACI)
**Besoin :** Exécuter des conteneurs rapidement sans orchestration.
**Utilité :** Conteneurs à la demande pour jobs batch, CI/CD, prototypage.
**Coût :** ~$0.0000125/s par vCPU + $0.0000015/s par Go RAM. ~$35/mois pour 1 vCPU + 1.5 Go RAM en continu.

### Azure Kubernetes Service (AKS)
**Besoin :** Orchestrer des conteneurs à grande échelle.
**Utilité :** Kubernetes managé, control plane gratuit, Azure AD, monitoring.
**Coût :** Control plane gratuit (Free tier) ou $0.10/h (Standard tier avec SLA). On paie les VMs des node pools + storage + networking. Cluster de production typique : $200–$2000+/mois.

### Azure Batch
**Besoin :** Calculs parallèles et HPC à grande échelle.
**Utilité :** Rendu 3D, simulations, transcoding. Pools auto-provisionnés.
**Coût :** Service gratuit. On paie uniquement les VMs et le stockage utilisés.

### Azure Container Apps
**Besoin :** Microservices conteneurisés avec scaling à zéro.
**Utilité :** Serverless containers basé sur KEDA/Dapr. Entre ACI et AKS.
**Coût :** Consumption : $0.000012/vCPU-s + $0.000002/GiB-s. Idle : $0.000002/vCPU-s. ~$50/mois pour un workload léger.

### Azure Service Fabric
**Besoin :** Microservices stateful/stateless.
**Utilité :** Plateforme sous-jacente à de nombreux services Azure.
**Coût :** Service gratuit. On paie les VMs du cluster.

---

## 2. Networking (Réseau)

### Azure Virtual Network (VNet)
**Besoin :** Isoler et segmenter les ressources dans un réseau privé.
**Utilité :** Subnets, NSG, peering, service endpoints.
**Coût :** Gratuit. Peering VNet : ~$0.01/Go (même région), ~$0.02/Go (inter-région).

### Azure Load Balancer
**Besoin :** Distribuer le trafic L4 (TCP/UDP).
**Utilité :** Zone-redundant, SLA 99.99% (Standard).
**Coût :** Basic : gratuit. Standard : ~$18/mois + $0.005/Go pour les règles et données traitées.

### Azure Application Gateway
**Besoin :** Load balancing L7 + WAF + routage URL.
**Utilité :** Reverse proxy managé avec Web Application Firewall.
**Coût :** V2 dès ~$175/mois (fixed) + ~$0.008 par capacity unit. WAF : +$0.144/gateway-hour.

### Azure Front Door
**Besoin :** CDN + Global LB L7 + WAF global.
**Utilité :** Anycast, failover inter-régions, split testing.
**Coût :** Standard : $35/mois + transfert. Premium (WAF) : $330/mois + transfert. Données : $0.01–$0.16/Go.

### Azure VPN Gateway
**Besoin :** VPN site-to-site ou point-to-site vers Azure.
**Utilité :** IPsec/IKE, jusqu'à 10 Gbps.
**Coût :** Basic : ~$27/mois. VpnGw1 : ~$140/mois. VpnGw5 : ~$2500/mois. + transfert sortant.

### Azure ExpressRoute
**Besoin :** Connexion privée dédiée datacenter → Azure.
**Utilité :** Fibre privée, latence prévisible, SLA garanti.
**Coût :** 50 Mbps : ~$55/mois. 1 Gbps : ~$436/mois. 10 Gbps : ~$5500/mois. + coût du partenaire de connectivité.

### Azure DNS
**Besoin :** Héberger des zones DNS.
**Utilité :** DNS managé sur l'infra anycast Azure.
**Coût :** $0.50/zone/mois (premières 25 zones). $0.40/million de requêtes.

### Azure Private Link / Private Endpoint
**Besoin :** Accéder aux PaaS via IP privée dans le VNet.
**Utilité :** Élimine l'exposition Internet.
**Coût :** $0.01/h par private endpoint (~$7.30/mois). + $0.01/Go de données traitées.

### Azure Firewall
**Besoin :** Firewall cloud managé.
**Utilité :** L3-L7, FQDN filtering, threat intelligence, IDPS.
**Coût :** Standard : ~$912/mois + $0.016/Go. Premium : ~$1140/mois + $0.016/Go.

### Azure DDoS Protection
**Besoin :** Protection contre les attaques DDoS.
**Utilité :** Atténuation automatique L3/L4.
**Coût :** Basic : gratuit. Standard : ~$2944/mois (protège jusqu'à 100 ressources).

### Azure Bastion
**Besoin :** Accès RDP/SSH sans ports publics.
**Utilité :** Jump box managé via HTTPS dans le portail.
**Coût :** Basic : ~$139/mois. Standard : ~$330/mois.

### Azure Virtual WAN
**Besoin :** Hub réseau managé à grande échelle.
**Utilité :** Unifie VPN, ExpressRoute, SD-WAN, peering.
**Coût :** Hub : $0.25/h (~$183/mois). + coûts de connexion par type.

### Azure Network Watcher
**Besoin :** Diagnostiquer et surveiller la connectivité.
**Utilité :** IP flow verify, packet capture, NSG flow logs.
**Coût :** Network Diagnostic Checks : 1000 gratuits/mois, puis $1/1000 checks. NSG Flow Logs : $0.50/Go collecté.

---

## 3. Storage (Stockage)

### Azure Blob Storage
**Besoin :** Stocker des objets non structurés à grande échelle.
**Utilité :** Hot/Cool/Cold/Archive. Versioning, lifecycle management.
**Coût :** Hot : $0.018/Go/mois. Cool : $0.010/Go. Cold : $0.0045/Go. Archive : $0.002/Go. Opérations : $0.004–$0.50/10k selon le tier.

### Azure Data Lake Storage Gen2
**Besoin :** Big Data et analytique massive.
**Utilité :** Namespace hiérarchique sur Blob Storage. Compatible Hadoop/Spark.
**Coût :** Similaire à Blob Storage. Hot : $0.018/Go/mois. + $0.065/10k opérations d'écriture.

### Azure Files
**Besoin :** Partages de fichiers SMB/NFS cloud.
**Utilité :** Remplacement de file servers on-prem. Azure File Sync.
**Coût :** Premium : ~$0.16/Go/mois (provisioned). Transaction-optimized : $0.06/Go. Hot : $0.025/Go. Cool : $0.015/Go.

### Azure Queue Storage
**Besoin :** Messaging asynchrone simple.
**Utilité :** Alternative légère à Service Bus.
**Coût :** $0.045/Go/mois. Opérations : $0.004/10k. Extrêmement économique.

### Azure Table Storage
**Besoin :** NoSQL key-value simple à bas coût.
**Utilité :** Données structurées schemaless.
**Coût :** $0.045/Go/mois. $0.00036/10k transactions.

### Azure Disk Storage
**Besoin :** Disques persistants pour VMs.
**Utilité :** HDD Standard, SSD Standard, SSD Premium, Ultra Disk.
**Coût :** HDD Standard (S10/128 Go) : ~$5.89/mois. SSD Premium (P30/1 To) : ~$122/mois. Ultra Disk : dès $0.12/Go/mois + $0.000084/IOPS.

### Azure NetApp Files
**Besoin :** NAS hautes performances (SAP, HPC, DB).
**Utilité :** Sub-millisecond latency, NFS/SMB.
**Coût :** Standard : ~$0.15/Go/mois. Premium : ~$0.30/Go. Ultra : ~$0.45/Go.

---

## 4. Databases (Bases de données)

### Azure SQL Database
**Besoin :** Base relationnelle managée compatible SQL Server.
**Utilité :** Auto-tuning, HA, serverless tier.
**Coût :** DTU Basic (5 DTU) : ~$5/mois. Standard S0 (10 DTU) : ~$15/mois. vCore General Purpose (2 vCores) : ~$370/mois. Serverless : $0.5218/vCore-heure. Hybrid Benefit : -55%.

### Azure SQL Managed Instance
**Besoin :** Migration lift-and-shift SQL Server on-prem.
**Utilité :** SQL Server complet en PaaS (Agent, CLR, cross-DB queries).
**Coût :** General Purpose (4 vCores) : ~$380/mois. Business Critical (4 vCores) : ~$1470/mois. Hybrid Benefit applicable.

### Azure Cosmos DB
**Besoin :** NoSQL distribuée globalement avec latence <10ms.
**Utilité :** Multi-modèle. 5 niveaux de cohérence. Multi-region writes.
**Coût :** Provisioned : ~$5.84/100 RU/s/mois. Serverless : $0.25/million RU. Free tier : 1000 RU/s + 25 Go gratuits. Storage : $0.25/Go/mois. Database Savings Plan : -35%.

### Azure Database for PostgreSQL
**Besoin :** PostgreSQL managé.
**Utilité :** Flexible Server, HA zone-redundant, extensions.
**Coût :** Burstable B1ms : ~$13/mois. General Purpose (2 vCores) : ~$125/mois. Storage : $0.115/Go/mois.

### Azure Database for MySQL
**Besoin :** MySQL managé.
**Utilité :** Flexible Server, HA, read replicas.
**Coût :** Burstable B1ms : ~$13/mois. General Purpose (2 vCores) : ~$125/mois.

### Azure Cache for Redis
**Besoin :** Cache in-memory.
**Utilité :** Caching, sessions, pub/sub, leaderboards.
**Coût :** Basic C0 (250 Mo) : ~$16/mois. Standard C1 (1 Go) : ~$41/mois. Premium P1 (6 Go) : ~$224/mois. Enterprise : ~$500+/mois.

---

## 5. Identity & Security

### Microsoft Entra ID (ex Azure AD)
**Besoin :** Gestion centralisée des identités.
**Utilité :** SSO, MFA, Conditional Access, RBAC, B2B/B2C.
**Coût :** Free : inclus avec Azure/M365. P1 : $6/utilisateur/mois. P2 (+ PIM + Identity Protection) : $9/utilisateur/mois. Entra Suite : $12/utilisateur/mois.

### Azure Key Vault
**Besoin :** Stocker secrets, clés, certificats.
**Utilité :** HSM-backed, intégration native.
**Coût :** Secrets : $0.03/10k opérations. Keys (Software) : $0.03/10k opérations. HSM-backed keys : ~$1/clé/mois + $0.03/10k opérations. Certificates : ~$3/renouvellement.

### Microsoft Defender for Cloud
**Besoin :** Posture de sécurité multi-cloud.
**Utilité :** CSPM + CWPP. Secure Score, conformité.
**Coût :** CSPM gratuit (basique). Defender plans : VMs $15/serveur/mois, SQL $15/instance/mois, Storage $15/compte/mois, App Service $15/instance/mois, Containers $7/vCore/mois.

### Microsoft Sentinel
**Besoin :** SIEM/SOAR cloud-native.
**Utilité :** Détection ML, playbooks, hunting KQL.
**Coût :** Pay-as-you-go : ~$2.46/Go ingéré/jour. Commitment tiers : 100 Go/jour à ~$123/jour (-50% vs PAYG). Les coûts Log Analytics sont inclus.

### Azure Managed HSM
**Besoin :** HSM dédié single-tenant.
**Utilité :** FIPS 140-2 Level 3. Exigences réglementaires.
**Coût :** ~$3/heure par pool HSM (~$2190/mois).

---

## 6. AI & Machine Learning

### Azure OpenAI Service
**Besoin :** Intégrer GPT-4, DALL-E, Whisper.
**Utilité :** API OpenAI avec sécurité Azure.
**Coût :** GPT-4o : ~$2.50/M tokens input, ~$10/M output. GPT-4o-mini : ~$0.15/M input, ~$0.60/M output. DALL-E 3 : $0.04–$0.12/image. Batch API : -50%.

### Azure Machine Learning
**Besoin :** Plateforme MLOps complète.
**Utilité :** AutoML, pipelines, model registry, endpoints.
**Coût :** Pas de surcoût pour le workspace. On paie le compute : Training clusters (VMs), managed endpoints ($0.37/h pour DS3_v2), storage.

### Azure AI Services (ex Cognitive Services)
**Besoin :** IA pré-entraînée via APIs.
**Utilité :** Vision, Language, Speech, Decision.
**Coût :** Free tiers généreux (5k–30k transactions/mois). Standard : Vision $1/1k images. Language $2/1k records. Speech STT $1/heure audio. Traduction $10/M caractères.

### Azure AI Search (ex Cognitive Search)
**Besoin :** Recherche full-text enrichie par l'IA (RAG).
**Utilité :** Extraction d'entités, OCR, traduction.
**Coût :** Free : 50 Mo. Basic : ~$73/mois. Standard S1 : ~$245/mois. Standard S3 : ~$985/mois.

---

## 7. Analytics & Big Data

### Azure Synapse Analytics
**Besoin :** Data warehousing + Spark + pipelines unifiés.
**Utilité :** Serverless SQL, Spark pools, Data Explorer intégré.
**Coût :** Serverless SQL : $5/To de données scannées. Dedicated SQL Pool (DW100c) : ~$1.20/h. Spark pool : ~$0.16/vCore-heure.

### Azure Databricks
**Besoin :** Plateforme Lakehouse collaborative.
**Utilité :** Delta Lake, MLflow, Unity Catalog.
**Coût :** Standard : $0.07/DBU (Jobs). Premium : $0.22/DBU (Jobs). + coût des VMs Azure sous-jacentes. Cluster typique : $300–$3000+/mois.

### Azure Data Factory (ADF)
**Besoin :** Orchestration ETL/ELT à grande échelle.
**Utilité :** 100+ connecteurs, mapping data flows.
**Coût :** Orchestration : $1/1k activity runs. Data flows : $0.27/vCore-heure. Pipeline : $0.25/1k runs. Self-hosted IR : gratuit.

### Azure Stream Analytics
**Besoin :** Analyse de flux en temps réel.
**Utilité :** SQL-like sur Event Hubs, IoT Hub.
**Coût :** Standard : $0.11/Streaming Unit/heure (~$80/SU/mois). 1–6 SU minimum pour la production.

### Azure Data Explorer (ADX / Kusto)
**Besoin :** Analytique temps réel sur logs et time-series.
**Utilité :** KQL, requêtes ad-hoc sur téraoctets.
**Coût :** Dev/test (D11_v2) : ~$110/mois. Production (D14_v2) : ~$445/mois par instance. + stockage.

### Microsoft Fabric
**Besoin :** Plateforme analytique SaaS unifiée.
**Utilité :** Data Factory + Synapse + Power BI sous un toit. OneLake.
**Coût :** F2 : ~$263/mois. F64 : ~$8400/mois. Pay-as-you-go sur capacité CU.

### Microsoft Purview
**Besoin :** Gouvernance et catalogage des données.
**Utilité :** Data catalog, lineage, classification.
**Coût :** Data Map : $0.20/scan-heure. Data Estate Insights : $10/reader/mois. Data Policy : inclus.

### Power BI
**Besoin :** Visualisation et BI self-service.
**Utilité :** Dashboards, rapports, NLP Q&A.
**Coût :** Pro : $10/utilisateur/mois. Premium Per User : $20/utilisateur/mois. Premium (embedded/capacity) : dès $4995/mois.

---

## 8. Integration & Messaging

### Azure Service Bus
**Besoin :** Messaging d'entreprise fiable.
**Utilité :** Queues et topics. Sessions, dead-lettering, transactions.
**Coût :** Basic : $0.05/M opérations. Standard : $10/mois base + $0.025/M opérations. Premium (1 MU) : ~$668/mois (resources dédiées).

### Azure Event Hubs
**Besoin :** Ingérer des millions d'événements/seconde.
**Utilité :** Streaming Big Data, compatible Kafka.
**Coût :** Basic : $0.015/throughput unit/h + $0.028/M events. Standard : $0.03/TU/h + $0.028/M events. Dedicated : ~$6/CU/h (~$4380/mois).

### Azure Event Grid
**Besoin :** Routing événementiel serverless.
**Utilité :** Événements Azure natifs + custom topics.
**Coût :** Premiers 100k opérations/mois : gratuit. Au-delà : $0.60/M opérations. Très économique.

### Azure Logic Apps
**Besoin :** Automatisation de workflows low-code.
**Utilité :** 400+ connecteurs, orchestration visuelle.
**Coût :** Consumption : ~$0.000025/action (standard) + ~$0.001/connecteur enterprise. Standard plan : dès $151/mois.

### Azure API Management (APIM)
**Besoin :** Gateway API : sécurité, rate limiting, analytics.
**Utilité :** Developer portal, policies, multi-backend.
**Coût :** Consumption : $3.50/M appels. Developer : ~$49/mois. Basic : ~$152/mois. Standard : ~$685/mois. Premium : ~$2785/mois par unité.

---

## 9. DevOps & Developer Tools

### Azure DevOps Services
**Besoin :** Cycle de vie complet du développement.
**Utilité :** Boards, Repos, Pipelines, Test Plans, Artifacts.
**Coût :** Basic : gratuit (5 premiers utilisateurs). Au-delà : $6/utilisateur/mois. Pipelines : 1 job parallèle gratuit, +$40/mois par job supplémentaire.

### Azure Container Registry (ACR)
**Besoin :** Stocker les images de conteneurs.
**Utilité :** Registry privé, geo-replication, vulnerability scanning.
**Coût :** Basic : ~$5/mois (10 Go). Standard : ~$20/mois (100 Go). Premium : ~$50/mois (500 Go, geo-replication).

### Azure DevTest Labs
**Besoin :** Environnements de dev/test contrôlés.
**Utilité :** Auto-shutdown, quotas, formules.
**Coût :** Service gratuit. On paie les VMs et le stockage utilisés.

---

## 10. Management & Governance

### Azure Policy
**Besoin :** Conformité et gouvernance des ressources.
**Utilité :** Deny, audit, modify, deployIfNotExists.
**Coût :** Gratuit pour les ressources Azure. Guest Configuration VMs : $6/serveur/mois.

### Azure Monitor
**Besoin :** Observabilité complète.
**Utilité :** Métriques, logs, alertes, workbooks.
**Coût :** Métriques de plateforme : gratuites. Logs ingérés : $2.76/Go (PAYG). Commitment : 100 Go/jour à ~$196/jour. Alertes : ~$0.10/règle de métrique/mois.

### Azure Application Insights
**Besoin :** APM pour applications web.
**Utilité :** Distributed tracing, anomaly detection, live metrics.
**Coût :** Premiers 5 Go/mois : gratuits. Au-delà : $2.76/Go (mêmes tarifs Log Analytics).

### Azure Arc
**Besoin :** Gestion Azure pour on-prem et multi-cloud.
**Utilité :** Serveurs, K8s, SQL Server projetés dans Azure.
**Coût :** Arc-enabled servers : contrôle gratuit. Azure Policy Guest Config : $6/serveur/mois. Arc-enabled SQL : ESU via Arc inclus. Arc-enabled K8s : GitOps $2/vCPU/mois.

### Azure Cost Management + Billing
**Besoin :** Optimisation des dépenses cloud.
**Utilité :** Analyses, budgets, alertes, recommandations.
**Coût :** Gratuit pour les ressources Azure. AWS/GCP connector : $0.01/Go de données de facturation.

---

## 11. Migration

### Azure Migrate
**Besoin :** Évaluer et migrer vers Azure.
**Utilité :** Discovery, assessment, migration de VMs et DBs.
**Coût :** Gratuit (outil). On paie l'infrastructure cible.

### Azure Database Migration Service (DMS)
**Besoin :** Migrer des bases de données avec downtime minimal.
**Utilité :** Online migration SQL Server, PostgreSQL, MySQL, MongoDB.
**Coût :** Standard : gratuit. Premium (4 vCores) : ~$0.404/h (~$295/mois).

### Azure Site Recovery (ASR)
**Besoin :** Disaster Recovery.
**Utilité :** Réplication, failover automatisé, RPO de secondes.
**Coût :** $25/instance protégée/mois (premières 31 jours gratuites).

---

## 12. Hybrid & Multi-Cloud

### Azure Stack HCI
**Besoin :** Azure dans le datacenter on-prem.
**Utilité :** HCI avec AKS, AVD, Azure Arc.
**Coût :** ~$10/cœur physique/mois. + coûts hardware du serveur.

### Azure Stack Hub
**Besoin :** Cloud privé déconnecté.
**Utilité :** APIs Azure en datacenter souverain.
**Coût :** Modèle capacity-based ou pay-as-you-use. Hardware : $200k+ pour un rack minimum.

---

## 13. IoT

### Azure IoT Hub
**Besoin :** Connecter et gérer des devices IoT.
**Utilité :** Messages bidirectionnels, device twins, DPS.
**Coût :** Free : 8k messages/jour. S1 : ~$25/mois (400k msg/jour). S2 : ~$250/mois (6M msg/jour). S3 : ~$2500/mois (300M msg/jour).

### Azure IoT Central
**Besoin :** Solution IoT SaaS clé en main.
**Utilité :** Templates, dashboards, règles. Pas d'expertise cloud requise.
**Coût :** Standard ST0 : gratuit (2 devices). ST1 : ~$0.80/device/mois. ST2 : ~$0.40/device/mois.

### Azure Digital Twins
**Besoin :** Jumeaux numériques pour smart buildings, industrie 4.0.
**Utilité :** Graphe DTDL, simulation.
**Coût :** $1/M opérations. $2.50/M messages. $0.10/M requêtes.

---

## 14. Media & Communication

### Azure Communication Services (ACS)
**Besoin :** Voix, vidéo, chat, SMS dans les apps.
**Utilité :** APIs de communication en temps réel.
**Coût :** VoIP : $0.004/participant/min. PSTN : $0.008/min. Chat : $0.0008/msg. SMS : $0.0075/msg.

### Azure CDN
**Besoin :** Distribuer du contenu au plus près des utilisateurs.
**Utilité :** Cache global, offload serveur.
**Coût :** Microsoft Standard : premiers 5 Go gratuits. $0.081/Go (premiers 10 To). Verizon/Akamai : $0.087/Go.

---

## 15. Desktop

### Azure Virtual Desktop (AVD)
**Besoin :** VDI managé Windows multi-session.
**Utilité :** DaaS, RemoteApp, FSLogix, Conditional Access.
**Coût :** Service gratuit (si licence M365/Win E3+). On paie les VMs : D4s_v3 (~$140/mois) pour 10–12 utilisateurs. + stockage FSLogix.

### Windows 365 Cloud PC
**Besoin :** PC Windows individuel persistant dans le cloud.
**Utilité :** Plus simple qu'AVD, pricing fixe.
**Coût :** 2 vCPU / 4 Go / 128 Go : ~$32/utilisateur/mois. 8 vCPU / 32 Go / 512 Go : ~$158/utilisateur/mois.

---

## Tableau récapitulatif des coûts d'entrée

| Service | Free Tier | Entrée Production | Usage Typique |
|---------|-----------|-------------------|---------------|
| VMs | Non | ~$70/mois (D2s_v3) | $200–$2000/mois |
| App Service | Oui | $70/mois (S1) | $140–$560/mois |
| Functions | Oui (1M exec) | $0 (Consumption) | $10–$200/mois |
| AKS | Oui (control plane) | ~$200/mois | $500–$5000/mois |
| Container Apps | Oui (scaling à zéro) | ~$50/mois | $100–$1000/mois |
| SQL Database | Non | ~$5/mois (Basic) | $150–$800/mois |
| Cosmos DB | Oui (1000 RU/s) | ~$24/mois (400 RU/s) | $100–$2000/mois |
| PostgreSQL | Non | ~$13/mois (B1ms) | $125–$500/mois |
| Redis Cache | Non | ~$16/mois (C0) | $41–$224/mois |
| Service Bus | Non | ~$10/mois (Standard) | $10–$668/mois |
| Event Hubs | Non | ~$22/mois (1 TU) | $50–$500/mois |
| API Management | Oui (Consumption) | ~$49/mois (Dev) | $152–$685/mois |
| Blob Storage | Oui (5 Go) | $0.018/Go/mois | $10–$500/mois |
| Azure Monitor | Oui (métriques) | $2.76/Go logs | $50–$1000/mois |
| Sentinel | Non | ~$2.46/Go/jour | $500–$10k/mois |
| Azure OpenAI | Non | Variable par token | $100–$10k+/mois |
| Databricks | Non | $0.07–$0.22/DBU | $300–$5000/mois |

---

## Architecture de référence : Application distribuée microservices sur Azure

Voir le diagramme d'architecture dans le chat pour la vue visuelle complète.

### Composants de l'architecture

**Couche Client & Ingress**
- Azure Front Door : point d'entrée global, WAF, routage géographique
- Azure CDN : cache des assets statiques
- Azure API Management : gateway API, rate limiting, authentification

**Couche Application (Microservices)**
- Azure Kubernetes Service (AKS) : orchestration des microservices conteneurisés
- Azure Container Apps : services événementiels avec scaling à zéro
- Azure Functions : traitements serverless (webhooks, notifications)

**Couche Data**
- Azure SQL Database : données transactionnelles (commandes, utilisateurs)
- Azure Cosmos DB : données NoSQL (catalogue produits, sessions, panier)
- Azure Cache for Redis : cache distribué, sessions, rate limiting
- Azure Blob Storage : fichiers, images, documents

**Couche Messaging & Événements**
- Azure Service Bus : communication inter-services fiable (commandes, compensations SAGA)
- Azure Event Hubs : streaming d'événements (clickstream, audit, CDC)
- Azure Event Grid : événements système (blob created, resource changed)

**Couche Observabilité**
- Azure Monitor + Log Analytics : métriques et logs centralisés
- Application Insights : APM, distributed tracing
- Microsoft Sentinel : SIEM/SOAR pour la sécurité

**Couche Sécurité & Identité**
- Microsoft Entra ID : authentification et autorisation
- Azure Key Vault : secrets et certificats
- Azure Private Link : connectivité privée vers les PaaS
- Microsoft Defender for Cloud : CSPM/CWPP

**Couche CI/CD**
- Azure DevOps / GitHub Actions : pipelines CI/CD
- Azure Container Registry : registry d'images Docker
- Azure Policy : governance as code

### Estimation de coût mensuel (production)

| Couche | Service | Configuration | Coût estimé |
|--------|---------|---------------|-------------|
| Ingress | Front Door Premium | 1 profil + WAF | ~$365 |
| Ingress | API Management | Standard (1 unit) | ~$685 |
| Compute | AKS (3 nodes D4s_v3) | 3×4 vCPU, 16 Go | ~$420 |
| Compute | Container Apps | 2 apps, moderate | ~$100 |
| Compute | Functions | Consumption | ~$20 |
| Data | SQL Database (S2) | 50 DTU | ~$75 |
| Data | Cosmos DB | 1000 RU/s + 50 Go | ~$58 |
| Data | Redis (C1 Standard) | 1 Go | ~$41 |
| Data | Blob Storage | 500 Go Hot | ~$10 |
| Messaging | Service Bus Standard | ~2M msg/mois | ~$12 |
| Messaging | Event Hubs | 1 TU | ~$22 |
| Security | Entra ID P1 | 50 users | ~$300 |
| Security | Key Vault | Standard | ~$5 |
| Observability | Monitor + App Insights | 50 Go logs/mois | ~$140 |
| DevOps | DevOps + ACR Standard | 10 users | ~$80 |
| **TOTAL** | | | **~$2,333/mois** |

> **Optimisations possibles :** Reserved Instances (VMs : -30% à -60%), Azure Hybrid Benefit (-55% SQL), Database Savings Plan (-35%), autoscaling agressif, spot instances pour les jobs batch. Un cluster bien optimisé peut descendre à **~$1,400–$1,700/mois**.
