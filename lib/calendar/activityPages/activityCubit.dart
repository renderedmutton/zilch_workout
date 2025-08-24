import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zilch_workout/activityPacker.dart';
import 'package:zilch_workout/calendar/activityPages/activityState.dart';
import 'package:zilch_workout/models/Activity.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/storageRepository.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final User user;
  final Activity activity;
  final StorageRepository storageRepo;
  ActivityCubit(
      {required this.user, required this.activity, required this.storageRepo})
      : super(UninitializedActivity()) {
    _initializeActivity();
  }

  void _initializeActivity() async {
    final tempDir = await getApplicationDocumentsDirectory();
    final path = tempDir.path + '/' + activity.name!;
    final fileExistLocally = await File(path).exists();
    print('$path \n $fileExistLocally');
    if (fileExistLocally) {
      print('activity data exist locally');
      final bytes = await File(path).readAsBytes();
      final data = ActivityPacker.fromBytes(bytes);
      emit(InitializedActivity(data));
      return;
    }
    print('activity data does not exist locally');
    try {
      File local = File(path);
      local = await storageRepo.downloadFile(local, activity.name!);
      final bytes = await local.readAsBytes();
      final data = ActivityPacker.fromBytes(bytes);
      emit(InitializedActivity(data));
    } catch (e) {
      print(e);
      emit(FailedInitializeActivity());
    }
  }
}
