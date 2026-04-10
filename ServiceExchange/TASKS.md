# Service Exchange (SE) — Uygulama Planlaması

> **Durum:** 🔴 HENÜZ BAŞLANMADI  
> **Versiyon:** V2 — Supabase Mimarisi + Schema Tamamlandı  
> **Son Güncelleme:** 2026-04-10

---

## 1. Uygulama Konsepti

**Service Exchange**, kullanıcıların birbirlerine hizmet sunup bu hizmetler karşılığında kredi kazandığı / harcadığı bir topluluk platformudur. Para yerine **kredi sistemi** kullanılır.

### Temel Akış
```
Kayıt Ol (OTP) → 1 Kredi Al → Servis Ara → Servis Talep Et
     → Verici Kabul Eder → Servis Tamamlanır
     → Kredi Transfer (Alıcı −N, Verici +N) → Çift Yönlü Review
```

---

## 2. Kullanıcı (User) Sistemi

### 2.1 Kayıt & Giriş ✅ ONAYLANDI
- [ ] **OTP ile kayıt/giriş** (email + doğrulama kodu)
- [ ] Kayıt olunca **1 kredi** otomatik verilir
- [ ] JWT Access + Refresh Token
- [ ] 🔮 **Gelecekte:** Google & Facebook OAuth eklenecek

### 2.2 Kullanıcı Profili
- [ ] **first_name** + **last_name** (ayrı alanlar) ✅ ONAYLANDI
- [ ] Profil fotoğrafı (avatar_url — Supabase Storage)
- [ ] Bio (kısa tanıtım)
- [ ] Konum (şehir + `latitude` / `longitude` harita noktası)
- [ ] Üyelik tarihi
- [ ] Toplam kredi
- [ ] Verdiği/aldığı servis sayısı
- [ ] Ortalama puan (`avg_rating` — trigger ile otomatik hesaplanır)
- [ ] **Rol (Role):** 4 katmanlı rol sistemi
  - `user` → Normal kullanıcı. Servis ekler/alır, review yazar.
  - `moderator` → İçerik onayı: servis ve review'ları onayla/reddet. Kullanıcıları listeler.
  - `admin` → Mod. yetkileri + kategori yönetimi + kullanıcı kredi yönetimi + mod. atama.
  - `superadmin` → Tam yetki: admin atama/kaldırma + sistem ayarları. (Tek hesap)

### Yetki Tablosu

| İşlem | user | moderator | admin | superadmin |
|-------|:----:|:---------:|:-----:|:----------:|
| Servis ekle/al | ✅ | ✅ | ✅ | ✅ |
| Review yaz | ✅ | ✅ | ✅ | ✅ |
| Servis onayla/reddet | ❌ | ✅ | ✅ | ✅ |
| Review onayla/reddet | ❌ | ✅ | ✅ | ✅ |
| Kullanıcıları listele | ❌ | ✅ | ✅ | ✅ |
| Moderatör ata/kaldır | ❌ | ❌ | ✅ | ✅ |
| Kategori yönet | ❌ | ❌ | ✅ | ✅ |
| Kredi ekle/çıkar | ❌ | ❌ | ✅ | ✅ |
| Admin ata/kaldır | ❌ | ❌ | ❌ | ✅ |
| Sistem ayarları | ❌ | ❌ | ❌ | ✅ |

---

## 3. Kredi Sistemi ✅ ONAYLANDI

| Aksiyon | Kredi Değişimi |
|---------|---------------|
| Kayıt ol | +1 |
| Servis ver (tamamlandığında) | +N (servis fiyatına göre) |
| Servis al (tamamlandığında) | −N (servis fiyatına göre) |

### Kurallar
- ✅ Kredi **0'ın altına DÜŞEMEZ** — yetersiz bakiye hatası
- ✅ Servis veren **kendi kredi fiyatını belirler** (minimum 1)
- ✅ Kredi **servis tamamlandığında** kesilir (talep anında değil)
- ✅ Kredisi yetersiz olan kullanıcı hizmet **alamaz**
- ✅ Talep anında `check_credits()` RPC ile kontrol yapılır ama kesilmez

---

## 4. Servis (Service) Sistemi

### 4.1 Servis Oluşturma
Bir kullanıcı "Ben şu hizmeti verebilirim" diye ilan oluşturur.

