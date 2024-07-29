part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();
}

final class ChatInitialState extends ChatState {
  @override
  List<Object> get props => [];
}

final class ChatLoadingState extends ChatState {
  @override
  List<Object> get props => [];
}

final class ChatLoadedState extends ChatState {
  final List<MessageModel> messages;
  const ChatLoadedState(this.messages);
  @override
  List<Object> get props => [messages];
}

final class ChatErrorState extends ChatState {
  final String message;
  const ChatErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ChatNewMessageAddedState extends ChatState {
  final List<MessageModel> messages;
  const ChatNewMessageAddedState(this.messages);
  @override
  List<Object> get props => [messages];
}
