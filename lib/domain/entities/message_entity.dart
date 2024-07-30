import '../../data/models/message_model.dart';

class MessageEntity {
  final String? id;
  final String content;
  final List<FileData> files;
  final List<ImageData> images;
  final int isSend;
  final DateTime createdAt;
  final int messageType;

  MessageEntity({
    this.id,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.createdAt,
    required this.messageType,
  });
}
