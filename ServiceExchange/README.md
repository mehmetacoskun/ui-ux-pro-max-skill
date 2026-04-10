# 🚀 Service Exchange (SE)

**Service Exchange**, kullanıcıların birbirlerine yetenekleri ve hizmetleri ile destek olduğu, para yerine **kredi** kullanılan modern bir topluluk platformudur. 

> **Durum:** 🟢 V6 — Mimari Supabase'e (PostgreSQL) taşındı  
> **Son Güncelleme:** 2026-04-10

---

## 🏗️ Proje Yapısı

| Klasör / Dosya | Açıklama |
| :--- | :--- |
| **`App/`** | Flutter (Frontend) kaynak kodları. |
| **`Supabase_Schema.sql`** | PostgreSQL veritabanı şeması, PostGIS ve DB Trigger'ları. |
| **`README.md`** | Proje dökümantasyonu ve ana iş planı. |

---

## 🛠️ Teknoloji Stack

*   **Frontend:** Flutter (Mobile & Web)
*   **Backend & DB:** Supabase (PostgreSQL)
*   **Harita/Konum:** PostGIS (Mesafe bazlı arama)
*   **Auth:** Supabase Auth (Email OTP)
*   **Storage:** Supabase Storage (Avatar & Görseller)
*   **Güvenlik:** RLS (Row Level Security)

---

## 📄 Uygulama Akışı & Kurallar

### 1. Kredi Sistemi
- Yeni kayıt olan herkese **+1 kredi** hediye edilir.
- Servis veren kendi bedelini belirler (min. 1 kredi).
- Kredi sadece servis **tamamlandığında** transfer edilir.
- Bakiye 0'ın altına düşemez.

### 2. Talep & Onay Akışı
- Alıcı talep gönderir -> Verici 48 saat içinde yanıtlar (yoksa auto-cancel).
- Servis süreci biter -> Taraflardan biri "Tamamlandı" işaretler.
- Krediler transfer olur -> Çift yönlü Review sistemi açılır.

### 3. Moderasyon
- Eklenen her servis önce **Admin Onayı**'na düşer.
- Yazılan yorumlar (review) uygunsuz içerik denetimi için admin onayından geçer.

---

## 📅 İmplementasyon Yol Haritası (TASKS)

### Faz 1 — Altyapı Setup
- [ ] Supabase Projesi oluşturulması (Cloud veya VPS).
- [ ] `Supabase_Schema.sql` dosyasının SQL Editor'de çalıştırılması.
- [ ] PostGIS eklentisinin aktif edilmesi.

### Faz 2 — Güvenlik & Triggers
- [ ] RLS poliçelerinin her tablo için tanımlanması.
- [ ] Kredi Transfer (RPC) fonksiyonunun yazılması.
- [ ] Auth -> Profile senkronizasyon trigger'ının testi.

### Faz 3 — Flutter Entegrasyonu
- [ ] `supabase_flutter` paketinin kurulması ve konfigürasyonu.
- [ ] OTP Login akışının tamamlanması.
- [ ] Profil düzenleme ve Avatar upload.

### Faz 4 — Ana Özellikler (UI)
- [ ] Harita destekli servis arama ekranı.
- [ ] Servis detay ve talep oluşturma süreci.
- [ ] Taleplerim / Servislerim yönetim ekranları.
- [ ] Review yazma ve puanlama.

### Faz 5 — Admin Panel
- [ ] Onay bekleyen servisler ve yorumlar için basit dashboard.

---

> **Not:** Proje hakkında teknik detaylar ve kararlar bu döküman üzerinden takip edilmektedir. Herhangi bir kod yazımı öncesi buradaki planın güncelliği kontrol edilmelidir.
