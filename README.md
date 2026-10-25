# 🌙 Lunary

Aplikasi pelacak siklus menstruasi berbasis Flutter untuk mata kuliah Pemrograman Mobile, Universitas Sumatera Utara. Pengguna dapat mencatat haid, melihat prediksi fase siklus dan masa subur, membaca artikel edukasi, dan bertanya ke asisten Lunary AI.

## Fitur Utama

- **Splash** dengan animasi cincin siklus.
- **Home (Cycle)** menampilkan hari siklus, fase, cincin pelacak, kalender mingguan, dan tombol *Log Period*.
- **Calendar** berisi kalender bulanan dengan penanda haid, masa subur, ovulasi, dan prediksi haid berikutnya.
- **Cycle Detail** memuat ringkasan fase, kesuburan, hormon, dan saran gaya hidup.
- **Insights** memuat artikel edukasi.
- **Lunary AI** adalah chat bot berbasis aturan yang jawabannya mengikuti fase siklus.
- **Profile** mencakup Sign Up, Login, edit profil, ganti foto dari galeri, dan Logout.

## 1. Setup

**Prasyarat**

- Flutter SDK (Dart ^3.13.2), cek dengan `flutter doctor`
- Android Studio atau VS Code
- Emulator/HP Android, atau target Windows
- Windows: aktifkan *Developer Mode* (`start ms-settings:developers`)

**Langkah**

```bash
git clone https://github.com/naswazhahira/Lunary.git
cd Lunary
flutter pub get
```

## 2. Perintah Run

```bash
flutter devices                      # lihat perangkat yang tersedia
flutter run                          # jalankan di perangkat default
flutter run -d <device-id>           # jalankan di perangkat tertentu
flutter run -d windows               # jalankan di Windows
flutter build apk --release          # build APK
```

APK hasil build ada di `build/app/outputs/flutter-apk/app-release.apk`.

**Jika build Android gagal dengan error `Could not close incremental caches`**, tambahkan di `~/.gradle/gradle.properties`:

```
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
```

## 3. Data Dummy

Aplikasi **tidak memuat data awal haid**. Data dibuat sendiri oleh penguji lewat skenario di bawah. Yang sudah tertanam di kode:

| Data | Nilai / Lokasi |
|---|---|
| Panjang siklus rata-rata | 28 hari (`CycleProvider.averageCycleLength`) |
| Lama haid | 7 hari (`CycleProvider.periodLength`) |
| Fase luteal | 14 hari (`CycleProvider.lutealPhaseLength`) |
| Nama sapaan di Home & AI | "Awa" (hardcoded) |
| Artikel Insights | 3 bagian, 11 kategori, ditulis langsung di `insights_screen.dart` |
| Gambar artikel | `assets/images/` |
| Jawaban Lunary AI | Aturan berbasis kata kunci di `lunary_ai_screen.dart` |

**Akun uji yang disarankan** (dibuat lewat Sign Up, tidak ada akun bawaan):

| Field | Isi |
|---|---|
| Nama | Awa Test |
| Email | awa@gmail.com |
| Password | 123456 |

Aturan validasi: email harus berakhiran `@gmail.com`, password minimal 6 karakter, konfirmasi password harus sama.

## 4. Skenario Simulasi (Tiga Alur Utama)

### Alur 1: Autentikasi dan akses fitur terproteksi

1. Buka aplikasi lalu tunggu Splash selesai, Home terbuka.
2. Tap tab **Insights** atau **Lunary AI**. Muncul dialog *login required*.
3. Tap **Log In/Sign Up**, pilih **Sign Up**, isi akun uji lalu daftar.
4. Login dengan akun yang sama.

**Hasil yang diharapkan:** setelah login berhasil, Insights dan Lunary AI bisa dibuka. Nama akun tampil di Profile.

**Uji negatif:**

| Input | Pesan yang muncul |
|---|---|
| Email tanpa `@gmail.com` | "Email harus menggunakan @gmail.com" |
| Password kurang dari 6 karakter | "Password minimal 6 karakter" |
| Konfirmasi password berbeda | "Konfirmasi password tidak cocok" |
| Login sebelum Sign Up | "Akun belum terdaftar..." |
| Email salah | "Email tidak terdaftar" |
| Password salah | "Password tidak sesuai" |

### Alur 2: Mencatat haid dan prediksi siklus

1. Buka tab **Calendar**.
2. Pilih tanggal **14 hari yang lalu**, lalu tap tombol catat haid.
3. Lihat hasilnya di Calendar, Home, dan Cycle Detail.

**Hasil yang diharapkan:**

- 7 hari berturut-turut tercatat sebagai haid. Hari yang melewati hari ini tidak dicatat.
- Home menampilkan **Day 15** dan fase **Fertile Window**. Ovulasi jatuh pada hari ini, haid berikutnya diprediksi 14 hari lagi.
- Calendar menandai masa subur dan prediksi haid berikutnya.

**Variasi tanggal mulai haid:**

| Mulai haid | Hari siklus | Fase |
|---|---|---|
| 5 hari lalu | Day 6 | Follicular Phase |
| 14 hari lalu | Day 15 | Fertile Window |
| 20 hari lalu | Day 21 | Luteal Phase |

**Uji tambahan:**

- Tap tanggal yang sama sekali lagi untuk membatalkan catatan haid.
- Pilih tanggal di masa depan. Pencatatan tidak bisa dilakukan.
- Tap **Log Period** di Home untuk mencatat haid hari ini.

### Alur 3: Lunary AI dan Insights

1. Login, lalu buka tab **Lunary AI**.
2. Tap saran "What phase am I in?", "When is my next period?", dan "Am I fertile now?".
3. Ketik "kram" atau "makan".
4. Buka tab **Insights**, pilih kategori, lalu buka satu artikel.

**Hasil yang diharapkan:**

- Sebelum ada catatan haid, AI menjawab bahwa data belum ada dan meminta pengguna mencatat haid di Calendar.
- Setelah Alur 2, AI menjawab sesuai fase dan hari siklus.
- Pertanyaan tentang kram, makanan, mood, olahraga, dan tidur dijawab dengan tips.
- Artikel tampil lengkap dengan gambar dan isi.

## Struktur Proyek

```
lib/
├── main.dart
├── core/        # provider, routing, painters, theme, widgets
└── features/    # splash, home, calendar, insights, lunary_ai, profile
assets/images/   # gambar artikel
```

## Teknologi

Flutter, `provider` (state management), `go_router` (routing), `image_picker` (foto profil), `CustomPainter` (cincin dan grafik).

## Batasan

- Data dan akun hanya tersimpan selama sesi berjalan.
- Autentikasi masih simulasi lokal.
- Lunary AI berbasis aturan, bukan model AI.
- Login sosial (Google dll.) baru berupa tampilan.
- Prediksi memakai siklus tetap 28 hari dan bukan pengganti saran medis.

## Tim: Woman Kuat

| Nama | NIM |
|---|---|
| Naswa Zhahira | 241401059 |
| Yesi Jelita Sinaga | 241401071 |
| Grace Claudia Silitonga | 241401128 |
