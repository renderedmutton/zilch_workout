import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';

class CustomAppBar extends StatefulWidget {
  final BluetoothAPI bleRepo;
  final String title;
  CustomAppBar(this.bleRepo, this.title);
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  StreamSubscription? _powerSub;
  StreamSubscription? _cadenceSub;
  StreamSubscription? _hrSub;
  int _power = -1;
  int _cadence = -1;
  int _hr = -1;
  DateTime _lastHr = DateTime.now();
  DateTime _lastPower = DateTime.now();
  DateTime _lastCadence = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _subscribePower();
    _subscribeCadence();
    _subscribeHr();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().difference(_lastHr) > Duration(seconds: 5))
        setState(() => _hr = -1);
      if (DateTime.now().difference(_lastPower) > Duration(seconds: 5))
        setState(() => _power = -1);
      if (DateTime.now().difference(_lastCadence) > Duration(seconds: 5))
        setState(() => _cadence = -1);
    });
  }

  @override
  void dispose() {
    if (_powerSub != null) _powerSub?.cancel();
    if (_cadenceSub != null) _cadenceSub?.cancel();
    if (_hrSub != null) _hrSub?.cancel();
    if (_timer != null) _timer?.cancel();
    super.dispose();
  }

  void _subscribePower() {
    _powerSub = widget.bleRepo.powerStream.stream.listen((event) {
      setState(() {
        _power = event;
        _lastPower = DateTime.now();
      });
    });
  }

  void _subscribeCadence() {
    _cadenceSub = widget.bleRepo.cadenceStream.stream.listen((event) {
      setState(() {
        _cadence = event;
        _lastCadence = DateTime.now();
      });
    });
  }

  void _subscribeHr() {
    _hrSub = widget.bleRepo.heartRateStream.stream.listen((event) {
      setState(() {
        _hr = event;
        _lastHr = DateTime.now();
      });
    });
  }

  Widget _deviceConnections(int power, int cadence, int hr) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Icon(Icons.wifi_tethering,
          color: widget.bleRepo.trainerConnected ? Colors.green : Colors.red,
          size: 20.0),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(Icons.bolt,
            color: power >= 0 ? Colors.green : Colors.red, size: 20.0),
        SizedBox(width: 4.0),
        Text(power >= 0 ? power.toString() + ' W' : '--' + ' W',
            style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(CupertinoIcons.arrow_clockwise_circle_fill,
            color: cadence >= 0 ? Colors.green : Colors.red, size: 20.0),
        SizedBox(width: 4.0),
        Text(cadence >= 0 ? cadence.toString() + ' RPM' : '--' + ' RPM',
            style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(Icons.favorite,
            color: hr >= 0 ? Colors.green : Colors.red, size: 20.0),
        SizedBox(width: 4.0),
        Text(hr >= 0 ? hr.toString() : '--',
            style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
    ]);
  }

  /*Widget _test() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Icon(Icons.wifi_tethering, color: Colors.green, size: 20.0),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(Icons.bolt, color: Colors.green, size: 20.0),
        SizedBox(width: 4.0),
        Text('200 W', style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(CupertinoIcons.arrow_clockwise_circle_fill,
            color: Colors.green, size: 20.0),
        SizedBox(width: 4.0),
        Text('90 RPM', style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
      //SizedBox(width: 4.0),
      Row(children: [
        Icon(Icons.favorite, color: Colors.green, size: 20.0),
        SizedBox(width: 4.0),
        Text('136', style: TextStyle(color: Colors.black, fontSize: 15.0)),
      ]),
    ]);
  }*/

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 2 * kToolbarHeight,
      backgroundColor: Colors.grey[50],
      flexibleSpace: FlexibleSpaceBar(
        title: _deviceConnections(_power, _cadence, _hr), //_test()
        background: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
