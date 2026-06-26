# E- Wallet "dompet_kampus_global"

Nama : Mison Wenda 
NIM : 1123150103
Jurusan : Teknik Informatika
Konsentrasi : SoftWare Engineering
Kelas : TI SE 23 P2
Matakuliah : Mobileprogramming2

## Tugas UAS mobile App 

# Alur Integrasi Marketplace dan E-Wallet Menggunakan Deep Link

Project ini terdiri dari dua aplikasi yang saling terintegrasi, yaitu aplikasi **Marketplace** dan aplikasi **E-Wallet Dompet Kampus**. Marketplace digunakan untuk membuat pesanan, sedangkan E-Wallet digunakan sebagai metode pembayaran. Integrasi antara kedua aplikasi dilakukan menggunakan **Deep Link**.

Deep link adalah link khusus yang dapat membuka aplikasi e-wallet secara langsung dari aplikasi marketplace sambil membawa data transaksi seperti `order_id`, `amount`, dan `callback_url`.

Contoh deep link:

```text
myewallet://pay?order_id=ORD123&amount=50000&callback_url=https://marketplace.com/callback
```

## Data yang Dikirim Melalui Deep Link

Deep link membawa beberapa data penting dari marketplace ke e-wallet:

| Parameter      | Fungsi                                                            |
| -------------- | ----------------------------------------------------------------- |
| `order_id`     | ID pesanan dari marketplace                                       |
| `amount`       | Total nominal pembayaran                                          |
| `callback_url` | URL callback untuk mengembalikan status pembayaran ke marketplace |

## Alur Kerja Sistem

### 1. User Melakukan Checkout di Marketplace

User memilih produk pada aplikasi marketplace, kemudian masuk ke halaman checkout. Setelah itu marketplace membuat data pesanan dengan status awal belum dibayar.

Contoh data pesanan:

```text
Order ID : ORD123
Total    : Rp50.000
Status   : pending
```

Setelah user memilih metode pembayaran menggunakan E-Wallet Dompet Kampus, marketplace membuat deep link pembayaran.

Contoh:

```text
myewallet://pay?order_id=ORD123&amount=50000&callback_url=https://marketplace.com/callback
```

Deep link tersebut kemudian dibuka agar aplikasi e-wallet dapat menerima data pembayaran.

### 2. Aplikasi E-Wallet Terbuka Melalui Deep Link

Pada aplikasi e-wallet, deep link ditangani oleh `DeepLinkWrapper`. Sistem akan membaca link yang masuk dan memastikan formatnya sesuai.

Format yang valid:

```text
scheme : myewallet
host   : pay
```

Jika deep link valid, aplikasi mengambil data:

```text
order_id
amount
callback_url
```

Data tersebut kemudian disimpan sebagai payload pembayaran.

### 3. E-Wallet Mengecek Status Login User

Setelah deep link diterima, aplikasi e-wallet mengecek apakah user sudah login dan sudah terverifikasi.

Pengecekan dilakukan menggunakan token login dan status autentikasi.

Jika user sudah login, aplikasi langsung mengarahkan user ke halaman merchant checkout.

Jika user belum login, data deep link disimpan sementara agar tidak hilang. Setelah user berhasil login, pembayaran dapat dilanjutkan menggunakan data deep link tersebut.

### 4. User Masuk ke Halaman Merchant Checkout

User diarahkan ke halaman merchant checkout untuk melihat detail pembayaran.

Data yang ditampilkan antara lain:

```text
Order ID : ORD123
Nominal  : Rp50.000
```

Pada halaman ini user dapat mengecek detail pembayaran sebelum melanjutkan proses transaksi.

### 5. User Melakukan Konfirmasi Pembayaran

Setelah user menekan tombol bayar, aplikasi akan meminta user memasukkan PIN atau OTP sebagai validasi keamanan transaksi.

Tujuannya adalah memastikan bahwa transaksi benar-benar dilakukan oleh pemilik akun.

