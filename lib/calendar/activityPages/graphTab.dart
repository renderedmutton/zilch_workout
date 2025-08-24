import 'package:flutter/material.dart';
import 'package:zilch_workout/activityPacker.dart';
import 'package:zilch_workout/calendar/activityPages/activityGraphPainter.dart';

class GraphTab extends StatefulWidget {
  final bool isMetric;
  final ActivityPacker data;
  final List<int> zones;
  GraphTab(this.isMetric, this.data, this.zones);

  @override
  _GraphTabState createState() => _GraphTabState();
}

class _GraphTabState extends State<GraphTab> {
  late ActivityPacker _data;
  List<double> _speeds = [];
  TextStyle _largeText = TextStyle(fontSize: 20.0);
  TextStyle _mediumText = TextStyle(fontSize: 18.0);
  TextStyle _smallText = TextStyle(fontSize: 12.0);

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    for (int i = 0; i < _data.speeds.length; i++) {
      if (widget.isMetric)
        _speeds.add(_data.speeds[i] / 1000);
      else
        _speeds.add((_data.speeds[i] / 1000) / 1.6);
    }
  }

  double _touchX = -1.0;

  Widget _graphWidget(Size mediaSize, String title, List<num> data, Color color,
      IconData icon, bool isPower, bool isDouble) {
    num avg = data.fold(0, (p, c) => p + c);
    if (isDouble)
      avg = (avg / data.length);
    else
      avg = (avg / data.length).round();
    num max = data.fold(0, (p, c) => p > c ? p : c);

    if (isPower && max == 0) return Center(child: Text('No power data found'));
    return max == 0
        ? Container()
        : Column(children: [
            Center(child: Text(title, style: _largeText)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Column(children: [
                Text('Average', style: _smallText),
                Text(isDouble ? avg.toStringAsFixed(2) : '$avg',
                    style: _mediumText)
              ]),
              Column(children: [
                Text('Maximum', style: _smallText),
                Text('$max', style: _mediumText)
              ]),
            ]),
            GestureDetector(
                onLongPressStart: (details) =>
                    _updateXPos(details.localPosition.dx),
                onLongPressMoveUpdate: (details) =>
                    _updateXPos(details.localPosition.dx),
                onLongPressEnd: (details) => _updateXPos(-1.0),
                child: CustomPaint(
                    painter: ActivityGraphPainter(
                        color, icon, widget.zones, data, isPower, _touchX),
                    child: SizedBox(
                        width: mediaSize.width,
                        height: mediaSize.width * 0.75))),
            Divider(),
          ]);
  }

  void _updateXPos(double x) {
    setState(() {
      _touchX = x;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;

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
              //graphs
              _graphWidget(mediaSize, 'Power (W)', _data.powers,
                  Colors.blue.shade900, Icons.bolt, true, false),
              _graphWidget(mediaSize, 'Heart Rate (BPM)', _data.hrs,
                  Colors.red.shade800, Icons.favorite, false, false),
              _graphWidget(mediaSize, 'Cadence (RPM)', _data.cadences,
                  Colors.teal, Icons.refresh, false, false),
              _graphWidget(
                  mediaSize,
                  'Speed ' + (widget.isMetric ? '(KPH)' : '(MPH)'),
                  _speeds,
                  Colors.blue,
                  Icons.speed,
                  false,
                  true),
              //horizontal bar chart for times in power zones
              //horizontal bar chart for times in heart zones
            ])),
          )
        ]);
      }),
    );
  }
}
