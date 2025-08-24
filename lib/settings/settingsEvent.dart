abstract class SettingsEvent {}

class GetUser extends SettingsEvent {}

class NicknameChanged extends SettingsEvent {
  final String nickname;
  NicknameChanged(this.nickname);
}

class AgeChanged extends SettingsEvent {
  final int age;
  AgeChanged(this.age);
}

class SexChanged extends SettingsEvent {
  final int sex;
  SexChanged(this.sex);
}

class MetricChanged extends SettingsEvent {
  final bool metric;
  MetricChanged(this.metric);
}

class WeightChanged extends SettingsEvent {
  final int weight;
  WeightChanged(this.weight);
}

class BikeWeightChanged extends SettingsEvent {
  final int bikeWeight;
  BikeWeightChanged(this.bikeWeight);
}

class WheelCircumferenceChanged extends SettingsEvent {
  final int wheelCircumference;
  WheelCircumferenceChanged(this.wheelCircumference);
}

class FtpChanged extends SettingsEvent {
  final int ftp;
  FtpChanged(this.ftp);
}

class Zone1Changed extends SettingsEvent {
  final int zone1;
  Zone1Changed(this.zone1);
}

class Zone2Changed extends SettingsEvent {
  final int zone2;
  Zone2Changed(this.zone2);
}

class Zone3Changed extends SettingsEvent {
  final int zone3;
  Zone3Changed(this.zone3);
}

class Zone4Changed extends SettingsEvent {
  final int zone4;
  Zone4Changed(this.zone4);
}

class Zone5Changed extends SettingsEvent {
  final int zone5;
  Zone5Changed(this.zone5);
}

class RRHrChanged extends SettingsEvent {
  final int rrHr;
  RRHrChanged(this.rrHr);
}

class LTHrChanged extends SettingsEvent {
  final int ltHr;
  LTHrChanged(this.ltHr);
}

class MaxHrChanged extends SettingsEvent {
  final int maxHr;
  MaxHrChanged(this.maxHr);
}

class SettingsSubmitted extends SettingsEvent {}

class AuthorizeStrava extends SettingsEvent {}

class DeauthorizedStrava extends SettingsEvent {}