### 6. E-Wallet Mengirim Request Pembayaran ke Backend

Setelah PIN atau OTP dimasukkan, aplikasi e-wallet mengirim request pembayaran ke backend.

Alur request pada Flutter:

```text
PaymentBloc
→ PaymentRepositoryImpl
→ PaymentRemoteDatasourceImpl
→ ApiClient
→ proses_bayar.php
```

Data yang dikirim ke backend:

```json
{
  "order_id": "ORD123",
  "amount": 50000,
  "pin": "123456",
  "otp_type": "pin"
}
```

### 7. Backend Memvalidasi Token User

Backend e-wallet akan memvalidasi token user menggunakan helper `validate_token`.

Token dikirim melalui header:

```text
Authorization: Bearer TOKEN_USER
```

Jika token valid, backend akan mendapatkan `user_id` dari user yang sedang login.

Jika token tidak valid atau tidak tersedia, backend akan mengembalikan response unauthorized.

### 8. Backend Mengecek Saldo User

Setelah token valid, backend mengambil saldo user dari database.

Query menggunakan `FOR UPDATE` agar data saldo terkunci sementara selama transaksi berlangsung. Hal ini bertujuan untuk mencegah konflik jika ada beberapa transaksi yang berjalan bersamaan.

```sql
SELECT id, saldo FROM users WHERE id = ? FOR UPDATE
```

### 9. Backend Mengecek Status Order

Backend juga mengecek apakah order tersebut sudah pernah dibayar sebelumnya.

Jika `order_id` sudah memiliki transaksi dengan status `success`, maka pembayaran akan ditolak agar tidak terjadi pembayaran ganda.

### 10. Jika Saldo Tidak Mencukupi

Jika saldo user kurang dari nominal pembayaran, backend akan mencatat transaksi dengan status `failed`.

Contoh status transaksi:

```text
Status     : failed
Keterangan : Saldo tidak mencukupi
```

Kemudian backend mengirim response gagal ke aplikasi e-wallet.

### 11. Jika Saldo Mencukupi

Jika saldo mencukupi, backend akan mengurangi saldo user.

Contoh:

```text
Saldo awal : Rp100.000
Pembayaran : Rp50.000
Saldo akhir: Rp50.000
```

Setelah itu backend mencatat transaksi dengan status `success`.

Contoh data transaksi:

```text
Order ID   : ORD123
Tipe       : payment
Nominal    : Rp50.000
Status     : success
Keterangan : Pembayaran dari Marketplace
```

Backend kemudian mengirim response sukses ke aplikasi e-wallet.

Contoh response:

```json
{
  "success": true,
  "message": "Pembayaran berhasil",
  "data": {
    "order_id": "ORD123",
    "sisa_saldo": 50000
  }
}
```

### 12. E-Wallet Menampilkan Halaman Sukses

Setelah backend mengirim response sukses, aplikasi e-wallet menampilkan halaman pembayaran berhasil.

Informasi yang ditampilkan dapat berupa:

```text
Pembayaran Berhasil
Order ID    : ORD123
Nominal     : Rp50.000
Sisa Saldo  : Rp50.000
```

### 13. Marketplace Menerima Status Pembayaran

Setelah pembayaran berhasil, marketplace dapat menerima status pembayaran melalui `callback_url`.

Data callback dapat berisi:

```json
{
  "order_id": "ORD123",
  "status": "success",
  "amount": 50000
}
```

Setelah menerima callback, marketplace mengubah status pesanan menjadi sudah dibayar.

Contoh perubahan status:

```text
pending → paid
```

## Ringkasan Alur Integrasi

