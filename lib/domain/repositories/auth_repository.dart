import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({UserEntity user, String token})> register(String nama, String email, String password);
  Future<({UserEntity user, String token})> login(String email, String password);
  Future<void> verifyEmailOtp(String code);
  Future<UserEntity> getMe();
  Future<void> updateFcmToken(String fcmToken);
  Future<void> logout();
  Future<String?> getSavedToken();
  Future<UserEntity?> getSavedUser();
  Future<void> setAuthVerified(bool verified);
  Future<bool> isAuthVerified();
}
