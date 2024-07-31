import 'package:app_chat/domain/entities/user_entity.dart';

import '../../repositories/auth_repository.dart';

class CheckUserUseCase {
  final AuthRepository _repository;

  CheckUserUseCase(this._repository);

  Future<UserEntity?> execute() async {
    return await _repository.checkUser();
  }
}
