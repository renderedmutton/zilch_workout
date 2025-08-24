import 'package:flutter/material.dart';

abstract class CreateEvent {}

class WorkoutNameChanged extends CreateEvent {
  final String name;
  WorkoutNameChanged(this.name);
}

class CurrentTypeChanged extends CreateEvent {}

class TouchXYChanged extends CreateEvent {
  final Offset? touchXY;
  TouchXYChanged(this.touchXY);
}

class AddSegment extends CreateEvent {}

class CopySegment extends CreateEvent {}

class RemoveSegment extends CreateEvent {}

class ReorderSegment extends CreateEvent {
  final Key item;
  final Key newPos;
  ReorderSegment(this.item, this.newPos);
}

class ItemSelected extends CreateEvent {
  final Key key;
  ItemSelected(this.key);
}

class ItemClearSelection extends CreateEvent {}

class ItemChanged extends CreateEvent {
  final Key key;
  final int? type;
  final int? power;
  final double? slope;
  final int? duration;
  ItemChanged(
      {required this.key, this.type, this.power, this.slope, this.duration});
}

class GetWorkouts extends CreateEvent {}

class CreateWorkout extends CreateEvent {}

class UpdateWorkout extends CreateEvent {}

class LoadWorkout extends CreateEvent {
  final String workoutId;
  LoadWorkout(this.workoutId);
}

class DeleteWorkout extends CreateEvent {
  final String workoutId;
  DeleteWorkout(this.workoutId);
}
