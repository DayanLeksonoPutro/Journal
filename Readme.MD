## Nama App

Journal

## Bundle id 
com.appnovasi.journal

## Deskripsi Singkat 80 char
"Engine jurnal kustom: bangun tracker sholat, belanja, hingga trading journal."
"Satu aplikasi untuk semua tracker, rakit form kustom sesuai hobimu."
"Journal cerdas dengan Success Meter: Pantau progress trading & target harian."

## Penjelasan APP
Aplikasi "Journal Engine" yang memungkinkan user membangun sistem pencatatan mereka sendiri. Bukan sekadar catatan teks, tapi platform untuk merakit form kustom (Input Builder) untuk berbagai kebutuhan spesifik dengan fitur pengukuran keberhasilan (Success Rate).

## Fitur Utama (Versatilitas):
1.  **Custom Template Builder**: User merakit field sesuai kebutuhan (Teks, Angka, Checkbox, Image Before/After).
2.  **Success Meter (KPI)**: Menandai field tertentu sebagai indikator "Sukses" (misal: Win dalam trading, atau Selesai dalam target).
3.  **Category Based**: Pengelompokan jurnal berdasarkan hobi/kebutuhan (Folder System).
4.  **Image Comparison**: Slot khusus gambar Before/After (untuk Trading Chart atau Fitness Progress).

## Studi Kasus:
*   **Tracking Sholat**: Template Checklist 5 waktu. Success = Semua Tercentang.
*   **Checklist Belanja**: Template list belanja sederhana dengan fitur hapus/edit cepat.
*   **Trading Journal**: Field Pair, Profit (Number), Screenshot Chart (Before/After), dan Result (Win/Loss).
*   **Fitness & Diet**: Log kalori harian dan foto progres fisik.

## STRATEGI KONTEN TIKTOK (Viral Hooks)
*   **Hook Trading**: "Cara gue track win-rate trading biar gak boncos (pakai jurnal ini)."
*   **Hook Trading**: "Gini cara gue hitung Win-Rate trading cuma pake HP, rapi banget!"
*   **Hook Ibu Rumah Tangga**: "List belanja & jadwal imunisasi anak dalam satu aplikasi, sat-set banget"
*   **Hook Self-Care**: "POV: Lu mulai journaling setiap pagi dan mental health lu membaik."
*   **Hook Productivity**: "Berhenti pakai 10 aplikasi, satu Journal ini bisa buat semua (Notes, Todo, Finance)."
*   **Aesthetic Hook**: Video ASMR mengetik/input data dengan font aesthetic & dark mode.
*   **Hook Minimalis**: "Berhenti install banyak app tracker. Satu app ini bisa buat sholat, gym, sampe belanja."
*   **Hook Aesthetic**: Video transisi pembuatan template jurnal yang aesthetic (Dark mode + Lucide Icons).

## Struktur Navigasi Utama (5 Tab)

1. **Home** → (Smart Dashboard: Ringkasan Progress harian & Widget Kategori Favorit)
2. **Journal** → (The Engine: List Kategori & Input Journal kustom)
3. **Task/Notes** → (Quick List: Catatan cepat atau Checklist belanja tanpa template rumit)
4. **Report** → (Analysis: Visualisasi Success Rate (%), Grafik Keuangan, & Konsistensi harian)
5. **Setting** → (Personalization: Tema, Font, Mode App, & Data Management)

---

## 1. TAB HOME (Smart Dashboard)
*   **Daily Quote Card**: Motivasi harian (bisa di-share).
*   **Fast Action Widget**: Tombol "+" cepat untuk kategori yang paling sering digunakan.
*   **Success Overview**: Ringkasan singkat "Success Rate" harian dari semua kategori yang dilacak.
*   **Recent Entries**: List 3 entri terakhir untuk akses cepat.

## 2. TAB JOURNAL (The Engine)
*   **Category Grid**: List folder/kategori yang sudah dibuat user (Trading, Sholat, dll).
*   **Template Manager**: Tempat mengedit field (Tambah/Hapus kolom, Ubah Icon).
*   **Log Entry**: Tampilan list data per kategori dengan preview gambar Before/After.
*   **Search & Filter**: Cari data berdasarkan tanggal atau label sukses.

## 3. TAB TASK/CATATAN (Quick Checklist)
*   **Simple Todo**: Checklist cepat satu baris (untuk belanjaan dadakan atau reminder).
*   **Plain Notes**: Catatan teks bebas tanpa strukur (untuk ide spontan).
*   **Draft System**: Catatan yang bisa dipindahkan menjadi entri Journal permanen nanti.

## 4. TAB REPORT (Advanced Analytics)
*   **Success Rate Chart**: Grafik persentase keberhasilan per kategori (misal: Win-rate Trading 65%).
*   **Consistency Heatmap**: Seperti grid kontribusi GitHub untuk melihat rutinitas (misal: Sholat/Gym).
*   **Financial Summary**: Total angka (jika ada field bertipe Number/Currency).
*   **Shareable Insight**: Tombol untuk generate gambar "Report Kartu" (9:16) untuk sosmed.

## 5. TAB PENGATURAN
*   Bahasa (Indonesia, English)
*   Dark Mode & Color Theme Custom (6-8 Palette)
*   Font Style (Aesthetic/Gen-Z fonts: Inter, Montserrat, Poppins, Open Sans, Space Grotesk)
*   Font Size (Kecil, Sederhana, Besar)
*   **Mode App**: Simple (Sembunyikan Tab Report), Advanced (Full Fitur).
*   Data Management: Backup/Restore (Local file), Clear Data.
*   Manajemen Kategori
*   Developer Options: Dummy data generator.
    * Versi
    * Tutorial
    * Rate App
    * Share App

---

## TEKNIS DEVELOPMENT
*   **Framework**: Flutter (Android).
*   **Storage**: Local storage (Shared Preferences dalam bentuk JSON).
*   **Icons**: Lucide Icons (Clean & Modern).
*   **Visual Style**: Minimalist, High-Contrast (Black & White base), Smooth transitions.
*   **Export Feature**: Widget-to-Image untuk fitur Shareable Card.
*   **Custom Form Logic**: Dynamic form builder yang bisa generate controller secara otomatis berdasarkan template yang didefinisikan user.

## note lain lain
* ChangeNotifier provider 
* Full Icon https://pub.dev/packages/iconoir_flutter
* untuk kategori disiapkan dari aplikasi tetapi masih bisa di edit dan di tambahkan
* Di Toolbar ada Share dan Rate App
* onboarding 3 step dengan 3 Icon iconoir tanpa background / png 
* Flutter Single File Approach setiap halaman dengan pisahkan:
    * UI
    * Provider
    * Model 
