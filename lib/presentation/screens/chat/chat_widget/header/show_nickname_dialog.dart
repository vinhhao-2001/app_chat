part of 'header_widget.dart';

class ShowNicknameDialog extends StatelessWidget {
  final FriendEntity selectedFriend;

  const ShowNicknameDialog({super.key, required this.selectedFriend});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text(AppText.textNickname),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: AppText.hintTextNickname,
        ),
      ),
      actions: [
        TextButton(
          child: const Text(AppText.textCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(AppText.textOk),
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              selectedFriend.nickname = controller.text;
              await getIt<AddNicknameUseCase>()
                  .execute(selectedFriend.friendID, controller.text);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppText.nicknameEmpty),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
