# Chai Shorts Backend APIs

Base URL:
http://localhost:5000

---

## Authentication

### Signup
POST /api/auth/signup

Body:
{
  "name": "sadana",
  "email": "sadana@gmail.com",
  "password": "123456"
}

Response:
{
  "message": "User registered successfully"
}

---

### Login
POST /api/auth/login

Body:
{
  "email": "sadana@gmail.com",
  "password": "123456"
}

Response:
{
  "message": "Login successful",
  "token": "JWT_TOKEN"
}

---

## User

### Get Profile (Protected)
GET /api/user/profile

Headers:
Authorization: JWT_TOKEN

Response:
{
  "message": "Protected profile data",
  "userId": "..."
}

---

## Videos

### Upload Video (Protected)
POST /api/videos/upload

Headers:
Authorization: JWT_TOKEN

Body:
{
  "caption": "My first chai short",
  "videoUrl": "https://example.com/video.mp4"
}

---

### Video Feed
GET /api/videos/feed