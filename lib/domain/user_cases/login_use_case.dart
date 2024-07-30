import 'package:app_chat/domain/repositories/user_repository.dart';

import '../entities/user_entity.dart';

class LoginUseCase {
  final UserRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> execute(String username, String password) async {
    return await _repository.login(username, password);
  }
}
