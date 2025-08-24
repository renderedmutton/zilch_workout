import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zilch_workout/appConstants.dart';

class ActivityGraphPainter extends CustomPainter {
  ActivityGraphPainter(this.lineColor, this.icon, this.zones, this.data,
      this.isPower, this.touchX);
  final Color lineColor;
  final IconData icon;
  final List<int> zones;
  final List<num> data;
  final bool isPower;
  final double touchX;

  @override
  void paint(Canvas canvas, Size size) {
    double graphX = 4 + 25;
    double graphY = size.height * 0.9;
    double xLength = size.width - graphX - 10;
    double yLength = size.height * 0.8;
    num max = data.fold(0, (p, c) => p > c ? p : c);
    num avg = data.fold(0, (p, c) => p + c);
    avg = (avg / data.length).round();

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
    //axes calculation
    int tens = max.round().toString().length - 1;
    int firstDigit = int.parse(max.round().toString()[0]);
    num maxAxes = pow(10, tens) * firstDigit;
    //add 50 then add 50 again if still <max
    maxAxes = max > maxAxes ? maxAxes + 5 * pow(10, (tens - 1)) : maxAxes;
    maxAxes = max > maxAxes ? maxAxes + 5 * pow(10, (tens - 1)) : maxAxes;
    int numLines = (maxAxes / (0.5 * pow(10, tens))).round();
    numLines = numLines > 10 ? (maxAxes / pow(10, tens)).round() : numLines;
    //graph line guide
    paint.strokeWidth = 1;
    paint.color = Colors.grey.withOpacity(0.5);
    for (int i = 0; i < numLines - 1; i++) {
      axes.moveTo(graphX, graphY - yLength / numLines * (i + 1));
      axes.lineTo(graphX + xLength, graphY - yLength / numLines * (i + 1));
    }
    canvas.drawPath(axes, paint);
    //axes label
    var axesIcon = icon;
    var textStyle = TextStyle(
        color: lineColor, fontSize: 14, fontFamily: axesIcon.fontFamily);
    var textSpan = TextSpan(
        text: String.fromCharCode(axesIcon.codePoint), style: textStyle);
    var textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(graphX - 4, 8.0));
    for (int i = 0; i < numLines; i++) {
      int value = ((maxAxes / numLines) * (i + 1)).round();
      var textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
      );
      var powerSpan = TextSpan(text: value.toString(), style: textStyle);
      var textPainter = TextPainter(
          text: powerSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right);
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas,
          Offset(graphX - 30, graphY - 7 - yLength / numLines * (i + 1)));
    }
    //time labels
    for (int i = 1; i < 6; i++) {
      var textStyle = TextStyle(color: Colors.black, fontSize: 10);
      var timeSpan = TextSpan(
          text: AppConstants().getTimeFormat(data.length), style: textStyle);
      var textPainter =
          TextPainter(text: timeSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: 45);
      textPainter.paint(
          canvas, Offset(graphX - 30 + (i * xLength / 5), graphY + 3));
    }
    //draw line, segment
    paint.style = PaintingStyle.fill;
    var line = Path();
    var linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    double offsetX = 0;
    line.moveTo(graphX, graphY + 1 - (data[0] / maxAxes) * yLength);
    for (int i = 0; i < data.length; i++) {
      num value = data[i];
      //line
      line.lineTo(graphX + offsetX, graphY + 1 - (value / maxAxes) * yLength);
      if (isPower) {
        //power segment
        if (value <= zones[0])
          paint.color = Colors.grey.withOpacity(0.5);
        else if (value > zones[0] && data[i] <= zones[1])
          paint.color = Colors.blue.withOpacity(0.5);
        else if (value > zones[1] && data[i] <= zones[2])
          paint.color = Colors.green.withOpacity(0.5);
        else if (value > zones[2] && data[i] <= zones[3])
          paint.color = Colors.orange.withOpacity(0.5);
        else if (value > zones[3] && data[i] <= zones[4])
          paint.color = Colors.red.withOpacity(0.5);
        else if (value > zones[4]) paint.color = Colors.purple.withOpacity(0.5);
      } else {
        paint.color = lineColor.withOpacity(0.5);
      }
      double x = xLength / (data.length - 1);
      if (max != 0) {
        double y = (value / maxAxes) * yLength;
        canvas.drawRect(
            Offset(graphX + offsetX, graphY - 1) & Size(x, -y), paint);
      }
      offsetX += x;
    }
    canvas.drawPath(line, linePaint);
    double dashWidth = 9, dashSpace = 5, startX = graphX;
    double y = graphY - ((avg / maxAxes) * yLength);
    final dashPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    while (startX < graphX + xLength - dashWidth) {
      canvas.drawLine(
          Offset(startX, y), Offset(startX + dashWidth, y), dashPaint);
      startX += dashWidth + dashSpace;
    }
    //show touchX value
    if (touchX > graphX && touchX < graphX + xLength) {
      int index = ((touchX - graphX) * data.length / xLength).round();
      index = index >= data.length ? data.length : index;
      num value = data[index];
      double height = (value / maxAxes) * yLength;
      height = height.isNaN ? 0 : height;
      line = Path();
      linePaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      line.moveTo(touchX, graphY);
      line.lineTo(touchX, graphY - height);
      canvas.drawPath(line, linePaint);
      var rectPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Offset(touchX - 20.0, graphY - height - 30) & Size(40.0, 20.0),
          rectPaint);
      final ParagraphBuilder paragraphBuilder = ParagraphBuilder(ParagraphStyle(
          fontSize: 14,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center))
        ..addText(value.toString());
      final Paragraph paragraph = paragraphBuilder.build()
        ..layout(ParagraphConstraints(width: 40.0));
      canvas.drawParagraph(
          paragraph, Offset(touchX - 20, graphY - height - 27.5));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
