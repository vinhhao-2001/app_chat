part of 'friend_bloc.dart';

sealed class FriendState extends Equatable {
  const FriendState();
  @override
  List<Object> get props => [];
}

final class FriendInitial extends FriendState {}

final class FriendLoading extends FriendState {}

final class FriendLoaded extends FriendState {
  final List<FriendModel> fullFriends;
  final List<FriendModel> filteredFriends;
  final Map<String, Image> avatarCache;

  const FriendLoaded(this.fullFriends, this.filteredFriends, this.avatarCache);

  @override
  List<Object> get props => [fullFriends, filteredFriends, avatarCache];
}

final class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object> get props => [message];
}
