import 'package:flutter/material.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/create/segmentData.dart';

class GraphPainter extends CustomPainter {
  final List<SegmentData> segments;
  final List<Key> selectedSegments;
  final List<int> zones;
  final Offset? touchXY;
  final ValueChanged<Key?> segmentSelected;
  GraphPainter(this.segments, this.selectedSegments, this.zones, this.touchXY,
      this.segmentSelected);

  @override
  void paint(Canvas canvas, Size size) {
    double graphX = size.width * 0.1;
    double graphY = size.height * 0.9;
    double xLength = size.width * 0.8;
    double yLength = size.height * 0.8;
    double arrowOffset = 3.0;

    int totalTime = 0; //in seconds
    int maxPower = 0;
    for (int i = 0; i < segments.length; i++) {
      totalTime += segments[i].duration;
      maxPower = segments[i].power > maxPower ? segments[i].power : maxPower;
    }

    bool didSelected = false;
    int didSelectedIndex = -1;

    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //draw axes
    var axes = Path();
    axes.moveTo(graphX, graphY);
    axes.lineTo(graphX + xLength, graphY);
    axes.moveTo(graphX, graphY);
    axes.lineTo(graphX, graphY - yLength);
    //arrows
    /*axes.lineTo(graphX + arrowOffset, graphY - yLength + arrowOffset);
    axes.moveTo(graphX, graphY - yLength);
    axes.lineTo(graphX - arrowOffset, graphY - yLength + arrowOffset);
    axes.moveTo(graphX + xLength, graphY);
    axes.lineTo(graphX + xLength - arrowOffset, graphY - arrowOffset);
    axes.moveTo(graphX + xLength, graphY);
    axes.lineTo(graphX + xLength - arrowOffset, graphY + arrowOffset);*/
    canvas.drawPath(axes, paint);
    //draw segments
    double offsetX = graphX + 1;
    int currentTime = 0;
    for (int i = 0; i < segments.length; i++) {
      paint.style = PaintingStyle.fill;
      double x =
          (segments[i].duration / totalTime) * (xLength - 2 * arrowOffset);
      double y = (segments[i].power / maxPower) * (yLength - 2 * arrowOffset);
      if (segments[i].power <= zones[0])
        paint.color = Colors.grey;
      else if (segments[i].power > zones[0] && segments[i].power <= zones[1])
        paint.color = Colors.blue;
      else if (segments[i].power > zones[1] && segments[i].power <= zones[2])
        paint.color = Colors.green;
      else if (segments[i].power > zones[2] && segments[i].power <= zones[3])
        paint.color = Colors.orange;
      else if (segments[i].power > zones[3] && segments[i].power <= zones[4])
        paint.color = Colors.red;
      else
        paint.color = Colors.purple;
      Rect rect =
          Rect.fromLTRB(offsetX, graphY - 1 - y, offsetX + x, graphY - 1);
      canvas.drawRect(rect, paint);
      //check if touchXY selected
      if (touchXY != null && !didSelected) {
        didSelected = rect.contains(touchXY!);
        if (didSelected) didSelectedIndex = i;
        //print('$touchXY $offsetX ${offsetX + x} $graphY ${graphY - y}');
        //print('$didSelected $didSelectedIndex');
      }
      //draw selected segments
      if (selectedSegments.contains(segments[i].key)) {
        paint.style = PaintingStyle.stroke;
        paint.color = Colors.white;
        canvas.drawRect(Offset(offsetX, graphY - 1) & Size(x, -y), paint);
      }
      offsetX += x;
      //time labels
      if (segments.length < 7) {
        currentTime += segments[i].duration;
        if (x > 45 || i == 0) {
          var textStyle = TextStyle(color: Colors.black, fontSize: 10);
          var timeSpan = TextSpan(
              text: AppConstants().getTimeFormat(currentTime),
              style: textStyle);
          var textPainter =
              TextPainter(text: timeSpan, textDirection: TextDirection.ltr);
          textPainter.layout(minWidth: 0, maxWidth: 45);
          textPainter.paint(canvas, Offset(offsetX - 20, graphY + 3));
        }
      }
    }
    //time labels
    if (segments.length > 6) {
      double offsetX = graphX + 1 + xLength / 12;
      for (int i = 0; i < 6; i++) {
        currentTime = ((i + 1) * totalTime / 6).round();
        var textStyle = TextStyle(color: Colors.black, fontSize: 10);
        var timeSpan = TextSpan(
            text: AppConstants().getTimeFormat(currentTime), style: textStyle);
        var textPainter =
            TextPainter(text: timeSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 0, maxWidth: 45);
        textPainter.paint(canvas, Offset(offsetX, graphY + 3));
        offsetX += xLength / 6;
      }
    }
    //axes label
    var textStyle = TextStyle(color: Colors.black, fontSize: 12);
    var powerSpan = TextSpan(text: 'Power/W', style: textStyle);
    var textPainter =
        TextPainter(text: powerSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(8.0, 8.0));

    for (int i = 0; i < 3; i++) {
      int p = ((maxPower / 3) * (i + 1)).round();
      var textStyle = TextStyle(color: Colors.black, fontSize: 12);
      var powerSpan = TextSpan(text: p.toString(), style: textStyle);
      var textPainter =
          TextPainter(text: powerSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
          canvas, Offset(graphX - 30, graphY - yLength / 3 * (i + 1)));
    }

    //send selectedWidget
    if (touchXY != null && didSelected) {
      segmentSelected(segments[didSelectedIndex].key);
    } else if (touchXY != null && !didSelected) {
      segmentSelected(null);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
