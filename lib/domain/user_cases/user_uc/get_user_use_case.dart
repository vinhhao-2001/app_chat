import 'package:app_chat/domain/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';

@injectable
class GetUserUseCase {
  final UserRepository _repository;

  GetUserUseCase(this._repository);

  Future<UserEntity> execute(String token) async {
    return await _repository.getUser(token);
  }
}
