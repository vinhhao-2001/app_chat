import 'package:injectable/injectable.dart';

import '../../../data/data_sources/local/db_helper.dart';

@injectable
class LogoutUseCase {
  final DatabaseHelper _databaseHelper;

  LogoutUseCase(this._databaseHelper);
  Future<void> execute() async {
    await _databaseHelper.deleteDatabase();
  }
}
