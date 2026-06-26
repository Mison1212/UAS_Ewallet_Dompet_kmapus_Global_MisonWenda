import 'app_constants.dart';

class ApiEndpoints {
  static const String _base = AppConstants.apiVersion;

  // Health
  static const String health = '$_base/health';

  // Auth
  static const String verifyToken = '$_base/auth_helper.php';
  static const String register = '$_base/register.php';
  static const String login = '$_base/login.php';
  static const String verifyEmailOtp = '$_base/verify_pin.php';
  static const String me = '$_base/get_user_data.php';
  static const String fcmToken = '$_base/fcm-token.php'; // not implemented in backend
  static const String sendOtpFirebase = '$_base/send_otp_firebase.php';
  static const String sendOtpEmail = '$_base/send_otp_email.php';
  static const String confirmOtp = '$_base/confirm_otp.php';
  static const String totpRegister = '$_base/totp_register.php';
  static const String totpVerify = '$_base/totp_verify.php';
  // Account
  static const String account = '$_base/get_user_data.php';
  static const String transactions = '$_base/history.php';

  // Payment
  static const String topup = '$_base/topup.php';
  static const String transfer = '$_base/proses_bayar.php';
}
