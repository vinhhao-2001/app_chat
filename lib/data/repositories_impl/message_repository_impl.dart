import 'package:app_chat/data/data_mapper/message_data_mapper.dart';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/domain/entities/message_entity.dart';
import 'package:app_chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl extends MessageRepository {
  final ApiService _apiService;
  final MessageDataMapper _messageDataMapper;
  MessageRepositoryImpl(this._apiService, this._messageDataMapper);

  @override
  Future<List<MessageEntity>> getMessageList(String token, String friendID,
      {DateTime? lastTime}) async {
    List<MessageModel> listMessage =
        await _apiService.getMessageList(token, friendID);
    return listMessage.map(_messageDataMapper.mapToMessageEntity).toList();
  }

  @override
  Future<MessageEntity> sendMessage(
      String token, String friendID, MessageModel message) async {
    MessageModel? messageModel =
        await _apiService.sendMessage(token, friendID, message);
    if (messageModel != null) {
      return _messageDataMapper.mapToMessageEntity(messageModel);
    } else {
      return throw Exception();
    }
  }
}
