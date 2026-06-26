import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<({UserEntity user, String token})> call(String nama, String email, String password) {
    return repository.register(nama, email, password);
  }
}
