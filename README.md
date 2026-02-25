#  DevOps Case Study - MERN Stack & Python ETL Deployment

Bu proje, bir **MERN (MongoDB, Express, React, Node.js) stack** uygulaması ve bir **Python ETL** script'ini konteynerleştirme, orkestrasyon ve bulut dağıtımı ile production ortamına hazır hale getirir.

#  DevOps Technical Case Study
**Aday:** Muhammed Mirza Özkahraman  
**Rol:** DevOps Engineer Case Study  
**Tarih:** 25 Şubat 2026  
**Github:** [MirzaOzkahraman/BaykarDevOpsCase](https://github.com/MirzaOzkahraman/BaykarDevOpsCase)
---

##  İçindekiler

1. [Mimari Genel Bakış](#1-mimari-genel-bakış)
2. [Proje Yapısı](#2-proje-yapısı)
3. [Dockerfiles & Docker Compose](#3-dockerfiles--docker-compose)
4. [Kubernetes Yapılandırması](#4-kubernetes-yapılandırması)
5. [CI/CD Pipeline](#5-cicd-pipeline)
6. [Altyapı Kod Betikleri (Terraform)](#6-altyapı-kod-betikleri-terraform)
7. [Dağıtım Süreci](#7-dağıtım-süreci)
8. [İzleme ve Loglama](#8-izleme-ve-loglama)
9. [Karşılaşılan Zorluklar ve Çözümler](#9-karşılaşılan-zorluklar-ve-çözümler)
10. [Hızlı Başlangıç (Lokal Test)](#10-hızlı-başlangıç-lokal-test)

---

## 1. Mimari Genel Bakış

```
                    ┌──────────────────────────────────────────────────────────┐
                    │                     AWS Cloud                            │
                    │  ┌────────────────────────────────────────────────────┐  │
                    │  │                 VPC (10.0.0.0/16)                  │  │
                    │  │                                                    │  │
                    │  │  ┌──────────────┐        ┌───────────────────────┐ │  │
                    │  │  │ Public Subnet│        │    Private Subnet     │ │  │
  Internet ──► NLB ─►  │  │              │        │  ┌─────────────────┐  │ │  │
                    │  │  │  Internet GW │        │  │   EKS Cluster   │  │ │  │
                    │  │  │  NAT Gateway │        │  │                 │  │ │  │
                    │  │  └──────────────┘        │  │  ┌───────────┐  │  │ │  │
                    │  │                          │  │  │ Frontend  │  │  │ │  │
                    │  │                          │  │  │ (Nginx)   │  │  │ │  │
                    │  │                          │  │  ├───────────┤  │  │ │  │
                    │  │                          │  │  │ Backend   │  │  │ │  │
                    │  │                          │  │  │ (Node.js) │  │  │ │  │
                    │  │                          │  │  ├───────────┤  │  │ │  │
                    │  │                          │  │  │ MongoDB   │  │  │ │  │
                    │  │                          │  │  │(StatefulS)│  │  │ │  │
                    │  │                          │  │  ├───────────┤  │  │ │  │
                    │  │                          │  │  │Python ETL │  │  │ │  │
                    │  │                          │  │  │ (CronJob) │  │  │ │  │
                    │  │                          │  │  └───────────┘  │  │ │  │
                    │  │                          │  └─────────────────┘  │ │  │
                    │  │                          └───────────────────────┘ │  │
                    │  └────────────────────────────────────────────────────┘  │
                    │                                                          │
                    │  ┌──────────┐  ┌─────────────┐  ┌──────────────────┐     │
                    │  │   ECR    │  │  CloudWatch │  │  Prometheus +    │     │
                    │  │ (3 Repo) │  │    Logs     │  │   Grafana        │     │
                    │  └──────────┘  └─────────────┘  └──────────────────┘     │
                    └──────────────────────────────────────────────────────────┘

                    ┌──────────────────────────────────────────────────────────┐
                    │              GitHub Actions CI/CD                        │
                    │  ┌──────────────────┐   ┌──────────────────────────┐     │
                    │  │  main.yml        │   │  deploy-python.yml       │     │
                    │  │  (MERN Pipeline) │   │  (Python Pipeline)       │     │
                    │  │  mern-project/** │   │  python-project/**       │     │
                    │  └──────────────────┘   └──────────────────────────┘     │
                    └──────────────────────────────────────────────────────────┘
```

**Temel tasarım kararları:**
- **VPC**: Public/Private subnet mimarisi. Worker node'lar private subnet'te çalışır (güvenlik).
- **EKS**: Her iki proje aynı cluster'ı paylaşır, tek namespace (`mern-app`) altında izole edilir.
- **ECR**: Her proje için ayrı repository (mern-app/frontend, mern-app/backend, mern-python-etl).
- **CI/CD**: Path filtering ile bağımsız pipeline'lar — projeler birbirini etkilemez.

---

## 2. Proje Yapısı

```
.
├── mern-project/                        # MERN Stack Uygulaması
│   ├── client/                          # React Frontend
│   │   ├── Dockerfile                   # Multi-stage build (Node → Nginx)
│   │   ├── nginx.conf                   # Nginx konfigürasyonu
│   │   ├── .dockerignore
│   │   └── src/                         # React kaynak kodu
│   │
│   ├── server/                          # Node.js/Express Backend
│   │   ├── Dockerfile                   # Optimize edilmiş Node.js image
│   │   ├── .dockerignore
│   │   ├── server.mjs                   # Express API server
│   │   └── routes/                      # REST API endpoint'leri
│   │
│   ├── docker-compose.yml               # Lokal test ortamı
│   ├── mongo-init.js                    # MongoDB seed data
│   │
│   ├── terraform/                       # MERN Terraform (modüler)
│   │   ├── main.tf                      # Provider + modül çağrıları
│   │   ├── variables.tf                 # Giriş değişkenleri
│   │   ├── outputs.tf                   # Çıktı değerleri
│   │   ├── terraform.tfvars             # Varsayılan değerler
│   │   └── modules/
│   │       ├── vpc/                     # VPC, Subnet, IGW, NAT
│   │       ├── eks/                     # EKS Cluster, Node Group
│   │       ├── ecr/                     # ECR Repository'ler
│   │       └── security-groups/         # Security Group kuralları
│   │
│   ├── k8s/                             # Kubernetes Manifest'leri
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml               # Ortam değişkenleri
│   │   ├── secrets.yaml                 # Hassas veriler
│   │   ├── backend-deployment.yaml      # Backend (2 replika)
│   │   ├── backend-service.yaml         # ClusterIP
│   │   ├── backend-hpa.yaml             # Otomatik ölçeklendirme
│   │   ├── frontend-deployment.yaml     # Frontend (2 replika)
│   │   ├── frontend-service.yaml        # LoadBalancer
│   │   ├── frontend-hpa.yaml            # Otomatik ölçeklendirme
│   │   ├── mongodb-statefulset.yaml     # Kalıcı depolama
│   │   ├── mongodb-service.yaml         # Headless Service
│   │   └── monitoring/                  # Prometheus + Grafana
│   │
│   └── .github/workflows/main.yml       # MERN CI/CD Pipeline
│
├── python-project/                      # Python ETL Script
│   ├── ETL.py                           # Ana ETL script
│   ├── Dockerfile                       # Python slim image
│   ├── .dockerignore
│   ├── terraform/                       # Python'a özel Terraform
│   │   ├── main.tf                      # Data source ile EKS referansı
│   │   ├── variables.tf
│   │   ├── ecr.tf                       # mern-python-etl ECR repo
│   │   └── outputs.tf
│   ├── k8s/                             # Python K8s Manifest'leri
│   │   └── python-cronjob.yaml          # CronJob (her 1 saatte bir)
│   └── .github/workflows/
│       └── deploy-python.yml            # Python CI/CD Pipeline
│
└── README.md                            # Bu dosya
```

---

## 3. Dockerfiles & Docker Compose

### 3.1 Frontend Dockerfile (Multi-Stage Build)

**Dosya:** `mern-project/client/Dockerfile`

| Stage | Base Image | Amaç |
|-------|-----------|------|
| **Builder** | `node:18-alpine` | `npm ci` + `npm run build` ile React derleme |
| **Production** | `nginx:1.25-alpine` | Static dosyaları Nginx ile serve etme |

**Nginx konfigürasyonu** (`nginx.conf`):
- **SPA Routing**: `try_files $uri $uri/ /index.html` — React Router desteği
- **Reverse Proxy**: `/record` ve `/healthcheck` istekleri backend'e proxy edilir
- **Gzip**: JS, CSS, JSON dosyaları sıkıştırılır
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, XSS-Protection
- **Cache**: Statik dosyalar için 1 yıl cache, `immutable` header

### 3.2 Backend Dockerfile

**Dosya:** `mern-project/server/Dockerfile`

- **Base Image**: `node:18-alpine` (küçük boyut)
- **dumb-init**: PID 1 sinyal yönetimi (SIGTERM/SIGINT düzgün handle edilir)
- **Non-root user**: `node` kullanıcısı ile çalışır (güvenlik)
- **Production deps**: `npm ci --omit=dev` ile sadece production bağımlılıkları
- **Healthcheck**: 30 saniyede bir `/healthcheck` endpoint kontrolü

### 3.3 Python ETL Dockerfile

**Dosya:** `python-project/Dockerfile`

- **Base Image**: `python:3.12-slim` (minimal boyut)
- **Non-root user**: Özel `etl` kullanıcısı oluşturulur
- **Bağımlılık**: Sadece `requests` kütüphanesi
- **Entrypoint**: `python ETL.py`

### 3.4 Docker Compose (Lokal Test)

**Dosya:** `mern-project/docker-compose.yml`

Tüm MERN stack'i lokal ortamda tek komutla ayağa kaldırır:

```bash
cd mern-project
docker-compose up --build -d
```

| Servis | Port | Detay |
|--------|------|-------|
| **frontend** | `3000:80` | Nginx → React build |
| **backend** | `5050:5050` | Express API |
| **mongodb** | `27017:27017` | Mongo 7, seed data ile |

**Özellikler:**
- `depends_on` + `healthcheck` ile sıralı başlatma (MongoDB hazır → Backend → Frontend)
- `mongodb_data` volume ile veri kalıcılığı
- `mongo-init.js` ile 5 örnek kayıt otomatik eklenir
- Kaynak limitleri (CPU/Memory) tanımlanmış

---

## 4. Kubernetes Yapılandırması

Tüm manifest'ler `mern-project/k8s/` altındadır. Tek namespace: `mern-app`.

### 4.1 MERN Stack Bileşenleri

| Manifest | Kind | Detay |
|----------|------|-------|
| `namespace.yaml` | Namespace | `mern-app` — tüm kaynaklar izole |
| `configmap.yaml` | ConfigMap | NODE_ENV, PORT, MONGO_DATABASE |
| `secrets.yaml` | Secret | ATLAS_URI, MONGO_ROOT_PASSWORD (base64) |
| `backend-deployment.yaml` | Deployment | 2 replika, readiness/liveness probe (`/healthcheck`) |
| `backend-service.yaml` | Service | ClusterIP (sadece cluster içi) |
| `frontend-deployment.yaml` | Deployment | 2 replika, Nginx health probe |
| `frontend-service.yaml` | Service | LoadBalancer (NLB, internet-facing) |
| `mongodb-statefulset.yaml` | StatefulSet | 10Gi PVC (gp2 EBS), root credentials |
| `mongodb-service.yaml` | Service | Headless (clusterIP: None) — DNS keşfi |
| `backend-hpa.yaml` | HPA | CPU %70 → scale up, 2-10 pod |
| `frontend-hpa.yaml` | HPA | CPU %70 → scale up, 2-10 pod |

### 4.2 Python ETL CronJob

| Manifest | Kind | Detay |
|----------|------|-------|
| `python-cronjob.yaml` | CronJob | `schedule: "0 * * * *"` (her saat başı) |

**CronJob özellikleri:**
- **Concurrency**: `Forbid` — önceki job tamamlanmadan yenisi başlamaz
- **Retry**: `backoffLimit: 2` — başarısız olursa 2 kez tekrar dener
- **Cleanup**: `ttlSecondsAfterFinished: 3600` — 1 saat sonra otomatik temizlenir
- **History**: Son 3 başarılı + 3 başarısız job saklanır

### 4.3 Monitoring (Prometheus + Grafana)

`k8s/monitoring/` altında:

| Bileşen | Amaç |
|---------|------|
| **Prometheus** | Kubernetes node, pod ve service metriklerini otomatik keşfeder (RBAC ile) |
| **Grafana** | Prometheus'u veri kaynağı olarak kullanır, LoadBalancer ile erişilir |

---

## 5. CI/CD Pipeline

### 5.1 MERN Pipeline (`mern-project/.github/workflows/main.yml`)

**Tetikleyici:** `push` to `main` — sadece `mern-project/**` path'i değiştiğinde.

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Build & Push   │────►│    Terraform     │────►│  Deploy to EKS  │
│  Docker Images  │     │  Plan & Apply    │     │  Rolling Update │
│  → ECR          │     │  (infra)         │     │  + Verify       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

| Job | Adımlar |
|-----|---------|
| **Build & Push** | Checkout → AWS Credentials → ECR Login → Build Frontend → Build Backend → Push (SHA tag + latest) |
| **Terraform** | Init → Plan → Apply (sadece main push) |
| **Deploy** | kubectl config → Apply manifests → `kubectl set image` → `rollout status` doğrulama |

### 5.2 Python Pipeline (`python-project/.github/workflows/deploy-python.yml`)

**Tetikleyici:** `push` to `main` — sadece `python-project/**` path'i değiştiğinde.

```
┌─────────────────┐     ┌──────────────────────┐
│  Build & Push   │────►│  Deploy CronJob      │
│  Python Image   │     │  to EKS              │
│  → ECR          │     │  (sed + kubectl)     │
└─────────────────┘     └──────────────────────┘
```

**İzolasyon garantisi:** MERN değişikliği Python pipeline'ını tetiklemez, Python değişikliği MERN pipeline'ını tetiklemez.

### 5.3 Gerekli GitHub Secrets

| Secret | Açıklama |
|--------|----------|
| `AWS_ACCESS_KEY_ID` | AWS IAM erişim anahtarı |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM gizli anahtar |

---

## 6. Altyapı Kod Betikleri (Terraform)

### 6.1 MERN Terraform (`mern-project/terraform/`)

**Modüler yapı** — her bileşen kendi modülünde:

| Modül | Dosyalar | Kaynaklar |
|-------|----------|-----------|
| `modules/vpc/` | main.tf, variables.tf, outputs.tf | VPC, 2x Public Subnet, 2x Private Subnet, Internet GW, NAT GW, Route Tables |
| `modules/eks/` | main.tf, variables.tf, outputs.tf | EKS Cluster (v1.29), Managed Node Group (t3.medium, 1-4 auto-scale), IAM Roles |
| `modules/ecr/` | main.tf, variables.tf, outputs.tf | 2x ECR Repo (frontend, backend), Lifecycle Policy, Scan on Push |
| `modules/security-groups/` | main.tf, variables.tf, outputs.tf | Cluster SG, Node SG, least-privilege ingress/egress kuralları |

**Root dosyaları:**
- `main.tf`: Provider yapılandırması + modül çağrıları (bağımlılık sırası: VPC → SG → EKS → ECR)
- `variables.tf`: Tüm giriş değişkenleri
- `outputs.tf`: EKS endpoint, ECR URL'leri, kubectl/ECR login komutları
- `terraform.tfvars`: Varsayılan değerler

**State yönetimi:** S3 + DynamoDB remote backend (yorum satırı olarak hazır, aktif edilebilir).

### 6.2 Python Terraform (`python-project/terraform/`)

- **Data source** ile mevcut EKS cluster'a referans verir — yeni cluster oluşturmaz.
- `mern-python-etl` ECR repository oluşturur.
- IAM politikaları: ECR pull erişimi + CloudWatch Logs yazma izni (least privilege).
- MERN'den bağımsız ayrı state dosyası.

### 6.3 Güvenlik (Least Privilege)

| Katman | Uygulama |
|--------|----------|
| **Network** | Worker node'lar private subnet'te, internet erişimi NAT GW üzerinden |
| **Security Groups** | Cluster ↔ Node iletişimi yalnızca gerekli portlar (443, 1025-65535) |
| **IAM** | Her servis için ayrı role (EKS Cluster, Node Group, ECR) |
| **Container** | Non-root user, production-only dependencies |
| **ECR** | Her push'ta otomatik güvenlik taraması (scan_on_push) |
| **K8s Secrets** | Base64 encoded (production'da AWS Secrets Manager önerilir) |

---

## 7. Dağıtım Süreci

### 7.1 Adım Adım Deploy

```bash
# ─── 1. Terraform ile altyapıyı oluştur ───
cd mern-project/terraform
terraform init
terraform plan
terraform apply

# kubectl'i EKS'e bağla
aws eks update-kubeconfig --region eu-west-1 --name mern-app-eks

# ─── 2. Python ECR'ı oluştur ───
cd ../../python-project/terraform
terraform init
terraform apply

# ─── 3. Docker image'ları build & push ───
# ECR login
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com

# Frontend
cd ../../mern-project/client
docker build -t <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-app/frontend:v1 .
docker push <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-app/frontend:v1

# Backend
cd ../server
docker build -t <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-app/backend:v1 .
docker push <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-app/backend:v1

# Python ETL
cd ../../python-project
docker build -t <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-python-etl:v1 .
docker push <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/mern-python-etl:v1

# ─── 4. Kubernetes manifest'lerini uygula ───
cd ../mern-project/k8s
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f mongodb-service.yaml
kubectl apply -f mongodb-statefulset.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f backend-hpa.yaml
kubectl apply -f frontend-hpa.yaml
kubectl apply -f python-cronjob.yaml

# ─── 5. Monitoring ───
kubectl apply -f monitoring/

# ─── 6. Doğrulama ───
kubectl get all -n mern-app
kubectl get svc frontend -n mern-app   # EXTERNAL-IP → tarayıcıda aç
```

### 7.2 CI/CD ile Otomatik Deploy

Yukarıdaki adımlar `main` branch'e push yapıldığında CI/CD pipeline tarafından otomatik olarak çalıştırılır. Manuel müdahale gerekmez.

---

## 8. İzleme ve Loglama

| Araç | Amaç | Erişim |
|------|------|--------|
| **Prometheus** | Metrik toplama (CPU, Memory, Pod sayısı) | ClusterIP:9090 |
| **Grafana** | Dashboard görselleştirme | LoadBalancer:3000 (admin/admin123) |
| **CloudWatch** | EKS control plane logları (API, Audit, Authenticator) | AWS Console |
| **K8s Probes** | Liveness/Readiness health check | Otomatik (30s aralık) |

```bash
# Monitoring deploy
kubectl apply -f k8s/monitoring/

# Grafana erişimi
kubectl get svc grafana -n monitoring
```

---

## 9. Karşılaşılan Zorluklar ve Çözümler

### Zorluk 1: Frontend API URL Hardcoded
**Problem:** React bileşenlerinde API URL'si `http://localhost:5050` olarak sabitlenmiş.
**Çözüm:** Nginx reverse proxy ile `/record` ve `/healthcheck` istekleri container içinde backend servisine yönlendiriliyor. Frontend kodunda değişiklik gerektirmiyor.

### Zorluk 2: MongoDB Bağlantı Yönetimi
**Problem:** Backend `config.env` dosyasından `ATLAS_URI` okuyor, Docker/K8s ortamında bu dosya yok.
**Çözüm:** `dotenv` kütüphanesi dosya bulamazsa sessizce devam eder. Docker Compose ve K8s'te environment variable olarak `ATLAS_URI` doğrudan set edilir ve `process.env.ATLAS_URI` tarafından okunur.

### Zorluk 3: İki Projenin İzolasyonu
**Problem:** MERN ve Python projeleri aynı repo'da, deployment'lar birbirini etkilememeli.
**Çözüm:** GitHub Actions'da `paths` filtresi ile her pipeline sadece kendi dizinindeki değişikliklerde tetiklenir. Ayrı Terraform state dosyaları, ayrı ECR repo'lar kullanılır.

### Zorluk 4: CronJob Zamanlama
**Problem:** Python ETL script'inin her saat güvenilir şekilde çalışması gerekiyor.
**Çözüm:** Kubernetes CronJob ile `concurrencyPolicy: Forbid` (çakışma önleme), `backoffLimit: 2` (tekrar deneme) ve `startingDeadlineSeconds: 100` (kaçırılan job'ları kurtarma).

### Zorluk 5: Güvenlik ve Least Privilege
**Problem:** Tüm bileşenlerin gerektiği kadar yetkiye sahip olması.
**Çözüm:** Her IAM role sadece gerekli policy'lere sahip. Container'lar non-root user ile çalışır. Security group kuralları sadece gerekli portları açar. ECR image'ları otomatik taranır.

---

## 10. Hızlı Başlangıç (Lokal Test)

### Gereksinimler
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)

### MERN Stack

```bash
cd mern-project
docker-compose up --build -d

# Durumu kontrol et
docker-compose ps

# Logları izle
docker-compose logs -f
```

| Servis | URL |
|--------|-----|
| Frontend | http://localhost:3000 |
| Backend Healthcheck | http://localhost:5050/healthcheck |
| Record API | http://localhost:5050/record |

### Python ETL

```bash
cd python-project
docker build -t python-etl .
docker run --rm python-etl
```

### Temizlik

```bash
cd mern-project
docker-compose down -v    # Tüm container ve volume'ları temizle
```

---

## Teknoloji Tablosu

| Kategori | Teknoloji | Versiyon |
|----------|-----------|----------|
| Frontend | React | 18.x |
| Backend | Node.js / Express | 18.x / 4.x |
| Veritabanı | MongoDB | 7.x |
| Konteyner | Docker | Multi-stage |
| Orkestrasyon | Kubernetes (EKS) | 1.29 |
| IaC | Terraform | >= 1.5 |
| CI/CD | GitHub Actions | v4 |
| Monitoring | Prometheus + Grafana | 2.50 / 10.3 |
| Cloud | AWS (VPC, EKS, ECR, CloudWatch) | - |
