part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserInfo extends UserEvent {
  final String token;
  const GetUserInfo(this.token);
  @override
  List<Object?> get props => [token];
}

class UpdateUserInfo extends UserEvent {
  final String token;
  final String? newName;
  final String? newAvatarPath;
  const UpdateUserInfo(this.token, this.newName, this.newAvatarPath);

  @override
  List<Object?> get props => [token, newName];
}

class CheckUser extends UserEvent {}

class Logout extends UserEvent {}
