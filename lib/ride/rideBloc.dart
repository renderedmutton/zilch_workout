import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/ride/rideEvent.dart';
import 'package:zilch_workout/ride/rideState.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  RideBloc(
      {required User user,
      required DataRepository dataRepo,
      required BluetoothAPI bleRepo})
      : super(RideState(dataRepo: dataRepo, bleRepo: bleRepo, user: user));
  @override
  Stream<RideState> mapEventToState(RideEvent event) async* {
    if (event is GetWorkouts) {
      try {
        final workouts = await state.dataRepo.getWorkouts(state.user.id);
        yield state.copyWith(workouts: workouts);
      } catch (e) {
        print(e);
      }
    }
  }
}
