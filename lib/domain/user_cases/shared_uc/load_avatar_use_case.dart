import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/asset_constants.dart';

class LoadAvatarUseCase {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;

  LoadAvatarUseCase(this._apiService, this._databaseHelper);
  Future<Image> execute(String? avatarUrl) async {
    try {
      if (avatarUrl == null) {
        throw '';
      }
      final image = await _apiService.loadAvatar(avatarUrl);
      if (image != null) {
        await _databaseHelper.insertImage(avatarUrl, image);
        return Image.memory(image);
      } else {
        final imageBytesFromDb = await _databaseHelper.getImage(avatarUrl);
        if (imageBytesFromDb != null) {
          return Image.memory(imageBytesFromDb);
        } else {
          return Image.asset(AssetConstants.iconPerson);
        }
      }
    } catch (_) {
      return Image.asset(AssetConstants.iconPerson);
    }
  }
}
