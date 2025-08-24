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
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the Schedule type in your schema. */
@immutable
class Schedule extends Model {
  static const classType = const _ScheduleModelType();
  final String id;
  final int? _scheduledTimestamp;
  final int? _notificationTimestamp;
  final String? _workoutName;
  final String? _userID;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  int? get scheduledTimestamp {
    return _scheduledTimestamp;
  }
  
  int? get notificationTimestamp {
    return _notificationTimestamp;
  }
  
  String? get workoutName {
    return _workoutName;
  }
  
  String? get userID {
    return _userID;
  }
  
  const Schedule._internal({required this.id, scheduledTimestamp, notificationTimestamp, workoutName, userID}): _scheduledTimestamp = scheduledTimestamp, _notificationTimestamp = notificationTimestamp, _workoutName = workoutName, _userID = userID;
  
  factory Schedule({String? id, int? scheduledTimestamp, int? notificationTimestamp, String? workoutName, String? userID}) {
    return Schedule._internal(
      id: id == null ? UUID.getUUID() : id,
      scheduledTimestamp: scheduledTimestamp,
      notificationTimestamp: notificationTimestamp,
      workoutName: workoutName,
      userID: userID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Schedule &&
      id == other.id &&
      _scheduledTimestamp == other._scheduledTimestamp &&
      _notificationTimestamp == other._notificationTimestamp &&
      _workoutName == other._workoutName &&
      _userID == other._userID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Schedule {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("scheduledTimestamp=" + (_scheduledTimestamp != null ? _scheduledTimestamp!.toString() : "null") + ", ");
    buffer.write("notificationTimestamp=" + (_notificationTimestamp != null ? _notificationTimestamp!.toString() : "null") + ", ");
    buffer.write("workoutName=" + "$_workoutName" + ", ");
    buffer.write("userID=" + "$_userID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Schedule copyWith({String? id, int? scheduledTimestamp, int? notificationTimestamp, String? workoutName, String? userID}) {
    return Schedule(
      id: id ?? this.id,
      scheduledTimestamp: scheduledTimestamp ?? this.scheduledTimestamp,
      notificationTimestamp: notificationTimestamp ?? this.notificationTimestamp,
      workoutName: workoutName ?? this.workoutName,
      userID: userID ?? this.userID);
  }
  
  Schedule.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _scheduledTimestamp = json['scheduledTimestamp'],
      _notificationTimestamp = json['notificationTimestamp'],
      _workoutName = json['workoutName'],
      _userID = json['userID'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'scheduledTimestamp': _scheduledTimestamp, 'notificationTimestamp': _notificationTimestamp, 'workoutName': _workoutName, 'userID': _userID
  };

  static final QueryField ID = QueryField(fieldName: "schedule.id");
  static final QueryField SCHEDULEDTIMESTAMP = QueryField(fieldName: "scheduledTimestamp");
  static final QueryField NOTIFICATIONTIMESTAMP = QueryField(fieldName: "notificationTimestamp");
  static final QueryField WORKOUTNAME = QueryField(fieldName: "workoutName");
  static final QueryField USERID = QueryField(fieldName: "userID");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Schedule";
    modelSchemaDefinition.pluralName = "Schedules";
    
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
      key: Schedule.SCHEDULEDTIMESTAMP,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Schedule.NOTIFICATIONTIMESTAMP,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Schedule.WORKOUTNAME,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Schedule.USERID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _ScheduleModelType extends ModelType<Schedule> {
  const _ScheduleModelType();
  
  @override
  Schedule fromJson(Map<String, dynamic> jsonData) {
    return Schedule.fromJson(jsonData);
  }
}