import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:injectable/injectable.dart';

import '../../../core/data_types/file_data.dart';
@LazySingleton()
class DownloadFileUseCase {
  final ApiService _apiService;

  DownloadFileUseCase(this._apiService);
  Future<void> execute(FileData fileData) {
    return _apiService.downloadFile(fileData);
  }
}
