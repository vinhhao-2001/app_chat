part of 'friend_bloc.dart';

// enum ListStatus {
//   init,
//   loading,
//   loaded,
//   error,
// }

class FriendState extends Equatable {
  final List<FriendEntity> friendList;
  final Map<String, Image> avatarCache;
  final String query;
  final String message;

  const FriendState({
    this.friendList = const [],
    this.avatarCache = const {},
    this.message = '',
    this.query = '',
  });
  FriendState copyWith({
    List<FriendEntity>? friendList,
    Map<String, Image>? avatarCache,
    String? query,
    String? message,
  }) {
    return FriendState(
        friendList: friendList ?? this.friendList,
        avatarCache: avatarCache ?? this.avatarCache,
        query: query ?? this.query,
        message: message ?? this.message);
  }

  @override
  List<Object?> get props => [friendList, avatarCache, query, message];
}
