import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register(
      String fullName, String username, String password);

  Future<UserEntity> login(String username, String password);
}
