import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<({UserModel user, String token})> register(
    String nama,
    String email,
    String password,
  );

  Future<({UserModel user, String token})> login(
    String email,
    String password,
  );
  Future<void> verifyEmailOtp(String code);
  Future<UserModel> getMe();
  Future<void> updateFcmToken(String fcmToken);
  void clearAuthToken();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _client;
  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<({UserModel user, String token})> register(
    String nama,
    String email,
    String password,
  ) async {
    // 1. Buat akun di Firebase
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Kirim link verifikasi email
    await credential.user?.sendEmailVerification();

    // 3. Buat akun di XAMPP (MySQL)
    await _client.post(
      ApiEndpoints.register,
      data: {'nama': nama, 'email': email, 'pin': password},
    );

    // 4. Return dummy data (token kosong) karena user belum boleh login
    return (
      user: const UserModel(
        id: 0,
        firebaseUid: '',
        email: '',
        name: '',
        role: 'user',
        emailVerified: false,
        totpEnabled: false,
      ),
      token: ''
    );
  }

  @override
  Future<({UserModel user, String token})> login(
    String email,
    String password,
  ) async {
    // 1. Login ke Firebase Auth terlebih dahulu
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Cek apakah email sudah diverifikasi via link
      if (credential.user != null && !credential.user!.emailVerified) {
        throw UnauthorizedException(
          'Email belum diverifikasi. Silakan cek email Anda untuk memverifikasi akun.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw UnauthorizedException('Email atau password salah.');
      }
      throw ServerException(e.message ?? 'Terjadi kesalahan pada Firebase.');
    }

    // 3. Jika lolos Firebase & sudah verifikasi, ambil token dari XAMPP
    final response = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'pin': password},
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);
    _client.setAuthToken(token);
    return (user: user, token: token);
  }

  @override
  Future<void> verifyEmailOtp(String code) async {
    await _client.post(ApiEndpoints.verifyEmailOtp, data: {'code': code});
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    // try to update fcm token if endpoint exists, otherwise ignore for now
    try {
      await _client.post(ApiEndpoints.fcmToken, data: {'fcm_token': fcmToken});
    } catch (_) {}
  }

  @override
  void clearAuthToken() {
    _client.clearAuthToken();
  }
}
