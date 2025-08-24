import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:wakelock/wakelock.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/storageRepository.dart';
import 'package:zilch_workout/strava/stravaAPI.dart';
import 'package:zilch_workout/workouts/ergPainter.dart';
import 'package:zilch_workout/workouts/workoutBloc.dart';
import 'package:zilch_workout/workouts/workoutEvent.dart';
import 'package:zilch_workout/workouts/workoutState.dart';

class ErgPage extends StatefulWidget {
  final BluetoothAPI bleRepo;
  final User user;
  final int ftp;
  final List<int> zones;
  final double totalWeight;
  final bool isMetric;
  final bool showAd;
  ErgPage(
      {required this.bleRepo,
      required this.user,
      required this.ftp,
      required this.zones,
      required this.totalWeight,
      required this.isMetric,
      this.showAd = true});

  @override
  _ErgPageState createState() => _ErgPageState();
}

class _ErgPageState extends State<ErgPage> {
  late BluetoothAPI _bleRepo;
  Future _prefs = SharedPreferences.getInstance();

  StreamSubscription? _speedSub;
  StreamSubscription? _powerSub;
  StreamSubscription? _cadenceSub;
  StreamSubscription? _hrSub;
  bool _started = false;
  bool _paused = false;
  int _currentPower = 0;
  int _oldPower = 0;
  List<int> _powers = [];
  List<int> _cadences = [];
  List<int> _hrs = [];
  List<int> _times = [];
  List<double> _speeds = [];
  List<double> _distances = [];
  List<int> _laps = [];
  List<int> _reversedLaps = [];
  int _heartRate = 0;
  int _powerW = 0;
  int _cadence = 0;
  double _speed = 0.0;
  double _distance = 0;
  Stopwatch _stopwatch = Stopwatch();
  int _startTime = DateTime.now().millisecondsSinceEpoch;
  late Timer _timer;
  bool _writing = false;
  bool _lapPressed = false;
  Duration _lastLapStop = Duration();
  bool _minusHold = false;
  bool _plusHold = false;
  late Timer _checkHold;

