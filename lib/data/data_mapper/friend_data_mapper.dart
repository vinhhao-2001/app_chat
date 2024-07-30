import 'package:app_chat/data/models/friend_model.dart';
import 'package:app_chat/domain/entities/friend_entity.dart';

class FriendDataMapper {
  static FriendEntity mapToFriendEntity(FriendModel friend) {
    return FriendEntity(
        friendID: friend.friendID,
        fullName: friend.fullName,
        username: friend.username,
        avatar: friend.avatar,
        content: friend.content,
        files: friend.files,
        images: friend.images,
        isSend: friend.isSend,
        isOnline: friend.isOnline,
        nickname: friend.nickname);
  }
}