import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'picker_event.dart';
part 'picker_state.dart';

class PickerBloc extends Bloc<PickerEvent, PickerState> {
  PickerBloc() : super(PickerInitial()) {
    on<PickerEvent>((event, emit) {
    });
  }
}
