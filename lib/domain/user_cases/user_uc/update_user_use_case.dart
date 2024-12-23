import 'package:injectable/injectable.dart';

import '../../repositories/user_repository.dart';

@injectable
class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<bool> execute(
      String token, String? fullName, String? avatarFilePath) async {
    return await _repository.updateUser(token, fullName, avatarFilePath);
  }
}
