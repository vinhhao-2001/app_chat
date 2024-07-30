import '../constants/api_constants.dart';

class ImageData {
  final String urlImage;
  final String fileName;
  final String? id;

  ImageData({
    required this.urlImage,
    required this.fileName,
    this.id,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      urlImage: json[ApiConstants.urlImage],
      fileName: json[ApiConstants.filename],
      id: json[ApiConstants.idUnder],
    );
  }
}
