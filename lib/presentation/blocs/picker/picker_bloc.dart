import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'picker_event.dart';
part 'picker_state.dart';

class PickerBloc extends Bloc<PickerEvent, PickerState> {
  PickerBloc() : super(PickerInitial()) {
    on<EmojiPickerToggleEvent>(_onEmojiPickerToggleEvent);
    on<ImagePickerToggleEvent>(_onImagePickerToggleEvent);
    on<KeyboardFocusEvent>(_onKeyboardFocusEvent);
  }
  void _onEmojiPickerToggleEvent(
      EmojiPickerToggleEvent event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isEmojiPickerOpen: !state.isEmojiPickerOpen,
      isImagePickerOpen: false,
    ));
  }

  void _onImagePickerToggleEvent(
      ImagePickerToggleEvent event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isImagePickerOpen: !state.isImagePickerOpen,
      isEmojiPickerOpen: false,
    ));
  }

  void _onKeyboardFocusEvent(
      KeyboardFocusEvent event, Emitter<PickerState> emit) {
    emit(state.copyWith(
      isEmojiPickerOpen: false,
      isImagePickerOpen: false,
    ));
  }
}
