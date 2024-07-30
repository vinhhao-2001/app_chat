class FriendEntity {
  final String friendID;
  final String fullName;
  final String username;
  final String avatar;
  final String content;
  final List<dynamic> files;
  final List<dynamic> images;
  final int isSend;
  final bool isOnline;
  String? nickname;

  FriendEntity({
    required this.friendID,
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.isOnline,
    this.nickname,
  });
}
