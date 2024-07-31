import '../../entities/message_entity.dart';
import '../../repositories/message_repository.dart';

class ReloadMessageUseCase {
  final MessageRepository _repository;

  ReloadMessageUseCase(this._repository);

  Future<List<MessageEntity>> execute(
      String token, String friendID, DateTime dateTime) async {
    return await _repository.reloadMessageList(token, friendID, dateTime);
  }
}
