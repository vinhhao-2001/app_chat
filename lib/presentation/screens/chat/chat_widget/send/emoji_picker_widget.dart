import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

class EmojiPickerWidget extends StatelessWidget {
  final TextEditingController controller;
  const EmojiPickerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          controller.text += emoji.emoji;
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
}
