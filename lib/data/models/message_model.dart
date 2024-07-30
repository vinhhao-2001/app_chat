import '../../core/constants/api_constants.dart';
import '../../core/data_types/file_data.dart';
import '../../core/data_types/image_data.dart';

class MessageModel {
  final String? id;
  final String content;
  final List<FileData> files;
  final List<ImageData> images;
  int isSend;
  final DateTime createdAt;
  final int messageType;

  MessageModel({
    this.id,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.createdAt,
    required this.messageType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    List<FileData> files = [];
    if (json.containsKey(ApiConstants.files)) {
      files = (json[ApiConstants.files] as List<dynamic>).map((fileJson) {
        return FileData.fromJson(fileJson);
      }).toList();
    }
    List<ImageData> images = [];
    if (json.containsKey(ApiConstants.images)) {
      images = (json[ApiConstants.images] as List<dynamic>).map((imageJson) {
        return ImageData.fromJson(imageJson);
      }).toList();
    }

    return MessageModel(
      id: json[ApiConstants.id],
      content: json[ApiConstants.content] ?? '',
      files: files,
      images: images,
      isSend: json[ApiConstants.isSend],
      createdAt: DateTime.parse(json[ApiConstants.createdAt]),
      messageType: json[ApiConstants.messageType],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ApiConstants.id: id,
      ApiConstants.content: content,
      ApiConstants.isSend: isSend,
      ApiConstants.createdAt: createdAt.toIso8601String(),
      ApiConstants.messageType: messageType
    };
  }
}
