part of 'picker_bloc.dart';

sealed class PickerState extends Equatable {
  const PickerState();
}

final class PickerInitial extends PickerState {
  @override
  List<Object> get props => [];
}
