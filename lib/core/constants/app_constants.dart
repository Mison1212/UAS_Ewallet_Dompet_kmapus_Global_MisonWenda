class AppConstants {
  static const String appName = 'Wallet';
  static const String appVersion = '1.0.0';

  // API
  // Untuk emulator Android: gunakan 10.0.2.2 (alias untuk localhost di host machine)
  // Untuk HP fisik: gunakan IP Wi-Fi komputer host (cek via ipconfig/ifconfig)
  // Untuk produksi: ganti dengan URL publik/hosting
  static const String baseUrl = 'http://192.168.13.2/backend_ewallet';
  static const String apiVersion = '';
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  // Secure Storage Keys
  static const String kJwtToken = 'jwt_token';
  static const String kUserData = 'user_data';
  static const String k2faMethod = 'twofa_method';
  static const String kFcmToken = 'fcm_token';
  static const String kAuthVerified = 'auth_verified';  

  // 2FA Method identifiers
  static const String twoFaSmtp = 'smtp';
  static const String twoFaTotp = 'totp';
  static const String twoFaNotif = 'notif';

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // PIN
  static const int pinLength = 6;

  // Transaction kinds
  static const String txnTransfer = 'transfer';
  static const String txnTopup = 'topup';
  static const String txnPayment = 'payment';
  static const String txnDeeplink = 'deeplink';
  static const String txnPulsa = 'pulsa';
  static const String txnReceived = 'received';

  // OTP types (backend)
  static const String otpTypeFirebase = 'firebase';
  static const String otpTypeEmail = 'email';
  static const String otpTypeTotp = 'totp';
}
