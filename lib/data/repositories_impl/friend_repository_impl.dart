import 'package:app_chat/data/data_mapper/friend_data_mapper.dart';
import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/models/friend_model.dart';
import 'package:app_chat/domain/entities/friend_entity.dart';
import 'package:app_chat/domain/repositories/friend_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FriendRepository)
class FriendRepositoryImpl implements FriendRepository {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final FriendDataMapper _friendDataMapper;

  FriendRepositoryImpl(
      this._apiService, this._friendDataMapper, this._databaseHelper);

  @override
  Future<List<FriendEntity>> getFriendList(String token) async {
    List<FriendModel> friendList = await _apiService.getFriendList(token);
    if (friendList.isNotEmpty) {
      friendList = await _databaseHelper.updateAllFriends(friendList);
    } else {
      friendList = await _databaseHelper.getAllFriends();
    }
    return friendList.map(_friendDataMapper.mapToFriendEntity).toList();
  }
}
