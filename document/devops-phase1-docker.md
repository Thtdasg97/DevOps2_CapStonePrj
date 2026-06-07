# 🐳 Phase 1 — Docker & docker-compose

> **Mục tiêu:** `docker-compose up` → mở browser thấy app chạy hoàn chỉnh
> **Stack:** ReactJS (port 3000) + ExpressJS (port 5000) + MongoDB (port 27017)
> **Nguyên tắc:** Baby Steps + Verify từng bước — KHÔNG làm nhiều thứ cùng lúc

---

## 🗺️ Toàn cảnh Phase 1

```
Bước 1: Chạy app trên localhost (không Docker)
    ↓ verify: browser thấy UI, API trả data
Bước 2: Dockerfile cho Backend (ExpressJS)
    ↓ verify: docker build + docker run thành công
Bước 3: Dockerfile cho Frontend (ReactJS)
    ↓ verify: docker build + docker run thành công
Bước 4: docker-compose.yml (3 services)
    ↓ verify: docker-compose up → app chạy end-to-end
Bước 5: Tối ưu (volume, healthcheck, .env)
    ↓ verify: data persist sau khi restart
```

---

## Bước 1: Chạy app trên Localhost

### Tại sao làm bước này?

> Nếu app không chạy được trên localhost, sẽ không bao giờ chạy được trong Docker.
> Đây là "baseline" để so sánh khi có lỗi sau này.

### Thực hiện

```bash
# 1. Clone source về
git clone <source_url>
cd project

# 2. Chạy MongoDB local (hoặc dùng MongoDB Atlas free)
# Option A: Cài MongoDB local
# Option B: Dùng Docker chỉ cho MongoDB
docker run -d -p 27017:27017 --name mongo mongo:6

# 3. Chạy Backend
cd backend
cp .env.example .env        # Xem file .env cần những biến nào
npm install
npm run dev                 # hoặc node server.js

# 4. Chạy Frontend (terminal mới)
cd frontend
cp .env.example .env        # Sửa API_URL = http://localhost:5000
npm install
npm start
```

### Verify ✅

```
□ Mở http://localhost:3000 → thấy UI Todo app
□ Thêm 1 todo → data lưu được vào MongoDB
□ Refresh trang → data vẫn còn
□ Mở Network tab trong DevTools → API calls trả về 200
```

### Những gì cần ghi nhận từ bước này

```
□ File .env của Backend cần những biến nào?
  → Ví dụ: MONGO_URI, PORT, NODE_ENV

□ File .env của Frontend cần những biến nào?
  → Ví dụ: REACT_APP_API_URL

□ Backend lắng nghe ở port nào?
□ Frontend gọi API theo path nào? (/api/todos, /todos,...)
```

---

## Bước 2: Dockerfile cho Backend (ExpressJS)

### Understand trước khi viết

```
INPUT:   Source code NodeJS + package.json
PROCESS: Cài dependencies → copy code → chạy server
OUTPUT:  Container expose port 5000, nhận HTTP requests

Câu hỏi cần trả lời:
- Node version đang dùng là bao nhiêu? (node --version)
- Entry point của app là file nào? (server.js? index.js? app.js?)
- Port Backend đang lắng nghe là bao nhiêu?
```

### Minimum Viable Dockerfile

```dockerfile
# backend/Dockerfile

# Stage 1: Base
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files TRƯỚC (tận dụng Docker layer cache)
COPY package*.json ./

# Cài dependencies
RUN npm install

# Copy source code SAU
COPY . .

# Expose port
EXPOSE 5000

# Start command
CMD ["node", "server.js"]
```

### Tại sao COPY package*.json trước?

```
Docker build theo từng layer và cache lại.

Nếu copy tất cả cùng lúc:
  COPY . .          → Mỗi lần đổi 1 dòng code → npm install lại toàn bộ

Nếu copy package.json trước:
  COPY package*.json → npm install  (cache nếu package.json không đổi)
  COPY . .           → Chỉ re-run từ đây nếu code thay đổi

→ Build nhanh hơn nhiều lần trong thực tế
```

