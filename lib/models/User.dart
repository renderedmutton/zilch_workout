/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// ignore_for_file: public_member_api_docs

import 'ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the User type in your schema. */
@immutable
class User extends Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _username;
  final String? _nickname;
  final int? _age;
  final int? _sex;
  final bool? _metric;
  final int? _weight;
  final int? _bikeWeight;
  final int? _wheelCircumference;
  final int? _ftp;
  final int? _zone1;
  final int? _zone2;
  final int? _zone3;
  final int? _zone4;
  final int? _zone5;
  final int? _rrHr;
  final int? _ltHr;
  final int? _maxHr;
  final int? _newFtp;
  final List<int>? _powerCurve;
  final List<Workout>? _Workouts;
  final List<Activity>? _Activities;
  final List<Schedule>? _Schedules;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String get username {
    try {
      return _username!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  String get nickname {
    try {
      return _nickname!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int? get age {
    return _age;
  }
  
  int? get sex {
    return _sex;
  }
  
  bool get metric {
    try {
      return _metric!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get weight {
    try {
      return _weight!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get bikeWeight {
    try {
      return _bikeWeight!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int? get wheelCircumference {
    return _wheelCircumference;
  }
  
  int get ftp {
    try {
      return _ftp!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get zone1 {
    try {
      return _zone1!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get zone2 {
    try {
      return _zone2!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get zone3 {
    try {
      return _zone3!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get zone4 {
    try {
      return _zone4!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get zone5 {
    try {
      return _zone5!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int get rrHr {
    try {
      return _rrHr!;
    } catch(e) {
      throw new DataStoreException(DataStoreExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage, recoverySuggestion: DataStoreExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion, underlyingException: e.toString());
    }
  }
  
  int? get ltHr {
    return _ltHr;
  }
  
  int? get maxHr {
    return _maxHr;
  }
  
  int? get newFtp {
    return _newFtp;
  }
  
  List<int>? get powerCurve {
    return _powerCurve;
  }
  
  List<Workout>? get Workouts {
    return _Workouts;
  }
  
  List<Activity>? get Activities {
    return _Activities;
  }
  
  List<Schedule>? get Schedules {
    return _Schedules;
  }
  
  const User._internal({required this.id, required username, required nickname, age, sex, required metric, required weight, required bikeWeight, wheelCircumference, required ftp, required zone1, required zone2, required zone3, required zone4, required zone5, required rrHr, ltHr, maxHr, newFtp, powerCurve, Workouts, Activities, Schedules}): _username = username, _nickname = nickname, _age = age, _sex = sex, _metric = metric, _weight = weight, _bikeWeight = bikeWeight, _wheelCircumference = wheelCircumference, _ftp = ftp, _zone1 = zone1, _zone2 = zone2, _zone3 = zone3, _zone4 = zone4, _zone5 = zone5, _rrHr = rrHr, _ltHr = ltHr, _maxHr = maxHr, _newFtp = newFtp, _powerCurve = powerCurve, _Workouts = Workouts, _Activities = Activities, _Schedules = Schedules;
  
  factory User({String? id, required String username, required String nickname, int? age, int? sex, required bool metric, required int weight, required int bikeWeight, int? wheelCircumference, required int ftp, required int zone1, required int zone2, required int zone3, required int zone4, required int zone5, required int rrHr, int? ltHr, int? maxHr, int? newFtp, List<int>? powerCurve, List<Workout>? Workouts, List<Activity>? Activities, List<Schedule>? Schedules}) {
    return User._internal(
      id: id == null ? UUID.getUUID() : id,
      username: username,
      nickname: nickname,
      age: age,
      sex: sex,
      metric: metric,
      weight: weight,
      bikeWeight: bikeWeight,
      wheelCircumference: wheelCircumference,
      ftp: ftp,
      zone1: zone1,
      zone2: zone2,
      zone3: zone3,
      zone4: zone4,
      zone5: zone5,
      rrHr: rrHr,
      ltHr: ltHr,
      maxHr: maxHr,
      newFtp: newFtp,
      powerCurve: powerCurve != null ? List<int>.unmodifiable(powerCurve) : powerCurve,
      Workouts: Workouts != null ? List<Workout>.unmodifiable(Workouts) : Workouts,
      Activities: Activities != null ? List<Activity>.unmodifiable(Activities) : Activities,
      Schedules: Schedules != null ? List<Schedule>.unmodifiable(Schedules) : Schedules);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
      id == other.id &&
      _username == other._username &&
      _nickname == other._nickname &&
      _age == other._age &&
      _sex == other._sex &&
      _metric == other._metric &&
      _weight == other._weight &&
      _bikeWeight == other._bikeWeight &&
      _wheelCircumference == other._wheelCircumference &&
      _ftp == other._ftp &&
      _zone1 == other._zone1 &&
      _zone2 == other._zone2 &&
      _zone3 == other._zone3 &&
      _zone4 == other._zone4 &&
      _zone5 == other._zone5 &&
      _rrHr == other._rrHr &&
      _ltHr == other._ltHr &&
      _maxHr == other._maxHr &&
      _newFtp == other._newFtp &&
      DeepCollectionEquality().equals(_powerCurve, other._powerCurve) &&
      DeepCollectionEquality().equals(_Workouts, other._Workouts) &&
      DeepCollectionEquality().equals(_Activities, other._Activities) &&
      DeepCollectionEquality().equals(_Schedules, other._Schedules);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("nickname=" + "$_nickname" + ", ");
    buffer.write("age=" + (_age != null ? _age!.toString() : "null") + ", ");
    buffer.write("sex=" + (_sex != null ? _sex!.toString() : "null") + ", ");
    buffer.write("metric=" + (_metric != null ? _metric!.toString() : "null") + ", ");
    buffer.write("weight=" + (_weight != null ? _weight!.toString() : "null") + ", ");
    buffer.write("bikeWeight=" + (_bikeWeight != null ? _bikeWeight!.toString() : "null") + ", ");
    buffer.write("wheelCircumference=" + (_wheelCircumference != null ? _wheelCircumference!.toString() : "null") + ", ");
    buffer.write("ftp=" + (_ftp != null ? _ftp!.toString() : "null") + ", ");
    buffer.write("zone1=" + (_zone1 != null ? _zone1!.toString() : "null") + ", ");
    buffer.write("zone2=" + (_zone2 != null ? _zone2!.toString() : "null") + ", ");
    buffer.write("zone3=" + (_zone3 != null ? _zone3!.toString() : "null") + ", ");
    buffer.write("zone4=" + (_zone4 != null ? _zone4!.toString() : "null") + ", ");
    buffer.write("zone5=" + (_zone5 != null ? _zone5!.toString() : "null") + ", ");
    buffer.write("rrHr=" + (_rrHr != null ? _rrHr!.toString() : "null") + ", ");
    buffer.write("ltHr=" + (_ltHr != null ? _ltHr!.toString() : "null") + ", ");
    buffer.write("maxHr=" + (_maxHr != null ? _maxHr!.toString() : "null") + ", ");
    buffer.write("newFtp=" + (_newFtp != null ? _newFtp!.toString() : "null") + ", ");
    buffer.write("powerCurve=" + (_powerCurve != null ? _powerCurve!.toString() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? id, String? username, String? nickname, int? age, int? sex, bool? metric, int? weight, int? bikeWeight, int? wheelCircumference, int? ftp, int? zone1, int? zone2, int? zone3, int? zone4, int? zone5, int? rrHr, int? ltHr, int? maxHr, int? newFtp, List<int>? powerCurve, List<Workout>? Workouts, List<Activity>? Activities, List<Schedule>? Schedules}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
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
      newFtp: newFtp ?? this.newFtp,
      powerCurve: powerCurve ?? this.powerCurve,
      Workouts: Workouts ?? this.Workouts,
      Activities: Activities ?? this.Activities,
      Schedules: Schedules ?? this.Schedules);
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _username = json['username'],
      _nickname = json['nickname'],
      _age = json['age'],
      _sex = json['sex'],
      _metric = json['metric'],
      _weight = json['weight'],
      _bikeWeight = json['bikeWeight'],
      _wheelCircumference = json['wheelCircumference'],
      _ftp = json['ftp'],
      _zone1 = json['zone1'],
      _zone2 = json['zone2'],
      _zone3 = json['zone3'],
      _zone4 = json['zone4'],
      _zone5 = json['zone5'],
      _rrHr = json['rrHr'],
      _ltHr = json['ltHr'],
      _maxHr = json['maxHr'],
      _newFtp = json['newFtp'],
      _powerCurve = (json['powerCurve'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _Workouts = json['Workouts'] is List
        ? (json['Workouts'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Workout.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _Activities = json['Activities'] is List
        ? (json['Activities'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Activity.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _Schedules = json['Schedules'] is List
        ? (json['Schedules'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => Schedule.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'username': _username, 'nickname': _nickname, 'age': _age, 'sex': _sex, 'metric': _metric, 'weight': _weight, 'bikeWeight': _bikeWeight, 'wheelCircumference': _wheelCircumference, 'ftp': _ftp, 'zone1': _zone1, 'zone2': _zone2, 'zone3': _zone3, 'zone4': _zone4, 'zone5': _zone5, 'rrHr': _rrHr, 'ltHr': _ltHr, 'maxHr': _maxHr, 'newFtp': _newFtp, 'powerCurve': _powerCurve, 'Workouts': _Workouts?.map((e) => e?.toJson())?.toList(), 'Activities': _Activities?.map((e) => e?.toJson())?.toList(), 'Schedules': _Schedules?.map((e) => e?.toJson())?.toList()
  };

  static final QueryField ID = QueryField(fieldName: "user.id");
  static final QueryField USERNAME = QueryField(fieldName: "username");
  static final QueryField NICKNAME = QueryField(fieldName: "nickname");
  static final QueryField AGE = QueryField(fieldName: "age");
  static final QueryField SEX = QueryField(fieldName: "sex");
  static final QueryField METRIC = QueryField(fieldName: "metric");
  static final QueryField WEIGHT = QueryField(fieldName: "weight");
  static final QueryField BIKEWEIGHT = QueryField(fieldName: "bikeWeight");
  static final QueryField WHEELCIRCUMFERENCE = QueryField(fieldName: "wheelCircumference");
  static final QueryField FTP = QueryField(fieldName: "ftp");
  static final QueryField ZONE1 = QueryField(fieldName: "zone1");
  static final QueryField ZONE2 = QueryField(fieldName: "zone2");
  static final QueryField ZONE3 = QueryField(fieldName: "zone3");
  static final QueryField ZONE4 = QueryField(fieldName: "zone4");
  static final QueryField ZONE5 = QueryField(fieldName: "zone5");
  static final QueryField RRHR = QueryField(fieldName: "rrHr");
  static final QueryField LTHR = QueryField(fieldName: "ltHr");
  static final QueryField MAXHR = QueryField(fieldName: "maxHr");
  static final QueryField NEWFTP = QueryField(fieldName: "newFtp");
  static final QueryField POWERCURVE = QueryField(fieldName: "powerCurve");
  static final QueryField WORKOUTS = QueryField(
    fieldName: "Workouts",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Workout).toString()));
  static final QueryField ACTIVITIES = QueryField(
    fieldName: "Activities",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Activity).toString()));
  static final QueryField SCHEDULES = QueryField(
    fieldName: "Schedules",
    fieldType: ModelFieldType(ModelFieldTypeEnum.model, ofModelName: (Schedule).toString()));
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PRIVATE,
        operations: [
          ModelOperation.CREATE,
          ModelOperation.READ,
          ModelOperation.UPDATE
        ])
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.USERNAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.NICKNAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.AGE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.SEX,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.METRIC,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.WEIGHT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.BIKEWEIGHT,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.WHEELCIRCUMFERENCE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.FTP,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.ZONE1,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.ZONE2,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.ZONE3,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.ZONE4,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.ZONE5,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.RRHR,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.LTHR,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.MAXHR,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.NEWFTP,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: User.POWERCURVE,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: User.WORKOUTS,
      isRequired: false,
      ofModelName: (Workout).toString(),
      associatedKey: Workout.USERID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: User.ACTIVITIES,
      isRequired: false,
      ofModelName: (Activity).toString(),
      associatedKey: Activity.USERID
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
      key: User.SCHEDULES,
      isRequired: false,
      ofModelName: (Schedule).toString(),
      associatedKey: Schedule.USERID
    ));
  });
}

class _UserModelType extends ModelType<User> {
  const _UserModelType();
  
  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }
}