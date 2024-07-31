import 'package:app_chat/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getUser(String token);

  Future<bool> updateUser(
      String token, String? fullName, String? avatarFilePath);

}
