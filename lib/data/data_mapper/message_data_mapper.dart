import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/domain/entities/message_entity.dart';

class MessageDataMapper {
  MessageEntity mapToMessageEntity(MessageModel message) {
    return MessageEntity(
        content: message.content,
        files: message.files,
        images: message.images,
        isSend: message.isSend,
        createdAt: message.createdAt,
        messageType: message.messageType);
  }
}
