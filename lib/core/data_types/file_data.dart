import '../constants/api_constants.dart';

class FileData {
  final String urlFile;
  final String fileName;
  final String? id;

  FileData({
    required this.urlFile,
    required this.fileName,
    this.id,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      urlFile: json[ApiConstants.urlFile],
      fileName: json[ApiConstants.filename],
      id: json[ApiConstants.idUnder],
    );
  }
}
