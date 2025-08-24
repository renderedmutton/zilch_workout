import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zilch_workout/activityPacker.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/storageRepository.dart';
import 'package:zilch_workout/strava/stravaAPI.dart';
import 'package:zilch_workout/tcx/tcxWriter.dart';
import 'package:zilch_workout/workouts/workoutEvent.dart';
import 'package:zilch_workout/workouts/workoutState.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final DataRepository dataRepo;
  final StorageRepository storageRepo;
  final StravaAPI stravaAPI;
  WorkoutBloc(
      {required user,
      required this.dataRepo,
      required this.storageRepo,
      required this.stravaAPI})
      : super(WorkoutState(user: user));

  @override
  Stream<WorkoutState> mapEventToState(WorkoutEvent event) async* {
    if (event is UpdateWorkoutName) {
      yield state.copyWith(workoutName: event.workoutName);

      //save to datastore
    } else if (event is SaveActivity) {
      yield state.copyWith(formStatus: FormSubmitting());
      try {
        //create binary file
        Uint8List data = ActivityPacker(
                powers: event.powers,
                cadences: event.cadences,
                hrs: event.hrs,
                times: event.times,
                speeds: event.speeds,
                distances: event.distances,
                laps: event.laps,
                startTime: event.startTime,
                totalAscent: event.totalAscent)
            .toBytes();
        //save file to temp dir
        final tempDir = await getApplicationDocumentsDirectory();
        final file = await File(tempDir.path + '/' + event.dataName + '.dat')
            .writeAsBytes(data);
        print('filepath ${file.path}');
        String fileKey = event.dataName + '.dat';
        //upload to s3
        if (state.user.id != AppConstants().guestUUID)
          fileKey = await storageRepo.uploadFile(file, event.dataName + '.dat');
        //update workout lastmodified and create activity
        await Future.wait([
          if (state.workoutName! != 'ERG_FREE' &&
              state.workoutName! != 'SIM_FREE')
            dataRepo.updateWorkout(
                userId: state.user.id, name: state.workoutName!),
          dataRepo.createActivityJSON(
              userId: state.user.id,
              workoutName: state.workoutName!,
              startTime: event.startTime,
              averagePower: event.averagePower,
              duration: event.duration,
              tss: event.tss,
              segmentDurations: event.segmentDurations,
              dataName: fileKey),
        ]);
        //upload to strava
        if (event.isAuthok && state.syncStrava) {
          int dur =
              ((event.times[event.times.length - 1] - event.startTime) / 1000)
                  .round();
          num workDone = event.powers.fold(0, (p, c) => p + c);
          workDone = (workDone * dur / event.powers.length).roundToDouble();
          workDone = (workDone * 3.6 / 3600).round();
          String stravaFilename =
              'strava_garmin_${state.workoutName!}_${event.startTime}.tcx';
          File stravaFile = await TcxWriter().writeTCX(
              filename: stravaFilename,
              dateActivity:
                  DateTime.fromMillisecondsSinceEpoch(event.startTime),
              duration: (event.duration / 1000).round(),
              totalDistance: (event.distances.last * 1000).round(),
              calories: workDone.round(),
              times: event.times,
              distances: event.distances,
              speeds: event.speeds,
              powers: event.powers,
              hrs: event.hrs,
              cadences: event.cadences);
          await stravaAPI.uploadWorkout(stravaFile);
        }

        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch (e) {
        print('try error: $e');
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //sync strava
    } else if (event is ChangeSyncStrava) {
      yield state.copyWith(syncStrava: event.syncStrava);
    }
  }
}
