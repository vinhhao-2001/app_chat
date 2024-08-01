part of 'message_list_widget.dart';

class ContentWidget extends StatelessWidget {
  final MessageEntity messageEntity;
  final AvatarWidget avatarWidget;
  const ContentWidget(
      {super.key, required this.messageEntity, required this.avatarWidget});

  @override
  Widget build(BuildContext context) {
    bool isMe = messageEntity.messageType == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) Container(alignment: Alignment.center, child: avatarWidget),
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColor.backgroundSendColor
                    : AppColor.backgroundGetColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: Text(
                  messageEntity.content,
                  style: TextStyle(
                    color:
                        isMe ? AppColor.chatSendColor : AppColor.chatGetColor,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
