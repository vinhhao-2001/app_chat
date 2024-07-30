import '../../domain/repositories/user_repository.dart';
import '../data_sources/remote/api/api_service.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final ApiService _apiService;
  UserRepositoryImpl(this._apiService);

  @override
  Future<UserModel> getUser(String token) async {
    return await _apiService.getUserInfo(token);
  }

  @override
  Future<bool> updateUser(
      String token, String? fullName, String? avatarFilePath) async {
    return await _apiService.updateUserInfo(token, fullName, avatarFilePath);
  }
}
