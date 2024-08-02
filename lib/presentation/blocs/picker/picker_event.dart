part of 'picker_bloc.dart';

sealed class PickerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ToggleEmojiPicker extends PickerEvent {}
class ToggleImagePicker extends PickerEvent {}
class ClosePickers extends PickerEvent {}
