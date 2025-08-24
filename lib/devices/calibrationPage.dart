import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';

class CalibrationPage extends StatefulWidget {
  final BluetoothAPI bleRepo;
  CalibrationPage(this.bleRepo);

  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  bool started = false;
  double speed = 0.0;
  bool hitSpeed = false;
  StreamSubscription? speedSub;
  bool calibrationFinish = false;

  @override
  void initState() {
    super.initState();
    speedSub = widget.bleRepo.speedStream.stream.listen((value) {
      setState(() {
        speed = value / 100;
        if (speed >= widget.bleRepo.fecTargetSpeed) hitSpeed = true;
      });
    });
  }

  @override
  void dispose() {
    if (speedSub != null) speedSub?.cancel();
    super.dispose();
  }

  void calibrationChecker() async {
    await Future.delayed(Duration(seconds: 2));
    int counter = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (counter >= 30) calibrationFinish = true;
      if (!widget.bleRepo.fecCalibrationStarted) calibrationFinish = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Text stopText = Text('STOP PEDALLING',
        style: TextStyle(fontSize: 16.0, color: Colors.red));

    return Scaffold(
        appBar: AppBar(
          title: Text('Calibration'),
          centerTitle: true,
          backgroundColor: Colors.blueGrey.shade700,
        ),
        body: Center(
          child: Column(children: [
            SizedBox(height: 8.0),
            Text('Calibration Started', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 8.0),
            hitSpeed ? stopText : Text('Start Pedaling'),
            SizedBox(height: 8.0),
            Text('Current speed: ' + speed.toStringAsFixed(2) + ' km/h'),
            if (started)
              Text('Target speed: ' +
                  widget.bleRepo.fecTargetSpeed.toStringAsFixed(2) +
                  ' km/h'),
            SizedBox(height: 20.0),
            if (!started)
              OutlinedButton(
                  onPressed: () {
                    started = true;
                    widget.bleRepo.writeSpindown();
                    calibrationChecker();
                    setState(() {});
                  },
                  child: Text('START')),
            if (calibrationFinish && widget.bleRepo.fecCalibrationStarted)
              Text('Timeout, exit and calibrate again'),
            if (calibrationFinish && !widget.bleRepo.fecCalibrationStarted)
              Text('Calibration Completed'),
            if (calibrationFinish) SizedBox(height: 8.0),
            if (calibrationFinish)
              OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('EXIT')),
          ]),
        ));
  }
}
