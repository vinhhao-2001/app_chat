import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_mapper/user_data_mapper.dart';
import '../data_sources/local/db_helper.dart';
import '../data_sources/remote/api/api_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final UserDataMapper _userDataMapper;

  AuthRepositoryImpl(this._apiService, this._userDataMapper);
  @override
  Future<UserEntity> register(
      String fullName, String username, String password) async {
    UserModel userModel =
        await _apiService.register(fullName, username, password);
    return _userDataMapper.mapToUserEntity(userModel);
  }

  @override
  Future<UserEntity> login(String username, String password) async {
    UserModel userModel = await _apiService.login(username, password);
    return _userDataMapper.mapToUserEntity(userModel);
  }

  @override
  Future<UserEntity?> checkUser() async {
    UserModel? userModel = await DatabaseHelper().getUser();
    if (userModel != null) {
      return _userDataMapper.mapToUserEntity(userModel);
    } else {
      return null;
    }
  }
}
