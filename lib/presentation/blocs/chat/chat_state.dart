part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<MessageEntity> messageList;
  final String error;
  final DateTime? lastTime;
  const ChatState({
    this.messageList = const [],
    this.error = '',
    this.lastTime,
  });

  ChatState copyWith({
    final List<MessageEntity>? messageList,
    final String? error,
    final DateTime? lastTime,
  }) {
    return ChatState(
      messageList: messageList ?? this.messageList,
      error: error ?? this.error,
      lastTime: lastTime ?? this.lastTime,
    );
  }

  @override
  List<Object?> get props => [messageList, error];
}
