# 🚀 DevOps Capstone Project - MERN Todo App

Triển khai hoàn chỉnh một ứng dụng MERN (MongoDB, Express, React, Node.js) với pipeline DevOps đầy đủ: Containerization, CI/CD, Monitoring, Infrastructure as Code, Configuration Management, Domain & SSL.

# Link demo
https://youtu.be/BiKb-l2AHVg

---

## 📋 Mục lục

- [Tổng quan](#-tổng-quan)
- [Tech Stack](#-tech-stack)
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
- [Live URLs](#-live-urls)
- [Thông tin Infrastructure](#-thông-tin-infrastructure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
- [Các Phase triển khai](#-các-phase-triển-khai)
- [GitHub Secrets](#-github-secrets)
- [Acceptance Criteria](#-acceptance-criteria)
- [Tác giả](#-tác-giả)

---

## 🎯 Tổng quan

Dự án này triển khai một ứng dụng Todo List với đầy đủ quy trình DevOps tự động hóa, bao gồm 8 phase:

| Phase | Nội dung | Trạng thái |
|-------|----------|:----------:|
| **Phase 1** | Docker Containerization | ✅ |
| **Phase 2** | CI/CD Pipeline (GitHub Actions + Jenkins) | ✅ |
| **Phase 3** | Monitoring (Prometheus + Grafana) | ✅ |
| **Phase 4** | Infrastructure as Code (Terraform) | ✅ |
| **Phase 5** | Configuration Management (Ansible) | ✅ |
| **Phase 6** | Integration & Testing | ✅ |
| **Phase 7** | Documentation | ✅ |
| **Phase 8** | Domain & SSL (Nginx Proxy Manager) | ✅ |

---

## 🛠 Tech Stack

| Category | Technology |
|----------|-----------|
| **Frontend** | React, Vite, Nginx |
| **Backend** | Node.js, Express |
| **Database** | MongoDB |
| **Containerization** | Docker, Docker Compose |
| **CI/CD** | GitHub Actions, Jenkins |
| **Monitoring** | Prometheus, Grafana, Node Exporter, MongoDB Exporter |
| **IaC** | Terraform |
| **Config Management** | Ansible |
| **Cloud Provider** | DigitalOcean |
| **Reverse Proxy / SSL** | Nginx Proxy Manager, Let's Encrypt |
| **Domain Registrar** | name.com |

---

## 🏗 Kiến trúc hệ thống

```
                          ┌────────────────────────────┐
                          │   Internet (Users)         │
                          └─────────────┬──────────────┘
                                        │
                                  ttrinh.dev (DNS)
                                        │
                          ┌─────────────▼──────────────┐
                          │   Nginx Proxy Manager      │
                          │   (SSL - Let's Encrypt)    │
                          └─────────────┬──────────────┘
              ┌───────────┬─────────────┼─────────────┬──────────────┐
              │           │             │             │              │
        ttrinh.dev   api.ttrinh.dev  grafana.    jenkins.       prometheus.
                                     ttrinh.dev  ttrinh.dev     ttrinh.dev
              │           │             │             │              │
          ┌───▼───┐   ┌───▼────┐   ┌───▼─────┐  ┌────▼────┐    ┌────▼─────┐
          │Front  │   │Backend │   │Grafana  │  │Jenkins  │    │Prometheus│
          │(React)│   │(Node)  │   │         │  │         │    │          │
          └───────┘   └───┬────┘   └─────────┘  └─────────┘    └──────────┘
                          │
                      ┌───▼─────┐
                      │ MongoDB │
                      └─────────┘

  ┌──────────────────────────────────┐    ┌──────────────────────────────────┐
  │  VPS 1 - CI/CD Server            │    │  VPS 2 - Application Server      │
  │  IP: 178.128.16.105              │    │  IP: 178.128.30.8                │
  │  - Jenkins                       │    │  - Docker Compose Stack          │
  │  - GitHub Actions runner target  │    │  - Created by Terraform          │
  │                                  │    │  - Configured by Ansible         │
  └──────────────────────────────────┘    └──────────────────────────────────┘
```

---

## 🌐 Live URLs

| Service | URL |
|---------|-----|
| **Frontend (Todo App)** | https://ttrinh.dev |
| **Backend API** | https://api.ttrinh.dev |
| **Grafana Dashboard** | https://grafana.ttrinh.dev |
| **Jenkins** | https://jenkins.ttrinh.dev |
| **Prometheus** | https://prometheus.ttrinh.dev |

---

## 🖥 Thông tin Infrastructure

### VPS 1 - CI/CD Server
- **IP**: `178.128.16.105`
- **Mục đích**: Host Jenkins và làm deployment target cho GitHub Actions
- **OS**: Ubuntu 22.04
- **Provider**: DigitalOcean

### VPS 2 - Application Server (tạo bằng Terraform + Ansible)
- **IP**: `178.128.30.8`
- **Mục đích**: Host toàn bộ stack ứng dụng (Frontend, Backend, MongoDB, Monitoring, NPM)
- **OS**: Ubuntu 22.04
- **Provisioning**: Terraform
- **Configuration**: Ansible

### Domain
- **Domain name**: `ttrinh.dev`
- **Registrar**: name.com
- **DNS**: A records trỏ về `178.128.30.8`
- **SSL**: Let's Encrypt (tự động cấp/gia hạn qua Nginx Proxy Manager)

---

## 📦 Prerequisites

Trước khi bắt đầu, đảm bảo bạn có:

- [Docker](https://docs.docker.com/get-docker/) >= 20.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0
- [Terraform](https://www.terraform.io/downloads) >= 1.5
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.14
- [Git](https://git-scm.com/)
- Tài khoản:
  - GitHub (cho source code + GitHub Actions)
  - DigitalOcean (cho VPS)
  - DockerHub (cho image registry)
  - name.com hoặc registrar khác (cho domain)

---

## 🚀 Quick Start

### Chạy local với Docker Compose

```bash
# Clone repository
git clone https://github.com/<your-username>/devops-capstone.git
cd devops-capstone

# Khởi động toàn bộ stack
docker compose up -d

# Kiểm tra trạng thái containers
docker compose ps

# Truy cập:
# - Frontend:  http://localhost:3000
# - Backend:   http://localhost:5000
# - MongoDB:   mongodb://localhost:27017
```

### Dừng stack

```bash
docker compose down

# Xóa kèm volumes (cẩn thận, sẽ mất data!)
docker compose down -v
```

---

## 📁 Cấu trúc dự án

```
devops-capstone/
├── frontend/                    # React app
│   ├── Dockerfile
│   ├── nginx.conf
│   └── src/
├── backend/                     # Node.js Express API
│   ├── Dockerfile
│   └── src/
├── docker-compose.yml           # Stack chính
├── docker-compose.monitoring.yml # Stack monitoring
├── .github/
│   └── workflows/
│       └── ci-cd.yml            # GitHub Actions pipeline
├── Jenkinsfile                  # Jenkins pipeline
├── terraform/                   # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── ansible/                     # Configuration Management
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── docker/
│       ├── app/
│       └── monitoring/
├── monitoring/
│   ├── prometheus.yml
│   └── grafana/
│       └── dashboards/
└── README.md
```

---

## 📚 Các Phase triển khai

### Phase 1 - Docker Containerization 🐳

Containerize cả Frontend (React) và Backend (Node.js) bằng Docker, sử dụng **multi-stage build** để tối ưu image size.

- Frontend: Build bằng Node, serve bằng Nginx
- Backend: Node.js Alpine
- Database: MongoDB official image
- Sử dụng **Docker Compose** để orchestration

```bash
docker compose up -d --build
```

---

### Phase 2 - CI/CD Pipeline 🔄

Hai pipeline song song:

**GitHub Actions** (`.github/workflows/ci-cd.yml`) - trigger trên branch `main`:
1. Checkout code
2. Build Docker images (frontend + backend)
3. Push lên DockerHub
4. SSH vào VPS `178.128.16.105` và deploy

**Jenkins** (`Jenkinsfile`) - trigger trên branch `jenkins`:
1. Pull source
2. Build & test
3. Build Docker images
4. Push DockerHub
5. Deploy lên VPS qua SSH agent


---

### Phase 3 - Monitoring 📊

Stack monitoring đầy đủ:

| Component | Port | Mục đích |
|-----------|------|----------|
| Prometheus | 9090 | Thu thập metrics |
| Grafana | 3001 | Visualize dashboards |
| Node Exporter | 9100 | Metrics của VPS |
| MongoDB Exporter | 9216 | Metrics của MongoDB |
| cAdvisor | 8080 | Metrics của containers |

Dashboards mặc định: **Node Exporter Full**, **MongoDB**, **Docker Container**.

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

---

### Phase 4 - Terraform IaC ☁️

Provisioning VPS trên DigitalOcean bằng Terraform:

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Resource được tạo:
- 1 Droplet Ubuntu 22.04 (s-2vcpu-4gb) tại region SGP1
- SSH key được upload tự động
- Firewall rules (mở port 22, 80, 443)
- Output: IP `178.128.30.8`

---

### Phase 5 - Ansible Configuration Management ⚙️

Sau khi Terraform tạo VPS, Ansible sẽ cấu hình:

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

Các task được thực thi:
1. Update apt packages
2. Cài đặt Docker + Docker Compose
3. Tạo user `deploy`
4. Copy source code lên server
5. Generate `.env` file
6. Khởi động `docker compose up -d`
7. Khởi động monitoring stack


---

### Phase 6 - Integration & Testing 🧪

Kiểm tra end-to-end toàn bộ 10 Acceptance Criteria:

- ✅ Containers chạy ổn định
- ✅ CI/CD tự động deploy khi push code
- ✅ Monitoring thu thập đầy đủ metrics
- ✅ Terraform tạo được VPS
- ✅ Ansible cấu hình hoàn chỉnh
- ✅ Ứng dụng truy cập được qua domain
- ✅ SSL hoạt động (HTTPS)
- ✅ Backup/restore MongoDB
- ✅ Logs tập trung
- ✅ Tài liệu đầy đủ


---

### Phase 7 - Documentation 📝

Tài liệu hóa toàn bộ quy trình:
- README tổng hợp
- Diagram kiến trúc
- Runbook xử lý sự cố


---

### Phase 8 - Domain & SSL 🔐

Cấu hình domain `ttrinh.dev` (mua tại name.com) với SSL miễn phí từ Let's Encrypt thông qua **Nginx Proxy Manager**.

**Các subdomain**:
| Subdomain | Forward to |
|-----------|-----------|
| `ttrinh.dev` | `frontend:80` |
| `api.ttrinh.dev` | `backend:5000` |
| `grafana.ttrinh.dev` | `grafana:3000` |
| `jenkins.ttrinh.dev` | `178.128.16.105:8080` |
| `prometheus.ttrinh.dev` | `prometheus:9090` |


SSL được Nginx Proxy Manager tự động cấp và renew qua Let's Encrypt (HTTP-01 challenge).

---

## 🔑 GitHub Secrets

Cấu hình các secrets sau trong **Repository Settings → Secrets and variables → Actions**:

| Secret Name | Mô tả |
|-------------|-------|
| `DOCKERHUB_USERNAME` | Username DockerHub |
| `DOCKERHUB_TOKEN` | Access token DockerHub |
| `SSH_HOST` | `178.128.16.105` |
| `SSH_USER` | `root` hoặc `deploy` |
| `SSH_PRIVATE_KEY` | Private SSH key để truy cập VPS |
| `DO_TOKEN` | DigitalOcean API token (cho Terraform) |
| `MONGO_URI` | Connection string MongoDB |

---

## ✅ Acceptance Criteria

| # | AC | Status |
|:-:|-----|:------:|
| 1 | Ứng dụng được container hóa bằng Docker | ✅ |
| 2 | Docker Compose orchestrate đầy đủ các service | ✅ |
| 3 | CI/CD pipeline tự động build & deploy | ✅ |
| 4 | Prometheus thu thập được metrics | ✅ |
| 5 | Grafana hiển thị dashboards | ✅ |
| 6 | Terraform provisioning VPS thành công | ✅ |
| 7 | Ansible cấu hình server tự động | ✅ |
| 8 | Ứng dụng truy cập được qua domain `ttrinh.dev` | ✅ |
| 9 | HTTPS hoạt động với SSL Let's Encrypt | ✅ |
| 10 | Tài liệu đầy đủ cho từng phase | ✅ |

---

## 👤 Tác giả

- **Tên**: Trinh, Huy Thanh
- **Domain**: [ttrinh.dev](https://ttrinh.dev)

---

## 📄 License

This project is licensed under the **MIT License** - see the LICENSE file for details.

---

## 🙏 Acknowledgements

- DigitalOcean
- DockerHub
- Let's Encrypt
- Nginx Proxy Manager
- Grafana Labs
- Prometheus
- HashiCorp Terraform
- Red Hat Ansible

---

⭐ **Nếu dự án hữu ích, hãy give a star!** ⭐
