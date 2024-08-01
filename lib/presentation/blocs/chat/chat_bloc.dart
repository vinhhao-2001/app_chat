import 'package:app_chat/domain/entities/message_entity.dart';
import 'package:app_chat/domain/user_cases/message_uc/get_message_list_use_case.dart';
import 'package:app_chat/domain/user_cases/message_uc/reload_message_use_case.dart';
import 'package:app_chat/domain/user_cases/message_uc/send_message_use_case.dart';
import 'package:app_chat/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  List<MessageEntity> _messageList = [];

  ChatBloc() : super(ChatInitialState()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onFetchMessages(
      FetchMessages event, Emitter<ChatState> emit) async {
    if (event.lastTime == null) {
      _messageList = [];
      emit(ChatLoadingState());
      final getMessage = getIt<GetMessageListUseCase>();

      await for (var messageList
          in getMessage.execute(event.token, event.friendID)) {
        _messageList = messageList;
        emit(ChatLoadedState(_messageList));
      }
    } else {
      // lấy tin nhắn định kì
      final reloadMessage = getIt<ReloadMessageUseCase>();
      final messageNew = await reloadMessage.execute(
          event.token, event.friendID, event.lastTime!);
      _messageList.addAll(messageNew);
      emit(ChatInitialState());
      emit(ChatLoadedState(_messageList));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    final sendMessage = getIt<SendMessageUseCase>();
    try {
      _messageList.add(event.message); // trạng thái đang gửi
      emit(ChatLoadedState(_messageList));

      MessageEntity message =
          await sendMessage.execute(event.token, event.friendID, event.message);
      _messageList.removeLast();
      _messageList.add(message);
      emit(ChatLoadedState(_messageList));
    } catch (e) {
      emit(ChatErrorState(e.toString()));
      event.message.isSend = 3;
      _messageList.removeLast();
      _messageList.add(event.message);
      emit(ChatLoadedState(_messageList));
    }
  }
}
