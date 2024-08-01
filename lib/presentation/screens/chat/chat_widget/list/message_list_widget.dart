import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color.dart';
import '../../../../../data/data_sources/remote/api/api_service.dart';
import '../../../../../domain/entities/message_entity.dart';
import '../avatar_widget.dart';

part 'content_widget.dart';
part 'files_widget.dart';
part 'images_widget.dart';
part 'footer_widget.dart';

class MessageListWidget extends StatelessWidget {
  final List<MessageEntity> messageList;
  final AvatarWidget avatarWidget;
  final ScrollController scrollController;
  const MessageListWidget({
    super.key,
    required this.messageList,
    required this.scrollController,
    required this.avatarWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        final message = messageList[index];
        final bool isMe = message.messageType == 1;
        final bool hasContent = message.content.isNotEmpty;
        final bool hasFiles = message.files.isNotEmpty;
        final bool hasImages = message.images.isNotEmpty;
        final bool isLastMessageByMe = _isLastMessageByMe(index, messageList);

        return Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasContent)
              ContentWidget(
                messageEntity: message,
                avatarWidget: avatarWidget,
              ),
            if (hasFiles)
              FilesWidget(messageEntity: message, avatarWidget: avatarWidget),
            if (hasImages)
              ImagesWidget(messageEntity: message, avatarWidget: avatarWidget),
            if (hasContent || hasFiles || hasImages)
              FooterWidget(
                  messageEntity: message, isLastMessageByMe: isLastMessageByMe),
          ],
        );
      },
    );
  }

  bool _isLastMessageByMe(int index, List<MessageEntity> messageList) {
    for (int i = index + 1; i < messageList.length; i++) {
      if (messageList[i].messageType == 1) {
        return false;
      }
    }
    return true;
  }
}
