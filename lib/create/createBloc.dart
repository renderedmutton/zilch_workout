import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/create/createStatus.dart';
import 'package:zilch_workout/create/createEvent.dart';
import 'package:zilch_workout/create/createState.dart';
import 'package:zilch_workout/create/item.dart';
import 'package:zilch_workout/create/segmentData.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/Workout.dart';

class CreateBloc extends Bloc<CreateEvent, CreateState> {
  final DataRepository dataRepo;
  CreateBloc({required user, required this.dataRepo})
      : super(CreateState(user: user));

  @override
  Stream<CreateState> mapEventToState(CreateEvent event) async* {
    if (event is WorkoutNameChanged) {
      yield state.copyWith(name: event.name);

      //CurrentType changed
    } else if (event is CurrentTypeChanged) {
      yield state.copyWith(currentType: state.currentType == 1 ? 2 : 1);

      //touchXY changed
    } else if (event is TouchXYChanged) {
      yield state.copyWith(touchXY: event.touchXY);

      //add segment
    } else if (event is AddSegment) {
      List<int> zones = [state.user.zone2, state.user.zone4];
      List<Item> buffer = [];
      int i = state.segmentWidgets.length % 2 == 0 ? 0 : 1;
      SegmentData newData = SegmentData(UniqueKey(), state.currentType,
          (zones[i] * state.user.ftp * 0.01).round(), 0.0, 600);
      for (int i = 0; i < state.segmentWidgets.length + 1; i++) {
        SegmentData data = i < state.segmentWidgets.length
            ? state.segmentWidgets[i].data
            : newData;
        buffer.add(Item(
            data: data,
            isFirst: i == 0,
            isLast: i == buffer.length - 1,
            selected: false));
      }
      yield state.copyWith(segmentWidgets: buffer);

      //copy segment
    } else if (event is CopySegment) {
      if (state.selectedSegments.isEmpty) return;
      List<Item> buffer = state.segmentWidgets;
      for (int i = 0; i < state.segmentWidgets.length; i++) {
        if (state.selectedSegments.contains(state.segmentWidgets[i].data.key)) {
          final oldData = state.segmentWidgets[i].data;
          SegmentData newData = SegmentData(UniqueKey(), oldData.type,
              oldData.power, oldData.slope, oldData.duration);
          buffer.add(Item(
              data: newData,
              isFirst: i == 0,
              isLast: i == buffer.length - 1,
              selected: false));
        }
      }
      yield state.copyWith(segmentWidgets: buffer);

      //Remove segment
    } else if (event is RemoveSegment) {
      if (state.selectedSegments.isEmpty) return;
      List<Item> buffer = state.segmentWidgets;
      buffer.removeWhere(
          (element) => state.selectedSegments.contains(element.data.key));
      yield state.copyWith(segmentWidgets: buffer);

      //Reorder segments
    } else if (event is ReorderSegment) {
      int draggingIndex = _indexOfKey(event.item);
      int newPosIndex = _indexOfKey(event.newPos);
      final draggedWidget = state.segmentWidgets[draggingIndex];
      List<Item> buffer = state.segmentWidgets;
      buffer.removeAt(draggingIndex);
      buffer.insert(newPosIndex, draggedWidget);
      yield state.copyWith(segmentWidgets: buffer);

      //item selected
    } else if (event is ItemSelected) {
      List<Key> buffer = state.selectedSegments;
      if (buffer.contains(event.key))
        buffer.removeWhere((element) => element == event.key);
      else
        buffer.add(event.key);
      List<Item> bufferItem = [];
      for (int i = 0; i < state.segmentWidgets.length; i++) {
        bufferItem.add(Item(
          data: state.segmentWidgets[i].data,
          isFirst: i == 0,
          isLast: i == state.segmentWidgets.length - 1,
          selected: buffer.contains(state.segmentWidgets[i].data.key),
        ));
      }
      yield state.copyWith(
          segmentWidgets: bufferItem, selectedSegments: buffer);

      //clear all selections
    } else if (event is ItemClearSelection) {
      List<Item> bufferItem = [];
      for (int i = 0; i < state.segmentWidgets.length; i++) {
        bufferItem.add(Item(
            data: state.segmentWidgets[i].data,
            isFirst: i == 0,
            isLast: i == state.segmentWidgets.length - 1,
            selected: false));
      }
      yield state.copyWith(segmentWidgets: bufferItem, selectedSegments: []);

      //item changed
    } else if (event is ItemChanged) {
      List<Item> buffer = [];
      for (int i = 0; i < state.segmentWidgets.length; i++) {
        SegmentData newData = state.segmentWidgets[i].data;
        if (state.segmentWidgets[i].data.key == event.key) {
          newData = SegmentData(
              event.key,
              event.type ?? state.segmentWidgets[i].data.type,
              event.power ?? state.segmentWidgets[i].data.power,
              event.slope ?? state.segmentWidgets[i].data.slope,
              event.duration ?? state.segmentWidgets[i].data.duration);
        }
        buffer.add(Item(
            data: newData,
            isFirst: state.segmentWidgets[i].isFirst,
            isLast: state.segmentWidgets[i].isLast,
            selected: state.segmentWidgets[i].selected));
      }
      yield state.copyWith(segmentWidgets: buffer);

      //get workout
    } else if (event is GetWorkouts) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        final workouts = await dataRepo.getWorkouts(state.user.id);
        yield state.copyWith(
            workouts: workouts, formStatus: SubmissionSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //create workout
    } else if (event is CreateWorkout) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        print('saving workout');
        yield state.copyWith(createStatus: CreationInProgress());
        if (state.isConflictingName) {
          yield state.copyWith(createStatus: CreationFailure());
          return;
        }
        List<int> types = state.segmentWidgets.map((e) => e.data.type).toList();
        List<int> powers =
            state.segmentWidgets.map((e) => e.data.power).toList();
        List<int> slopes = state.segmentWidgets
            .map((e) => (e.data.slope * 10).round())
            .toList();
        List<int> durations =
            state.segmentWidgets.map((e) => e.data.duration).toList();
        await dataRepo.createWorkout(
            state.user.id, state.name, types, powers, slopes, durations);
        yield state.copyWith(
            formStatus: SubmissionSuccess(), createStatus: CreationSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //update workout
    } else if (event is UpdateWorkout) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        print('updating workout');
        List<int> types = state.segmentWidgets.map((e) => e.data.type).toList();
        List<int> powers =
            state.segmentWidgets.map((e) => e.data.power).toList();
        List<int> slopes = state.segmentWidgets
            .map((e) => (e.data.slope * 10).round())
            .toList();
        List<int> durations =
            state.segmentWidgets.map((e) => e.data.duration).toList();
        await dataRepo.updateWorkout(
            userId: state.user.id,
            name: state.name,
            type: types,
            power: powers,
            slope: slopes,
            duration: durations);
        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //load workout
    } else if (event is LoadWorkout) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        Workout workout = await dataRepo.getWorkout(event.workoutId);
        List<Item> buffer = [];
        for (int i = 0; i < workout.power!.length; i++) {
          SegmentData data = SegmentData(UniqueKey(), workout.type![i],
              workout.power![i], workout.slope![i] / 10, workout.duration![i]);
          buffer.add(Item(
              data: data,
              isFirst: i == 0,
              isLast: i == workout.power!.length - 1,
              selected: false));
        }
        yield state.copyWith(
            name: workout.name,
            segmentWidgets: buffer,
            formStatus: SubmissionSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //delete workout
    } else if (event is DeleteWorkout) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        await dataRepo.deleteWorkout(event.workoutId);
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }
    }
  }

  int _indexOfKey(Key key) {
    return state.segmentWidgets.indexWhere((Item i) => i.data.key == key);
  }
}
