import 'package:app_chat/domain/entities/message_entity.dart';

abstract class MessageRepository {
  // Future<List<MessageEntity>> getMessageList(String token, String friendID);

  Stream<List<MessageEntity>> getMessageList(String token, String friendID);

  Future<List<MessageEntity>> reloadMessageList(
      String token, String friendID, DateTime lastTime);

  Future<MessageEntity> sendMessage(
      String token, String friendID, MessageEntity message);
}
