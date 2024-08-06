import 'package:app_chat/core/theme/app_text.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/di.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/user_cases/message_uc/get_message_list_use_case.dart';
import '../../../domain/user_cases/message_uc/reload_message_use_case.dart';
import '../../../domain/user_cases/message_uc/send_message_use_case.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  List<MessageEntity> _messageList = [];

  ChatBloc() : super(const ChatState()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onFetchMessages(
      FetchMessages event, Emitter<ChatState> emit) async {
    if (event.lastTime == null) {
      _messageList = [];
      emit(state.copyWiht(messageList: [], error: ''));
      final getMessage = getIt<GetMessageListUseCase>();
      await for (var messageList
          in getMessage.execute(event.token, event.friendID)) {
        _messageList.addAll(messageList);
        if (messageList.isNotEmpty) {
          // danh sách lấy về không rỗng thì hiển thị ra màn hình
          emit(state.copyWiht(messageList: _messageList));
        } else {
          emit(state.copyWiht(error: AppText.textChatEmpty));
        }
      }
    } else {
      // lấy tin nhắn định kì
      final reloadMessage = getIt<ReloadMessageUseCase>();
      final messageNew = await reloadMessage.execute(
          event.token, event.friendID, event.lastTime!);
      _messageList.addAll(messageNew);
      emit(state.copyWiht(messageList: _messageList));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    final sendMessage = getIt<SendMessageUseCase>();
    try {
      _messageList.add(event.message); // state đang gửi
      emit(state.copyWiht(messageList: _messageList));

      MessageEntity message =
          await sendMessage.execute(event.token, event.friendID, event.message);
      _messageList.removeLast();
      _messageList.add(message);
      // state da gui tin nhan
      emit(state.copyWiht(messageList: _messageList));
    } catch (e) {
      emit(state.copyWiht(error: e.toString()));
      event.message.isSend = 3;
      _messageList.removeLast();
      _messageList.add(event.message);
      emit(state.copyWiht(messageList: _messageList));
    }
  }
}
