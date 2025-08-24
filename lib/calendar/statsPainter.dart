import 'dart:ui';
import 'package:flutter/material.dart';

class StatsPainter extends CustomPainter {
  StatsPainter(this.ctl, this.atl, this.touchX);
  final List<int> ctl;
  final List<int> atl;
  final double touchX;

  @override
  void paint(Canvas canvas, Size size) {
    List<int> tsb = [];
    for (int i = 0; i < ctl.length; i++) {
      tsb.add(ctl[i] - atl[i]);
    }
    int maxC = ctl.fold(0, (p, c) => p > c ? p : c);
    int maxA = atl.fold(0, (p, c) => p > c ? p : c);
    int max = maxC > maxA ? maxC : maxA;
    int maxT = tsb.fold(0, (p, c) => p.abs() > c.abs() ? p.abs() : c.abs());
    int primaryAxis = max > 100 ? 200 : 100;
    int secondaryAxis = maxT > 25 ? 100 : 50;

    double graphX = 30;
    double graphY = size.height * 0.9;
    double xLength = size.width - 60;
    double yLength = size.height * 0.8;
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    //draw axes
    var axes = Path();
    axes.moveTo(graphX, graphY);
    axes.lineTo(graphX + xLength, graphY);
    axes.moveTo(graphX, graphY);
    axes.lineTo(graphX, graphY - yLength);
    axes.moveTo(graphX + xLength, graphY);
    axes.lineTo(graphX + xLength, graphY - yLength);
    canvas.drawPath(axes, paint);
    //axes calculation
    int numLines = 5;
    /*paint.strokeWidth = 0.5;
    paint.color = Colors.black.withOpacity(0.5);
    for (int i = 0; i < numLines - 1; i++) {
      axes.moveTo(graphX, graphY - yLength / numLines * (i + 1));
      axes.lineTo(graphX + xLength, graphY - yLength / numLines * (i + 1));
    }
    canvas.drawPath(axes, paint);*/
    //draw labels
    for (int i = 0; i < numLines; i++) {
      int priValue = ((primaryAxis / numLines) * (i + 1)).round();
      int secValue =
          (((secondaryAxis / numLines) * (i + 1)) - secondaryAxis * 0.5)
              .round();
      var textStyle = TextStyle(
        color: Colors.black,
        fontSize: 12,
      );
      var priTextSpan = TextSpan(text: priValue.toString(), style: textStyle);
      var priTextPainter = TextPainter(
          text: priTextSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right);
      priTextPainter.layout(minWidth: 0, maxWidth: 30);
      priTextPainter.paint(canvas,
          Offset(graphX - 25, graphY - 7 - yLength / numLines * (i + 1)));
      var secTextSpan = TextSpan(text: secValue.toString(), style: textStyle);
      var secTextPainter = TextPainter(
          text: secTextSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left);
      secTextPainter.layout(minWidth: 0, maxWidth: 25);
      secTextPainter.paint(
          canvas,
          Offset(
              graphX + xLength + 5, graphY - 7 - yLength / numLines * (i + 1)));
    }
    //draw lines
    for (int j = 0; j < 3; j++) {
      double offsetX = 0;
      Color lineColor = Colors.orange;
      List<int> data = ctl.toList();
      if (j == 1) {
        data = atl.toList();
        lineColor = Colors.blue;
      }
      if (j == 2) {
        data = tsb.toList();
        lineColor = Colors.grey;
      }
      var line = Path();
      var linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < data.length; i++) {
        num value = data[i];
        if (j != 2)
          value = value / primaryAxis;
        else if (j == 2) {
          value = (value + 0.5 * secondaryAxis) / secondaryAxis;
        }
        //line
        if (i == 0)
          line.moveTo(graphX, graphY + 1 - value * yLength);
        else
          line.lineTo(graphX + offsetX, graphY + 1 - value * yLength);
        offsetX += xLength / (data.length - 1);
      }
      canvas.drawPath(line, linePaint);
    }
    //show touchX value
    if (touchX > graphX && touchX < graphX + xLength) {
      int index = ((touchX - graphX) * ctl.length / xLength).round();
      index = index >= ctl.length - 1 ? ctl.length - 1 : index;
      List<int> values = [ctl[index], atl[index], tsb[index]];
      double height = yLength + size.height * 0.1;
      double x = graphX + (index / (ctl.length - 1)) * xLength;
      var linePaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      double dashWidth = 6, dashSpace = 3, startY = graphY;
      while (startY > (graphY - height + 40 + dashWidth)) {
        canvas.drawLine(
            Offset(x, startY), Offset(x, startY - dashWidth), linePaint);
        startY -= (dashWidth + dashSpace);
      }
      var rectPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Offset(x - 30.0, graphY - height) & Size(60.0, 40.0), rectPaint);
      final ParagraphBuilder paragraphBuilder = ParagraphBuilder(ParagraphStyle(
          fontSize: 10,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center))
        ..addText('CTL: ${values[0]}')
        ..addText('\nATL: ${values[1]}')
        ..addText('\nTSB: ${values[2]}');
      final Paragraph paragraph = paragraphBuilder.build()
        ..layout(ParagraphConstraints(width: 60.0));
      canvas.drawParagraph(paragraph, Offset(x - 30, graphY - height + 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