```text
1. User checkout di marketplace
2. Marketplace membuat order_id dan total pembayaran
3. Marketplace membuka deep link myewallet://pay
4. E-wallet menerima deep link melalui DeepLinkWrapper
5. E-wallet mengambil order_id, amount, dan callback_url
6. E-wallet mengecek status login user
7. Jika user sudah login, masuk ke halaman merchant checkout
8. User melakukan konfirmasi pembayaran
9. User memasukkan PIN atau OTP
10. E-wallet mengirim request pembayaran ke backend
11. Backend memvalidasi token user
12. Backend mengecek saldo user
13. Backend mengecek apakah order sudah pernah dibayar
14. Jika saldo cukup, saldo user dikurangi
15. Backend mencatat transaksi sukses
16. E-wallet menampilkan halaman pembayaran berhasil
17. Marketplace menerima callback dan mengubah status order menjadi paid
```

## Pembagian Tugas Setiap Sistem

### Marketplace

Marketplace bertugas untuk:

* Menampilkan produk
* Membuat pesanan
* Menghasilkan `order_id`
* Menghitung total pembayaran
* Membuat deep link pembayaran
* Mengirim user ke aplikasi e-wallet
* Menerima callback status pembayaran
* Mengubah status order menjadi paid jika pembayaran berhasil

### E-Wallet

E-Wallet bertugas untuk:

* Menerima deep link dari marketplace
* Membaca data `order_id`, `amount`, dan `callback_url`
* Mengecek status login user
* Menampilkan halaman checkout merchant
* Meminta PIN atau OTP
* Mengirim request pembayaran ke backend
* Menampilkan hasil pembayaran
* Menyimpan riwayat transaksi

### Backend E-Wallet

Backend e-wallet bertugas untuk:

* Memvalidasi token user
* Mengambil data saldo user
* Mengecek kecukupan saldo
* Mencegah pembayaran ganda
* Mengurangi saldo jika pembayaran berhasil
* Mencatat transaksi ke database
* Mengirim response sukses atau gagal ke aplikasi Flutter

## Kesimpulan

Integrasi marketplace dan e-wallet menggunakan deep link memungkinkan user berpindah dari aplikasi marketplace ke aplikasi e-wallet secara langsung untuk melakukan pembayaran.
Deep link hanya berfungsi sebagai penghubung dan pembawa data transaksi. Proses pembayaran sebenarnya tetap dilakukan oleh aplikasi e-wallet dan backend e-wallet.
Dengan alur ini, sistem menjadi lebih aman dan terstruktur karena pembayaran tetap melalui validasi token, pengecekan saldo, validasi PIN atau OTP, serta pencatatan transaksi di database.


Link github backend dan frontend project aplikasi marketplace dan E-Wallet yang sudah terintegrasi menggunakan Deeplink:

- [Backend E-Wallet ( Dompet_Kampus_Global )](https://github.com/Mison1212/backend_api_e-wallet)
- [Frontend Aplikasi Ecommerce atau marketplace](https://github.com/Mison1212/pasar_malam)
- [Backend Ecommerce atau Marketpla](https://github.com/Mison1212/backend_api_marketplace_fashionpapua)

## Marketplace
    1. [splash marektplace]<img width="407" height="920" alt="image" src="https://github.com/user-attachments/assets/370fd7ca-9065-48f8-8c07-10aa46d860e0" />
    2. [Login marketplace]<img width="407" height="922" alt="image" src="https://github.com/user-attachments/assets/1634a36d-6034-461b-8c75-21b1003feecb" />
    3. [Dashboard Marketplace]<img width="406" height="918" alt="image" src="https://github.com/user-attachments/assets/33f3bf55-fa2d-4f9d-a293-2af380a793ca" />
    4. [Detile Produk]<img width="410" height="920" alt="image" src="https://github.com/user-attachments/assets/3f826fc9-f92e-44ef-a1b6-a23738682b1b" />
    5. [Keranjang Belanja]<img width="407" height="922" alt="image" src="https://github.com/user-attachments/assets/9a379e7a-4b4c-4e35-8522-b4604be08c63" />
    6. [Checkout]<img width="410" height="922" alt="image" src="https://github.com/user-attachments/assets/12ac182a-52b0-408c-a119-bd00b73b06c8" />

    





