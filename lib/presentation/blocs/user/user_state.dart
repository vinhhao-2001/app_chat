part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

final class UserInitialState extends UserState {}

final class UserLoadedState extends UserState {
  final String userName;
  final String fullName;
  final String? avatar;
  final Image? avatarImage;

  const UserLoadedState({
    required this.userName,
    required this.fullName,
    required this.avatar,
    this.avatarImage,
  });

  UserLoadedState copyWith({
    String? userName,
    String? fullName,
    String? avatar,
    Image? avatarImage,
  }) {
    return UserLoadedState(
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      avatarImage: avatarImage ?? this.avatarImage,
    );
  }

  @override
  List<Object?> get props => [userName, fullName, avatar, avatarImage];
}

final class UserLoadingState extends UserState {}

final class UserErrorState extends UserState {
  final String message;

  const UserErrorState(this.message);

  @override
  List<Object?> get props => [message];
}