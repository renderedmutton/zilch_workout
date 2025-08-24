import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/models/Workout.dart';

class RideState {
  final DataRepository dataRepo;
  final BluetoothAPI bleRepo;
  final User user;
  List<Workout> workouts;
  RideState({
    required DataRepository dataRepo,
    required BluetoothAPI bleRepo,
    required User user,
    List<Workout>? workouts,
  })  : this.dataRepo = dataRepo,
        this.bleRepo = bleRepo,
        this.user = user,
        this.workouts = workouts ?? [];

  RideState copyWith({List<Workout>? workouts}) {
    return RideState(
        dataRepo: this.dataRepo,
        bleRepo: this.bleRepo,
        user: this.user,
        workouts: workouts ?? this.workouts);
  }
}
