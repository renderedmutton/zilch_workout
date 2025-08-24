import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zilch_workout/calendar/calendarView.dart';
import 'package:zilch_workout/create/createView.dart';
import 'package:zilch_workout/devices/devicesView.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/ride/rideView.dart';
import 'package:zilch_workout/settings/settingsView.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SessionView extends StatefulWidget {
  final User user;
  SessionView(this.user);
  @override
  _SessionViewState createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  List<Widget> _pages = [];
  int _currentIndex = 0;
  bool _settingsChanged = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      CalendarView(),
      CreateView(),
      RideView(),
      DevicesView(),
      SettingsView(settingsChanged),
    ];
    _checkFirstTime();
    _initializeNotification();
  }

  void _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('firstTime')) {
      prefs.setBool('firstTime', false);
      setState(() => _currentIndex = 4);
    } else {
      if (prefs.getBool('firstTime')! == true) {
        prefs.setBool('firstTime', false);
        setState(() => _currentIndex = 4);
      }
    }
  }

  void _initializeNotification() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void settingsChanged(bool changed) {
    _settingsChanged = changed;
  }

  void _showSettingsDialog(int value) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Settings changed, continue?',
                textAlign: TextAlign.center),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        _settingsChanged = false;
                        setState(() => _currentIndex = value);
                      },
                      child: Text('Do not save',
                          style: TextStyle(color: Colors.red))),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Text('Back')),
                ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    return Scaffold(
      body: _pages.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        //backgroundColor: Colors.blueGrey.shade700,
        selectedItemColor: Colors.blue[700], //Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        currentIndex: _currentIndex,
        onTap: (value) {
          if (_settingsChanged)
            _showSettingsDialog(value);
          else
            setState(() => _currentIndex = value);
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bike), label: 'Ride'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth), label: 'Devices'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}
