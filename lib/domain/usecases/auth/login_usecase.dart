import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<({UserEntity user, String token})> call(String email, String password) {
    return repository.login(email, password);
  }
}
