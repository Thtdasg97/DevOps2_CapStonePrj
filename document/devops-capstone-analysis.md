# 🚀 DevOps Capstone Project — Phân tích toàn diện

> **Stack:** ReactJS (Frontend) + ExpressJS (Backend) + MongoDB (Database)
> **Mục tiêu:** Containerize, CI/CD, Infrastructure as Code, Monitoring

---

## 📐 Framework 1: C4 Model — Nhìn hệ thống từ ngoài vào trong

### Level 1 — Context (Bức tranh tổng thể)

```
[User / Browser]
      ↓
[Todo App] ← chạy trên VPS, deploy tự động qua CI/CD
      ↑
[Developer] → push code → trigger pipeline
```

### Level 2 — Container (Các "hộp" lớn)

```
┌─────────────────────────────────────────────────────────┐
│                        VPS Server                       │
│                                                         │
│  ┌──────────────┐   ┌──────────────┐  ┌─────────────┐  │
│  │   ReactJS    │   │  ExpressJS   │  │   MongoDB   │  │
│  │  port: 3000  │──▶│  port: 5000  │─▶│  port:27017 │  │
│  └──────────────┘   └──────────────┘  └─────────────┘  │
│                                                         │
│  ┌──────────────┐   ┌──────────────┐                   │
│  │  Prometheus  │   │   Grafana    │                   │
│  │  port: 9090  │──▶│  port: 3001  │                   │
│  └──────────────┘   └──────────────┘                   │
│                                                         │
│  ┌──────────────┐                                       │
│  │   Jenkins    │                                       │
│  │  port: 8080  │                                       │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

### Level 3 — Component (Bên trong từng container)

| Container | Components |
|---|---|
| **ReactJS** | Pages, Components, Axios (gọi API), `.env` (API URL) |
| **ExpressJS** | Router, Controller, Model (Mongoose), Middleware, `/metrics` endpoint |
| **MongoDB** | Collections: todos, users |
| **Prometheus** | `prometheus.yml`, node-exporter, mongodb-exporter |
| **Grafana** | Datasource config, Dashboard JSON |

### Level 4 — Code (Files cần tạo)

```
project/
├── frontend/
│   ├── Dockerfile
│   └── .env
├── backend/
│   ├── Dockerfile
│   └── .env
├── docker-compose.yml
├── docker-compose.prod.yml
├── .github/
│   └── workflows/
│       └── deploy.yml
├── jenkins/
│   └── Jenkinsfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
└── monitoring/
    ├── prometheus.yml
    └── grafana/
        └── dashboard.json
```

---

## ❓ Framework 2: 5 Whys — Hiểu bản chất từng requirement

### Tại sao dùng Docker?

```
Why 1: Để app chạy nhất quán trên mọi môi trường
Why 2: Vì "works on my machine" không có giá trị trên VPS
Why 3: VPS có OS khác, không có Node/npm sẵn
Why 4: Cài Node trực tiếp lên VPS → khó rollback, khó scale
→ KẾT LUẬN: Docker giải quyết "environment consistency"
```

### Tại sao dùng docker-compose?

```
Why 1: Để chạy 3 service (React + Express + MongoDB) cùng lúc
Why 2: Vì mỗi service cần được start đúng thứ tự và kết nối đúng network
Why 3: Gõ tay 3 lệnh docker run mỗi lần quá tốn công và dễ sai
→ KẾT LUẬN: docker-compose = orchestration đơn giản cho local/single-server
```

### Tại sao dùng cả GitHub Actions VÀ Jenkins?

```
Why 1: Hai tool đều làm CI/CD — nhưng mục đích học khác nhau
GitHub Actions → cloud-native, tích hợp sẵn với GitHub, dễ setup
Jenkins       → self-hosted, pipeline phức tạp, phổ biến ở enterprise
→ KẾT LUẬN: Trong thực tế chọn 1. Ở đây học cả 2 để hiểu trade-off
```

### Tại sao dùng Terraform?

```
Why 1: Để tạo VPS bằng code thay vì click tay trên dashboard
Why 2: Click tay không reproducible, không version control được
Why 3: Nếu VPS bị xóa, phải setup lại từ đầu mất hàng giờ
→ KẾT LUẬN: Terraform = Infrastructure as Code, tạo lại VPS trong vài phút
```

### Tại sao dùng Ansible?

```
Why 1: Để tự động cài Docker, kéo image, chạy app trên VPS mới tạo
Why 2: SSH vào server gõ tay mỗi lần deploy = không scalable
Why 3: Script bash cũng làm được nhưng không idempotent, khó maintain
→ KẾT LUẬN: Ansible = Configuration Management, server luôn ở đúng trạng thái
```

---

## 🔗 Framework 3: Dependency Mapping

### Build-time vs Runtime Dependencies

```
BUILD-TIME (chỉ cần trong Dockerfile):
  React  → Node.js 18+, npm packages (react, axios...)
  Express → Node.js 18+, npm packages (express, mongoose...)

