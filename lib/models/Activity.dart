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

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the Activity type in your schema. */
@immutable
class Activity extends Model {
  static const classType = const _ActivityModelType();
  final String id;
  final String? _name;
  final int? _startTime;
  final int? _averagePower;
  final int? _duration;
  final int? _tss;
  final List<int>? _segmentsDuration;
  final String? _workoutName;
  final String? _userID;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String? get name {
    return _name;
  }
  
  int? get startTime {
    return _startTime;
  }
  
  int? get averagePower {
    return _averagePower;
  }
  
  int? get duration {
    return _duration;
  }
  
  int? get tss {
    return _tss;
  }
  
  List<int>? get segmentsDuration {
    return _segmentsDuration;
  }
  
  String? get workoutName {
    return _workoutName;
  }
  
  String? get userID {
    return _userID;
  }
  
  const Activity._internal({required this.id, name, startTime, averagePower, duration, tss, segmentsDuration, workoutName, userID}): _name = name, _startTime = startTime, _averagePower = averagePower, _duration = duration, _tss = tss, _segmentsDuration = segmentsDuration, _workoutName = workoutName, _userID = userID;
  
  factory Activity({String? id, String? name, int? startTime, int? averagePower, int? duration, int? tss, List<int>? segmentsDuration, String? workoutName, String? userID}) {
    return Activity._internal(
      id: id == null ? UUID.getUUID() : id,
      name: name,
      startTime: startTime,
      averagePower: averagePower,
      duration: duration,
      tss: tss,
      segmentsDuration: segmentsDuration != null ? List<int>.unmodifiable(segmentsDuration) : segmentsDuration,
      workoutName: workoutName,
      userID: userID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Activity &&
      id == other.id &&
      _name == other._name &&
      _startTime == other._startTime &&
      _averagePower == other._averagePower &&
      _duration == other._duration &&
      _tss == other._tss &&
      DeepCollectionEquality().equals(_segmentsDuration, other._segmentsDuration) &&
      _workoutName == other._workoutName &&
      _userID == other._userID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Activity {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("startTime=" + (_startTime != null ? _startTime!.toString() : "null") + ", ");
    buffer.write("averagePower=" + (_averagePower != null ? _averagePower!.toString() : "null") + ", ");
    buffer.write("duration=" + (_duration != null ? _duration!.toString() : "null") + ", ");
    buffer.write("tss=" + (_tss != null ? _tss!.toString() : "null") + ", ");
    buffer.write("segmentsDuration=" + (_segmentsDuration != null ? _segmentsDuration!.toString() : "null") + ", ");
    buffer.write("workoutName=" + "$_workoutName" + ", ");
    buffer.write("userID=" + "$_userID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Activity copyWith({String? id, String? name, int? startTime, int? averagePower, int? duration, int? tss, List<int>? segmentsDuration, String? workoutName, String? userID}) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      averagePower: averagePower ?? this.averagePower,
      duration: duration ?? this.duration,
      tss: tss ?? this.tss,
      segmentsDuration: segmentsDuration ?? this.segmentsDuration,
      workoutName: workoutName ?? this.workoutName,
      userID: userID ?? this.userID);
  }
  
  Activity.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _startTime = json['startTime'],
      _averagePower = json['averagePower'],
      _duration = json['duration'],
      _tss = json['tss'],
      _segmentsDuration = (json['segmentsDuration'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _workoutName = json['workoutName'],
      _userID = json['userID'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'startTime': _startTime, 'averagePower': _averagePower, 'duration': _duration, 'tss': _tss, 'segmentsDuration': _segmentsDuration, 'workoutName': _workoutName, 'userID': _userID
  };

  static final QueryField ID = QueryField(fieldName: "activity.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField STARTTIME = QueryField(fieldName: "startTime");
  static final QueryField AVERAGEPOWER = QueryField(fieldName: "averagePower");
  static final QueryField DURATION = QueryField(fieldName: "duration");
  static final QueryField TSS = QueryField(fieldName: "tss");
  static final QueryField SEGMENTSDURATION = QueryField(fieldName: "segmentsDuration");
  static final QueryField WORKOUTNAME = QueryField(fieldName: "workoutName");
  static final QueryField USERID = QueryField(fieldName: "userID");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Activity";
    modelSchemaDefinition.pluralName = "Activities";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PRIVATE,
        operations: [
          ModelOperation.CREATE,
          ModelOperation.UPDATE,
          ModelOperation.DELETE,
          ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.NAME,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.STARTTIME,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.AVERAGEPOWER,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.DURATION,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.TSS,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.SEGMENTSDURATION,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.WORKOUTNAME,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Activity.USERID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _ActivityModelType extends ModelType<Activity> {
  const _ActivityModelType();
  
  @override
  Activity fromJson(Map<String, dynamic> jsonData) {
    return Activity.fromJson(jsonData);
  }
}