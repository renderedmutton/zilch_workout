import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:zilch_workout/calendar/calendarEvent.dart';
import 'package:zilch_workout/calendar/calendarState.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/Activity.dart';
import 'package:zilch_workout/models/Schedule.dart';
import 'package:zilch_workout/models/User.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final User user;
  final DataRepository dataRepo;
  CalendarBloc({required this.user, required this.dataRepo})
      : super(CalendarState(user: user, dataRepo: dataRepo));

  @override
  Stream<CalendarState> mapEventToState(CalendarEvent event) async* {
    if (event is InitializeCalendar) {
      try {
        //read dataRepo for activities, schedules
        final results = await Future.wait([
          dataRepo.getActivitiesJSON(user.id),
          dataRepo.getSchedules(user.id),
        ]);
        List<Activity> activities = results[0] as List<Activity>;
        List<Schedule> schedules = results[1] as List<Schedule>;
        //update markedmap
        EventList<Event> markedDateMap = state.markedDateMap;
        activities.forEach((activity) {
          DateTime dt =
              DateTime.fromMillisecondsSinceEpoch(activity.startTime! * 1000);
          markedDateMap.add(
              DateTime(dt.year, dt.month, dt.day),
              Event(
                date: dt,
                title: activity.workoutName,
                dot: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.all(Radius.circular(2.0))),
                    margin: EdgeInsets.all(1.0),
                    width: 4.0,
                    height: 4.0),
              ));
        });
        schedules.forEach((schedule) {
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(
              schedule.scheduledTimestamp! * 1000);
          markedDateMap.add(
              DateTime(dt.year, dt.month, dt.day),
              Event(
                date: dt,
                title: schedule.workoutName,
                dot: Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(2.0))),
                    margin: EdgeInsets.all(1.0),
                    width: 4.0,
                    height: 4.0),
              ));
        });
        //print('activities ${activities.length} schedules ${schedules.length}');
        yield state.copyWith(
            activities: activities,
            schedules: schedules,
            markedDateMap: markedDateMap);
        //get all statistics
        if (activities.isNotEmpty) {
          final statistics = _getStats(activities);
          yield state.copyWith(statistics: statistics);
        }
      } catch (e) {
        print(e);
      }

      //read dataRepo for workouts
      try {
        final workouts = await dataRepo.getWorkouts(user.id);
        yield state.copyWith(workouts: workouts);
      } catch (e) {
        print(e);
      }

      //create schedule
    } else if (event is CreateNewSchedule) {
      print('create new schedule');
      int scheduledTimestamp =
          (event.scheduledDateTime.millisecondsSinceEpoch / 1000).round();
      int notificationTimestamp =
          (event.notifyDateTime.millisecondsSinceEpoch / 1000).round();
      //createSchedule
      await dataRepo.createSchedule(
          userId: user.id,
          scheduledTimestamp: scheduledTimestamp,
          notificationTimestamp: notificationTimestamp,
          workoutName: event.workoutName);
      //update schedules
      final schedules = await dataRepo.getSchedules(user.id);
      //update markedmap
      EventList<Event> markedDateMap = state.markedDateMap;
      markedDateMap.add(
          DateTime(event.scheduledDateTime.year, event.scheduledDateTime.month,
              event.scheduledDateTime.day),
          Event(
            date: event.scheduledDateTime,
            title: event.workoutName,
            dot: Container(
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(2.0))),
                margin: EdgeInsets.all(1.0),
                width: 4.0,
                height: 4.0),
          ));
      yield state.copyWith(schedules: schedules, markedDateMap: markedDateMap);

      //delete schedule
    } else if (event is DeleteSchedule) {
      //deleteSchedule
      await dataRepo.deleteSchedule(scheduleId: event.scheduleId);
      //update schedules
      final schedules = await dataRepo.getSchedules(user.id);
      //update markedmap
      EventList<Event> markedDateMap = EventList<Event>(events: {});
      schedules.forEach((schedule) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(
            schedule.scheduledTimestamp! * 1000);
        markedDateMap.add(
            DateTime(dt.year, dt.month, dt.day),
            Event(
              date: dt,
              title: schedule.workoutName,
              dot: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(2.0))),
                  margin: EdgeInsets.all(1.0),
                  width: 4.0,
                  height: 4.0),
            ));
      });
      yield state.copyWith(schedules: schedules, markedDateMap: markedDateMap);
    }
  }

  Map<DateTime, List<int>> _getStats(List<Activity> activities) {
    int baseCTL = 70;
    int baseATL = 70;
    Map<DateTime, List<int>> stats = {};
    activities.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    DateTime firstDate = _dayMonthYear(
        DateTime.fromMillisecondsSinceEpoch(activities[0].startTime! * 1000));
    //DateTime today = DateTime.now();
    //int days = today.difference(firstDate).inDays;
    int days = 30;
    for (int i = 0; i <= days; i++) {
      DateTime date = firstDate.add(Duration(days: i));
      int tss = 0;
      activities.forEach((e) {
        DateTime activityDate =
            DateTime.fromMillisecondsSinceEpoch(e.startTime! * 1000);
        if (activityDate.day == date.day &&
            activityDate.month == date.month &&
            activityDate.year == date.year) tss += e.tss!;
      });
      //CTL = TSS x (1-e^(-1/42)) + Yesterdays CTL x e^(-1/42), BASE: 70
      //ATL = TSS x (1-e^(-1/7)) + Yesterdays ATL x e^(-1/7), BASE: 70
      //CTL = CTLy+(TSS-CTLy)/42, ATL = ATLy+(TSS-ATLy)/7
      if (stats.length == 0) {
        int c = (tss * (1 - exp(-1 / 42)) + baseCTL * exp(-1 / 42)).round();
        int a = (tss * (1 - exp(-1 / 7)) + baseATL * exp(-1 / 7)).round();
        //int c = (baseCTL + (tss - baseCTL) / 42).round();
        //int a = (baseATL + (tss - baseATL) / 7).round();
        stats[_dayMonthYear(date)] = [c, a];
      } else {
        int previousC = stats[date.subtract(Duration(days: 1))]![0];
        int previousA = stats[date.subtract(Duration(days: 1))]![1];
        int c = (tss * (1 - exp(-1 / 42)) + previousC * exp(-1 / 42)).round();
        int a = (tss * (1 - exp(-1 / 7)) + previousA * exp(-1 / 7)).round();
        //int c = (previousC + (tss - previousC) / 42).round();
        //int a = (previousA + (tss - previousA) / 7).round();
        stats[_dayMonthYear(date)] = [c, a];
      }
    }
    return stats;
  }

  DateTime _dayMonthYear(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
