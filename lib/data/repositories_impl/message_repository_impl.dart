import 'package:app_chat/data/data_mapper/message_data_mapper.dart';
import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/models/message_model.dart';
import 'package:app_chat/domain/entities/message_entity.dart';
import 'package:app_chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl extends MessageRepository {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final MessageDataMapper _messageDataMapper;
  MessageRepositoryImpl(
      this._apiService, this._databaseHelper, this._messageDataMapper);

  @override
  Future<List<MessageEntity>> getMessageList(
      String token, String friendID) async {
    // lấy tin nhắn trong db khi mới vào chat screen
    List<MessageModel> messageList = [];
    final messageDB = await _databaseHelper.getMessages(friendID);
    if (messageDB.isNotEmpty) {
      messageList.addAll(messageDB);
      // lấy tin nhắn mới ở server
      final messageServer = await _apiService.getMessageList(token, friendID,
          lastTime: messageDB.last.createdAt);
      if (messageServer.isNotEmpty) {
        messageList.addAll(messageServer);
        // lưu tin nhắn mới vào db
        await _databaseHelper.insertMessages(friendID, messageServer);
      }
      return messageList.map(_messageDataMapper.mapToMessageEntity).toList();
    } else {
      // db rỗng thì lấy toàn bộ tin nhắn trên server
      final messageServer = await _apiService.getMessageList(token, friendID);
      if (messageServer.isNotEmpty) {
        // thực hiện khi có tin nhắn trên server
        messageList.addAll(messageServer);
        // Lưu tin nhắn vào db
        await _databaseHelper.insertMessages(friendID, messageServer);
        return messageList.map(_messageDataMapper.mapToMessageEntity).toList();
      }
      return [];
    }
  }

  @override
  Future<List<MessageEntity>> reloadMessageList(
      String token, String friendID, DateTime lastTime) async {
    final messagesNew =
        await _apiService.getMessageList(token, friendID, lastTime: lastTime);
    if (messagesNew.isNotEmpty) {
      await DatabaseHelper().insertMessages(friendID, messagesNew);
      return messagesNew.map(_messageDataMapper.mapToMessageEntity).toList();
    }
    return [];
  }

  @override
  Future<MessageEntity> sendMessage(
      String token, String friendID, MessageEntity message) async {
    MessageModel? messageModel =
        await _apiService.sendMessage(token, friendID, message);
    if (messageModel != null) {
      final message = _messageDataMapper.mapToMessageEntity(messageModel);
      await _databaseHelper.insertMessage(friendID, messageModel);
      return message;
    } else {
      return throw Exception();
    }
  }
}
