import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddNicknameUseCase {
  final DatabaseHelper _databaseHelper;

  AddNicknameUseCase(this._databaseHelper);
  Future<void> execute(String friendID, String nickname) {
    return _databaseHelper.insertNickname(friendID, nickname);
  }
}