- [ ] Servis başlığı
- [ ] Açıklama
- [ ] Kategori seçimi
- [ ] **Kredi maliyeti (servis veren belirler, min: 1)**
- [ ] Konum (online / yüz yüze, `city` ve harita üzerinden `latitude`/`longitude`)
- [ ] Durum (pending_approval / active / inactive / rejected)
- [ ] 🔴 **Admin Onayı:** Servis eklendiğinde `pending_approval` olur. Admin onaylarsa yayına girer. Reddedilirse `rejection_reason` mesajı kullanıcıya gösterilir.

### 4.2 Servis Kategorileri (Tree Yapısı) ✅ ONAYLANDI (v1)

Kategoriler hiyerarşik (Tree) yapıda olacak (`parent_id` ile sınırsız derinlik). Sadece admin panelden yönetilebilir.

| # | Kategori | Icon | Örnek |
|---|----------|------|-------|
| 1 | Eğitim & Ders | `school` | Matematik dersi, dil kursu |
| 2 | Teknoloji | `computer` | Web geliştirme, telefon tamiri |
| 3 | Ev & Bahçe | `home` | Temizlik, tamirat, bahçe bakımı |
| 4 | Sağlık & Spor | `fitness_center` | Yoga, personal training |
| 5 | Sanat & Tasarım | `palette` | Logo tasarımı, fotoğrafçılık |
| 6 | Ulaşım | `directions_car` | Taşınma yardımı, araç paylaşımı |
| 7 | Yemek & Mutfak | `restaurant` | Yemek yapma, catering |
| 8 | Diğer | `more_horiz` | Kategorilere girmeyen |

> 📌 Kategoriler ileride eklenip/çıkarılabilir.

### 4.3 Servis Arama (Ana Sayfa)
- [ ] Anahtar kelime ile arama
- [ ] Kategoriye göre filtreleme
- [ ] 📍 **Harita & Konuma göre filtreleme** (PostGIS `ST_DWithin` ile)
- [ ] Sıralama (en yakın, en yeni, en popüler, en yüksek puan)

---

## 5. Servis Talebi & Akış (Service Request) ✅ ONAYLANDI

```
[Alıcı] Servis talep eder (check_credits RPC ile kontrol yapılır, kesilmez)
        ↓
[Verici] 48 saat içinde kabul / reddet (süre aşımında pg_cron otomatik expire eder)
        ↓
[Kabul] → Servis başlar (in_progress)
        ↓
[Tamamlanma] → Alıcı VEYA Verici "tamamlandı" işaretler
        ↓
transfer_credits() RPC → Alıcı −N, Verici +N (atomik, DB içinde)
        ↓
[Her iki taraf] Review bırakabilir (çift yönlü)
```

### Talep Durumları (Status)
| Durum | Açıklama |
|-------|----------|
| `pending` | Talep gönderildi, verici 48 saat içinde yanıt vermeli |
| `accepted` | Verici kabul etti |
| `rejected` | Verici reddetti |
| `in_progress` | Servis başladı |
| `completed` | Servis tamamlandı, **kredi bu noktada transfer edilir** |
| `cancelled` | İptal edildi |
| `expired` | 48 saat içinde yanıt verilmedi, pg_cron otomatik set eder |

### Kurallar
- ✅ 48 saat içinde yanıt verilmezse **otomatik expired** (pg_cron, her 10 dk çalışır)
- ✅ Flutter INSERT yaparken `expires_at = now() + 48 saat` set etmeli
- ✅ Kredi **sadece `completed` durumunda** transfer edilir (`transfer_credits` RPC)
- ✅ İptal/red durumunda kredi kesilmez (zaten kesilmemiş olacak)

---

## 6. Review (Değerlendirme) Sistemi ✅ ONAYLANDI

- [ ] **Çift yönlü review** — hem alıcı hem verici birbirini değerlendirebilir
- [ ] 1-5 yıldız puanlama
- [ ] Yazılı yorum (opsiyonel)
- [ ] Review **düzenlenebilir** (trigger otomatik tekrar `pending_approval` yapar)
- [ ] Review **silinebilir**
- [ ] Sadece `completed` olan talepler için review yazılabilir
- [ ] `avg_rating` trigger ile otomatik hesaplanır (Flutter manuel güncelleme yapmaz)
- [ ] 🔴 **Admin Onayı:** Review yazıldığında `pending_approval` olur. Admin onaylarsa gösterilir.

