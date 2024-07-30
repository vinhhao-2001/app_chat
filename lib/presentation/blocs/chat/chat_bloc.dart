import 'dart:developer';

import 'package:app_chat/data/models/message_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/local/db_helper.dart';
import '../../../data/data_sources/remote/api/api_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  List<MessageModel> _messageList = [];

  ChatBloc() : super(ChatInitialState()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onFetchMessages(
      FetchMessages event, Emitter<ChatState> emit) async {
    if (event.lastTime == null) {
      _messageList = [];
      emit(ChatLoadingState());
      final messageDB = await DatabaseHelper().getMessages(event.friendID);
      log(messageDB.length.toString());
      if (messageDB.isNotEmpty) {
        // lấy tin nhắn trong db khi mới vào chat screen
        _messageList.addAll(messageDB);
        emit(ChatLoadedState(_messageList));
        // lấy những tin nhắn mới ở server
        final messageServer = await ApiService().getMessageList(
            event.token, event.friendID,
            lastTime: messageDB.last.createdAt);
        if (messageServer.isNotEmpty) {
          _messageList.addAll(messageServer);
          await DatabaseHelper().insertMessages(event.friendID, messageServer);
        }
      } else {
        // db rỗng thì lấy toàn bộ tin ở server
        final messageServer =
            await ApiService().getMessageList(event.token, event.friendID);
        _messageList.addAll(messageServer);
        await DatabaseHelper().insertMessages(event.friendID, messageServer);
      }
      emit(ChatLoadedState(_messageList));
    } else {
      // lấy tin nhắn định kì
      log(event.lastTime.toString());
      final messagesNew = await ApiService()
          .getMessageList(event.token, event.friendID, lastTime: event.lastTime);
      if (messagesNew.isNotEmpty) {
        _messageList.addAll(messagesNew);
        emit(ChatNewMessageAddedState(_messageList));
        emit(ChatLoadedState(_messageList));
        await DatabaseHelper().insertMessages(event.friendID, messagesNew);
      }
      log(messagesNew.toString());
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      _messageList.add(event.message); // test trạng thái đang gửi
      emit(ChatNewMessageAddedState(_messageList));
      MessageModel? message = await ApiService()
          .sendMessage(event.token, event.friendID, event.message)
          .timeout(const Duration(seconds: 10));
      if (message != null) {
        _messageList.removeLast();
        _messageList.add(message);
        emit(ChatNewMessageAddedState(_messageList));
        emit(ChatLoadedState(_messageList));
        await DatabaseHelper().insertMessage(event.friendID, message);
      }
    } catch (e) {
      emit(ChatErrorState(e.toString()));
      event.message.isSend = 3;
      _messageList.removeLast();
      _messageList.add(event.message);
      emit(ChatLoadedState(_messageList));
    }
  }
}
