part of 'picker_bloc.dart';

class PickerState extends Equatable {
  final bool isEmojiPickerOpen;
  final bool isImagePickerOpen;
  const PickerState({
    this.isEmojiPickerOpen = false,
    this.isImagePickerOpen = false,
  });

  PickerState copyWith({bool? isEmojiPickerOpen, bool? isImagePickerOpen}) {
    return PickerState(
      isEmojiPickerOpen: isEmojiPickerOpen ?? this.isEmojiPickerOpen,
      isImagePickerOpen: isImagePickerOpen ?? this.isImagePickerOpen,
    );
  }

  @override
  List<Object> get props => [];
}

class PickerInitial extends PickerState {}
