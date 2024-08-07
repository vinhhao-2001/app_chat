import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_color.dart';

import '../../../../../core/theme/app_text.dart';
import '../../../../../core/utils/di.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../domain/entities/message_entity.dart';
import '../../../../../domain/user_cases/shared_uc/download_file_use_case.dart';
import '../../../../../domain/user_cases/shared_uc/load_image_use_case.dart';
import '../../../../blocs/chat/chat_bloc.dart';
import '../../../../widgets/loading_widget.dart';
import '../avatar_widget.dart';

part 'content_widget.dart';
part 'files_widget.dart';
part 'images_widget.dart';
part 'footer_widget.dart';

class MessageListWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final AvatarWidget avatarWidget;
  final ChatBloc chatBloc;
  MessageListWidget({
    super.key,
    required this.avatarWidget,
    required this.chatBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (a, b) => a.messageList != b.messageList || a.error != b.error,
      builder: (context, state) {
        if (state.messageList.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.messageList.length,
            itemBuilder: (context, index) {
              final message = state.messageList[index];
              final bool isMe = message.messageType == 1;
              final bool hasContent = message.content.isNotEmpty;
              final bool hasFiles = message.files.isNotEmpty;
              final bool hasImages = message.images.isNotEmpty;
              final bool isLastMessageByMe =
                  _isLastMessageByMe(index, state.messageList);

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
                    FilesWidget(
                        messageEntity: message, avatarWidget: avatarWidget),
                  if (hasImages)
                    ImagesWidget(
                        messageEntity: message, avatarWidget: avatarWidget),
                  if (hasContent || hasFiles || hasImages)
                    FooterWidget(
                        messageEntity: message,
                        isLastMessageByMe: isLastMessageByMe),
                ],
              );
            },
          );
        } else if (state.error.isNotEmpty) {
          return const Center(child: Text(AppText.textChatEmpty));
        } else {
          return const Center(child: LoadingWidget(size: 60));
        }
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }
}
