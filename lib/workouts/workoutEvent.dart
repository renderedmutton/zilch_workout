abstract class WorkoutEvent {}

class UpdateWorkoutName extends WorkoutEvent {
  final String workoutName;
  UpdateWorkoutName(this.workoutName);
}

class SaveActivity extends WorkoutEvent {
  final String workoutName;
  final int startTime;
  final int averagePower;
  final int duration;
  final int tss;
  final List<int> segmentDurations;
  final String dataName;
  final List<int> powers;
  final List<int> cadences;
  final List<int> hrs;
  final List<int> times;
  final List<int> speeds;
  final List<int> distances;
  final List<int> laps;
  final int totalAscent;
  final bool isAuthok;
  SaveActivity(
      this.workoutName,
      this.startTime,
      this.averagePower,
      this.duration,
      this.tss,
      this.segmentDurations,
      this.dataName,
      this.powers,
      this.cadences,
      this.hrs,
      this.times,
      this.speeds,
      this.distances,
      this.laps,
      this.totalAscent,
      this.isAuthok);
}

class ChangeSyncStrava extends WorkoutEvent {
  final bool syncStrava;
  ChangeSyncStrava(this.syncStrava);
}
