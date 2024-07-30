import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/theme/app_color.dart';
import '../../core/theme/app_text.dart';
import '../../data/data_sources/remote/api/api_service.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/friend/friend_bloc.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    context.read<UserBloc>().add(GetUserInfo(widget.token));
    context.read<FriendBloc>().add(FetchFriends(widget.token));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            _buildSearchBarWidget(context, searchController),
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
          builder: (context, state) {
            if (state is UserLoadingState) {
              return const CircularProgressIndicator();
            } else if (state is UserLoadedState) {
              return GestureDetector(
                onTap: () => openPopupMenu(context),
                child: CircleAvatar(
                  backgroundImage: state.avatarImage?.image ??
                      const AssetImage(AssetConstants.iconPerson),
                  radius: 20,
                ),
              );
            } else if (state is UserErrorState) {
              log(state.message);
              return GestureDetector(
                onTap: () => openPopupMenu(context),
                child: const CircleAvatar(
                  backgroundImage: AssetImage(AssetConstants.iconPerson),
                  radius: 20,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBarWidget(
      BuildContext context, TextEditingController searchController) {
    return TextFormField(
      controller: searchController,
      onChanged: (query) =>
          context.read<FriendBloc>().add(SearchFriends(query)),
      decoration: InputDecoration(
        hintText: AppText.hintTextSearch,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (searchController.text.isNotEmpty) {
              searchController.clear();
              context.read<FriendBloc>().add(const SearchFriends(''));
            }
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
        builder: (context, state) {
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendLoaded) {
            return ListView.builder(
              itemCount: state.filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = state.filteredFriends[index];
                Image? avatarImage = state.avatarCache[friend.avatar];

                return FutureBuilder<Image>(
                  future: avatarImage == null
                      ? ApiService().loadAvatar(friend.avatar)
                      : Future.value(avatarImage),
                  builder: (context, snapshot) {
                    Widget leadingWidget;

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        avatarImage == null) {
                      leadingWidget = const CircleAvatar(
                        radius: 25,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      leadingWidget = const CircleAvatar(
                        backgroundImage: AssetImage(AssetConstants.iconPerson),
                        radius: 25,
                      );
                    } else {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        context
                            .read<FriendBloc>()
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
                              style: const TextStyle(
                                  color: AppColor.contentColor,
                                  fontStyle: FontStyle.italic),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            token: widget.token,
                            friendID: friend.friendID,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is FriendError) {
            log(state.message);
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void openPopupMenu(BuildContext context) {
    final userBloc = context.read<UserBloc>();
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(80, 80, 0, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: BlocProvider.value(
            value: userBloc,
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoadedState) {
                  return Text(state.fullName);
                } else {
                  return const Text('');
                }
              },
            ),
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
    final userBloc = context.read<UserBloc>();
    String? currentName;
    final state = userBloc.state;
    if (state is UserLoadedState) {
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
    final userBloc = context.read<UserBloc>();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      userBloc.add(UpdateUserInfo(widget.token, null, pickedFile.path));
    }
  }

  void _logout(BuildContext context) async {
    final userBloc = context.read<UserBloc>();
    userBloc.add(Logout());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
