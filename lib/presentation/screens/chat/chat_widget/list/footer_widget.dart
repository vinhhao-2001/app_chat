part of 'message_list_widget.dart';

class FooterWidget extends StatelessWidget {
  final MessageEntity messageEntity;
  final bool isLastMessageByMe;
  const FooterWidget(
      {super.key,
      required this.messageEntity,
      required this.isLastMessageByMe});

  @override
  Widget build(BuildContext context) {
    bool isMe = messageEntity.messageType == 1;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : (MediaQuery.of(context).size.width * 0.05),
            right: isMe ? (MediaQuery.of(context).size.width * 0.05) : 0,
          ),
          child: Text(
            ApiService().formatMessageTime(messageEntity.createdAt),
            style: const TextStyle(color: AppColor.textTime),
          ),
        ),
        if (isMe && isLastMessageByMe)
          Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: messageEntity.isSend == 2
                  ? const Icon(Icons.arrow_upward,
                      size: 20, color: Colors.orange)
                  : messageEntity.isSend == 3
                      ? const Icon(Icons.dangerous, size: 20, color: Colors.red)
                      : const Icon(Icons.done_all,
                          size: 20, color: Colors.blue)),
      ],
    );
  }
}