### .dockerignore — Bắt buộc phải có

```
# backend/.dockerignore
node_modules
.env
.git
*.log
README.md
```

> ⚠️ Nếu không có `.dockerignore`, Docker sẽ copy `node_modules` local vào image
> → Image nặng hơn, có thể lỗi do platform khác nhau (Mac vs Linux)

### Verify từng bước nhỏ

```bash
# Bước 2.1: Build image
cd backend
docker build -t todo-backend .

# Verify: Không có lỗi, thấy "Successfully built"
docker images | grep todo-backend

# Bước 2.2: Chạy container (tạm thời dùng MongoDB local)
docker run -d \
  -p 5000:5000 \
  -e MONGO_URI=mongodb://host.docker.internal:27017/tododb \
  -e NODE_ENV=development \
  --name backend \
  todo-backend

# Verify: Container đang chạy
docker ps | grep backend

# Verify: API hoạt động
curl http://localhost:5000/api/todos
# hoặc mở Postman: GET http://localhost:5000/api/todos

# Xem logs nếu có lỗi
docker logs backend
```

### Các lỗi thường gặp ở bước này

| Lỗi | Nguyên nhân | Fix |
|---|---|---|
| `Cannot find module` | Entry point sai | Kiểm tra lại CMD trong Dockerfile |
| `ECONNREFUSED mongodb` | Không connect được MongoDB | Dùng `host.docker.internal` thay `localhost` |
| `port already in use` | Port 5000 đang bị chiếm | `docker rm -f backend` rồi chạy lại |
| Image build chậm | Không có `.dockerignore` | Tạo file `.dockerignore` |

---

## Bước 3: Dockerfile cho Frontend (ReactJS)

### Understand trước khi viết

```
INPUT:   Source code ReactJS
PROCESS: Build static files → serve bằng nginx
OUTPUT:  Container expose port 3000 (hoặc 80), serve HTML/CSS/JS

Lưu ý quan trọng:
- React app sau khi build → chỉ là HTML/CSS/JS tĩnh
- Không cần Node.js để CHẠY, chỉ cần để BUILD
- Dùng multi-stage build: Stage 1 build, Stage 2 chỉ serve
```

### Multi-stage Dockerfile

```dockerfile
# frontend/Dockerfile

# ── Stage 1: Build ──────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Tận dụng cache
COPY package*.json ./
RUN npm install

# Copy source và build
COPY . .
RUN npm run build
# → Output: /app/build/ (thư mục chứa static files)

# ── Stage 2: Serve ──────────────────────────────
FROM nginx:alpine

# Copy static files từ stage 1 vào nginx
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx config (xem bên dưới)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Tại sao dùng Multi-stage?

```
Single stage:  Image ~900MB (node_modules + source + build output)
Multi-stage:   Image ~25MB  (chỉ nginx + static files)

