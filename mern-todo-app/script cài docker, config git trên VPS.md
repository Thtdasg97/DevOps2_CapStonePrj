# Cập nhật package list
apt update

# Cài Docker
apt install docker.io

# Cài Docker Compose (phải cài thêm, server không có sẵn như local)
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

# Cấp quyền execute cho Docker Compose
chmod 700 /usr/local/bin/docker-compose

# Kiểm tra cài thành công
docker compose -v

# ===== BƯỚC 1: Clone source về server =====
git clone https://github.com/username/repo-name.git

# Nếu repo PRIVATE → cần token để clone
# Setup một lần để không cần nhập lại mỗi lần:
git config --global credential.helper store
# Sau đó git clone → nhập username + token → lần sau tự nhớ

# ===== BƯỚC 2: Kiểm tra trước khi build =====
# 1. Có Dockerfile chưa? (không có = không build được)
ls Dockerfile

# 2. File .env đã config đúng địa chỉ IP server chưa?
cat .env

# ===== BƯỚC 3: Build và chạy container =====
# Cách 1 — Dùng lệnh docker trực tiếp:
docker build . -t img-html           # Build image từ Dockerfile
docker images                        # Kiểm tra image đã build
docker run -d -p 3001:80 --name cons-html img-html   # Chạy container
docker ps                            # Kiểm tra container đang chạy

# Cách 2 — Dùng Docker Compose (tiện hơn khi có nhiều container):
docker-compose up -d                 # Build + chạy tất cả service

# ===== BƯỚC 4: Kiểm tra kết quả =====
# Truy cập: http://<IP_server>:<port>
# Ví dụ: http://167.99.12.34:3001