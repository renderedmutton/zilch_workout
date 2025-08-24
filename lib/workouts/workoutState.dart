import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/models/User.dart';

class WorkoutState {
  final User user;
  final String? workoutName;
  final bool syncStrava;
  final FormSubmissionStatus formStatus;
  WorkoutState({
    required User user,
    String? workoutName,
    bool? syncStrava,
    this.formStatus = const InitialFormStatus(),
  })  : this.user = user,
        this.workoutName = workoutName,
        this.syncStrava = syncStrava ?? true;

  WorkoutState copyWith(
      {String? workoutName,
      bool? syncStrava,
      FormSubmissionStatus? formStatus}) {
    return WorkoutState(
        user: this.user,
        workoutName: workoutName ?? this.workoutName,
        syncStrava: syncStrava ?? this.syncStrava,
        formStatus: formStatus ?? this.formStatus);
  }
}