Stage 1 (builder) bị loại bỏ hoàn toàn sau khi build xong
Stage 2 (nginx) chỉ chứa những gì cần thiết để serve
```

### nginx.conf — Cần thiết cho React Router

```nginx
# frontend/nginx.conf
server {
    listen 80;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html;  # Quan trọng cho React Router
    }

    # Proxy API calls đến Backend
    location /api {
        proxy_pass http://backend:5000;    # "backend" = tên service trong compose
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

> 💡 `try_files $uri $uri/ /index.html` giải quyết lỗi 404 khi refresh trang
> ở React Router (ví dụ: refresh tại `/todos/123` → nginx không biết route này)

### .dockerignore cho Frontend

```
# frontend/.dockerignore
node_modules
build
.env
.git
*.log
```

### Verify

```bash
# Build image
cd frontend
docker build -t todo-frontend .

# Chạy container
docker run -d -p 3000:80 --name frontend todo-frontend

# Verify
open http://localhost:3000
# hoặc curl http://localhost:3000

# Xem logs
docker logs frontend
```

### Các lỗi thường gặp

| Lỗi | Nguyên nhân | Fix |
|---|---|---|
| Blank page | `build` folder rỗng hoặc `npm run build` lỗi | Check Stage 1 logs |
| API calls fail | URL hardcode `localhost:5000` trong React | Dùng nginx proxy hoặc env variable |
| 404 khi refresh | Thiếu `try_files` trong nginx.conf | Thêm config nginx như trên |
| `REACT_APP_*` undefined | Env var không có prefix `REACT_APP_` | Đổi tên biến |

---

## Bước 4: docker-compose.yml

### Understand trước khi viết

```
INPUT:   3 Dockerfiles + cấu hình network/volume
PROCESS: Tạo network chung, start theo thứ tự đúng
OUTPUT:  3 container kết nối được với nhau

Câu hỏi cần trả lời:
- Service nào phụ thuộc service nào? (depends_on)
- Service nào cần persist data? (volumes)
- Biến môi trường nào cần truyền vào từng service?
- Tất cả service có cùng network không?
```

### docker-compose.yml — Minimum Viable

```yaml
# docker-compose.yml (đặt ở root project)
version: '3.8'

services:

  # ── MongoDB ─────────────────────────────────
  mongodb:
    image: mongo:6
    container_name: todo-mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db    # Persist data
    networks:
      - todo-network

  # ── Backend (ExpressJS) ──────────────────────
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: todo-backend
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - PORT=5000
      - MONGO_URI=mongodb://mongodb:27017/tododb  # "mongodb" = tên service trên
    depends_on:
      - mongodb                  # Chỉ start sau mongodb
    networks:
      - todo-network

  # ── Frontend (ReactJS) ───────────────────────
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: todo-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend                  # Chỉ start sau backend
    networks:
      - todo-network

# ── Volumes ─────────────────────────────────────
volumes:
  mongodb_data:
    driver: local

# ── Networks ────────────────────────────────────
networks:
  todo-network:
    driver: bridge
```

### Tại sao cần custom network?

```
Mặc định Docker tạo network riêng cho mỗi container → không giao tiếp được.

Khi dùng custom network "todo-network":
  - Các container gọi nhau bằng TÊN SERVICE (không phải IP)
  - Backend gọi MongoDB: mongodb://mongodb:27017  ← "mongodb" là tên service
  - Nginx proxy đến Backend: http://backend:5000  ← "backend" là tên service
  - Không cần biết IP thực của container
```

### Verify từng bước

```bash
# Bước 4.1: Validate file compose
docker-compose config
# → Không có lỗi syntax

# Bước 4.2: Build tất cả images
docker-compose build

# Bước 4.3: Start tất cả services
docker-compose up -d

# Bước 4.4: Kiểm tra tất cả container đang chạy
docker-compose ps
# → Tất cả STATUS = "Up"

# Bước 4.5: Xem logs realtime
docker-compose logs -f

# Bước 4.6: Test end-to-end
open http://localhost:3000
# → Thêm todo → data lưu được → refresh vẫn còn
```

### Các lỗi thường gặp

| Lỗi | Nguyên nhân | Fix |
|---|---|---|
| Backend exit ngay | MongoDB chưa ready dù `depends_on` | Thêm `restart: unless-stopped` hoặc dùng wait-for-it script |
| `ECONNREFUSED mongodb` | Sai tên service trong MONGO_URI | Tên phải khớp với tên service trong compose |
| Port conflict | Port đang được dùng bởi process khác | `lsof -i :5000` để tìm, hoặc đổi port |
| Data mất sau restart | Không có volume cho MongoDB | Thêm `volumes: mongodb_data:/data/db` |

---

## Bước 5: Tối ưu sau khi chạy được

> ⚠️ Chỉ làm bước này SAU KHI bước 4 đã verify xong

### 5.1 — Tách biến môi trường ra file `.env`

```bash
# .env (đặt ở root, KHÔNG commit lên git)
MONGO_URI=mongodb://mongodb:27017/tododb
NODE_ENV=production
PORT=5000
```

```yaml
# docker-compose.yml — dùng env_file thay vì hardcode
backend:
  env_file:
    - .env
```

```bash
# .gitignore — BẮT BUỘC
.env
```

### 5.2 — Healthcheck cho MongoDB

```yaml
mongodb:
  image: mongo:6
  healthcheck:
    test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
    interval: 10s
    timeout: 5s
    retries: 5

backend:
  depends_on:
    mongodb:
      condition: service_healthy    # Chờ MongoDB THỰC SỰ ready
```

> 💡 `depends_on` mặc định chỉ chờ container START, không chờ service READY.
> `condition: service_healthy` mới đảm bảo MongoDB accept connections rồi mới start Backend.

### 5.3 — docker-compose.prod.yml (cho VPS)

```yaml
# docker-compose.prod.yml — override cho production
version: '3.8'

services:
  backend:
    environment:
      - NODE_ENV=production
    restart: always              # Tự restart khi VPS reboot

  frontend:
    restart: always

  mongodb:
    restart: always
    # Không expose port 27017 ra ngoài trong production
    ports: []
```

```bash
# Dùng cho production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 📋 Checklist Phase 1 — Definition of Done

### Bước 1: Localhost

```
□ App chạy được trên localhost không dùng Docker
□ Đã ghi lại tất cả biến .env cần thiết
□ Biết entry point của Backend là file nào
```

### Bước 2: Backend Dockerfile

```
□ docker build -t todo-backend . → không lỗi
□ docker run → container không exit ngay
□ curl http://localhost:5000/api/todos → trả về response (dù là [])
□ Có file .dockerignore
```

### Bước 3: Frontend Dockerfile

```
□ docker build -t todo-frontend . → không lỗi
□ docker run -p 3000:80 → mở browser thấy UI
□ Không có lỗi 404 khi navigate
□ Có file .dockerignore
```

### Bước 4: docker-compose

```
□ docker-compose config → không lỗi syntax
□ docker-compose up -d → tất cả container STATUS = Up
□ http://localhost:3000 → thấy UI
□ Thêm todo → data lưu vào MongoDB
□ docker-compose restart → data vẫn còn (volume hoạt động)
□ docker-compose logs → không có ERROR
```

### Bước 5: Tối ưu

```
□ Biến môi trường tách ra file .env
□ .env có trong .gitignore
□ Healthcheck cho MongoDB
□ Image size hợp lý (frontend < 50MB, backend < 200MB)
```

---

## 🐛 Bug Journal Template

Dùng template này mỗi khi gặp và fix được lỗi:

```markdown
## Bug #001 — [Tên lỗi ngắn gọn]

**Triệu chứng:**
[Error message hoặc mô tả hành vi sai]

**Root Cause:**
[Tại sao lỗi xảy ra]

**Fix:**
[Làm gì để fix]

**Lesson:**
[Rút ra được gì, không mắc lại lần sau]
```

---

## 🧠 Key Insights Phase 1

```
1. COPY package*.json trước → tận dụng Docker layer cache
2. Multi-stage build cho Frontend → giảm image size ~97%
3. .dockerignore là bắt buộc → không copy node_modules vào image
4. Custom network → container gọi nhau bằng tên service
5. depends_on không đủ → cần healthcheck để đảm bảo service READY
6. Tách .env → không hardcode credentials trong docker-compose.yml
7. Volume cho MongoDB → data persist sau khi restart
```

---

## ➡️ Bước tiếp theo: Phase 2 — CI/CD

Sau khi Phase 1 hoàn thành, Phase 2 sẽ tự động hóa toàn bộ quá trình này:

```
git push → GitHub Actions tự động:
  1. Build images từ Dockerfile
  2. Run tests
  3. Push images lên Docker Hub
  4. Trigger deploy lên VPS
```

---

*Phase 1 — Docker & docker-compose | DevOps Capstone Project*
*Stack: ReactJS + ExpressJS + MongoDB*
