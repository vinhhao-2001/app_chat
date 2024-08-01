import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_text.dart';
import '../../../../../data/data_sources/local/db_helper.dart';
import '../../../../../domain/entities/friend_entity.dart';
import '../../../../blocs/friend/friend_bloc.dart';
import '../../../../widgets/widget.dart';
import '../avatar_widget.dart';

part 'show_nickname_dialog.dart';

class HeaderWidget extends StatelessWidget {
  final FriendEntity selectedFriend;
  final Image? avatarImage;

  const HeaderWidget({
    super.key,
    required this.selectedFriend,
    required this.avatarImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendBloc(),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => ShowNicknameDialog(selectedFriend: selectedFriend),
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 30, left: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (avatarImage == null)
                    const LoadingWidget(size: 20)
                  else
                    AvatarWidget(
                        image: avatarImage,
                        isOnline: selectedFriend.isOnline,
                        size: 20),
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
                                ? AppText.online
                                : AppText.offline,
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
          ),
        ],
      ),
    );
  }
}
