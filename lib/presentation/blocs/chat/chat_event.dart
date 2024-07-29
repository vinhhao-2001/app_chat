part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

final class FetchMessages extends ChatEvent {
  final String token;
  final String friendID;
  final DateTime? lastTime;
  const FetchMessages(this.token, this.friendID, [this.lastTime]);
  @override
  List<Object?> get props => [token, friendID, lastTime];
}

final class SendMessage extends ChatEvent {
  final String token;
  final String friendID;
  final MessageModel message;
  const SendMessage(this.token, this.friendID, this.message);
  @override
  List<Object?> get props => [token, friendID, message];
}