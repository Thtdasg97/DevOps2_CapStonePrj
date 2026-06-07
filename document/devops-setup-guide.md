# ⚙️ Setup Guide — DevOps Capstone Project

> **OS:** macOS Apple Silicon (M1/M2/M3)
> **Đã có sẵn:** Docker Desktop, Git, VS Code
> **Cloud Provider:** DigitalOcean (cho Terraform)
> **Mục tiêu:** Sẵn sàng 100% trước khi bắt đầu Phase 1

---

## 🗺️ Tổng quan — Cần cài gì?

```
✅ Docker Desktop     → đã có
✅ Git                → đã có
✅ VS Code            → đã có
⬜ Node.js / npm      → cần cài (chạy app local - Bước 1 Phase 1)
⬜ Homebrew           → cần cài (package manager cho Mac)
⬜ Terraform          → cần cài (Phase 3 - Infrastructure)
⬜ Ansible            → cần cài (Phase 4 - Configuration)
⬜ Account setup      → Docker Hub, GitHub, DigitalOcean
```

---

## Phần 1: Verify những gì đã có

### 1.1 — Docker Desktop

```bash
# Kiểm tra Docker đang chạy
docker --version
# Expected: Docker version 24.x.x hoặc mới hơn

docker-compose --version
# Expected: Docker Compose version v2.x.x

# Verify Docker chạy được
docker run hello-world
# Expected: "Hello from Docker!"
```

> ⚠️ **Apple Silicon quan trọng:** Vào Docker Desktop → Settings → General
> → Bật **"Use Rosetta for x86/amd64 emulation"**
> → Bật **"Use containerd for pulling and storing images"**
> Cần thiết để chạy một số image chưa có bản `arm64`

### 1.2 — Git

```bash
git --version
# Expected: git version 2.x.x

# Nếu chưa config
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"

# Verify
git config --list | grep user
```

### 1.3 — VS Code

Cài các extensions cần thiết:

```
Mở VS Code → Extensions (Cmd + Shift + X) → Tìm và cài:

□ Docker          (ms-azuretools.vscode-docker)
□ YAML            (redhat.vscode-yaml)
□ HashiCorp Terraform (hashicorp.terraform)
□ Ansible         (redhat.ansible)
□ GitLens         (eamodio.gitlens)
□ REST Client     (humao.rest-client)  ← test API không cần Postman
```

---

## Phần 2: Cài Homebrew (Package Manager)

> Homebrew là tool quản lý packages trên macOS — cần để cài Terraform, Ansible sau này.

### Kiểm tra đã có chưa

```bash
brew --version
# Nếu có: Homebrew 4.x.x → bỏ qua bước cài đặt
```

### Cài đặt

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Quan trọng với Apple Silicon — Thêm vào PATH

```bash
# Sau khi cài xong, terminal sẽ hiện hướng dẫn, thường là:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify
brew --version
# Expected: Homebrew 4.x.x
```

> ⚠️ Trên Apple Silicon, Homebrew cài vào `/opt/homebrew/` thay vì `/usr/local/`
> như Intel Mac. Nếu không thêm PATH sẽ không tìm thấy lệnh `brew`.

---

## Phần 3: Cài Node.js / npm

> Cần để chạy ReactJS và ExpressJS trên localhost (Bước 1 Phase 1)

### Cài qua nvm (khuyến nghị — quản lý nhiều version)

```bash
# Cài nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Reload terminal
source ~/.zshrc

# Verify nvm
nvm --version
# Expected: 0.39.x

# Cài Node.js LTS
nvm install --lts
nvm use --lts

# Verify
node --version   # Expected: v20.x.x
npm --version    # Expected: 10.x.x
```

### Tại sao dùng nvm thay vì cài thẳng?

```
Cài thẳng:  node 20 → sau này project cần node 18 → conflict
nvm:        nvm use 18  /  nvm use 20  → switch dễ dàng
            Mỗi project có thể pin version riêng qua .nvmrc
```

---

## Phần 4: Cài Terraform

> Cần cho Phase 3 — tạo VPS trên DigitalOcean bằng code

