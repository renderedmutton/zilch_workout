import 'package:flutter/material.dart';

class SegmentData {
  late Key key;
  late int type; //1 = erg, 2=slope
  late int power;
  late double slope; //int slope/10
  late int duration; //in seconds

  SegmentData(Key key, int type, int power, double slope, int duration) {
    this.key = key;
    this.type = type;
    this.power = power;
    this.slope = slope;
    this.duration = duration;
  }
}
