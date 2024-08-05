part of 'user_bloc.dart';

class UserState extends Equatable {
  final String userName;
  final String fullName;
  final Image? avatarImage;
  final String message;

  const UserState({
    this.userName = '',
    this.fullName = '',
    this.avatarImage,
    this.message = '',
  });

  UserState copyWith({
    String? userName,
    String? fullName,
    Image? avatarImage,
    String? message,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      avatarImage: avatarImage ?? this.avatarImage,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [userName, fullName, avatarImage, message];
}
