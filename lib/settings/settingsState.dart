import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/models/User.dart';

class SettingsState {
  final User user;
  final String nickname;
  bool get isValidNickname => nickname.length > 3;
  final int age;
  bool get isValidAge => age > -1 && age < 121;
  final int sex;
  bool get isValidSex => sex > -2 && sex < 3;
  final bool metric;
  final int weight;
  bool get isValidWeight => weight > 0 && weight < 30000;
  final int bikeWeight;
  bool get isValidBikeWeight => bikeWeight > 0 && bikeWeight < 3000;
  final int wheelCircumference;
  bool get isValidWheelCircumference => wheelCircumference > 0;
  final int ftp;
  bool get isValidFtp => ftp > 0 && ftp < 1001;
  final int zone1;
  bool get isValidZone1 => zone1 > 0 && zone1 < zone2;
  final int zone2;
  bool get isValidZone2 => zone2 > zone1 && zone2 < zone3;
  final int zone3;
  bool get isValidZone3 => zone3 > zone2 && zone3 < zone4;
  final int zone4;
  bool get isValidZone4 => zone4 > zone3 && zone4 < zone5;
  final int zone5;
  bool get isValidZone5 => zone5 > zone4;
  final int rrHr;
  bool get isValidRRHR => rrHr > 0;
  final int ltHr;
  bool get isValidLTHR => ltHr > -1;
  final int maxHr;
  bool get isValidMaxHR => maxHr > -1;

  final FormSubmissionStatus formStatus;
  final FormSubmissionStatus stravaStatus;

  SettingsState({
    required User user,
    String? nickname,
    int? age,
    int? sex,
    bool? metric,
    int? weight,
    int? bikeWeight,
    int? wheelCircumference,
    int? ftp,
    int? zone1,
    int? zone2,
    int? zone3,
    int? zone4,
    int? zone5,
    int? rrHr,
    int? ltHr,
    int? maxHr,
    this.formStatus = const InitialFormStatus(),
    this.stravaStatus = const InitialFormStatus(),
  })  : this.user = user,
        this.nickname = nickname ?? user.nickname,
        this.age = age ?? user.age ?? 0,
        this.sex = sex ?? user.sex ?? -1,
        this.metric = metric ?? user.metric,
        this.weight = weight ?? user.weight,
        this.bikeWeight = bikeWeight ?? user.bikeWeight,
        this.wheelCircumference =
            wheelCircumference ?? user.wheelCircumference ?? 2105,
        this.ftp = ftp ?? user.ftp,
        this.zone1 = zone1 ?? user.zone1,
        this.zone2 = zone2 ?? user.zone2,
        this.zone3 = zone3 ?? user.zone3,
        this.zone4 = zone4 ?? user.zone4,
        this.zone5 = zone5 ?? user.zone5,
        this.rrHr = rrHr ?? user.rrHr,
        this.ltHr = ltHr ?? user.ltHr ?? 0,
        this.maxHr = maxHr ?? user.maxHr ?? 0;

  SettingsState copyWith({
    String? nickname,
    int? age,
    int? sex,
    bool? metric,
    int? weight,
    int? bikeWeight,
    int? wheelCircumference,
    int? ftp,
    int? zone1,
    int? zone2,
    int? zone3,
    int? zone4,
    int? zone5,
    int? rrHr,
    int? ltHr,
    int? maxHr,
    FormSubmissionStatus? formStatus,
    FormSubmissionStatus? stravaStatus,
  }) {
    return SettingsState(
      user: this.user,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      metric: metric ?? this.metric,
      weight: weight ?? this.weight,
      bikeWeight: bikeWeight ?? this.bikeWeight,
      wheelCircumference: wheelCircumference ?? this.wheelCircumference,
      ftp: ftp ?? this.ftp,
      zone1: zone1 ?? this.zone1,
      zone2: zone2 ?? this.zone2,
      zone3: zone3 ?? this.zone3,
      zone4: zone4 ?? this.zone4,
      zone5: zone5 ?? this.zone5,
      rrHr: rrHr ?? this.rrHr,
      ltHr: ltHr ?? this.ltHr,
      maxHr: maxHr ?? this.maxHr,
      formStatus: formStatus ?? this.formStatus,
      stravaStatus: stravaStatus ?? this.stravaStatus,
    );
  }
}
