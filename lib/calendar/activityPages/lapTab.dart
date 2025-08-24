import 'package:flutter/material.dart';
import 'package:zilch_workout/activityPacker.dart';
import 'package:zilch_workout/models/Activity.dart';

class LabTab extends StatelessWidget {
  final Activity activity;
  final ActivityPacker data;
  LabTab(this.activity, this.data);

  Widget cellWidget(String text, double unitWidthValue) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: unitWidthValue)),
      ),
    );
  }

  List<int> _averages(int start, int end) {
    int p = 0;
    int hr = 0;
    int c = 0;
    int dur = end - start;
    for (int i = start; i < end; i++) {
      p += data.powers[i];
      hr += data.hrs[i];
      c += data.cadences[i];
    }
    p = (p / (end - start)).round();
    hr = (hr / (end - start)).round();
    c = (c / (end - start)).round();
    return [p, hr, c, dur];
  }

  Widget _lapWidget(double unitWidthValue) {
    List<TableRow> rows = [];
    rows.add(TableRow(children: [
      cellWidget('Lap', unitWidthValue),
      cellWidget('Average Power', unitWidthValue),
      cellWidget('Average Heart Rate', unitWidthValue),
      cellWidget('Average Cadence', unitWidthValue),
      cellWidget('Duration', unitWidthValue),
    ]));
    for (int i = 0; i < data.laps.length; i++) {
      int start = 0;
      if (i != 0) {
        start = data.times.indexWhere((e) => e == data.laps[i - 1]) + 1;
        if (start == -1) {
          int lastTimeCheck = data.times.first;
          for (int j = 0; j < data.times.length; j++) {
            if (data.laps[i - 1] > lastTimeCheck &&
                data.laps[i - 1] <= data.times[j]) {
              start = j;
              break;
            }
            lastTimeCheck = data.times[j];
          }
        }
      }
      int end = data.times.indexWhere((e) => e == data.laps[i]);
      if (end == -1) {
        int lastTimeCheck = data.times.first;
        for (int j = 0; j < data.times.length; j++) {
          if (data.laps[i] > lastTimeCheck && data.laps[i] <= data.times[j]) {
            end = j;
            break;
          }
          lastTimeCheck = data.times[j];
        }
      }
      if (end == -1 || start == -1) return Text('Error Occured');
      List<int> avg = _averages(start, end);
      rows.add(TableRow(children: [
        cellWidget((i + 1).toString(), unitWidthValue),
        cellWidget(avg[0].toString(), unitWidthValue),
        cellWidget(avg[1].toString(), unitWidthValue),
        cellWidget(avg[2].toString(), unitWidthValue),
        cellWidget(_printDuration(Duration(seconds: avg[3])), unitWidthValue),
      ]));
    }
    List<int> avg = _averages(0, data.powers.length);
    rows.add(TableRow(children: [
      cellWidget('All', unitWidthValue),
      cellWidget(avg[0].toString(), unitWidthValue),
      cellWidget(avg[1].toString(), unitWidthValue),
      cellWidget(avg[2].toString(), unitWidthValue),
      cellWidget(_printDuration(Duration(seconds: (avg[3]))), unitWidthValue),
    ]));

    return Table(
        border:
            TableBorder(horizontalInside: BorderSide(), bottom: BorderSide()),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
        },
        children: rows);
  }

  Widget _segmentWidget(double unitWidthValue) {
    List<TableRow> rows = [];
    rows.add(TableRow(children: [
      cellWidget('Seg', unitWidthValue),
      cellWidget('Average Power', unitWidthValue),
      cellWidget('Average Heart Rate', unitWidthValue),
      cellWidget('Average Cadence', unitWidthValue),
      cellWidget('Duration', unitWidthValue),
    ]));
    int totalSegmentDuration = 0;
    for (int i = 0; i < activity.segmentsDuration!.length; i++) {
      int start = 0;
      if (i != 0) start = totalSegmentDuration;
      int end = start + activity.segmentsDuration![i] - 1;
      if (data.powers.length > start && data.powers.length < end)
        end = data.powers.length;
      totalSegmentDuration += activity.segmentsDuration![i];
      if (end > data.powers.length) continue;
      List<int> avg = _averages(start, end);
      rows.add(TableRow(children: [
        cellWidget((i + 1).toString(), unitWidthValue),
        cellWidget(avg[0].toString(), unitWidthValue),
        cellWidget(avg[1].toString(), unitWidthValue),
        cellWidget(avg[2].toString(), unitWidthValue),
        cellWidget(_printDuration(Duration(seconds: avg[3])), unitWidthValue),
      ]));
    }

    return Table(
        border:
            TableBorder(horizontalInside: BorderSide(), bottom: BorderSide()),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
        },
        children: rows);
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    double unitWidthValue = (mediaSize.width / 390) * 12;
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
                if (activity.segmentsDuration!.isNotEmpty)
                  Text('Segments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold)),
                if (activity.segmentsDuration!.isNotEmpty)
                  _segmentWidget(unitWidthValue),
                if (activity.segmentsDuration!.isNotEmpty)
                  SizedBox(height: 8.0),
                Text('Laps',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.0),
                _lapWidget(unitWidthValue),
              ]),
            ),
          )
        ]);
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
