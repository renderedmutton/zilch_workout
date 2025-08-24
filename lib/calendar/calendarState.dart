import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/Activity.dart';
import 'package:zilch_workout/models/Schedule.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/models/Workout.dart';

class CalendarState {
  final User user;
  final DataRepository dataRepo;
  final List<Workout> workouts;
  final List<Activity> activities;
  final List<Schedule> schedules;
  final EventList<Event> markedDateMap;
  final Map<DateTime, List<int>> statistics;
  CalendarState(
      {required User user,
      required DataRepository dataRepo,
      List<Workout>? workouts,
      List<Activity>? activities,
      List<Schedule>? schedules,
      EventList<Event>? markedDateMap,
      Map<DateTime, List<int>>? statistics})
      : this.user = user,
        this.dataRepo = dataRepo,
        this.workouts = workouts ?? [],
        this.activities = activities ?? [],
        this.schedules = schedules ?? [],
        this.markedDateMap = markedDateMap ?? EventList<Event>(events: {}),
        this.statistics = statistics ?? {};

  CalendarState copyWith(
      {List<Workout>? workouts,
      List<Activity>? activities,
      List<Schedule>? schedules,
      EventList<Event>? markedDateMap,
      Map<DateTime, List<int>>? statistics}) {
    return CalendarState(
        user: this.user,
        dataRepo: this.dataRepo,
        workouts: workouts ?? this.workouts,
        activities: activities ?? this.activities,
        schedules: schedules ?? this.schedules,
        markedDateMap: markedDateMap ?? this.markedDateMap,
        statistics: statistics ?? this.statistics);
  }
}
