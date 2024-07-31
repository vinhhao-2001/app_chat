import '../../../data/data_sources/local/db_helper.dart';

class LogoutUseCase {
  Future<void> execute() async {
    await DatabaseHelper().deleteDatabase();
  }
}
