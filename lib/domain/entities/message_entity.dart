import '../../core/data_types/file_data.dart';
import '../../core/data_types/image_data.dart';

class MessageEntity {
  final String content;
  final List<FileData> files;
  final List<ImageData> images;
  int isSend;
  final DateTime createdAt;
  final int messageType;

  MessageEntity({
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.createdAt,
    required this.messageType,
  });
}
