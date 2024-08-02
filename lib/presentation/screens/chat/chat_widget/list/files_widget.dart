part of 'message_list_widget.dart';

class FilesWidget extends StatelessWidget {
  final MessageEntity messageEntity;
  final AvatarWidget avatarWidget;
  const FilesWidget(
      {super.key, required this.messageEntity, required this.avatarWidget});

  @override
  Widget build(BuildContext context) {
    bool isMe = messageEntity.messageType == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: avatarWidget,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: messageEntity.files.map((fileData) {
                return Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(5),
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
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.file_download,
                              color: Colors.grey),
                          onPressed: () => getIt<DownloadFileUseCase>().execute(fileData),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileData.fileName,
                                style: TextStyle(
                                  color: isMe
                                      ? AppColor.chatSendColor
                                      : AppColor.chatGetColor,
                                ),
                                softWrap: true,
                              ),
                              Text(
                                '${(3000 / 1024).toStringAsFixed(2)} MB',
                                style: TextStyle(
                                  color: isMe
                                      ? AppColor.chatSendColor
                                      : AppColor.chatGetColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
