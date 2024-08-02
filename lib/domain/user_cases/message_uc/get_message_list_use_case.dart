import 'package:injectable/injectable.dart';

import '../../entities/message_entity.dart';
import '../../repositories/message_repository.dart';

@injectable
class GetMessageListUseCase {
  final MessageRepository _repository;

  GetMessageListUseCase(this._repository);

  // Future<List<MessageEntity>> execute(String token, String friendID) async {
  //   return await _repository.getMessageList(token, friendID);
  // }

  Stream<List<MessageEntity>> execute(String token, String friendID) async* {
    yield* _repository.getMessageList(token, friendID);
  }
}
