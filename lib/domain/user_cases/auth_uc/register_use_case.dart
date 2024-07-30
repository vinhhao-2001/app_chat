import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> execute(
      String fullName, String username, String password) async {
    return await _repository.register(fullName, username, password);
  }
}
