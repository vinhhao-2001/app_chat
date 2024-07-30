class UserEntity {
  final String userName;
  final String fullName;
  final String? avatar;
  final String token;

  UserEntity({
    required this.userName,
    required this.fullName,
    this.avatar,
    required this.token,
  });
}
