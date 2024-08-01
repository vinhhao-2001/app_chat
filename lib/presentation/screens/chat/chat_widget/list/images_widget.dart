part of 'message_list_widget.dart';

class ImagesWidget extends StatelessWidget {
  final MessageEntity messageEntity;
  final AvatarWidget avatarWidget;
  const ImagesWidget(
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
              children: messageEntity.images.map((imageData) {
                return FutureBuilder<Image>(
                  future: ApiService().loadImage(imageData.urlImage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        color: Colors.grey,
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        color: Colors.red,
                        child: const Icon(Icons.error, size: 50),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: snapshot.data,
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
