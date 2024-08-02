import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'picker_event.dart';
part 'picker_state.dart';

class PickerBloc extends Bloc<PickerEvent, PickerState> {
  PickerBloc() : super(const PickerState()) {
    on<ToggleEmojiPicker>(_onToggleEmojiPicker);
    on<ToggleImagePicker>(_onToggleImagePicker);
    on<ClosePickers>(_onClosePickers);
  }

  void _onToggleEmojiPicker(
      ToggleEmojiPicker event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isEmojiOpen: !state.isEmojiOpen,
      isImagePickerOpen: false,
    ));
  }

  void _onToggleImagePicker(
      ToggleImagePicker event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isEmojiOpen: false,
      isImagePickerOpen: !state.isImagePickerOpen,
    ));
  }

  void _onClosePickers(ClosePickers event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isEmojiOpen: false,
      isImagePickerOpen: false,
    ));
  }
}
