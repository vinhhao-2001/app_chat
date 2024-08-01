part of 'picker_bloc.dart';

sealed class PickerEvent extends Equatable {
  const PickerEvent();
  @override
  List<Object?> get props => [];
}

class EmojiPickerToggleEvent extends PickerEvent {}

class ImagePickerToggleEvent extends PickerEvent {}

class KeyboardFocusEvent extends PickerEvent {}