```bash
# Cài qua Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform --version
# Expected: Terraform v1.x.x
# on darwin_arm64  ← quan trọng: phải là arm64, không phải amd64
```

---

## Phần 5: Cài Ansible

> Cần cho Phase 4 — tự động cài app lên VPS

```bash
# Cài Python pip trước (Ansible chạy trên Python)
brew install python3

# Cài Ansible
pip3 install ansible

# Verify
ansible --version
# Expected: ansible [core 2.x.x]

# Cài thêm collection cần thiết
ansible-galaxy collection install community.docker
# → Dùng để manage Docker containers qua Ansible
```

> ⚠️ **Apple Silicon:** Ansible chạy native trên arm64, không cần Rosetta.

---

## Phần 6: Account Setup

### 6.1 — GitHub

```bash
# Kiểm tra đã có SSH key chưa
ls ~/.ssh/id_ed25519.pub

# Nếu chưa có → tạo mới
ssh-keygen -t ed25519 -C "email@example.com"
# → Enter 3 lần (mặc định)

# Copy public key
cat ~/.ssh/id_ed25519.pub
# → Copy toàn bộ output

# Thêm vào GitHub:
# github.com → Settings → SSH and GPG keys → New SSH key → Paste
```

```bash
# Verify kết nối GitHub
ssh -T git@github.com
# Expected: "Hi username! You've successfully authenticated..."
```

### 6.2 — Docker Hub

```bash
# Tạo account tại: https://hub.docker.com
# Username sẽ dùng để đặt tên image: username/todo-backend

# Login từ terminal
docker login
# Nhập username và password

# Verify
docker info | grep Username
```

### 6.3 — DigitalOcean

```
1. Tạo account: https://www.digitalocean.com
   → Có thể dùng GitHub để đăng ký (tiện hơn)
   → Free tier: $200 credit cho 60 ngày với account mới

2. Tạo Personal Access Token (cho Terraform):
   DigitalOcean Dashboard
   → API (menu trái)
   → Personal access tokens
   → Generate New Token
   → Name: "terraform-capstone"
   → Scope: Read + Write
   → Copy token → lưu vào file .env (KHÔNG commit lên git)

3. Thêm SSH key vào DigitalOcean:
   Dashboard → Settings → Security → SSH Keys → Add SSH Key
   → Paste nội dung file ~/.ssh/id_ed25519.pub
   → Name: "macbook-m1"
   → Lưu lại fingerprint (cần cho Terraform config sau)
```

---

## Phần 7: Cấu trúc Project

### Clone source mẫu

```bash
# Tạo thư mục làm việc
mkdir ~/projects/devops-capstone
cd ~/projects/devops-capstone

# Clone source mẫu (Todo list ReactJS + ExpressJS + MongoDB)
git clone <source_url> app
cd app

# Xem cấu trúc
ls -la
```

### Cấu trúc thư mục cần có sau Phase 1

```
devops-capstone/
├── app/                         ← Source code (clone về)
│   ├── frontend/                ← ReactJS
│   │   ├── src/
│   │   ├── package.json
│   │   ├── Dockerfile           ← Bạn sẽ tạo
│   │   ├── nginx.conf           ← Bạn sẽ tạo
│   │   └── .dockerignore        ← Bạn sẽ tạo
│   ├── backend/                 ← ExpressJS
│   │   ├── src/
│   │   ├── package.json
│   │   ├── Dockerfile           ← Bạn sẽ tạo
│   │   └── .dockerignore        ← Bạn sẽ tạo
│   ├── docker-compose.yml       ← Bạn sẽ tạo
│   ├── docker-compose.prod.yml  ← Bạn sẽ tạo
│   └── .env                     ← Bạn sẽ tạo (KHÔNG commit)
├── .github/
│   └── workflows/               ← Phase 2
├── jenkins/                     ← Phase 2
├── terraform/                   ← Phase 3
├── ansible/                     ← Phase 4
└── monitoring/                  ← Phase 5
```

### Init Git repository

