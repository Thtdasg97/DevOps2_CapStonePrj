# Chạy MERN Todo App trên Docker Desktop

## Mục tiêu

```
[Browser] → [Frontend container :3000] → [Backend container :8000] → [MongoDB container :27017]
```

Thay vì cài Node.js, MongoDB trên máy → mọi thứ chạy bên trong Docker container.

---

## Chuẩn bị

- [x] Docker Desktop đã cài và đang chạy
- [x] Code đã có sẵn trong `mern-todo-app/`

---

## Bước 1 — Sửa Frontend API URL

**Vấn đề:** Frontend đang gọi `http://localhost:8000/api` — URL này chỉ đúng khi chạy trên máy thật.  
Khi vào trong container, `localhost` sẽ trỏ vào chính container đó, không tìm thấy backend.

**File cần sửa:** `mern-todo-app/frontend/src/Axios/axios.js`

```js
// Trước
baseURL: "http://localhost:8000/api"

// Sau
baseURL: "http://backend:8000/api"
```

> `backend` là tên service trong `docker-compose.yml` — Docker tự resolve tên này thành IP của container.

---

## Bước 2 — Viết Dockerfile cho Backend

Tạo file: `mern-todo-app/backend/Dockerfile`

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8000

CMD ["node", "server.js"]
```

**Giải thích từng dòng:**

| Dòng | Ý nghĩa |
|------|---------|
| `FROM node:18-alpine` | Lấy image Node.js 18 (bản nhẹ) làm nền |
| `WORKDIR /app` | Mọi lệnh tiếp theo chạy trong thư mục `/app` |
| `COPY package*.json ./` | Copy file khai báo dependencies trước |
| `RUN npm install` | Cài dependencies (được cache lại nếu package.json không đổi) |
| `COPY . .` | Copy toàn bộ code vào container |
| `EXPOSE 8000` | Khai báo container dùng port 8000 |
| `CMD` | Lệnh chạy khi container start |

---

## Bước 3 — Viết Dockerfile cho Frontend

Tạo file: `mern-todo-app/frontend/Dockerfile`

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

> Frontend dùng `npm start` (React dev server) — phù hợp để chạy thử local.  
> Production sẽ dùng `npm run build` + Nginx, nhưng chưa cần thiết ở bước này.

---

## Bước 4 — Viết docker-compose.yml

Tạo file: `mern-todo-app/docker-compose.yml`

```yaml
version: "3.8"

services:

  mongo:
    image: mongo:6
    container_name: mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  backend:
    build: ./backend
    container_name: backend
    ports:
      - "8000:8000"
    environment:
      - MONGO_URI=mongodb://mongo:27017/todo
      - PORT=8000
      - JWT_SECRET=
    depends_on:
      - mongo

  frontend:
    build: ./frontend
    container_name: frontend
    ports:
      - "3000:3000"
    environment:
      - CHOKIDAR_USEPOLLING=true
    depends_on:
      - backend

volumes:
  mongo_data:
```

**Giải thích các phần quan trọng:**

| Phần | Ý nghĩa |
|------|---------|
| `image: mongo:6` | Dùng image MongoDB có sẵn, không cần Dockerfile |
| `volumes: mongo_data` | Data MongoDB được lưu lại dù container bị xóa |
| `MONGO_URI=mongodb://mongo:27017/todo` | Dùng tên service `mongo` thay vì `localhost` |
| `depends_on` | Đảm bảo thứ tự khởi động: mongo → backend → frontend |
| `CHOKIDAR_USEPOLLING=true` | React hot-reload hoạt động đúng trong Docker |

---

## Bước 5 — Tạo .dockerignore

Tạo file `mern-todo-app/backend/.dockerignore` và `mern-todo-app/frontend/.dockerignore`:

```
node_modules
.env
.git
```

> Tránh copy `node_modules` từ máy vào container (sẽ bị conflict với OS).

---

## Bước 6 — Chạy

```bash
cd mern-todo-app

# Build image và khởi động tất cả containers
docker compose up --build

# Chạy ngầm (background)
docker compose up --build -d
```

Kết quả mong đợi trong log:
```
mongo      | {"t":...,"msg":"Waiting for connections","attr":{"port":27017}}
backend    | Listening on localhost:8000
backend    | DB Connected
frontend   | Compiled successfully!
frontend   | Local: http://localhost:3000
```

Mở trình duyệt: **http://localhost:3000**

---

## Cấu trúc file sau khi hoàn thành

```
mern-todo-app/
├── backend/
│   ├── Dockerfile          ← MỚI
│   ├── .dockerignore       ← MỚI
│   ├── server.js
│   └── ...
├── frontend/
│   ├── Dockerfile          ← MỚI
│   ├── .dockerignore       ← MỚI
│   ├── src/
│   │   └── Axios/axios.js  ← SỬA (localhost → backend)
│   └── ...
└── docker-compose.yml      ← MỚI
```

---

## Các lệnh Docker hữu ích

```bash
# Xem containers đang chạy
docker ps

# Xem log của 1 service
docker compose logs backend
docker compose logs frontend

# Vào bên trong container để debug
docker exec -it backend sh

# Dừng tất cả
docker compose down

# Dừng và xóa luôn data (MongoDB volume)
docker compose down -v
```

---

## Troubleshooting

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| `Cannot connect to MongoDB` | Backend start trước mongo kịp sẵn sàng | Thêm retry logic hoặc dùng `healthcheck` |
| Frontend không gọi được API | Quên sửa `localhost` → `backend` trong axios.js | Kiểm tra Bước 1 |
| `Port already in use` | Máy đang chạy service trùng port | `docker compose down` hoặc tắt service local |
| Hot-reload không hoạt động | Thiếu `CHOKIDAR_USEPOLLING` | Kiểm tra environment trong compose file |
