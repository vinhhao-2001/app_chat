import 'package:app_chat/data/models/user_model.dart';
import 'package:app_chat/domain/entities/user_entity.dart';

class UserDataMapper {
  static UserEntity mapToFriendEntity(UserModel user) {
    return UserEntity(
        userName: user.userName, fullName: user.fullName, token: user.token);
  }
}
