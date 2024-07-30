import 'package:app_chat/domain/entities/friend_entity.dart';

abstract class FriendRepository {
  Future<List<FriendEntity>> getFriendList(String token);
}
