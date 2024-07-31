import 'package:app_chat/domain/repositories/friend_repository.dart';

import '../../entities/friend_entity.dart';

class GetFriendListUseCase {
  final FriendRepository _repository;

  GetFriendListUseCase(this._repository);

  Future<List<FriendEntity>> execute(String token) async {
    final friendList = await _repository.getFriendList(token);
    friendList.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    return friendList;
  }
}
