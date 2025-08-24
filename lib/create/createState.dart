import 'package:flutter/material.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/create/createStatus.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/models/Workout.dart';
import 'package:zilch_workout/create/item.dart';

class CreateState {
  final User user;
  final String name;
  bool get isValidName => RegExp(r'^[a-zA-z0-9 _\-=@,\.]+$').hasMatch(name);
  bool get isConflictingName => workouts.any((element) => element.name == name);
  int currentType;
  List<Item> segmentWidgets;
  List<Key> selectedSegments;
  Offset? touchXY;
  List<Workout> workouts;
  final FormSubmissionStatus formStatus;
  final CreateStatus createStatus;

  CreateState(
      {required User user,
      this.name = 'New Workout',
      this.currentType = 1,
      List<Item>? segmentWidgets,
      List<Key>? selectedSegments,
      this.touchXY,
      List<Workout>? workouts,
      this.formStatus = const InitialFormStatus(),
      this.createStatus = const InitialCreateStatus()})
      : this.user = user,
        this.segmentWidgets = segmentWidgets ?? [],
        this.selectedSegments = selectedSegments ?? [],
        this.workouts = workouts ?? [];

  CreateState copyWith({
    String? name,
    int? currentType,
    List<Item>? segmentWidgets,
    List<Key>? selectedSegments,
    Offset? touchXY,
    List<Workout>? workouts,
    FormSubmissionStatus? formStatus,
    CreateStatus? createStatus,
  }) {
    return CreateState(
      user: this.user,
      name: name ?? this.name,
      currentType: currentType ?? this.currentType,
      segmentWidgets: segmentWidgets ?? this.segmentWidgets,
      selectedSegments: selectedSegments ?? this.selectedSegments,
      touchXY: touchXY,
      workouts: workouts ?? this.workouts,
      formStatus: formStatus ?? this.formStatus,
      createStatus: createStatus ?? this.createStatus,
    );
  }
}
