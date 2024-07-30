import 'package:app_chat/domain/entities/message_entity.dart';

import '../../data/models/message_model.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> getMessageList(String token, String friendID,
      {DateTime? lastTime});

  Future<MessageEntity> sendMessage(
      String token, String friendID, MessageModel message);
}
