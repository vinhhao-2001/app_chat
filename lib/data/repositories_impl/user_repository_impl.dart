import 'package:app_chat/data/data_mapper/user_data_mapper.dart';
import 'package:app_chat/domain/entities/user_entity.dart';

import '../../domain/repositories/user_repository.dart';
import '../data_sources/remote/api/api_service.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final ApiService _apiService;
  final UserDataMapper _userDataMapper;

  UserRepositoryImpl(this._apiService, this._userDataMapper);


  @override
  Future<UserEntity> getUser(String token) async {
    UserModel userModel = await _apiService.getUserInfo(token);
    return _userDataMapper.mapToUserEntity(userModel);
  }

  @override
  Future<bool> updateUser(
      String token, String? fullName, String? avatarFilePath) async {
    return await _apiService.updateUserInfo(token, fullName, avatarFilePath);
  }
}
