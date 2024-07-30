import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> execute(String username, String password) async {
    return await _repository.login(username, password);
  }
}
