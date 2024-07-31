import '../../entities/message_entity.dart';
import '../../repositories/message_repository.dart';

class GetMessageListUseCase {
  final MessageRepository _repository;

  GetMessageListUseCase(this._repository);

  Future<List<MessageEntity>> execute(String token, String friendID) async {
    return await _repository.getMessageList(token, friendID);
  }
}