---

## 7. Ekranlar (Flutter Screens)

| # | Ekran | Açıklama |
|---|-------|----------|
| 1 | **Ana Sayfa** | Servis arama + kategoriler + öne çıkan servisler |
| 2 | **Giriş (OTP)** | Email gir → OTP doğrula |
| 3 | **Servis Detay** | Servis bilgileri + verici profili + review'lar |
| 4 | **Servis Oluştur** | Yeni servis ilanı (kredi fiyatı dahil) |
| 5 | **Profil** | Kullanıcı bilgileri + istatistikler + aldığı/verdiği review'lar |
| 6 | **Taleplerim** | Gelen ve giden talepler |
| 7 | **Servislerim** | Yayınladığım servisler listesi |
| 8 | **Review Yaz** | Çift yönlü puan + yorum formu |

---

## 8. Admin Panel (Web) ✅ ONAYLANDI

Admin süreçleri mobil uygulamadan bağımsız, ayrı bir **Basit Web Panel** üzerinden yürütülecek. Giriş yetkisi `role IN ('moderator', 'admin', 'superadmin')` olanlarda var; ancak görüntüledikleri sektörler role göre kısıtlıdır.

### Moderatör Yetkileri:
1. **Servis Onay Kuyruğu:** `pending_approval` servisleri incele, onayla veya reddet (red sebebi ile).
2. **Review Onay Kuyruğu:** Yazılan değerlendirmeleri yayına al veya uygunsuzsa reddet.
3. **Kullanıcı Listesi:** Kullanıcıları görüntüle (salt okunur).

### Admin Yetkileri (Moderatör yetkilerine ek):
4. **Kategori Yönetimi (Tree):** Sürükle bırak ile parent/child ilişkili kategoriler.
5. **Kredi Yönetimi:** Kullanıcılara kredi ekle/çıkar (`admin_adjustment`).
6. **Moderatör Yönetimi:** `user`'a `moderator` rolü ata veya geri al.

### Superadmin Yetkileri (Admin yetkilerine ek):
7. **Admin Yönetimi:** `moderator`'a `admin` rolü ata veya geri al.
8. **Sistem Ayarları:** Gelecekte eklenebilecek ek sistem parametreleri.
9. **Tek Hesap Kuralı:** Veritabanında yalnızca 1 adet `superadmin` olmalı. Supabase SQL Editor'dan manuel set edilir, panel üzerinden atanamaz.

---

## 9. Backend — Supabase (PostgreSQL) ✅ TASARIM TAMAMLANDI

Tüm veritabanı şeması `Supabase_Schema.sql` dosyasına yazıldı. Henüz Supabase'e uygulanmadı.

### 9.1 Neden Supabase?
- **Backend Kodu Yok:** Rest API (Express vb.) yazılmasına gerek kalmaz. Flutter doğrudan db'ye bağlanır.
- **Hazır Auth:** Supabase'in hazır Email OTP altyapısı kullanılır.
- **Canlı Veri (Real-time):** Yeni bir talep geldiğinde Flutter anında `.stream()` ile güncellenir.
- **Güvenlik (RLS):** Yetkiler doğrudan Postgres DB'sinde yazılır.
- **Harita (PostGIS):** Mesafe hesaplamaları PostGIS ile yapılır.

### 9.2 Schema Özeti (Supabase_Schema.sql — V2)

| Tablo | Durum | Notlar |
|-------|-------|--------|
| `profiles` | ✅ Tasarlandı | `avatar_url`, `avg_rating` eklendi |
| `categories` | ✅ Tasarlandı | Tree yapısı, sadece admin yönetir |
| `services` | ✅ Tasarlandı | Admin onay akışı dahil |
| `service_requests` | ✅ Tasarlandı | `expires_at` Flutter tarafı set eder |
| `reviews` | ✅ Tasarlandı | Çift yönlü, admin onaylı |
| `credit_transactions` | ✅ Tasarlandı | Sadece trigger/RPC yazar |
| Trigger: `handle_new_user` | ✅ Tasarlandı | Yeni üye → profil + 1 kredi |
| Trigger: `handle_review_update` | ✅ Tasarlandı | Düzenleme → pending_approval |
| Trigger: `update_avg_rating` | ✅ Tasarlandı | Onay → avg_rating güncelle |
| RPC: `transfer_credits` | ✅ Tasarlandı | Atomik kredi transferi |
| RPC: `check_credits` | ✅ Tasarlandı | Talep öncesi bakiye kontrolü |
| pg_cron job | ✅ Tasarlandı | 48 saat expire (her 10 dk) |
| RLS Poliçeleri | 🔴 Henüz yazılmadı | Faz 2'de ayrı dosya yapılacak |

