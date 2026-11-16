# Mixing & Pump SCADA — Aplikasi Flutter iOS + Firebase Realtime Database

Aplikasi iOS bergaya **Modern Industrial Dark (Cupertino)** untuk memonitor dan mengontrol sistem **Mixer** dan **Pump (dengan PID Control)** secara *real-time* menggunakan **Google Firebase Realtime Database**.

## Fitur Utama

1. **Panel Unit Mixer**:
   - Tombol **START MIXER** & **STOP MIXER** dengan umpan balik *HapticFeedback* khas iOS.
   - Tampilan *real-time* **Arus (Ampere)** dan **Frequency (Hz)** lengkap dengan bar beban.
2. **Panel Unit Pump & PID Control**:
   - Tombol **START PUMP** & **STOP PUMP**.
   - Tampilan *real-time* **Ampere (A)** dan **Frequency (Hz)**.
   - Panel **Pressure Monitor**: menampilkan **Pressure PV (Aktual - Bar)**, **Pressure SV (Target - Bar)**, selisih error (`Δ Bar`), dan tombol cepat `-` / `+` untuk mengubah Setpoint SV.
   - Panel **PID Control**:
     - Pilihan mode **AUTO (Closed-Loop)** atau **MANUAL (Open-Loop)**.
     - Indikator parameter **Kp**, **Ki**, **Kd**, serta **PID Output (MV %)**.
     - *Bottom Sheet* khusus untuk melakukan *tuning* nilai **Kp, Ki, Kd** dan **Pressure SV** beserta preset tuning cepat.
3. **Mode Simulasi Otomatis (Demo)**:
   - Dilengkapi simulator fisika VFD & algoritma PID diskrit setiap `400 ms` yang menggerakkan nilai Arus, Frekuensi, PID Output, dan Pressure PV secara realistis menuju Pressure SV saat tombol Start ditekan.

## Cara Menghubungkan ke Firebase Realtime Database (iOS)

1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat proyek baru atau buka proyek Anda.
2. Tambahkan aplikasi **iOS** dengan Bundle ID (misal `com.example.mixingPumpIosScada`) lalu unduh berkas `GoogleService-Info.plist`.
3. Letakkan berkas `GoogleService-Info.plist` ke dalam folder `ios/Runner/GoogleService-Info.plist`.
4. Buka menu **Realtime Database** di Firebase Console, lalu klik **Import JSON** dan pilih berkas `firebase_seed_data.json` yang sudah disediakan di proyek ini.
5. Jalankan aplikasi:
   ```bash
   flutter pub get
   flutter run
   ```
