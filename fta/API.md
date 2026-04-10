# API Dökümantasyonu

Express.js REST API - Dinamik tablo işlemleri (Korumalı)

## Temel URL

```
https://otp.joshqun.com
```

---

## Kimlik Doğrulama (OTP)

### Akış

1. **OTP İste** → Email'e 6 haneli kod gönderilir
2. **Kodu Doğrula** → Access + Refresh token al (Tokenlar User ID içerir)
3. **Token Yenile** → Access token süresi dolunca refresh ile yenile

---

### 1. OTP Kodu Gönder

```http
POST /api/auth/otp
```

**Body:**
```json
{
  "email": "kullanici@example.com"
}
```

**Başarılı Yanıt (200):**
```json
{
  "message": "Doğrulama kodu gönderildi",
  "email": "kullanici@example.com"
}
```

---

### 2. OTP Doğrula ve Token Al

```http
POST /api/auth/verify
```

**Body:**
```json
{
  "email": "kullanici@example.com",
  "code": "123456"
}
```

**Başarılı Yanıt (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "user": { "id": 1, "email": "..." }
}
```

---

## Korumalı Endpoint'ler

Tüm `/api/` endpoint'leri (OTP isteği hariç) `Authorization: Bearer TOKEN` header'ı gerektirir.

### Dinamik Tablo İşlemleri

Sadece beyaz listedeki (whitelisted) tablolara erişilebilir. Şu anki beyaz liste: `todos`.

#### Tüm Kayıtları Getir

```http
GET /api/{table}
```

**Örnek:**
```bash
curl -H "Authorization: Bearer ACCESS_TOKEN" \
     https://otp.joshqun.com/api/todos
```

---

## Todo İşlemleri (Özel Rotalar)

Todolar otomatik olarak giriş yapan kullanıcıya (`user_id`) göre filtrelenir.

| Metod | Endpoint | Açıklama |
|-------|----------|----------|
| GET | `/api/todos` | Kullanıcının todolarını listeler |
| POST | `/api/todos` | Yeni todo oluşturur |
| GET | `/api/todos/{id}` | Tekil todo getirir |
| PUT | `/api/todos/{id}` | Todo günceller |
| DELETE | `/api/todos/{id}` | Todo siler |

---

## Güvenlik

### Whitelisting
Dinamik API (`/api/:table`) sadece izin verilen tablolara erişim sağlar. `users`, `otps`, `refresh_tokens` gibi hassas tablolar dışarıya kapalıdır.

### Dosya Yükleme
Avatar yüklemelerinde sadece resim formatları (`jpg`, `png`, `gif`, `webp`) kabul edilir ve 2MB sınırı vardır.

### Rate Limiting
- **Limit:** 100 istek / 15 dakika / IP
- Helmet middleware ile temel güvenlik header'ları eklenmiştir.
