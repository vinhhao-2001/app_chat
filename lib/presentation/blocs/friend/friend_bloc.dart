import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local/data.dart';
import '../../../data/data_sources/local/db_helper.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/user_cases/friend_uc/get_friend_list_use_case.dart';
import '../../../main.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  FriendBloc() : super(FriendInitial()) {
    on<FetchFriends>((event, emit) async {
      emit(FriendLoading());
      try {
        final getFriendList = getIt<GetFriendListUseCase>();
        // lấy danh sách bạn bè
        friendList = await getFriendList.execute(event.token);
        emit(FriendLoaded(friendList, friendList, avatarCache));
      } catch (e) {
        emit(FriendError(e.toString()));
      }
    });

    on<SearchFriends>((event, emit) {
      final currentState = state;
      if (currentState is FriendLoaded) {
        if (event.query.isEmpty) {
          emit(FriendLoaded(
              currentState.fullFriends, currentState.fullFriends, avatarCache));
        } else {
          final filteredFriends = currentState.fullFriends
              .where((friend) => friend.fullName
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
              .toList();
          emit(FriendLoaded(
              currentState.fullFriends, filteredFriends, avatarCache));
        }
      }
    });

    on<CacheAvatar>((event, emit) {
      if (state is FriendLoaded) {
        final currentState = state as FriendLoaded;
        avatarCache = Map<String, Image>.from(currentState.avatarCache)
          ..[event.avatarUrl] = event.avatarImage;
        emit(FriendLoaded(currentState.fullFriends,
            currentState.filteredFriends, avatarCache));
      }
    });

    on<UpdateNickname>((event, emit) async {
      await _dbHelper.insertNickname(event.friendID, event.nickname);
      add(FetchFriends(event.token));
    });
  }
}
