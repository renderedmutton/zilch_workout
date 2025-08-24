import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zilch_workout/activityPacker.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/models/Activity.dart';
import 'package:zilch_workout/tcx/tcxWriter.dart';
import 'package:share_plus/share_plus.dart';

class SummaryTab extends StatefulWidget {
  final bool isMetric;
  final ActivityPacker data;
  final Activity activity;
  SummaryTab(this.isMetric, this.data, this.activity);

  @override
  _SummaryTabState createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  late bool _isMetric;
  late ActivityPacker _data;
  late Activity _activity;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.isMetric;
    _data = widget.data;
    _activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle largeStyle = TextStyle(fontSize: 18.0);
    int dur = ((_data.times[_data.times.length - 1] - _data.startTime) / 1000)
        .round();
    num workDone = _data.powers.fold(0, (p, c) => p + c);
    workDone = (workDone * dur / _data.powers.length).roundToDouble();
    workDone = (workDone * 3.6 / 3600).round();
    int avgP =
        (_data.powers.reduce((p, c) => p + c) / _data.powers.length).round();
    int normalizedPower = avgP;
    if (_data.powers.length > 30) {
      List<double> pSmooth = [];
      for (int i = 29; i < _data.powers.length; i++) {
        List<int> buf = _data.powers.sublist(i - 29, i).toList();
        double avg = buf.reduce((p, c) => p + c) / buf.length;
        pSmooth.add(avg * avg * avg * avg);
      }
      double averagePSmooth_4 =
          pSmooth.reduce((p, c) => p + c) / pSmooth.length;
      normalizedPower = pow(averagePSmooth_4, 0.25).round();
    }
    double variability = avgP == 0 ? 0 : normalizedPower / avgP;

    num averageActivity(List<num> dat) {
      num avg = dat.fold(0, (p, c) => p + c);
      avg = avg / dat.length;
      return avg;
    }

    num maxActivity(List<num> dat) {
      return dat.fold(0, (p, c) => p > c ? p : c);
    }

    double avgSpeed = averageActivity(_data.speeds) / 1000;
    double maxSpeed = maxActivity(_data.speeds) / 1000;
    double totalDistance = _data.distances.last / 1000;
    if (!_isMetric) {
      avgSpeed /= 1.6;
      maxSpeed /= 1.6;
      totalDistance /= 1.6;
    }

    Widget _tableWidget() {
      return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2)
        },
        children: [
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.watch_later_outlined),
            ),
            Column(children: [
              Text('Total Time'),
              Text(AppConstants().getTimeFormat(dur), style: largeStyle),
            ]),
            Column(children: [
              Text('Laps'),
              Text(_data.laps.length.toString(), style: largeStyle)
            ])
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.bolt),
            ),
            Column(children: [
              Text('Average Power (W)', textAlign: TextAlign.center),
              Text(averageActivity(_data.powers).round().toString(),
                  style: largeStyle)
            ]),
            Column(children: [
              Text('Maximum Power (W)', textAlign: TextAlign.center),
              Text(maxActivity(_data.powers).round().toString(),
                  style: largeStyle)
            ]),
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.favorite),
            ),
            Column(children: [
              Text('Average Heart Rate (BPM)', textAlign: TextAlign.center),
              Text(averageActivity(_data.hrs).round().toString(),
                  style: largeStyle)
            ]),
            Column(children: [
              Text('Maximum Heart Rate (BPM)', textAlign: TextAlign.center),
              Text(maxActivity(_data.hrs).round().toString(), style: largeStyle)
            ]),
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
            Column(children: [
              Text('Average Cadence (RPM)', textAlign: TextAlign.center),
              Text(averageActivity(_data.cadences).round().toString(),
                  style: largeStyle)
            ]),
            Column(children: [
              Text('Maximum Cadence (RPM)', textAlign: TextAlign.center),
              Text(maxActivity(_data.cadences).round().toString(),
                  style: largeStyle)
            ]),
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.speed),
            ),
            Column(children: [
              Text('Average Speed ' + (_isMetric ? '(kph)' : '(mph)'),
                  textAlign: TextAlign.center),
              Text(avgSpeed.toStringAsFixed(2), style: largeStyle)
            ]),
            Column(children: [
              Text('Maximum Speed ' + (_isMetric ? '(kph)' : '(mph)'),
                  textAlign: TextAlign.center),
              Text(maxSpeed.toStringAsFixed(2), style: largeStyle)
            ]),
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.directions_bike),
            ),
            Column(children: [
              Text('Total Distance ' + (_isMetric ? '(km)' : '(mi)'),
                  textAlign: TextAlign.center),
              Text(totalDistance.toStringAsFixed(2), style: largeStyle)
            ]),
            Column(children: []),
          ]),
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.terrain),
            ),
            Column(children: [
              Text('Total Ascent (m)', textAlign: TextAlign.center),
              Text(_data.totalAscent.toString(), style: largeStyle)
            ]),
            Column(children: []),
          ]),
        ],
      );
    }

    void _exportDialog(BuildContext context) async {
      late BuildContext dc;
      showDialog(
        //barrierDismissible: false,
        context: context,
        builder: (ctx) {
          dc = ctx;
          print('dialog');
          return SimpleDialog(
              title: Text('Exporting', textAlign: TextAlign.center),
              children: [CupertinoActivityIndicator()]);
        },
      );
      await Future.delayed(Duration(milliseconds: 500));
      print('export');
      String filename =
          'strava_garmin_${_activity.workoutName!}_${_activity.startTime}.tcx';
      File file = await TcxWriter().writeTCX(
          filename: filename,
          dateActivity:
              DateTime.fromMillisecondsSinceEpoch(_activity.startTime! * 1000),
          duration: (_activity.duration! / 1000).round(),
          totalDistance: (totalDistance * 1000).round(),
          calories: workDone.round(),
          times: _data.times,
          distances: _data.distances,
          speeds: _data.speeds,
          powers: _data.powers,
          hrs: _data.hrs,
          cadences: _data.cadences);
      Navigator.of(dc).maybePop();
      Share.shareFiles([file.path]);
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(builder: (context) {
        return CustomScrollView(slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              _tableWidget(),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calories*', style: largeStyle),
                      Text('~$workDone KCal', style: largeStyle)
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Effective Power', style: largeStyle),
                      Text('$normalizedPower W', style: largeStyle)
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Variability', style: largeStyle),
                      Text(variability.toStringAsFixed(2), style: largeStyle)
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Training Load', style: largeStyle),
                      Text(_activity.tss.toString(), style: largeStyle)
                    ]),
              ),
              Divider(),
              TextButton(
                  onPressed: () {
                    _exportDialog(context);
                  },
                  child: Text('Export TCX')),
              Divider(),
              Text('*Calories is estimated', style: TextStyle(fontSize: 10.0)),
              Text(
                  'Effective power, variability and training load adapted from Hunter Allen and Andrew Coggan, Ph.D.\'s book:',
                  style: TextStyle(fontSize: 10.0)),
              Text('Training and Racing with a Power Meter',
                  style:
                      TextStyle(fontStyle: FontStyle.italic, fontSize: 10.0)),
            ])),
          )
        ]);
      }),
    );
  }
}
