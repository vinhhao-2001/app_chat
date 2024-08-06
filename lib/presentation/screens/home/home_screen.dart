import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/asset_constants.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_text.dart';

import '../../../core/utils/di.dart';

import '../../../core/utils/flush_helper.dart';
import '../../../domain/user_cases/shared_uc/load_avatar_use_case.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';

import '../../widgets/loading_widget.dart';
import '../chat/chat_screen.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserBloc userBloc;
  late FriendBloc friendBloc;

  @override
  void initState() {
    super.initState();
    userBloc = context.read<UserBloc>();
    friendBloc = context.read<FriendBloc>();
    userBloc.add(GetUserInfo(widget.token));
    friendBloc.add(FetchFriends(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildAppBarWidget(context),
            const SizedBox(height: 20),
            _buildSearchBarWidget(),
            const SizedBox(height: 20),
            const Text(
              AppText.textFriendList,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            _buildFriendListWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppText.appName,
          style: TextStyle(
            color: AppColor.appNameColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        BlocBuilder<UserBloc, UserState>(
          buildWhen: (a, b) =>
              a.avatarImage != b.avatarImage ||
              a.message != b.message ||
              a.userName != b.userName,
          builder: (context, state) {
            if (state.userName.isEmpty) {
              if (state.message.isNotEmpty) {
                // xử lý trường hợp lỗi server
                FlushBarHelper.flushBarErrorMessage(state.message, context);
                _logout(context);
              }
              return const LoadingWidget();
            } else {
              if (state.message.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FlushBarHelper.flushBarErrorMessage(state.message, context);
                });
                // trường hợp mất mạng
              }
              return GestureDetector(
                onTap: () => openPopupMenu(context),
                child: CircleAvatar(
                  backgroundImage: state.avatarImage?.image ??
                      const AssetImage(AssetConstants.iconPerson),
                  radius: 20,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBarWidget() {
    TextEditingController searchController = TextEditingController();
    return TextFormField(
      controller: searchController,
      onChanged: (query) => {
        friendBloc.add(SearchFriends(query)),
      },
      decoration: InputDecoration(
        hintText: AppText.hintTextSearch,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            searchController.clear();
            friendBloc.add(const SearchFriends(''));
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildFriendListWidget(BuildContext context) {
    return Expanded(
      child: BlocBuilder<FriendBloc, FriendState>(
        buildWhen: (a, b) =>
            a.friendList != b.friendList || a.message != b.message,
        builder: (context, state) {
          if (state.message.isEmpty && state.friendList.isEmpty) {
            return const Center(child: LoadingWidget());
          } else if (state.friendList.isNotEmpty) {
            return ListView.builder(
              itemCount: state.friendList.length,
              itemBuilder: (context, index) {
                final friend = state.friendList[index];
                Image? avatarImage = state.avatarCache[friend.avatar];

                return FutureBuilder<Image>(
                  future: avatarImage == null
                      ? getIt<LoadAvatarUseCase>().execute(friend.avatar)
                      : Future.value(avatarImage),
                  builder: (context, snapshot) {
                    Widget leadingWidget;

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        avatarImage == null) {
                      leadingWidget = const CircleAvatar(
                        radius: 25,
                        child: LoadingWidget(),
                      );
                    } else if (snapshot.hasError) {
                      leadingWidget = const CircleAvatar(
                        backgroundImage: AssetImage(AssetConstants.iconPerson),
                        radius: 25,
                      );
                    } else {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        friendBloc
                            .add(CacheAvatar(friend.avatar, snapshot.data!));
                      }
                      leadingWidget = CircleAvatar(
                        backgroundImage:
                            snapshot.data?.image ?? avatarImage?.image,
                        radius: 25,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 5,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: friend.isOnline
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListTile(
                      leading: leadingWidget,
                      title: Text(
                        friend.nickname ?? friend.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: friend.content.isNotEmpty
                          ? Text(
                              friend.content,
                              style:
                                  const TextStyle(color: AppColor.contentColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : friend.images.isNotEmpty
                              ? Text(
                                  '${AppText.textSent} ${friend.images.length} ${AppText.textImage}',
                                  style: const TextStyle(
                                      color: AppColor.contentColor,
                                      fontStyle: FontStyle.italic),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : friend.files.isNotEmpty
                                  ? Text(
                                      '${AppText.textSent} ${friend.files.length} ${AppText.textFile}',
                                      style: const TextStyle(
                                          color: AppColor.contentColor,
                                          fontStyle: FontStyle.italic),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )
                                  : null,
                      onTap: snapshot.connectionState == ConnectionState.done &&
                              snapshot.data != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    token: widget.token,
                                    selectedFriend: friend,
                                    friendAvatar:
                                        friendBloc.avatarCache[friend.avatar],
                                  ),
                                ),
                              )
                          : null,
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: Text(state.message),
          );
        },
      ),
    );
  }

  void openPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(80, 80, 0, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: BlocBuilder<UserBloc, UserState>(
            buildWhen: (a, b) => a.fullName != b.fullName,
            builder: (context, state) {
              return Text(state.fullName);
            },
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text(AppText.textChangeAvatar),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text(AppText.textLogout),
        ),
      ],
    ).then((value) {
      if (value != null) {
        if (value == 1) {
          _showChangeNameDialog(context);
        } else if (value == 2) {
          _updateAvatar(context);
        } else if (value == 3) {
          _logout(context);
        }
      }
    });
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    String? currentName;
    final state = userBloc.state;
    if (state.fullName.isNotEmpty) {
      currentName = state.fullName;
    }
    TextEditingController nameController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppText.textChangeName),
          content: TextField(
            controller: nameController,
            decoration:
                const InputDecoration(hintText: AppText.hintTextNewName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppText.textCancel),
            ),
            TextButton(
              onPressed: () {
                userBloc.add(
                    UpdateUserInfo(widget.token, nameController.text, null));
                Navigator.of(context).pop();
              },
              child: const Text(AppText.textOk),
            ),
          ],
        );
      },
    );
  }

  void _updateAvatar(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      userBloc.add(UpdateUserInfo(widget.token, null, pickedFile.path));
    }
  }

  void _logout(BuildContext context) async {
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