  bool _instantenousP = false;
  bool _displayCadence = true;
  bool _displayHr = true;
  int _displayLength = 0; //0-fullworkout,1-30minutes,2-15minutes,3-5minutes
  bool _simulatedSpeed = true; //false uses actual spinning speed
  int _countdown = 0;
  bool _isAuthOk = false;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _bleRepo = widget.bleRepo;
    initializeWorkout();
    _readPrefs();
    Wakelock.enable();
    _createInterstitialAd();
    _checkHold = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_minusHold) {
        setState(() {
          _currentPower -= 10;
          _currentPower = _currentPower < 0 ? 0 : _currentPower;
        });
      }
      if (_plusHold) {
        setState(() {
          _currentPower += 10;
          _currentPower = _currentPower > 2000 ? 2000 : _currentPower;
        });
      }
    });
    _currentPower = widget.zones[1];
  }

  @override
  void dispose() {
    if (_speedSub != null) _speedSub?.cancel();
    if (_powerSub != null) _powerSub?.cancel();
    if (_cadenceSub != null) _cadenceSub?.cancel();
    if (_hrSub != null) _hrSub?.cancel();
    if (_started) _timer.cancel();
    _checkHold.cancel();
    if (_interstitialAd != null) _interstitialAd?.dispose();
    super.dispose();
  }

  void _createInterstitialAd() {
    if (!widget.showAd) return;
    AdRequest request = AdRequest(
      keywords: AppConstants.keywords,
      //contentUrl: 'http://foo.com/bar.html',
      //nonPersonalizedAds: true,
    );
    InterstitialAd.load(
        adUnitId: AppConstants.intersitialUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= 3) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void initializeWorkout() {
    _speedSub =
        _bleRepo.speedStream.stream.listen((event) => speedChanged(event));
    _powerSub =
        _bleRepo.powerStream.stream.listen((event) => powerChanged(event));
    _cadenceSub =
        _bleRepo.cadenceStream.stream.listen((event) => cadenceChanged(event));
    _hrSub =
        _bleRepo.heartRateStream.stream.listen((event) => hrChanged(event));
  }

  void _readPrefs() async {
    SharedPreferences prefs = await _prefs;
    setState(() {
      _instantenousP = prefs.getBool('instantenousP') ?? _instantenousP;
      _displayCadence = prefs.getBool('displayCadence') ?? _displayCadence;
      _displayHr = prefs.getBool('displayHr') ?? _displayHr;
      _displayLength = prefs.getInt('displayLength') ?? _displayLength;
      _simulatedSpeed = prefs.getBool('simulatedSpeed') ?? _simulatedSpeed;
      _countdown = prefs.getInt('countdown') ?? _countdown;
      _isAuthOk = prefs.getBool('strava') ?? _isAuthOk;
    });
  }

  void hrChanged(int i) {
    setState(() {
      _heartRate = i;
    });
  }

  void powerChanged(int i) {
    setState(() {
      _powerW = i;
    });
  }

  void cadenceChanged(int i) {
    setState(() {
      _cadence = i;
    });
  }

  void speedChanged(int i) {
    if (!_simulatedSpeed) {
      setState(() {
        _speed = i / 100;
      });
    }
  }

  double _calculateSpeed(double vi) {
    vi = vi / 3.6;
    double fg =
        0.0; //9.8067 * sin(atan(_currentSlope / 100)) * widget.totalWeight;
    double fr = 9.8067 * 1.0 * widget.totalWeight * 0.0032;
    double fd = 0.5 * 0.32 * 1.22601 * vi * vi;
    double pResist = (fg + fr + fd) * vi;
    double pTotal = _powerW - pResist;
    double vf2 = pTotal * 0.5 / (0.5 * widget.totalWeight) +
        vi * vi; //P=0.5*m*(vf^2-vi^2)/dt
    return sqrt(vf2) * 3.6;
  }

  void _startWorkout() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _paused = false;
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_paused) {
        setState(() {
          //FOR TEST/////////////////////////////////////////////////////////////
          //_cadence = Random().nextInt(10) + 65;
          //_heartRate = Random().nextInt(10) + 155;
          //_powerW = Random().nextInt(10) + 130;
          ///////////////////////////////////////////////////////////////////////
          int timeStamp = DateTime.now().millisecondsSinceEpoch;
          _times.add(timeStamp);
          if (_lapPressed) {
            _laps.add(timeStamp);
            _lastLapStop = _stopwatch.elapsed;
            _lapPressed = false;
            _reversedLaps = _laps.reversed.toList();
          }
          _powers.add(_powerW);
          _cadences.add(_cadence);
          _hrs.add(_heartRate);
          if (_simulatedSpeed) {
            _speed = _calculateSpeed(
                _speeds.length == 0 ? 0.0 : _speeds[_speeds.length - 1]);
            _speed = _speed < 0 ? 0.0 : _speed;
            int buffer = (_speed * 100).round();
            _speed = buffer / 100;
          }
          _speeds.add(_speed);
          _distance += (((_speed / 3600) * 0.5 * 1000).round()) / 1000;
          _distances.add(_distance);
          if (_currentPower != _oldPower) _changeTrainerPower();
        });
      }
    });
    _started = true;
  }

  void _pauseWorkout(BuildContext context, WorkoutBloc workoutBloc) {
    if (_started) {
      _paused = true;
      _stopwatch.stop();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(contentPadding: EdgeInsets.all(10.0), children: [
            Column(children: [
              Text('PAUSED', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10.0),
              ElevatedButton(
                  onPressed: () {
                    _resumeWorkout(context);
                    Navigator.of(context).maybePop();
                  },
                  child: Text('RESUME'),
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(Size(140.0, 40.0)))),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _endWorkout(context, workoutBloc);
                  },
                  child: Text('END WORKOUT'),
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(Size(140.0, 40.0)))),
            ])
          ]);
        },
      );
    }
  }

  void _endWorkout(BuildContext context, WorkoutBloc workoutBloc) {
    _paused = true;
    _stopwatch.stop();
    int avgP = 0;
    _powers.forEach((e) => avgP += e);
    avgP = (avgP / _powers.length).round();
    //showgeneraldialog check if want save or discard
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: workoutBloc,
          child:
              BlocBuilder<WorkoutBloc, WorkoutState>(builder: (context, state) {
            return SimpleDialog(
                contentPadding: EdgeInsets.all(10.0),
                children: [
                  Column(children: [
                    Text('END WORKOUT', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 10.0),
                    Text('Avg Power: $avgP W'),
                    Text('Duration: ' +
                        _printDuration(
                            Duration(seconds: _stopwatch.elapsed.inSeconds))),
                    if (state.user.id != AppConstants().guestUUID && _isAuthOk)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Strava'),
                            SizedBox(width: 16.0),
                            Checkbox(
                                activeColor: Colors.orange,
                                value: state.syncStrava,
                                onChanged: (value) => context
                                    .read<WorkoutBloc>()
                                    .add(ChangeSyncStrava(value!))),
                          ]),
                    SizedBox(height: 10.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                _started = false;
                                _stopwatch.stop();
                                _stopwatch.reset();
                                _timer.cancel();
                                Navigator.of(context).pop();
                                _exitWorkoutPage();
                              },
                              child: Text('DISCARD',
                                  style: TextStyle(color: Colors.red)),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(100.0, 40.0)))),
                          ElevatedButton(
                              onPressed: () {
                                _started = false;
                                _stopwatch.stop();
                                _stopwatch.reset();
                                _timer.cancel();
                                Navigator.of(context).pop();
                                _saveWorkout(context, workoutBloc, state);
                              },
                              child: Text('SAVE'),
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(100.0, 40.0)))),
                        ]),
                    OutlinedButton(
                        onPressed: () {
                          _resumeWorkout(context);
                          Navigator.of(context).maybePop();
                        },
                        child: Text('CANCEL'),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(140.0, 40.0)))),
                  ])
                ]);
          }),
        );
      },
    );
  }

  void _saveWorkout(
      BuildContext context, WorkoutBloc workoutBloc, WorkoutState state) {
    //write to file
    List<int> powers = [];
    List<int> cadences = [];
    List<int> hrs = [];
    List<int> times = [];
    List<int> speeds = [];
    List<int> distances = [];
    for (int i = 0; i < _powers.length; i++) {
      if (i % 2 != 0) continue;
      powers.add(_powers[i]);
      cadences.add(_cadences[i]);
      hrs.add(_hrs[i]);
      times.add(_times[i]);
      speeds.add((_speeds[i] * 1000).round());
      distances.add((_distances[i] * 1000).round());
    }
    int totalAscent = 0;
    String dataName = state.user.id + '_ERG_$_startTime';
    int averagePower = 0;
    powers.forEach((e) => averagePower += e);
    averagePower = (averagePower / powers.length).round();
    int duration = times[times.length - 1] - _startTime;
    int tss = AppConstants.getTSS(_startTime, times, powers, widget.ftp);
    context.read<WorkoutBloc>().add(SaveActivity(
        state.workoutName!,
        _startTime,
        averagePower,
        duration,
        tss,
        [],
        dataName,
        powers,
        cadences,
        hrs,
        times,
        speeds,
        distances,
        _laps,
        totalAscent,
        _isAuthOk));
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return BlocProvider.value(
            value: workoutBloc,
            child: BlocConsumer<WorkoutBloc, WorkoutState>(
                listener: (context, state) {
              if (state.formStatus is SubmissionSuccess) {
                Navigator.of(context).maybePop();
                _exitWorkoutPageWithAd();
              } else if (state.formStatus is SubmissionFailure) {
                Navigator.of(context).maybePop();
                //_endWorkout(context, workoutBloc);
                print('failed');
                setState(() {});
              }
            }, builder: (context, state) {
              return SimpleDialog(
                title: Text('Saving', textAlign: TextAlign.center),
                children: [
                  SizedBox(height: 10.0),
                  CupertinoActivityIndicator(),
                ],
              );
            }),
          );
        });
  }

  void _exitWorkoutPage() {
    Navigator.of(context).pop();
  }

  void _exitWorkoutPageWithAd() {
    if (widget.showAd) _showInterstitialAd();
    _exitWorkoutPage();
  }

  void _resumeWorkout(BuildContext context) {
    _paused = false;
    _stopwatch.start();
    _started = true;
  }

  void _changeTrainerPower() async {
    if (_writing) return;
    _writing = true;
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _bleRepo.writePower(_currentPower);
      _oldPower = _currentPower;
      print('change power $_currentPower');
      Future.delayed(Duration(milliseconds: 500))
          .then((value) => _writing = false);
    });
  }

  Widget _lapsWidget(int index) {
    int p = 0;
    int hr = 0;
    int start = 0;
    if (index != _reversedLaps.length - 1)
      start = _times.indexWhere((e) => e == _reversedLaps[index + 1]) + 1;
    int end = _times.indexWhere((e) => e == _reversedLaps[index]);
    if (start == -1 || end == -1) return Container();
    int dur = ((end - start) * 0.5).round();
    for (int i = start; i <= end; i++) {
      p += _powers[i];
      hr += _hrs[i];
    }
    p = (p / (end - start + 1)).round();
    hr = (hr / (end - start + 1)).round();
    return Row(children: [
      Text('Lap ${_reversedLaps.length - index} | '),
      Text('${_printDuration(Duration(seconds: dur))} | '),
      Text('$p W | '),
      Text('$hr BPM'),
    ]);
  }

  String _currentLapTime() {
    if (!_started) return '00:00:00';
    Duration elapsed = _stopwatch.elapsed - _lastLapStop;
    return _printDuration(elapsed);
  }

  void _callUpdate() {
    setState(() {});
  }

  void _showSettings(Size mediaSize, bool scrollControlled) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: scrollControlled,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Wrap(alignment: WrapAlignment.center, children: [
            Container(
              width: mediaSize.width,
              height: kToolbarHeight,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 10),
              child: Container(
                  width: 64.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(6))),
            ),
            Column(children: [
              CupertinoSlidingSegmentedControl(
                  groupValue: _instantenousP,
                  children: {
                    true: Text('Instantenous Power'),
                    false: Text('3 Seconds-Power Smoothing',
                        textAlign: TextAlign.center)
                  },
                  onValueChanged: (bool? value) {
                    setState(() {
                      _instantenousP = value!;
                    });
                  }),
              Row(children: [
                Checkbox(
                    value: _displayCadence,
                    onChanged: (dcd) {
                      setState(() {
                        _displayCadence = dcd!;
                      });
                    }),
                Text('Display Cadence'),
              ]),
              Row(children: [
                Checkbox(
                    value: _displayHr,
                    onChanged: (dhr) {
                      setState(() {
                        _displayHr = dhr!;
                      });
                    }),
                Text('Display Heart Rate'),
              ]),
              Row(children: [
                Checkbox(
                    value: _simulatedSpeed,
                    onChanged: (simS) {
                      setState(() {
                        _simulatedSpeed = simS!;
                      });
                    }),
                Text('Use Simulated Speed'),
                Text(' *unticked uses wheel speed',
                    style: TextStyle(fontSize: 10))
              ]),
              Text('Display Chart Time Length', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4.0),
              CupertinoSlidingSegmentedControl(
                  groupValue: _displayLength,
                  children: {
                    0: Text('Full Workout'),
                    1: Text('30 mins'),
                    2: Text('15 mins'),
                    3: Text('5 mins')
                  },
                  onValueChanged: (int? index) {
                    setState(() {
                      _displayLength = index!;
                    });
                  }),
              Text('Countdown', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4.0),
              CupertinoSlidingSegmentedControl(
                  groupValue: _countdown,
                  children: {
                    0: Text('Sound + Vibrate', textAlign: TextAlign.center),
                    1: Text('Sound'),
                    2: Text('Vibrate'),
                    3: Text('None')
                  },
                  onValueChanged: (int? index) {
                    setState(() {
                      _countdown = index!;
                    });
                  }),
            ]),
            Container(height: kToolbarHeight),
          ]);
        });
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    ).then((value) => _callUpdate());
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double safeAreaPadding = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    double sidePaddings = MediaQuery.of(context).padding.left +
        MediaQuery.of(context).padding.right;

    TextStyle largeText = TextStyle(fontSize: 20.0);
    TextStyle mediumText = TextStyle(fontSize: 18.0);
    TextStyle smallText = TextStyle(fontSize: 14.0);
    ButtonStyle buttonStyle(Color c) {
      return ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(c),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0))));
    }

    BoxDecoration boxStyle() {
      return BoxDecoration(
          color: Colors.grey, borderRadius: BorderRadius.circular(18.0));
    }

    Widget _firstRow() {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          children: [
            Text('distance', style: smallText),
            Text(
                widget.isMetric
                    ? _distance.toStringAsFixed(2) + ' km'
                    : (_distance / 1.6).toStringAsFixed(2) + ' mi',
                style: mediumText),
          ],
        ),
        Column(
          children: [
            Text('elapsed', style: smallText),
            Text(_printDuration(_stopwatch.elapsed), style: mediumText),
          ],
        ),
      ]);
    }

    Widget _secondRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('speed', style: smallText),
              Text(
                  widget.isMetric
                      ? _speed.toStringAsFixed(1) + ' kph'
                      : (_speed / 1.6).toStringAsFixed(1) + ' mph',
                  style: mediumText),
            ],
          ),
          Column(children: [
            Text('lap', style: smallText),
            Text(_currentLapTime(), style: mediumText),
          ]),
        ],
      );
    }

    Widget _controlRow() {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        GestureDetector(
            onTap: () {
              setState(() {
                _currentPower -= 1;
                _currentPower = _currentPower < 0 ? 0 : _currentPower;
              });
            },
            onLongPressStart: (details) => _minusHold = true,
            onLongPressEnd: (details) => _minusHold = false,
            child: Container(
              width: 66.0,
              height: 36.0,
              child: Icon(Icons.remove, color: Colors.white),
              decoration: boxStyle(),
            )),
        Text('$_currentPower W', style: largeText),
        GestureDetector(
            onTap: () {
              setState(() {
                _currentPower += 1;
                _currentPower = _currentPower > 2000 ? 2000 : _currentPower;
              });
            },
            onLongPressStart: (details) => _plusHold = true,
            onLongPressEnd: (details) => _plusHold = false,
            child: Container(
              width: 66.0,
              height: 36.0,
              child: Icon(Icons.add, color: Colors.white),
              decoration: boxStyle(),
            )),
      ]);
    }

    Widget _lapRow() {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _reversedLaps.length,
                  itemBuilder: (ctx, index) {
                    return _lapsWidget(index);
                  }),
            ),
            ElevatedButton(
                onPressed: () {
                  if (!_started) return;
                  _lapPressed = true;
                },
                child: Text('LAP')),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (context) => WorkoutBloc(
          user: widget.user,
          dataRepo: context.read<DataRepository>(),
          storageRepo: context.read<StorageRepository>(),
          stravaAPI: context.read<StravaAPI>())
        ..add(UpdateWorkoutName('ERG_FREE')),
      child: BlocBuilder<WorkoutBloc, WorkoutState>(builder: (context, state) {
        return isPortrait
            ? Scaffold(
                appBar: AppBar(
                    leading:
                        _started ? Icon(Icons.directions_bike) : BackButton(),
                    centerTitle: true,
                    title: Text('ERG MODE'),
                    backgroundColor: Colors.blue.shade600),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text(_powerW.toString(), style: largeText),
                            Text('WATTS', style: largeText)
                          ]),
                          Column(children: [
                            Text(_cadence.toString(), style: largeText),
                            Text('RPM', style: largeText)
                          ]),
                          Column(children: [
                            Text(_heartRate == 0 ? '--' : _heartRate.toString(),
                                style: largeText),
                            Text('BPM', style: largeText)
                          ]),
                        ]),
                    Divider(),
                    CustomPaint(
                      painter: ErgPainter(
                          widget.zones,
                          _powers,
                          _cadences,
                          _hrs,
                          _instantenousP,
                          _displayCadence,
                          _displayHr,
                          _displayLength),
                      child: SizedBox(
                          width: mediaSize.width,
                          height: mediaSize.width * 0.75),
                    ),
                    Divider(),
                    _firstRow(),
                    _secondRow(),
                    Divider(),
                    _controlRow(),
                    SizedBox(height: 8.0),
                    _lapRow(),
                  ]),
                ),
                bottomNavigationBar: Container(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: MediaQuery.of(context).padding.bottom),
                  color: Colors.blue.shade600,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _pauseWorkout(context,
                                  BlocProvider.of<WorkoutBloc>(context));
                            },
                            child: Icon(Icons.pause),
                            style: buttonStyle(Colors.orange)),
                        ElevatedButton(
                            onPressed: () {
                              if (!_started) {
                                _startWorkout();
                              } else {
                                _endWorkout(context,
                                    BlocProvider.of<WorkoutBloc>(context));
                              }
                            },
                            child:
                                Icon(_started ? Icons.stop : Icons.play_arrow),
                            style: buttonStyle(Colors.red)),
                        ElevatedButton(
                            onPressed: () => _showSettings(mediaSize, false),
                            child: Icon(Icons.settings),
                            style: buttonStyle(Colors.grey)),
                      ]),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                    leading:
                        _started ? Icon(Icons.directions_bike) : BackButton(),
                    centerTitle: true,
                    title: Text('ERG MODE'),
                    backgroundColor: Colors.blue.shade600),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [
                              Text(_powerW.toString(), style: largeText),
                              Text('WATTS', style: largeText)
                            ]),
                            Column(children: [
                              Text(_cadence.toString(), style: largeText),
                              Text('RPM', style: largeText)
                            ]),
                            Column(children: [
                              Text(
                                  _heartRate == 0
                                      ? '--'
                                      : _heartRate.toString(),
                                  style: largeText),
                              Text('BPM', style: largeText)
                            ]),
                            ElevatedButton(
                                onPressed: () {
                                  _pauseWorkout(context,
                                      BlocProvider.of<WorkoutBloc>(context));
                                },
                                child: Icon(Icons.pause),
                                style: buttonStyle(Colors.orange)),
                            ElevatedButton(
                                onPressed: () {
                                  if (!_started) {
                                    _startWorkout();
                                  } else {
                                    _endWorkout(context,
                                        BlocProvider.of<WorkoutBloc>(context));
                                  }
                                },
                                child: Icon(
                                    _started ? Icons.stop : Icons.play_arrow),
                                style: buttonStyle(Colors.red)),
                            ElevatedButton(
                                onPressed: () => _showSettings(mediaSize, true),
                                child: Icon(Icons.settings),
                                style: buttonStyle(Colors.grey)),
                          ]),
                      Divider(),
                      Row(children: [
                        CustomPaint(
                          painter: ErgPainter(
                              widget.zones,
                              _powers,
                              _cadences,
                              _hrs,
                              _instantenousP,
                              _displayCadence,
                              _displayHr,
                              _displayLength),
                          child: SizedBox(
                              width: (mediaSize.width / 2) - 16,
                              height: mediaSize.height -
                                  kToolbarHeight -
                                  safeAreaPadding -
                                  16 -
                                  66),
                        ),
                        SizedBox(
                          width: mediaSize.width / 2 - sidePaddings,
                          height: mediaSize.height -
                              kToolbarHeight -
                              safeAreaPadding -
                              16 -
                              66,
                          child: Column(children: [
                            _firstRow(),
                            _secondRow(),
                            Divider(),
                            _controlRow(),
                            SizedBox(height: 8.0),
                            _lapRow(),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ),
              );
      }),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
