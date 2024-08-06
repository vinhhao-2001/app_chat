part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<MessageEntity> messageList;
  final String error;
  const ChatState({
    this.messageList = const [],
    this.error = '',
  });

  ChatState copyWiht({
    final List<MessageEntity>? messageList,
    final String? error,
  }) {
    return ChatState(
      messageList: messageList ?? this.messageList,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [messageList, error];
}