RUNTIME (cần khi container đang chạy):
  React   → Express phải đang chạy tại API_URL
  Express → MongoDB phải đang chạy tại MONGO_URI
  Prometheus → App expose /metrics, node-exporter chạy
  Grafana → Prometheus phải đang chạy tại prometheus:9090
```

### Thứ tự khởi động (Start Order)

```
1. MongoDB      (không phụ thuộc gì)
2. ExpressJS    (phụ thuộc MongoDB)
3. ReactJS      (phụ thuộc ExpressJS)
4. node-exporter (độc lập, monitor host)
5. Prometheus   (phụ thuộc /metrics endpoints)
6. Grafana      (phụ thuộc Prometheus)
7. Jenkins      (độc lập)
```

### docker-compose depends_on

```yaml
services:
  mongodb:
    image: mongo:6

  backend:
    build: ./backend
    depends_on:
      - mongodb        # Chỉ start sau MongoDB

  frontend:
    build: ./frontend
    depends_on:
      - backend        # Chỉ start sau Backend

  prometheus:
    image: prom/prometheus
    depends_on:
      - backend        # Cần backend expose /metrics

  grafana:
    image: grafana/grafana
    depends_on:
      - prometheus     # Cần Prometheus làm datasource
```

---

## ⚠️ Framework 4: Risk-First Analysis

### Ma trận rủi ro

| Phần | Rủi ro | Lý do | Ưu tiên |
|---|---|---|---|
| Dockerfile + docker-compose | 🔴 Cao | Nền tảng của mọi thứ | **Làm đầu tiên** |
| Ansible | 🔴 Cao | YAML phức tạp, SSH config dễ sai | **Làm sớm** |
| Terraform | 🟡 Trung bình | Cloud API có thể thay đổi | Làm sau Docker |
| GitHub Actions | 🟡 Trung bình | Syntax đơn giản, docs tốt | Song song Terraform |
| Prometheus + Grafana | 🟢 Thấp | Image có sẵn, nhiều template | Làm gần cuối |
| Jenkins | 🟢 Thấp | Làm sau GH Actions, đã hiểu CI/CD | **Làm cuối** |

### Nguyên tắc

> ⚠️ **Đừng làm Terraform khi docker-compose chưa chạy được.**
> Lỗi sẽ chồng lỗi — không biết lỗi do infrastructure hay do app.

---

## 📦 Framework 5: IPO (Input → Process → Output)

| Tool | Input | Process | Output |
|---|---|---|---|
| **Dockerfile** | Source code + base image | `docker build` | Docker image |
| **docker-compose** | `docker-compose.yml` | Orchestrate containers | Running services |
| **GitHub Actions** | Git push event | Run `.github/workflows/*.yml` | CI/CD pipeline |
| **Jenkins** | Trigger (webhook/poll) | Run `Jenkinsfile` | Build + Deploy |
| **Terraform** | `.tf` files + cloud credentials | `terraform apply` | VPS instance |
| **Ansible** | `playbook.yml` + `inventory.ini` | SSH + execute tasks | Configured server |
| **Prometheus** | `scrape_config` targets | Poll `/metrics` endpoints | Time-series data |
| **Grafana** | Prometheus datasource | Visualize queries | Dashboard |

---

## 🗺️ Toàn bộ Pipeline — Từ code đến production

```
┌─────────────────────────────────────────────────────────────────┐
│                        DEVELOPER                                │
│                    git push origin main                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     GITHUB ACTIONS                              │
│  1. Checkout code                                               │
│  2. Build Docker images (frontend + backend)                    │
│  3. Run tests                                                   │
│  4. Push images to Docker Hub                                   │
│  5. Trigger Ansible deploy (hoặc SSH vào VPS)                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┴──────────────┐
              ▼                            ▼
┌─────────────────────┐      ┌─────────────────────────┐
│      JENKINS        │      │        ANSIBLE          │
│  (Alternative/      │      │  1. SSH vào VPS         │
│   Parallel pipeline)│      │  2. Pull latest images  │
│  Jenkinsfile        │      │  3. docker-compose up   │
└─────────────────────┘      └───────────┬─────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    VPS (tạo bởi Terraform)                      │
│                                                                 │
│   [ReactJS :3000] → [ExpressJS :5000] → [MongoDB :27017]       │
│                                                                 │
│   [Prometheus :9090] ← scrape metrics ← [node-exporter]        │
│   [Grafana :3001]    ← datasource     ← [Prometheus]           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Thứ tự implement — Checklist thực tế

### Phase 1: Local Foundation 🏗️

- [ ] Clone source mẫu, chạy được trên localhost
- [ ] Hiểu `.env` file — các biến môi trường cần thiết
- [ ] Viết `Dockerfile` cho Frontend (ReactJS)
- [ ] Viết `Dockerfile` cho Backend (ExpressJS)
- [ ] Viết `docker-compose.yml` (3 service + network + volume)
- [ ] Test: `docker-compose up` → mở browser thấy app chạy

### Phase 2: CI/CD 🔄

- [ ] Tạo Docker Hub account, tạo repository
- [ ] Viết GitHub Actions workflow (build + push image)
- [ ] Test: push code → Actions tab hiện ✅
- [ ] Setup Jenkins (chạy bằng Docker)
- [ ] Viết Jenkinsfile tương tự GitHub Actions
- [ ] Test: trigger Jenkins → pipeline chạy xanh

### Phase 3: Infrastructure 🏢

- [ ] Cài Terraform, setup cloud provider credentials (DigitalOcean/AWS)
- [ ] Viết `main.tf` tạo VPS
- [ ] Test: `terraform apply` → VPS xuất hiện trên dashboard
- [ ] Ghi lại IP của VPS vào Ansible inventory

### Phase 4: Configuration Management ⚙️

- [ ] Cài Ansible
- [ ] Viết `inventory.ini` với IP của VPS
- [ ] Viết `playbook.yml`: cài Docker, copy compose file, chạy app
- [ ] Test: `ansible-playbook playbook.yml` → SSH vào VPS thấy container chạy

### Phase 5: Monitoring 📊

- [ ] Thêm `/metrics` endpoint vào ExpressJS (dùng `prom-client`)
- [ ] Thêm Prometheus + Grafana vào `docker-compose.yml`
- [ ] Viết `prometheus.yml` config scrape targets
- [ ] Import MongoDB Exporter
- [ ] Mở Grafana → tạo dashboard → thấy metrics

### Phase 6: Polish ✨ (Điểm cộng)

- [ ] Thuê VPS thật + domain
- [ ] Setup SSL (Let's Encrypt + Nginx reverse proxy)
- [ ] Quay video demo

---

## 🎯 Definition of Done — Từng bước

| Bước | ✅ Done khi... |
|---|---|
| Docker | `docker build` không lỗi, container start được |
| docker-compose | `docker-compose up` → UI hiện trên browser, API trả data |
| GitHub Actions | Push code → workflow chạy xanh, image xuất hiện trên Docker Hub |
| Jenkins | Trigger pipeline → tất cả stage xanh |
| Terraform | `terraform apply` → VPS tồn tại, SSH được vào |
| Ansible | `ansible-playbook` chạy xong → app đang chạy trên VPS |
| Monitoring | Grafana dashboard hiện CPU, RAM, MongoDB metrics |

---

## 🧠 Key Mental Models cần nhớ

```
1. Docker    = đóng gói app vào "hộp" chạy được ở mọi nơi
2. Compose   = chạy nhiều "hộp" phối hợp với nhau
3. CI/CD     = robot tự động làm việc mỗi khi code thay đổi
4. Terraform = thuê mặt bằng bằng code
5. Ansible   = thiết kế và setup nội thất bằng code
6. Prometheus = camera giám sát thu thập số liệu
7. Grafana   = màn hình hiển thị số liệu từ camera
```

---

## 🔗 Liên kết thực tế

> Khái niệm này xuất hiện ở đâu trong công việc hàng ngày của bạn?

- **Docker** → Môi trường dev đồng nhất trong team
- **CI/CD** → Tự động deploy khi merge PR vào main
- **Monitoring** → Alert khi server CPU > 80% hoặc DB query chậm
- **IaC (Terraform/Ansible)** → Tạo môi trường staging/prod giống hệt nhau

---

*Tài liệu này được tạo từ phân tích DevOps Capstone Project — Cybersoft Academy*
*Stack: ReactJS + ExpressJS + MongoDB | Tools: Docker, GitHub Actions, Jenkins, Terraform, Ansible, Prometheus, Grafana*
