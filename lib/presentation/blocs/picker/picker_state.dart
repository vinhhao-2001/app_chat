part of 'picker_bloc.dart';

class PickerState extends Equatable {
  final bool isEmojiOpen;
  final bool isImagePickerOpen;

  const PickerState({
    this.isEmojiOpen = false,
    this.isImagePickerOpen = false,
  });

  @override
  List<Object> get props => [isEmojiOpen, isImagePickerOpen];

  PickerState copyWith({
    bool? isEmojiOpen,
    bool? isImagePickerOpen,
  }) {
    return PickerState(
      isEmojiOpen: isEmojiOpen ?? this.isEmojiOpen,
      isImagePickerOpen: isImagePickerOpen ?? this.isImagePickerOpen,
    );
  }
}