---

## 10. Teknoloji Stack ✅ GÜNCELLENDI

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Flutter Web / Mobile |
| State Management | Provider |
| Backend & DB | **Supabase (PostgreSQL)** |
| Auth | **Supabase Auth** (Email OTP) |
| Harita/Konum | **PostGIS** |
| File Upload | **Supabase Storage** |

---

## 11. Onay Durumu

| Madde | Durum |
|-------|-------|
| Kullanıcı sistemi (OTP) | ✅ Supabase Auth ile yapılacak |
| Kredi sistemi | ✅ `transfer_credits` RPC (Supabase Func) ile güvenli yapılacak |
| Servis kategorileri (v1) | ✅ Parent/Child tree yapısı (DB) |
| Servis talep akışı | ✅ RLS ile korunacak, Real-Time akacak |
| Review sistemi (çift yönlü) | ✅ Onaylı |
| Backend teknolojisi | ✅ **Supabase** (Node.js/MySQL tamamen iptal edildi) |
| Harita / Konum | ✅ PostGIS ile `latitude`/`longitude` tutulacak |
| Supabase Schema (V2) | ✅ Tasarım tamamlandı, uygulanmayı bekliyor |
| Flutter ekranları | 🟡 Detaylandırılacak |

---

## 12. İmplementasyon Yol Haritası

> 🔴 **Henüz hiçbir adım başlanmadı. Aşağıdaki sırayla ilerlenecek.**

---

### ✅ Faz 0 — Ön Hazırlık (BAŞLANMADI)

