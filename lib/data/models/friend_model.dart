import 'dart:convert';

import '../../core/constants/api_constants.dart';

class FriendModel {
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

  FriendModel({
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

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    // Chuyển chuỗi json từ api server thành đối tượng Friend
    return FriendModel(
      friendID: json[ApiConstants.friendId] ?? '',
      fullName: json[ApiConstants.fullName] ?? '',
      username: json[ApiConstants.username] ?? '',
      avatar: json[ApiConstants.avatar] ?? '',
      content: json[ApiConstants.content] ?? '',
      files: json[ApiConstants.files] ?? [],
      images: json[ApiConstants.images] ?? [],
      isSend: json[ApiConstants.isSend] ?? 0,
      isOnline: json[ApiConstants.isOnline] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    // Chuyển đối tượng Friend thành Map để lưu vào db
    return {
      ApiConstants.friendId: friendID,
      ApiConstants.fullName: fullName,
      ApiConstants.username: username,
      ApiConstants.avatar: avatar,
      ApiConstants.content: content,
      ApiConstants.files: jsonEncode(files),
      ApiConstants.images: jsonEncode(images),
      ApiConstants.isSend: isSend,
      ApiConstants.isOnline: isOnline ? 1 : 0, // chuyển kiểu thành int
      ApiConstants.nickname: nickname,
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map) {
    // Tạo đối tượng Friend từ Map lấy từ db
    return FriendModel(
      friendID: map[ApiConstants.friendId],
      fullName: map[ApiConstants.fullName] ?? '',
      username: map[ApiConstants.username] ?? '',
      avatar: map[ApiConstants.avatar] ?? '',
      content: map[ApiConstants.content] ?? '',
      files: List<dynamic>.from(jsonDecode(map[ApiConstants.files] ?? '[]')),
      images: List<dynamic>.from(jsonDecode(map[ApiConstants.images] ?? '[]')),
      isSend: map[ApiConstants.isSend] ?? 0,
      isOnline: (map[ApiConstants.isOnline] ?? 0) == 1, // chuyển lại kiểu bool
      nickname: map[ApiConstants.nickname],
    );
  }
}
