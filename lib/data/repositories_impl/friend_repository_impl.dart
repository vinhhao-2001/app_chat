import 'package:app_chat/data/data_mapper/friend_data_mapper.dart';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/models/friend_model.dart';
import 'package:app_chat/domain/entities/friend_entity.dart';
import 'package:app_chat/domain/repositories/friend_repository.dart';

class FriendRepositoryImpl extends FriendRepository {
  final ApiService _apiService;
  final FriendDataMapper _friendDataMapper;

  FriendRepositoryImpl(this._apiService, this._friendDataMapper);

  @override
  Future<List<FriendEntity>> getFriendList(String token) async {
    List<FriendModel> friendList = await _apiService.getFriendList(token);
    return friendList.map(_friendDataMapper.mapToFriendEntity).toList();
  }
}
