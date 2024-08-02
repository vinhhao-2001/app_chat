import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../data/data_sources/local/db_helper.dart';
import '../../../data/data_sources/remote/api/api_service.dart';

@injectable
class LoadImageUseCase {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;

  LoadImageUseCase(this._apiService, this._databaseHelper);
  Future<Image> execute(String? imageUrl) async {
    try {
      if (imageUrl == null) {
        throw '';
      }
      final image = await _apiService.loadImage(imageUrl);
      if (image != null) {
        await _databaseHelper.insertImage(imageUrl, image);
        return Image.memory(image);
      } else {
        final imageBytesFromDb = await _databaseHelper.getImage(imageUrl);
        if (imageBytesFromDb != null) {
          return Image.memory(imageBytesFromDb);
        } else {
          return Image.asset(AssetConstants.iconError);
        }
      }
    } catch (_) {
      return Image.asset(AssetConstants.iconPerson);
    }
  }
}
