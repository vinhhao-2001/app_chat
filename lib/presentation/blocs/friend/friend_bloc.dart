import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/utils/di.dart';

import '../../../domain/entities/friend_entity.dart';
import '../../../domain/user_cases/friend_uc/get_friend_list_use_case.dart';
import '../../../domain/user_cases/shared_uc/add_nickname_use_case.dart';

part 'friend_event.dart';
part 'friend_state.dart';

@injectable
class FriendBloc extends Bloc<FriendEvent, FriendState> {
  List<FriendEntity> _friendList = [];
  Map<String, Image> _avatarCache = {};
  Map<String, Image> get avatarCache => _avatarCache;
  FriendBloc() : super(const FriendState()) {
    on<FetchFriends>((event, emit) async {
      emit(state.copyWith());
      try {
        final getFriendList = getIt<GetFriendListUseCase>();
        // lấy danh sách bạn bè
        _friendList = await getFriendList.execute(event.token);
        if (_friendList.isNotEmpty) {
          emit(state.copyWith(friendList: _friendList));
        } else {
          emit(state.copyWith(message: AppText.textFriendEmpty));
        }
      } catch (e) {
        emit(state.copyWith(message: AppText.internetError));
      }
    });

    on<SearchFriends>((event, emit) {
      if (_friendList.isNotEmpty) {
        if (event.query.isEmpty) {
          emit(state.copyWith(friendList: _friendList));
        } else {
          final filteredList = _friendList
              .where((friend) => friend.fullName
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
              .toList();
          emit(state.copyWith(
              friendList: filteredList,
              query: event.query,
              message: AppText.textSearchFriendEmpty));
        }
      }
    });

    on<CacheAvatar>((event, emit) {
      if (state.friendList.isNotEmpty) {
        _avatarCache = Map<String, Image>.from(state.avatarCache)
          ..[event.avatarUrl] = event.avatarImage;
        emit(state.copyWith(avatarCache: _avatarCache));
      }
    });

    on<UpdateNickname>((event, emit) async {
      final updateNickname = getIt<AddNicknameUseCase>();
      await updateNickname.execute(event.friendID, event.nickname);
      final updatedFriendList = _friendList.map((friend) {
        if (friend.friendID == event.friendID) {
          return FriendEntity(
              friendID: friend.friendID,
              nickname: event.nickname,
              fullName: friend.fullName,
              avatar: friend.avatar,
              content: friend.content,
              files: friend.files,
              images: friend.images,
              isSend: friend.isSend,
              isOnline: friend.isOnline);
        }
        return friend;
      }).toList();
      emit(state.copyWith(friendList: updatedFriendList));
    });
  }
}
