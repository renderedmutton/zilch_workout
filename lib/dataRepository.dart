import 'package:amplify_flutter/amplify.dart';
import 'package:zilch_workout/models/ModelProvider.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/models/Workout.dart';

class DataRepository {
  Future<User?> getUserById(String userId) async {
    try {
      final users = await Amplify.DataStore.query(User.classType,
          where: User.ID.eq(userId));
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      throw e;
    }
  }

  Future<User> createUser(
      {required String userId,
      required String username,
      String nickname = ''}) async {
    final newUser = User(
      id: userId,
      username: username,
      nickname: nickname,
      ftp: 200,
      metric: true,
      weight: 7000,
      bikeWeight: 800,
      wheelCircumference: 2105,
      zone1: 55,
      zone2: 75,
      zone3: 90,
      zone4: 105,
      zone5: 120,
      rrHr: 60,
      powerCurve: [],
    );
    try {
      await Amplify.DataStore.save(newUser);
      return newUser;
    } catch (e) {
      throw e;
    }
  }

  Future<User> updateUser(
      {required String userId,
      String? newId,
      String? username,
      String? nickname,
      int? age,
      int? sex,
      bool? metric,
      int? weight,
      int? bikeWeight,
      int? wheelCircumference,
      int? ftp,
      int? zone1,
      int? zone2,
      int? zone3,
      int? zone4,
      int? zone5,
      int? rrHr,
      int? ltHr,
      int? maxHr,
      int? newFtp,
      List<int>? powerCurve}) async {
    User? oldUser = await getUserById(userId);
    if (oldUser == null) {
      throw ('Failed to get user');
    }
    User updatedUser = oldUser.copyWith(
        id: newId ?? oldUser.id,
        username: username ?? oldUser.username,
        nickname: nickname ?? oldUser.nickname,
        age: age ?? oldUser.age,
        sex: sex ?? oldUser.sex,
        metric: metric ?? oldUser.metric,
        weight: weight ?? oldUser.weight,
        bikeWeight: bikeWeight ?? oldUser.bikeWeight,
        wheelCircumference: wheelCircumference ?? oldUser.wheelCircumference,
        ftp: ftp ?? oldUser.ftp,
        zone1: zone1 ?? oldUser.zone1,
        zone2: zone2 ?? oldUser.zone2,
        zone3: zone3 ?? oldUser.zone3,
        zone4: zone4 ?? oldUser.zone4,
        zone5: zone5 ?? oldUser.zone5,
        rrHr: rrHr ?? oldUser.rrHr,
        ltHr: ltHr ?? oldUser.ltHr,
        maxHr: maxHr ?? oldUser.maxHr,
        newFtp: newFtp ?? oldUser.newFtp,
        powerCurve: powerCurve ?? oldUser.powerCurve);
    try {
      await Amplify.DataStore.save(updatedUser);
      return updatedUser;
    } catch (e) {
      throw e;
    }
  }

  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final workouts = await Amplify.DataStore.query(Workout.classType,
          where: Workout.USERID.eq(userId),
          sortBy: [Workout.LASTMODIFIED.descending()]);
      return workouts;
    } catch (e) {
      throw e;
    }
  }

  Future<Workout> getWorkout(String workoutId) async {
    try {
      final workout = await Amplify.DataStore.query(Workout.classType,
          where: Workout.ID.eq(workoutId));
      return workout.firstWhere((element) => element.id == workoutId);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> createWorkout(String userId, String name, List<int> type,
      List<int> power, List<int> slope, List<int> duration) async {
    final user = await getUserById(userId);
    if (user == null) throw ('Error occured saving workout');
    final newWorkout = Workout(
        userID: user.id,
        name: name,
        type: type,
        power: power,
        slope: slope,
        duration: duration,
        lastModified: (DateTime.now().millisecondsSinceEpoch / 1000).round());
    try {
      print('createWorkout ${newWorkout.name}');
      await Amplify.DataStore.save(newWorkout);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> updateWorkout(
      {required String userId,
      required String name,
      String? newId,
      List<int>? type,
      List<int>? power,
      List<int>? slope,
      List<int>? duration}) async {
    final workouts = await getWorkouts(userId);
    if (workouts.isEmpty)
      throw ('Error occured: No workout of same name found');
    final oldWorkout = workouts.firstWhere((workout) => workout.name == name);
    final updatedWorkout = oldWorkout.copyWith(
        userID: newId ?? oldWorkout.userID,
        type: type ?? oldWorkout.type,
        power: power ?? oldWorkout.power,
        slope: slope ?? oldWorkout.slope,
        duration: duration ?? oldWorkout.duration,
        lastModified: (DateTime.now().millisecondsSinceEpoch / 1000).round());
    try {
      print('updateWorkout ${updatedWorkout.name}');
      await Amplify.DataStore.save(updatedWorkout);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    final workout = await getWorkout(workoutId);
    try {
      await Amplify.DataStore.delete(workout);
    } catch (e) {
      throw e;
    }
  }

  Future<List<Activity>> getActivitiesJSON(String userId) async {
    try {
      final activities = await Amplify.DataStore.query(Activity.classType,
          where: Activity.USERID.eq(userId));
      return activities;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> createActivityJSON(
      {required String userId,
      required String workoutName,
      required int startTime,
      required int averagePower,
      required int duration,
      required int tss,
      required List<int> segmentDurations,
      required String dataName}) async {
    final user = await getUserById(userId);
    if (user == null) throw ('Error occured saving activity');
    final newActivity = Activity(
        name: dataName,
        startTime: (startTime / 1000).round(),
        averagePower: averagePower,
        duration: duration, //milliseconds
        tss: tss,
        segmentsDuration: segmentDurations,
        workoutName: workoutName,
        userID: user.id);
    try {
      print('saving newActivity');
      await Amplify.DataStore.save(newActivity);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<List<Schedule>> getSchedules(String userId) async {
    try {
      final schedules = await Amplify.DataStore.query(Schedule.classType,
          where: Schedule.USERID.eq(userId));
      return schedules;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> createSchedule(
      {required String userId,
      required int scheduledTimestamp,
      required int notificationTimestamp,
      required String workoutName}) async {
    final user = await getUserById(userId);
    if (user == null) throw ('Error occured saving activity');
    final newSchedule = Schedule(
        scheduledTimestamp: scheduledTimestamp,
        notificationTimestamp: notificationTimestamp,
        workoutName: workoutName,
        userID: user.id);
    try {
      print('saving newSchedule');
      await Amplify.DataStore.save(newSchedule);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> deleteSchedule({required String scheduleId}) async {
    try {
      final schedules = await Amplify.DataStore.query(Schedule.classType,
          where: Schedule.ID.eq(scheduleId));
      await Amplify.DataStore.delete(
          schedules.firstWhere((element) => element.id == scheduleId));
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateWorkoutsActivitiesSchedules(
      {required String userId, required String guestId}) async {
    print('updating guest activities & schedules');
    try {
      final workouts = await getWorkouts(guestId);
      final activities = await getActivitiesJSON(guestId);
      final schedules = await getSchedules(guestId);

      await Future.forEach(
          workouts,
          (Workout w) => createWorkout(
              userId, w.name!, w.type!, w.power!, w.slope!, w.duration!));
      Future.forEach(workouts, (Workout w) => deleteWorkout(w.id));
      await Future.forEach(activities, (Activity a) {
        createActivityJSON(
            userId: userId,
            workoutName: a.workoutName!,
            startTime: (a.startTime! * 1000),
            averagePower: a.averagePower!,
            duration: a.duration!,
            tss: a.tss!,
            segmentDurations: a.segmentsDuration!,
            dataName: a.name!);
      });
      Future.forEach(activities, (Activity a) => Amplify.DataStore.delete(a));
      await Future.forEach(schedules, (Schedule s) {
        createSchedule(
            userId: userId,
            scheduledTimestamp: s.scheduledTimestamp!,
            notificationTimestamp: s.notificationTimestamp!,
            workoutName: s.workoutName!);
      });
      Future.forEach(schedules, (Schedule s) => Amplify.DataStore.delete(s));
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteGuestUser({required String userId}) async {
    print('deleting guest user');
    final user = await getUserById(userId);
    final workouts = await getWorkouts(userId);
    final activities = await getActivitiesJSON(userId);
    final schedules = await getSchedules(userId);
    if (user != null) Amplify.DataStore.delete(user);
    Future.forEach(workouts, (Workout w) => Amplify.DataStore.delete(w));
    Future.forEach(activities, (Activity a) => Amplify.DataStore.delete(a));
    Future.forEach(schedules, (Schedule s) => Amplify.DataStore.delete(s));
  }

  Future<Strava> getStrava() async {
    print('getting strava ids');
    final stravas = (await Amplify.DataStore.query(Strava.classType));
    return stravas.first;
  }
}
