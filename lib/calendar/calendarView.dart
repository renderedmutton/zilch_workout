import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/calendar/activityPages/activityCubit.dart';
import 'package:zilch_workout/calendar/activityPages/activityPage.dart';
import 'package:zilch_workout/calendar/calendarBloc.dart';
import 'package:zilch_workout/calendar/calendarEvent.dart';
import 'package:zilch_workout/calendar/calendarState.dart';
import 'package:zilch_workout/calendar/statsPainter.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/Activity.dart';
import 'package:zilch_workout/models/Schedule.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/session/sessionView.dart';
import 'package:zilch_workout/storageRepository.dart';
import 'package:zilch_workout/workouts/workoutPage.dart';

class CalendarView extends StatefulWidget {
  final bool showAd;
  CalendarView({this.showAd = true});
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  DateTime _setDate = DateTime.now();
  int _durIndex = 0;
  int _numDays = 7;
  double _touchX = -1.0;

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void initState() {
    super.initState();
    _getTimeZones();
  }

  @override
  void dispose() {
    if (_anchoredBanner != null) _anchoredBanner?.dispose();
    super.dispose();
  }

  void _getTimeZones() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Widget _getCalendar(
      CalendarState state, double unitHeightValue, double calendarHeight) {
    //calendar
    CalendarCarousel _calendarCarousel = CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        setState(() => _currentDate2 = date);
      },
      firstDayOfWeek: 0,
      headerMargin: EdgeInsets.zero,
      weekDayMargin: EdgeInsets.zero,
      weekDayPadding: EdgeInsets.zero,
      headerTextStyle:
          TextStyle(color: Colors.blue, fontSize: unitHeightValue * 2.5),
      weekendTextStyle:
          TextStyle(color: Colors.red, fontSize: unitHeightValue * 2.0),
      daysTextStyle:
          TextStyle(color: Colors.black, fontSize: unitHeightValue * 2.0),
      weekdayTextStyle: TextStyle(fontSize: unitHeightValue * 2.0),
      nextDaysTextStyle:
          TextStyle(color: Colors.grey, fontSize: unitHeightValue * 2.0),
      prevDaysTextStyle:
          TextStyle(color: Colors.grey, fontSize: unitHeightValue * 2.0),
      thisMonthDayBorderColor: Colors.transparent,
      weekFormat: false,
      height: calendarHeight,
      selectedDateTime: _currentDate2,
      daysHaveCircularBorder: false,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      pageSnapping: true,
      selectedDayTextStyle:
          TextStyle(color: Colors.yellow, fontSize: unitHeightValue * 2.5),
      todayTextStyle:
          TextStyle(color: Colors.blue, fontSize: unitHeightValue * 2.5),
      minSelectedDate: _currentDate.subtract(Duration(days: 1096)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.black,
      markedDatesMap: state.markedDateMap,
      //markedDateIconMaxShown: 2,
      /*markedDateShowIcon: true,
      markedDateIconBuilder: (event) {
        return event.icon;
      },*/
      markedDateMoreShowTotal: null,
    );
    return _calendarCarousel;
  }

  Widget _statsWidget(Map<DateTime, List<int>> data) {
    DateTime date = _dayMonthYear(_currentDate2);
    if (!data.containsKey(date))
      return Center(child: Text('No data available on this date'));
    int ctl = data[date]![0];
    int atl = data[date]![1];
    int tsb = ctl - atl;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(children: [Text('CTL'), Text(ctl.toString())]),
          Column(children: [Text('ATL'), Text(atl.toString())]),
          Column(children: [Text('TSB'), Text(tsb.toString())]),
        ]),
        //graph for past 7 days stats
      ]),
    );
  }

  Widget _scheduleWidgets(BuildContext context, CalendarState state) {
    List<Schedule> daySchedule = [];
    List<Widget> containers = [];
    for (var s in state.schedules) {
      final sDate =
          DateTime.fromMillisecondsSinceEpoch(s.scheduledTimestamp! * 1000);
      if (sDate.day == _currentDate2.day &&
          sDate.month == _currentDate2.month &&
          sDate.year == _currentDate2.year) {
        daySchedule.add(s);
      }
    }
    if (daySchedule.isNotEmpty) {
      for (int i = 0; i < daySchedule.length; i++) {
        bool notifying = DateTime.fromMillisecondsSinceEpoch(
                        daySchedule[i].notificationTimestamp! * 1000)
                    .year ==
                2000
            ? false
            : true;
        containers.add(Row(children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(width: 8),
              Text(daySchedule[i].workoutName!,
                  style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: 16)),
              SizedBox(width: 8.0),
              Text(
                ' ' +
                    DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            daySchedule[i].scheduledTimestamp! * 1000)),
              ),
              SizedBox(width: 8.0),
              if (notifying)
                Icon(Icons.notifications, color: Colors.yellow.shade700)
            ],
          )),
          TextButton(
              onPressed: () {
                final scheduleId = daySchedule[i].id;
                context.read<CalendarBloc>().add(DeleteSchedule(scheduleId));
              },
              child: Icon(Icons.delete_forever, color: Colors.red)),
          OutlinedButton(
              onPressed: () {
                //_startWorkout(context, state, daySchedule[i].workoutName!);
                _checkTrainer(context, state, daySchedule[i].workoutName!);
              },
              child: Text('GO!')),
        ]));
      }
      return Column(
        children: containers,
      );
    }
    return Text('No workouts scheduled on this date.');
  }

  void _checkTrainer(BuildContext ctx, CalendarState state, String name) {
    if (ctx.read<BluetoothAPI>().trainerConnected)
      _startWorkout(state, name);
    else
      showDialog(
        context: ctx,
        builder: (context) => SimpleDialog(
          title: Text('Trainer not connected', textAlign: TextAlign.center),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startWorkout(state, name);
                  },
                  child: Text('Continue')),
            ]),
          ],
        ),
      );
  }

  void _startWorkout(CalendarState state, String name) async {
    bool found = false;
    for (var w in state.workouts) {
      if (name == w.name) {
        found = true;
        double totalWeight = (state.user.weight + state.user.bikeWeight) / 100;
        List<int> zones = [
          (state.user.zone1 * state.user.ftp * 0.01).round(),
          (state.user.zone2 * state.user.ftp * 0.01).round(),
          (state.user.zone3 * state.user.ftp * 0.01).round(),
          (state.user.zone4 * state.user.ftp * 0.01).round(),
          (state.user.zone5 * state.user.ftp * 0.01).round(),
        ];
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkoutPage(
                  bleRepo: context.read<SessionCubit>().bleRepo,
                  user: state.user,
                  workout: w,
                  ftp: state.user.ftp,
                  zones: zones,
                  totalWeight: totalWeight,
                  isMetric: state.user.metric)),
        );
        return;
      }
    }
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Workout no longer exist'),
          duration: Duration(seconds: 3)));
    }
  }

  void _addWorkout(
      BuildContext context, CalendarBloc calendarBloc, CalendarState state) {
    Size mediaSize = MediaQuery.of(context).size;
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (ctx, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 96.0),
                title: Text('Load Workouts'),
                content: state.workouts.isNotEmpty
                    ? Container(
                        width: mediaSize.width - 2 * 21,
                        child: ListView.builder(
                          itemCount: state.workouts.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      child: Text(state.workouts[index].name!)),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showTimePicker(
                                          context,
                                          state.workouts[index].name!,
                                          calendarBloc,
                                          state);
                                    },
                                    child: Text('Add')),
                              ],
                            );
                          },
                        ))
                    : Center(child: Text('No Workouts Found')),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (ctx, animation1, animation2) {
          return widget;
        });
  }

  void _showTimePicker(BuildContext context, String name,
      CalendarBloc calendarBloc, CalendarState state) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 300 + 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showNotification(context, name, calendarBloc);
                          },
                          child: Text('Submit')),
                    ],
                  ),
                  Container(
                    height: 300,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (dateTime) {
                          _setDate = dateTime;
                        }),
                  ),
                ],
              ));
        });
  }

  void _showNotification(
      BuildContext context, String name, CalendarBloc calendarBloc) {
    int index = 0;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BlocProvider.value(
            value: calendarBloc,
            child: BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0))),
                child: Column(children: [
                  SizedBox(height: 10.0),
                  Text('Schedule a notification?',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int i) => index = i,
                        children: [
                          Text('None'),
                          Text('15 mins'),
                          Text('30 mins'),
                          Text('1 hour'),
                          Text('2 hours')
                        ]),
                  ),
                  TextButton(
                      onPressed: () {
                        DateTime notification = DateTime(2000);
                        if (index == 1)
                          notification =
                              _setDate.subtract(Duration(minutes: 15));
                        else if (index == 2)
                          notification =
                              _setDate.subtract(Duration(minutes: 30));
                        else if (index == 3)
                          notification = _setDate.subtract(Duration(hours: 1));
                        else if (index == 4)
                          notification = _setDate.subtract(Duration(hours: 2));

                        if (notification.difference(DateTime.now()) <
                                Duration(seconds: 1) &&
                            index != 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Notification is in the past.'),
                              duration: Duration(seconds: 3)));
                        } else {
                          print(_setDate);
                          context.read<CalendarBloc>().add(
                              CreateNewSchedule(_setDate, notification, name));
                          //set local notification
                          if (index != 0)
                            _setNotification(name, _setDate, notification);
                        }
                        Navigator.of(context).maybePop();
                      },
                      child: Text('DONE')),
                ]),
              );
            }),
          );
        });
  }

  void _setNotification(String name, DateTime setDate, DateTime notify) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Time to cycle! 🚴🏼🚴🏼‍♀️',
        'Workout scheduled: $name \nTime: ' +
            DateFormat('hh:mm a').format(setDate),
        tz.TZDateTime(tz.local, notify.year, notify.month, notify.day,
            notify.hour, notify.minute, notify.second),
        NotificationDetails(
            android: AndroidNotificationDetails(
                '0', 'Zilch Workout', 'Notification')),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  List<Widget> _activityWidget(CalendarState state) {
    List<Activity> dayActivities = [];
    List<Widget> widgets = [];
    for (var a in state.activities) {
      var dt = DateTime.fromMillisecondsSinceEpoch(a.startTime! * 1000);
      if (dt.day == _currentDate2.day &&
          dt.month == _currentDate2.month &&
          dt.year == _currentDate2.year) {
        dayActivities.add(a);
      }
    }
    if (dayActivities.isNotEmpty) {
      for (int i = 0; i < dayActivities.length; i++) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(children: [
                  Text(dayActivities[i].workoutName!,
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 16)),
                  Text('Average power: ${dayActivities[i].averagePower} W'),
                  Text('Duration: ' +
                      AppConstants().getTimeFormat(
                          (dayActivities[i].duration! / 1000).round())),
                ]),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                onPressed: () {
                  _pushActivity(dayActivities[i], state);
                },
              ),
            ],
          ),
        ));
      }
      return widgets;
    }
    return [Text('No activities recorded on this date.')];
  }

  void _pushActivity(Activity activity, CalendarState state) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider(
            create: (context) => ActivityCubit(
                user: state.user,
                activity: activity,
                storageRepo: context.read<StorageRepository>()),
            child: ActivityPage());
      }),
    );
  }

  void _updateXPos(double x) {
    setState(() => _touchX = x);
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    if (!widget.showAd) return;
    AdRequest request = AdRequest(
      keywords: AppConstants.keywords,
      //contentUrl: 'http://foo.com/bar.html',
      //nonPersonalizedAds: true,
    );
    AdSize size = AdSize.banner;
    final BannerAd banner = BannerAd(
        size: size,
        adUnitId: AppConstants.calendarBannerUnitId,
        listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              print('$BannerAd loaded');
              setState(() {
                _anchoredBanner = ad as BannerAd?;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              print('$BannerAd failedtoload:  $error');
              ad.dispose();
            },
            onAdOpened: (Ad ad) => print('$BannerAd onAdOpened'),
            onAdClosed: (Ad ad) => print('$BannerAd onAdClosed')),
        request: request);
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    bool isPotrait = mediaSize.height > mediaSize.width;
    //double sizeMult = 1.5 * MediaQuery.of(context).size.longestSide / 810;
    //sizeMult = mediaSize.height > 512 ? 1 : sizeMult;
    double unitHeightValue = MediaQuery.of(context).size.longestSide * 0.01;
    double sideSafeAreaPadding = MediaQuery.of(context).padding.left +
        MediaQuery.of(context).padding.right;
    double calendarHeight = MediaQuery.of(context).size.shortestSide; //+padding
    calendarHeight =
        calendarHeight + (isPotrait ? (2 * 8.0) : sideSafeAreaPadding);
    double calendarPadding = isPotrait
        ? 8.0
        : ((mediaSize.width - calendarHeight - sideSafeAreaPadding) / 2);

    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    return BlocProvider(
      create: (context) => CalendarBloc(
          user: context.read<SessionCubit>().currentUser,
          dataRepo: context.read<DataRepository>())
        ..add(InitializeCalendar()),
      child:
          BlocBuilder<CalendarBloc, CalendarState>(builder: (context, state) {
        List<int> ctl = [];
        List<int> atl = [];
        if (state.activities.isNotEmpty) {
          Map<DateTime, List<int>> newActivities = state.statistics;
          newActivities.removeWhere((key, value) =>
              key.difference(_dayMonthYear(DateTime.now())) <=
              -Duration(days: _numDays));
          newActivities.removeWhere((key, value) =>
              key.difference(_dayMonthYear(DateTime.now())) >
              Duration(days: 1));
          newActivities.forEach((key, value) {
            ctl.add(value[0]);
            atl.add(value[1]);
          });
        }

        return SafeArea(
          child: CustomScrollView(slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              backgroundColor: Colors.grey[50],
              shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              title: Text('Calendar', style: TextStyle(color: Colors.black)),
              centerTitle: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: EdgeInsets.symmetric(horizontal: calendarPadding),
                  //color: Colors.white,
                  child: _getCalendar(state, unitHeightValue, calendarHeight),
                ),
                Divider(),
                _statsWidget(state.statistics),
                Divider(),
                Center(
                  child: Text('Scheduled Workouts',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 8.0),
                Center(child: _scheduleWidgets(context, state)),
                SizedBox(height: 8.0),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _addWorkout(context,
                          BlocProvider.of<CalendarBloc>(context), state);
                    },
                    child: Text('+ schedule a saved workout',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ),
                if (_anchoredBanner != null) SizedBox(height: 16.0),
                if (_anchoredBanner != null) Divider(),
                if (_anchoredBanner != null)
                  Container(
                    color: Colors.white,
                    width: _anchoredBanner!.size.width.toDouble(),
                    height: _anchoredBanner!.size.height.toDouble(), //60.0
                    child: AdWidget(ad: _anchoredBanner!),
                  ),
                Divider(),
                Center(
                  child: Text('Activities',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Column(children: _activityWidget(state)),
                Divider(),
                GestureDetector(
                  onLongPressStart: (details) =>
                      _updateXPos(details.localPosition.dx),
                  onLongPressMoveUpdate: (details) =>
                      _updateXPos(details.localPosition.dx),
                  onLongPressEnd: (details) => _updateXPos(-1),
                  child: CustomPaint(
                      painter: StatsPainter(ctl, atl, _touchX),
                      child: SizedBox(
                          width: mediaSize.width,
                          height: mediaSize.width * 0.5)),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(children: [
                        Icon(Icons.circle, color: Colors.orange, size: 12.0),
                        Text('CTL')
                      ]),
                      Row(children: [
                        Icon(Icons.circle, color: Colors.blue, size: 12.0),
                        Text('ATL')
                      ]),
                      Row(children: [
                        Icon(Icons.circle, color: Colors.grey, size: 12.0),
                        Text('TSB')
                      ]),
                    ]),
                SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSlidingSegmentedControl(
                      groupValue: _durIndex,
                      children: {
                        0: Text('7 days'),
                        1: Text('30 days'),
                        2: Text('120 days')
                      },
                      onValueChanged: (int? index) {
                        setState(() {
                          _durIndex = index!;
                          if (_durIndex == 0) _numDays = 7;
                          if (_durIndex == 1) _numDays = 30;
                          if (_durIndex == 2) _numDays = 120;
                        });
                      }),
                ),
                /*Center(
                  child: Text('Power Curve',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: mediaSize.width,
                  height: mediaSize.width * 0.75,
                  //child: CustomPaint(painter: ,),
                ),*/
              ]),
            ),
          ]),
        );
      }),
    );
  }

  DateTime _dayMonthYear(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
