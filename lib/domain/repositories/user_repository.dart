import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getUser(String token);

  Future<bool> updateUser(
      String token, String? fullName, String? avatarFilePath);
}
