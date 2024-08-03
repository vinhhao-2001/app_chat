part of 'friend_bloc.dart';

sealed class FriendEvent extends Equatable {
  const FriendEvent();
  @override
  List<Object> get props => [];
}

final class FetchFriends extends FriendEvent {
  final String token;
  const FetchFriends(this.token);

  @override
  List<Object> get props => [token];
}

final class SearchFriends extends FriendEvent {
  final String query;

  const SearchFriends(this.query);

  @override
  List<Object> get props => [query];
}

final class CacheAvatar extends FriendEvent {
  final String avatarUrl;
  final Image avatarImage;

  const CacheAvatar(this.avatarUrl, this.avatarImage);

  @override
  List<Object> get props => [avatarUrl, avatarImage];
}

final class UpdateNickname extends FriendEvent {
  final String friendID;
  final String nickname;
  const UpdateNickname(this.friendID, this.nickname);

  @override
  List<Object> get props => [friendID, nickname];
}
