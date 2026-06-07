# Hướng dẫn chạy project MERN Todo App ở Local

## Tổng quan kiến trúc

```
mern-todo-app/
├── backend/     → Node.js + Express + Mongoose  (port 8000)
└── frontend/    → React + MUI + Tailwind         (port 3000)
```

Yêu cầu: **MongoDB** (local hoặc Atlas) + **Node.js** ≥ 18

---

## Bước 1 — Cài đặt MongoDB

> Máy hiện tại chưa có `mongod`. Chọn **một** trong hai cách:

### Cách A: MongoDB Local (macOS với Homebrew)

```bash
# Cài Homebrew nếu chưa có
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Thêm tap và cài MongoDB
brew tap mongodb/brew
brew install mongodb-community@7.0

# Khởi động MongoDB
brew services start mongodb-community@7.0

# Kiểm tra
mongosh --eval "db.runCommand({ connectionStatus: 1 })"
```

Sau khi cài, chuỗi kết nối là: `mongodb://localhost:27017/todo` ✅ (đã khớp với `.env`)

### Cách B: MongoDB Atlas (Cloud — không cần cài local)

1. Đăng ký tại [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas) (free tier)
2. Tạo cluster → **Connect** → chọn **Drivers** → copy connection string
3. Dán vào `MONGO_URI` ở bước 2 bên dưới

---

## Bước 2 — Cấu hình biến môi trường Backend

File: `mern-todo-app/backend/.env`

```env
MONGO_URI=mongodb://localhost:27017/todo   # hoặc URI Atlas
GMAIL_USERNAME=your_email@gmail.com        # dùng cho gửi mail (có thể để trống nếu chưa cần)
GMAIL_PASSWORD=your_app_password           # App Password của Gmail (không phải mật khẩu thường)
PORT=8000
JWT_SECRET=your_random_secret_key          # thay bằng chuỗi ngẫu nhiên, ví dụ: openssl rand -hex 32
```

> **Gmail App Password**: Vào Google Account → Security → 2-Step Verification → App Passwords → tạo password cho "Mail".
> Nếu chưa cần tính năng email, có thể để trống `GMAIL_USERNAME` và `GMAIL_PASSWORD`.

---

## Bước 3 — Cài dependencies và chạy Backend

```bash
cd mern-todo-app/backend

# Cài dependencies
npm install

# Chạy server (development)
node server.js
```

Kết quả mong đợi:
```
Server running on port 8000
Connected to MongoDB
```

Kiểm tra nhanh:
```bash
curl http://localhost:8000
```

---

## Bước 4 — Cài dependencies và chạy Frontend

Mở terminal mới:

```bash
cd mern-todo-app/frontend

# Cài dependencies
npm install

# Chạy dev server
npm start
```

Trình duyệt tự mở tại: **http://localhost:3000**

---

## Bước 5 — Kiểm tra kết nối Frontend ↔ Backend

Frontend gọi API đến backend. Kiểm tra file config API trong `frontend/src/` xem base URL đang trỏ về `http://localhost:8000`.

Nếu gặp lỗi CORS, kiểm tra `backend/server.js` — phần `cors()` middleware phải đặt trước các routes.

---

## Tóm tắt lệnh chạy nhanh

```bash
# Terminal 1 — Backend
cd mern-todo-app/backend && npm install && node server.js

# Terminal 2 — Frontend
cd mern-todo-app/frontend && npm install && npm start
```

---

## Troubleshooting thường gặp

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| `MongooseServerSelectionError` | MongoDB chưa chạy | `brew services start mongodb-community@7.0` |
| `EADDRINUSE: port 8000` | Cổng đang được dùng | `kill $(lsof -ti:8000)` |
| `EADDRINUSE: port 3000` | Cổng đang được dùng | `kill $(lsof -ti:3000)` |
| CORS error trên browser | Backend thiếu CORS config | Kiểm tra `cors()` trong `server.js` |
| `npm install` lỗi node-gyp | Thiếu Xcode tools | `xcode-select --install` |

---

## Yêu cầu phiên bản

| Tool | Phiên bản tối thiểu | Hiện tại |
|------|---------------------|----------|
| Node.js | ≥ 18 | v24.15.0 ✅ |
| npm | ≥ 8 | 11.12.1 ✅ |
| MongoDB | ≥ 6 | Chưa cài ⚠️ |