- [ ] Supabase hesabı oluştur / proje aç
- [ ] Proje URL ve `anon key` değerlerini not al (Flutter için lazım)
- [ ] **Authentication > Email OTP** aktif et (Dashboard > Auth > Providers > Email)
- [ ] **PostGIS** eklentisini aktif et (Dashboard > Database > Extensions > postgis)
- [ ] **pg_cron** eklentisini aktif et (⚠️ Free tier'da yoktur — Pro gerekir)
  - Free tierdaysan pg_cron yerine **Edge Function + Scheduled Trigger** kullanılacak
- [ ] **Supabase Storage** üzerinde `avatars` adlı bucket oluştur (public erişim)

---

### 🏗️ Faz 1 — Veritabanı Kurulumu (BAŞLANMADI)

Sırasıyla `Supabase_Schema.sql` dosyasındaki her aşama uygulanacak:

- [ ] **Aşama 1:** Extensions (`postgis`, `pg_cron`) — SQL Editor'dan çalıştır
- [ ] **Aşama 2:** Tabloları oluştur (profiles, categories, services, service_requests, reviews, credit_transactions)
  - [ ] Her tablonun Supabase Table Editor'da göründüğünü doğrula
- [ ] **Aşama 3:** Trigger'ları oluştur (handle_new_user, handle_review_update, update_avg_rating)
  - [ ] Test: Yeni kullanıcı oluşturulduğunda `profiles` tablosuna satır ekleniyor mu?
  - [ ] Test: `credit_transactions`'da `signup_bonus` kaydı oluşuyor mu?
- [ ] **Aşama 4:** RPC fonksiyonlarını oluştur (transfer_credits, check_credits)
  - [ ] Test: `check_credits` doğru boolean dönüyor mu?
- [ ] **Aşama 5:** pg_cron job'u ekle (⚠️ pg_cron aktifse)
- [ ] **Seed Data:** `categories` tablosuna 8 kök kategoriyi ekle (ayrı seed.sql yaz)

---

### 🔒 Faz 2 — Güvenlik: RLS Poliçeleri (BAŞLANMADI)

`RLS_Policies.sql` adlı ayrı dosya oluşturulacak.

- [ ] `profiles` → Herkes SELECT | Sadece kendisi UPDATE | admin/superadmin tümünü görür
- [ ] `categories` → Herkes SELECT | Sadece admin & superadmin INSERT/UPDATE/DELETE
- [ ] `services` → Herkes SELECT (yalnızca active olanlar) | Sadece sahibi yazabilir | moderator/admin/superadmin status güncelleyebilir
- [ ] `service_requests` → Sadece requester/provider okur & yazar | moderator/admin/superadmin listeler (salt okunur)
- [ ] `reviews` → Onaylananları herkes SELECT | Sadece reviewer INSERT/UPDATE | moderator/admin/superadmin status güncelleyebilir
- [ ] `credit_transactions` → Sadece kendisi SELECT | Kimse doğrudan yazamaz | admin/superadmin listeler
- [ ] Rol atama kuralı: `moderator` rolunu yalnızca admin & superadmin verebilir; `admin` rolünü yalnızca superadmin verebilir
- [ ] Tüm tabloları test et (user / moderator / admin / superadmin rolleriyle ayrı ayrı)

---

### 📱 Faz 3 — Flutter Supabase Entegrasyonu (BAŞLANMADI)

- [ ] Flutter projesine `supabase_flutter` paketini ekle (`pubspec.yaml`)
- [ ] `main.dart`'ta Supabase init yap (URL + anon key ile)
- [ ] **Auth Akışı:**
  - [ ] Email OTP gönderme (`supabase.auth.signInWithOtp`)
  - [ ] OTP doğrulama (`supabase.auth.verifyOtp`)
  - [ ] Oturum yönetimi (access + refresh token)
  - [ ] Oturum kontrolü (app açılışında `supabase.auth.currentSession`)
- [ ] **Supabase Storage:** Avatar yükleme (`supabase.storage.from('avatars').upload(...)`)
- [ ] **Provider ile State Management** kurulumu

---

### 🖥️ Faz 4 — Flutter Ekranları & İş Mantığı (BAŞLANMADI)

- [ ] **Ana Sayfa** — Kategori listesi + Servis arama + PostGIS konum filtresi
- [ ] **Servis Detay** — Servis bilgileri + verici profili + onaylı review'lar
- [ ] **Servis Oluştur** — Kredi fiyatı + kategori + konum formu
- [ ] **Profil Ekranı** — Kullanıcı istatistikleri + avatar + kredi bakiyesi
- [ ] **Taleplerim** — Gelen/giden talepler + durum takibi
- [ ] **Servislerim** — Yayınlanan servisler + durum bilgisi
- [ ] **Review Yaz** — Çift yönlü puan + yorum
- [ ] **Real-Time Dinleme** — `.stream()` ile anlık talep/durum güncellemeleri

---

### 🛠️ Faz 5 — Admin Web Paneli (BAŞLANMADI)

- [ ] Basit bir React veya Supabase Studio üzerinden admin işlemleri
- [ ] **Giriş Kontrolü:** `role IN ('moderator', 'admin', 'superadmin')` olan hesaplar giriş yapabilir; sayfa içeriği role göre filtrelenir
- [ ] **Moderator Paneli:**
  - [ ] Servis Onay Kuyruğu — `pending_approval` servisleri listele, onayla/reddet
  - [ ] Review Onay Kuyruğu — `pending_approval` review'ları listele, onayla/reddet
  - [ ] Kullanıcı Listesi — salt okunur görüntüleme
- [ ] **Admin Paneli (Mod. görünümleri + ekstralar):**
  - [ ] Kategori Yönetimi — Tree görünümü, parent/child ekleme/silme
  - [ ] Kredi Yönetimi — Kullanıcılara kredi ekle/çıkar (`admin_adjustment`)
  - [ ] Mod. Atama — Kullanıcıya `moderator` rolü ver / geri al
- [ ] **Superadmin Paneli (Admin görünümleri + ekstralar):**
  - [ ] Admin Atama — `moderator`'a `admin` rolü ver / geri al
  - [ ] Superadmin rolunu panel üzerinden atama **(KAPAT)** — sadece SQL ile yapılabilir

---

> **Not:** MySQL tabanlı eski yaklaşım terk edilmiştir. Tüm geliştirme akışı Supabase mimarisine göre yapılacaktır.
