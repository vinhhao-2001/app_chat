import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/constants/color_constants.dart';
import '../../core/theme/text_constants.dart';
import '../../data/data_sources/local/data.dart';
import '../../data/data_sources/local/db_helper.dart';
import '../../data/data_sources/remote/api/api_service.dart';
import '../../data/models/friend_model.dart';
import '../../data/models/message_model.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/friend/friend_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String friendID;
  final String token;

  const ChatScreen({super.key, required this.token, required this.friendID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _emojiOpen = false;
  bool _imagePickerOpen = false;
  List<AssetEntity> _images = [];
  final List<AssetEntity> _selectedImages = [];
  Timer? _timer;
  Image? _avatarImage;
  bool _isMounted = false;
  late FriendModel selectedFriend;
  DateTime? lastTime;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startPolling();
    selectedFriend = friendList.firstWhere(
      (friend) => friend.friendID == widget.friendID,
    );
    BlocProvider.of<ChatBloc>(context)
        .add(FetchMessages(widget.token, widget.friendID));
    _isMounted = true;
    _loadAvatar();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _emojiOpen = false;
          _imagePickerOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        _selectedImages.clear();
        _emojiOpen = false;
        _imagePickerOpen = false;
        setState(() {});
      },
      child:
          //return
          Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoadedState) {
                      final messages = state.messages;
                      if (messages.isNotEmpty) {
                        lastTime = messages.last.createdAt;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                        return _buildMessageList(messages);
                      } else {
                        lastTime =
                            DateTime.now().subtract(const Duration(hours: 7));
                        return const Center(
                            child: Text(TextConstants.textChatEmpty));
                      }
                    } else if (state is ChatNewMessageAddedState) {
                      final messages = state.messages;
                      if (messages.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                        lastTime = messages.last.createdAt;
                        return _buildMessageList(messages);
                      }
                    } else if (state is ChatErrorState) {
                      log(state.message);
                    }
                    return const Center(
                        child: Text(TextConstants.textChatEmpty));
                  },
                ),
              ),
              _buildSendMessage(),
              if (_emojiOpen) _buildEmojiPicker(),
              if (_imagePickerOpen) _buildImagePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocProvider(
      create: (context) => FriendBloc(),
      child: Stack(
        children: [
          _buildHeaderContent(
              selectedFriend,
              _avatarImage == null
                  ? const CircularProgressIndicator()
                  : _buildAvatar(20)),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(FriendModel selectedFriend, Widget avatar) {
    return GestureDetector(
      onTap: () => _showNicknameDialog(selectedFriend),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 30, left: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            avatar,
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedFriend.nickname ?? selectedFriend.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      selectedFriend.isOnline
                          ? TextConstants.online
                          : TextConstants.offline,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<MessageModel> messageList) {
    return ListView.builder(
      controller: _scrollController,
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
            if (hasContent) _buildMessageContent(isMe, message),
            if (hasFiles) _buildMessageFiles(isMe, message),
            if (hasImages) _buildMessageImages(isMe, message),
            if (hasContent || hasFiles || hasImages)
              _buildMessageFooter(isMe, message, isLastMessageByMe, index),
          ],
        );
      },
    );
  }

  Widget _buildSendMessage() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              _focusNode.unfocus();
              setState(() {
                _emojiOpen = !_emojiOpen;
                _imagePickerOpen = false;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _textEditController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                fillColor: ColorConstants.fillColor,
                filled: true,
                hintText: TextConstants.hintTextChat,
                hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.only(left: 15),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.blue,
                  iconSize: 35,
                  onPressed: _sendMessage,
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Transform.rotate(
            angle: 0.2,
            child: IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _openFilePicker,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              _focusNode.unfocus();
              _requestPermissionAndLoadImages();
              setState(() {
                _imagePickerOpen = !_imagePickerOpen;
                _emojiOpen = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 216,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _textEditController.text += emoji.emoji;
        },
        config: Config(
          height: 216,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.android
                    ? 1.20
                    : 1.0),
          ),
          swapCategoryAndBottomBar: false,
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 216,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                final selectedIndex = _selectedImages.indexOf(image);

                return FutureBuilder<File?>(
                  future: image.file,
                  builder: (context, snapshot) {
                    final file = snapshot.data;
                    if (file == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GestureDetector(
                      onTap: () => _selectImage(image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                            if (selectedIndex != -1)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    (selectedIndex + 1).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedImages.isNotEmpty)
            ElevatedButton(
              onPressed: _sendSelectedImages,
              child: Text('${TextConstants.textSend} ${_selectedImages.length} '
                  '${TextConstants.textImage}'),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isMe, MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              alignment: Alignment.center,
              child: _buildAvatar(15),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe
                    ? ColorConstants.backgroundSendColor
                    : ColorConstants.backgroundGetColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe
                        ? ColorConstants.chatSendColor
                        : ColorConstants.chatGetColor,
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

  Widget _buildMessageFiles(bool isMe, MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: _buildAvatar(15),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: message.files.map((fileData) {
                return Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? ColorConstants.backgroundSendColor
                        : ColorConstants.backgroundGetColor,
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
                          onPressed: () => ApiService().downloadFile(fileData),
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
                                      ? ColorConstants.chatSendColor
                                      : ColorConstants.chatGetColor,
                                ),
                                softWrap: true,
                              ),
                              Text(
                                '${(3000 / 1024).toStringAsFixed(2)} MB',
                                style: TextStyle(
                                  color: isMe
                                      ? ColorConstants.chatSendColor
                                      : ColorConstants.chatGetColor,
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

  Widget _buildMessageImages(bool isMe, MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10),
              child: _buildAvatar(15),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: message.images.map((imageData) {
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

  Widget _buildMessageFooter(
      bool isMe, MessageModel message, bool isLastMessageByMe, int index) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : (MediaQuery.of(context).size.width * 0.05),
            right: isMe ? (MediaQuery.of(context).size.width * 0.05) : 0,
          ),
          child: Text(
            ApiService().formatMessageTime(message.createdAt),
            style: const TextStyle(color: ColorConstants.textTime),
          ),
        ),
        if (isMe && isLastMessageByMe)
          Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: message.isSend == 2
                  ? const Icon(Icons.arrow_upward,
                      size: 20, color: Colors.orange)
                  : message.isSend == 3
                      ? const Icon(Icons.dangerous, size: 20, color: Colors.red)
                      : const Icon(Icons.done_all,
                          size: 20, color: Colors.blue)),
      ],
    );
  }

  Widget _buildAvatar(double size) {
    return CircleAvatar(
      radius: size,
      backgroundImage: _avatarImage?.image,
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 5,
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedFriend.isOnline ? Colors.green : Colors.red,
                ),
              ))
        ],
      ),
    );
  }

  void _showNicknameDialog(FriendModel selectedFriend) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(TextConstants.textNickname),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: TextConstants.hintTextNickname,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(TextConstants.textCancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(TextConstants.textOk),
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  selectedFriend.nickname = controller.text;
                  await DatabaseHelper()
                      .insertNickname(selectedFriend.friendID, controller.text);
                  setState(() {});
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(TextConstants.nicknameEmpty),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      BlocProvider.of<ChatBloc>(context)
          .add(FetchMessages(widget.token, widget.friendID, lastTime));
    });
  }

  void _sendMessage() {
    if (_textEditController.text.trim().isNotEmpty) {
      final newMessage = MessageModel(
        id: '',
        content: _textEditController.text,
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        messageType: 1,
        isSend: 2,
        files: [],
        images: [],
      );

      BlocProvider.of<ChatBloc>(context)
          .add(SendMessage(widget.token, widget.friendID, newMessage));
      _textEditController.clear();
    }
  }

  void _selectImage(AssetEntity image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else {
        _selectedImages.add(image);
      }
    });
  }

  Future<void> _sendSelectedImages() async {
    for (var image in _selectedImages) {
      final file = await image.file;
      if (file != null) {
        final newMessage = MessageModel(
          content: '',
          createdAt: DateTime.now(),
          messageType: 1,
          isSend: 0,
          files: [],
          images: [
            ImageData(
              urlImage: file.path,
              fileName: file.path.split('/').last,
            ),
          ],
        );
        if (!mounted) return;
        BlocProvider.of<ChatBloc>(context)
            .add(SendMessage(widget.token, widget.friendID, newMessage));
      }
    }

    setState(() {
      _selectedImages.clear();
      _imagePickerOpen = false;
    });
  }

  Future<void> _requestPermissionAndLoadImages() async {
    // xin quyền và lấy ảnh hiển thị vào lưới
    final status = await Permission.storage.request();

    if (status.isDenied) {
      openAppSettings();
    } else if (status.isGranted) {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.all);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final recentImages =
            await recentAlbum.getAssetListPaged(page: 0, size: 100);
        setState(() {
          _images = recentImages;
        });
      }
    }
  }

  void _openFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        final fileDataList = result.paths
            .map((path) => FileData(
                  fileName: path!.split('/').last,
                  urlFile: path,
                ))
            .toList();

        _sendFiles(fileDataList);
      }
    } catch (e) {
      log('$e');
    }
  }

  void _sendFiles(List<FileData> fileDataList) async {
    final newMessage = MessageModel(
      content: '',
      createdAt: DateTime.now(),
      messageType: 1,
      isSend: 0,
      files: fileDataList,
      images: [],
    );

    BlocProvider.of<ChatBloc>(context)
        .add(SendMessage(widget.token, widget.friendID, newMessage));
  }

  bool _isLastMessageByMe(int index, List<MessageModel> messageList) {
    for (int i = index + 1; i < messageList.length; i++) {
      if (messageList[i].messageType == 1) {
        return false;
      }
    }
    return true;
  }

  void _loadAvatar() async {
    final selectedFriend =
        friendList.firstWhere((friend) => friend.friendID == widget.friendID);
    Image? cachedAvatar = avatarCache[selectedFriend.avatar];

    if (cachedAvatar != null) {
      if (_isMounted) {
        setState(() {
          _avatarImage = cachedAvatar;
        });
      }
    } else {
      try {
        final avatar = await ApiService().loadAvatar(selectedFriend.avatar);
        if (_isMounted) {
          setState(() {
            _avatarImage = avatar;
            avatarCache[selectedFriend.avatar] = avatar;
          });
        }
      } catch (e) {
        if (_isMounted) {
          setState(() {
            _avatarImage = Image.asset(AssetConstants.iconPerson);
          });
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textEditController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    _isMounted = false;
    super.dispose();
  }
}
