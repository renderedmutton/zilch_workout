import 'package:zilch_workout/activityPacker.dart';

abstract class ActivityState {}

class UninitializedActivity extends ActivityState {}

class InitializedActivity extends ActivityState {
  final ActivityPacker activityData;
  InitializedActivity(this.activityData);
}

class FailedInitializeActivity extends ActivityState {}
