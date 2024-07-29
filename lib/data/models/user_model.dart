import '../../core/constants/api_constants.dart';

class UserModel {
  final String userName;
  final String fullName;
  final String? avatar;
  final String token;

  UserModel({
    required this.userName,
    required this.fullName,
    this.avatar,
    required this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map[ApiConstants.username],
      fullName: map[ApiConstants.fullName],
      avatar: map[ApiConstants.avatar],
      token: map[ApiConstants.token],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ApiConstants.username: userName,
      ApiConstants.fullName: fullName,
      ApiConstants.avatar: avatar,
      ApiConstants.token: token,
    };
  }
}
