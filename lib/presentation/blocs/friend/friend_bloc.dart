import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/data_sources/local/data.dart';
import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:app_chat/data/models/friend_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  FriendBloc() : super(FriendInitial()) {
    on<FetchFriends>((event, emit) async {
      emit(FriendLoading());
      try {
        // lấy danh sách bạn bè ở server.
        friendList = await ApiService().getListFriends(event.token);
        if (friendList.isNotEmpty) {
          friendList.sort((a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
          friendList = await _dbHelper.updateAllFriends(friendList);
        } else {
          friendList = await _dbHelper.getAllFriends();
        }
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