```bash
cd ~/projects/devops-capstone

# Tạo .gitignore ngay từ đầu
cat > .gitignore << 'EOF'
# Environment variables - KHÔNG BAO GIỜ commit
.env
*.env
.env.*

# Dependencies
node_modules/

# Terraform state (chứa sensitive data)
*.tfstate
*.tfstate.backup
.terraform/

# Ansible vault
*.vault

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/
EOF

git init
git add .gitignore
git commit -m "chore: init project with .gitignore"

# Tạo repo trên GitHub rồi push
git remote add origin git@github.com:username/devops-capstone.git
git push -u origin main
```

---

## Phần 8: Verify toàn bộ Setup

Chạy checklist này trước khi bắt đầu Phase 1:

```bash
echo "=== VERIFY SETUP ===" && \
echo "" && \
echo "--- Core Tools ---" && \
docker --version && \
docker-compose --version && \
git --version && \
node --version && \
npm --version && \
echo "" && \
echo "--- Phase 3/4 Tools ---" && \
terraform --version && \
ansible --version && \
brew --version && \
echo "" && \
echo "--- Docker Running ---" && \
docker run hello-world && \
echo "" && \
echo "=== ALL GOOD ==="
```

### Expected output

```
=== VERIFY SETUP ===

--- Core Tools ---
Docker version 24.x.x
Docker Compose version v2.x.x
git version 2.x.x
v20.x.x
10.x.x

--- Phase 3/4 Tools ---
Terraform v1.x.x
on darwin_arm64
ansible [core 2.x.x]
Homebrew 4.x.x

--- Docker Running ---
Hello from Docker!

=== ALL GOOD ===
```

---

## 🚨 Các vấn đề thường gặp trên Apple Silicon

| Vấn đề | Nguyên nhân | Fix |
|---|---|---|
| `image platform mismatch` | Image chưa có bản arm64 | Thêm `platform: linux/amd64` trong compose |
| `brew: command not found` | Chưa thêm `/opt/homebrew` vào PATH | Chạy lại lệnh `echo 'eval...' >> ~/.zprofile` |
| `terraform: darwin_amd64` | Cài nhầm bản Intel | `brew reinstall terraform` |
| Docker Desktop chậm | Chưa bật Rosetta | Settings → General → Use Rosetta |
| `ansible: command not found` | pip3 install vào PATH khác | Thêm `export PATH="$HOME/Library/Python/3.x/bin:$PATH"` vào `~/.zshrc` |

---

## 📋 Checklist Setup — Definition of Done

### Tools

```
□ docker --version          → hiện version
□ docker-compose --version  → hiện version
□ docker run hello-world    → "Hello from Docker!"
□ Docker Desktop Settings   → Rosetta được bật
□ git --version             → hiện version
□ git config user.name      → hiện tên bạn
□ node --version            → v20.x.x
□ npm --version             → 10.x.x
□ terraform --version       → hiện "on darwin_arm64"
□ ansible --version         → hiện version
□ brew --version            → hiện version
```

### Accounts

```
□ GitHub SSH key đã thêm → ssh -T git@github.com thành công
□ Docker Hub đã login    → docker info hiện Username
□ DigitalOcean token đã tạo và lưu an toàn
□ DigitalOcean SSH key đã upload
```

### Project

```
□ Repo đã tạo trên GitHub
□ .gitignore đã có (bao gồm .env, *.tfstate, node_modules)
□ Source mẫu đã clone về local
□ Cấu trúc thư mục đã chuẩn bị
```

---

## ➡️ Sau khi setup xong

Khi tất cả checkbox trên đã tick, bạn sẵn sàng bắt đầu **Phase 1 - Bước 1**:

```bash
# Chạy app trên localhost — không Docker
cd ~/projects/devops-capstone/app/backend
npm install && npm run dev

# Terminal mới
cd ~/projects/devops-capstone/app/frontend
npm install && npm start
```

Mở `http://localhost:3000` — nếu thấy UI Todo app → **Setup hoàn tất!** 🎉

---

*Setup Guide — DevOps Capstone Project*
*macOS Apple Silicon (M1/M2/M3) | DigitalOcean*
