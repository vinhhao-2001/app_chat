import 'package:app_chat/domain/entities/message_entity.dart';
import 'package:app_chat/domain/repositories/message_repository.dart';

import '../../../data/models/message_model.dart';

class SendMessageUseCase {
  final MessageRepository _repository;

  SendMessageUseCase(this._repository);

  Future<MessageEntity> execute(
      String token, String friendID, MessageModel message) async {
    return await _repository.sendMessage(token, friendID, message);
  }
}
