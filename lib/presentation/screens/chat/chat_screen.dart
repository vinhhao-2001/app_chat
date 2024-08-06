import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/asset_constants.dart';

import '../../../core/data_types/file_data.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_text.dart';

import '../../../core/utils/di.dart';

import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/user_cases/shared_uc/load_avatar_use_case.dart';

import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/picker/picker_bloc.dart';

import '../../widgets/widget.dart';
import 'chat_widget/avatar_widget.dart';
import 'chat_widget/header/header_widget.dart';
import 'chat_widget/list/message_list_widget.dart';
import 'chat_widget/send/emoji_picker_widget.dart';
import 'chat_widget/send/image_picker_widget.dart';

class ChatScreen extends StatefulWidget {
  final String token;
  final FriendEntity selectedFriend;
  final Image? friendAvatar;
  const ChatScreen({
    super.key,
    required this.selectedFriend,
    required this.token,
    required this.friendAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _editTextSendMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Image? _avatarImage;
  bool _isMounted = false;
  DateTime? lastTime;
  final FocusNode _focusNode = FocusNode();
  late ChatBloc _chatBloc;
  late PickerBloc _pickerBloc;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _pickerBloc = context.read<PickerBloc>();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(FetchMessages(widget.token, widget.selectedFriend.friendID));
    _isMounted = true;
    _loadAvatar();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _pickerBloc.add(ClosePickers());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerBloc, PickerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            _pickerBloc.add(ClosePickers());
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  HeaderWidget(
                    selectedFriend: widget.selectedFriend,
                    avatarImage: _avatarImage,
                  ),
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (a, b) => a.messageList != b.messageList,
                      builder: (context, state) {
                        if (state.messageList.isEmpty && state.error.isEmpty) {
                          return const Center(child: LoadingWidget(size: 60));
                        } else if (state.messageList.isNotEmpty) {
                          final messageList = state.messageList;
                          if (messageList.isNotEmpty) {
                            lastTime = messageList.last.createdAt;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });
                            return MessageListWidget(
                              messageList: messageList,
                              scrollController: _scrollController,
                              avatarWidget: AvatarWidget(
                                image: _avatarImage,
                                size: 15,
                                isOnline: widget.selectedFriend.isOnline,
                              ),
                            );
                          } else {
                            lastTime = DateTime.now()
                                .subtract(const Duration(hours: 7));
                            return const Center(
                                child: Text(AppText.textChatEmpty));
                          }
                        } else {
                          return const Center(
                              child: Text(AppText.textChatEmpty));
                        }
                      },
                    ),
                  ),
                  _buildSendMessage(),
                  if (state.isEmojiOpen)
                    EmojiPickerWidget(controller: _editTextSendMessage),
                  if (state.isImagePickerOpen)
                    ImagePickerWidget(
                        token: widget.token,
                        friendID: widget.selectedFriend.friendID),
                ],
              ),
            ),
          ),
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
              _pickerBloc.add(ToggleEmojiPicker());
            },
          ),
          Expanded(
            child: TextField(
              controller: _editTextSendMessage,
              focusNode: _focusNode,
              decoration: InputDecoration(
                fillColor: AppColor.fillColor,
                filled: true,
                hintText: AppText.hintTextChat,
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
              _pickerBloc.add(ToggleImagePicker());
            },
          ),
        ],
      ),
    );
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _chatBloc.add(FetchMessages(
          widget.token, widget.selectedFriend.friendID, lastTime));
    });
  }

  void _sendMessage() {
    if (_editTextSendMessage.text.trim().isNotEmpty) {
      final newMessage = MessageEntity(
        content: _editTextSendMessage.text,
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        messageType: 1,
        isSend: 2,
        files: [],
        images: [],
      );

      _chatBloc.add(SendMessage(
          widget.token, widget.selectedFriend.friendID, newMessage));
      _editTextSendMessage.clear();
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
      // log('$e');
    }
  }

  void _sendFiles(List<FileData> fileDataList) async {
    final newMessage = MessageEntity(
      content: '',
      createdAt: DateTime.now(),
      messageType: 1,
      isSend: 0,
      files: fileDataList,
      images: [],
    );

    _chatBloc.add(
        SendMessage(widget.token, widget.selectedFriend.friendID, newMessage));
  }

  void _loadAvatar() async {
    if (widget.friendAvatar != null) {
      if (_isMounted) {
        setState(() {
          _avatarImage = widget.friendAvatar;
        });
      }
    } else {
      try {
        final avatar = await getIt<LoadAvatarUseCase>()
            .execute(widget.selectedFriend.avatar);
        if (_isMounted) {
          setState(() {
            _avatarImage = avatar;
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _editTextSendMessage.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    _isMounted = false;
    super.dispose();
  }
}
