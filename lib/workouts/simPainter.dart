import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimPainter extends CustomPainter {
  SimPainter(
      this.zones,
      this.powers,
      this.cadences,
      this.hrs,
      this.instantenousP,
      this.displayCadence,
      this.displayHr,
      this.displayLength,
      this.slope);
  final List<int> zones;
  final List<int> powers;
  final List<int> cadences;
  final List<int> hrs;
  final bool instantenousP;
  final bool displayCadence;
  final bool displayHr;
  final int displayLength;
  final double slope;

  @override
  void paint(Canvas canvas, Size size) {
    double graphX = 4 + 25;
    double graphY = size.height * 0.9;
    double xLength = size.width - graphX - 10;
    double yLength = size.height * 0.8;

    int startTime = 0;
    int totalTime = 0; //in seconds
    int displayTime = 0;
    int currentTime = (powers.length / 2).round();
    int segmentTime = 0;
    int maxPower = 0;
    if (powers.length * 0.5 > segmentTime)
      totalTime = (powers.length * 0.5).round();
    else
      totalTime = segmentTime;
    powers.forEach((p) {
      if (p > maxPower) maxPower = p;
    });
    displayTime = totalTime;
    if (displayLength == 1) displayTime = 30 * 60;
    if (displayLength == 2) displayTime = 15 * 60;
    if (displayLength == 3) displayTime = 5 * 60;
    startTime = currentTime > displayTime ? currentTime - displayTime : 0;

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
    canvas.drawPath(axes, paint);
    //draw segments
    double offsetX = graphX + 1;
    paint.style = PaintingStyle.fill;
    for (int i = 2 * startTime; i < powers.length; i++) {
      double x = (0.5 / displayTime) * xLength;
      double y = (powers[i] / maxPower) * yLength;
      if (powers[i] == 0) {
        offsetX += x;
        continue;
      }
      if (powers[i] <= zones[0])
        paint.color = Colors.grey.withOpacity(0.5);
      else if (powers[i] > zones[0] && powers[i] <= zones[1])
        paint.color = Colors.blue.withOpacity(0.5);
      else if (powers[i] > zones[1] && powers[i] <= zones[2])
        paint.color = Colors.green.withOpacity(0.5);
      else if (powers[i] > zones[2] && powers[i] <= zones[3])
        paint.color = Colors.orange.withOpacity(0.5);
      else if (powers[i] > zones[3] && powers[i] <= zones[4])
        paint.color = Colors.red.withOpacity(0.5);
      else if (powers[i] > zones[4])
        paint.color = Colors.purple.withOpacity(0.5);
      canvas.drawRect(Offset(offsetX, graphY - 1) & Size(x, -y), paint);
      offsetX += x;
    }
    //time labels
    for (int i = 1; i < 6; i++) {
      var textStyle = TextStyle(color: Colors.black, fontSize: 10);
      var timeSpan = TextSpan(
          text: getTimeFormat(startTime + (i * displayTime / 5).round()),
          style: textStyle);
      var textPainter =
          TextPainter(text: timeSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: 45);
      textPainter.paint(
          canvas, Offset(graphX - 30 + (i * xLength / 5), graphY + 3));
    }
    //drawlines
    var powerLine = Path();
    var cadenceLine = Path();
    var hrLine = Path();
    var paintP = Paint()
      ..color = Colors.blue.shade900
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var paintC = Paint()
      ..color = Colors.teal
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    var paintH = Paint()
      ..color = Colors.red.shade800
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (powers.length > 0) {
      double offsetXTime = 0;
      for (int i = 0; i < powers.length; i++) {
        if (i < (2 * startTime)) continue;
        if (i == (2 * startTime)) {
          cadenceLine.moveTo(
              graphX, graphY + 1 - (cadences[i] / 150) * yLength / 2);
          hrLine.moveTo(
              graphX,
              graphY +
                  1 -
                  (yLength * 0.5) -
                  ((hrs[i] - 60) / 150) * yLength / 2);
        }
        cadenceLine.lineTo(graphX + offsetXTime,
            graphY + 1 - (cadences[i] / 150) * yLength / 2);
        if (hrs[i] != 0)
          hrLine.lineTo(
              graphX + offsetXTime,
              graphY -
                  (yLength * 0.5) +
                  1 -
                  ((hrs[i] - 60) / 150) * yLength / 2);

        if (instantenousP) {
          i == (2 * startTime)
              ? powerLine.moveTo(
                  graphX, graphY + 1 - (powers[i] / maxPower) * yLength)
              : powerLine.lineTo(graphX + offsetXTime,
                  graphY + 1 - (powers[i] / maxPower) * yLength);
        } else {
          if (i == (2 * startTime))
            powerLine.moveTo(
                graphX, graphY + 1 - (powers[i] / maxPower) * yLength);
          else if (i < 6)
            powerLine.lineTo(graphX + offsetXTime,
                graphY + 1 - (powers[i] / maxPower) * yLength);
          else {
            var avgP = powers[i] +
                powers[i - 1] +
                powers[i - 2] +
                powers[i - 3] +
                powers[i - 4] +
                powers[i - 5];
            avgP = (avgP / 6).round();
            powerLine.lineTo(
                graphX + offsetXTime, graphY - 1 - (avgP / maxPower) * yLength);
          }
        }
        offsetXTime += 0.5 * (xLength / displayTime);
      }
      canvas.drawPath(powerLine, paintP);
      if (displayCadence) canvas.drawPath(cadenceLine, paintC);
      if (displayHr) canvas.drawPath(hrLine, paintH);
    }
    //axes label
    //power
    var powerIcon = Icons.flash_on;
    var textStyle = TextStyle(
        color: Colors.blue.shade900,
        fontSize: 14,
        fontFamily: powerIcon.fontFamily);
    var powerSpan = TextSpan(
        text: String.fromCharCode(powerIcon.codePoint), style: textStyle);
    var textPainter =
        TextPainter(text: powerSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(graphX - 4, 8.0));
    for (int i = 0; i < 3; i++) {
      int p = ((maxPower / 3) * (i + 1)).round();
      var textStyle = TextStyle(
        color: Colors.blue.shade900,
        fontSize: 14,
      );
      var powerSpan = TextSpan(text: p.toString(), style: textStyle);
      var textPainter =
          TextPainter(text: powerSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
          canvas, Offset(graphX - 32, graphY - yLength / 3 * (i + 1)));
    }
    //draw slope
    offsetX = size.width / 2;
    var radius = 20.0;
    var slopeColor = Colors.blueAccent;
    var paintCircle = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(offsetX, radius), radius, paintCircle);
    paintCircle.strokeWidth = 0.5;
    if (slope < -2.9)
      slopeColor = Colors.blueAccent;
    else if (slope < 3.0)
      slopeColor = Colors.greenAccent;
    else if (slope < 5.0)
      slopeColor = Colors.orangeAccent;
    else
      slopeColor = Colors.redAccent;
    paintCircle.color = slopeColor;
    paintCircle.style = PaintingStyle.fill;
    paintCircle.shader = ui.Gradient.linear(Offset(offsetX, radius),
        Offset(offsetX, radius * 2), [slopeColor, slopeColor.withOpacity(0.1)]);
    var slopePath = Path();
    var points = [
      Offset(offsetX - radius, radius + slope * 0.3),
      Offset(offsetX + radius, radius),
      Offset(offsetX, 2 * radius)
    ];
    slopePath.addPolygon(points, true);
    canvas.drawPath(slopePath, paintCircle);
    textStyle = TextStyle(color: Colors.black, fontSize: 10);
    var slopeSpan =
        TextSpan(text: slope.toStringAsFixed(1) + '%', style: textStyle);
    textPainter = TextPainter(
        text: slopeSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout(minWidth: 0, maxWidth: 40);
    textPainter.paint(canvas, Offset(offsetX - radius * 0.75, radius * 0.5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //return true;
    return powers.isEmpty ? true : false;
  }

  String getTimeFormat(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = (seconds / 60).floor() - hours * 60;
    seconds -= minutes * 60 + hours * 3600;
    return hours.toString().padLeft(2, '0') +
        ':' +
        minutes.toString().padLeft(2, '0') +
        ':' +
        seconds.toString().padLeft(2, '0');
  }
}
