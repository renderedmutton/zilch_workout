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


/** This is an auto generated class representing the Workout type in your schema. */
@immutable
class Workout extends Model {
  static const classType = const _WorkoutModelType();
  final String id;
  final String? _name;
  final List<int>? _type;
  final List<int>? _power;
  final List<int>? _slope;
  final List<int>? _duration;
  final int? _lastModified;
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
  
  List<int>? get type {
    return _type;
  }
  
  List<int>? get power {
    return _power;
  }
  
  List<int>? get slope {
    return _slope;
  }
  
  List<int>? get duration {
    return _duration;
  }
  
  int? get lastModified {
    return _lastModified;
  }
  
  String? get userID {
    return _userID;
  }
  
  const Workout._internal({required this.id, name, type, power, slope, duration, lastModified, userID}): _name = name, _type = type, _power = power, _slope = slope, _duration = duration, _lastModified = lastModified, _userID = userID;
  
  factory Workout({String? id, String? name, List<int>? type, List<int>? power, List<int>? slope, List<int>? duration, int? lastModified, String? userID}) {
    return Workout._internal(
      id: id == null ? UUID.getUUID() : id,
      name: name,
      type: type != null ? List<int>.unmodifiable(type) : type,
      power: power != null ? List<int>.unmodifiable(power) : power,
      slope: slope != null ? List<int>.unmodifiable(slope) : slope,
      duration: duration != null ? List<int>.unmodifiable(duration) : duration,
      lastModified: lastModified,
      userID: userID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Workout &&
      id == other.id &&
      _name == other._name &&
      DeepCollectionEquality().equals(_type, other._type) &&
      DeepCollectionEquality().equals(_power, other._power) &&
      DeepCollectionEquality().equals(_slope, other._slope) &&
      DeepCollectionEquality().equals(_duration, other._duration) &&
      _lastModified == other._lastModified &&
      _userID == other._userID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Workout {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("type=" + (_type != null ? _type!.toString() : "null") + ", ");
    buffer.write("power=" + (_power != null ? _power!.toString() : "null") + ", ");
    buffer.write("slope=" + (_slope != null ? _slope!.toString() : "null") + ", ");
    buffer.write("duration=" + (_duration != null ? _duration!.toString() : "null") + ", ");
    buffer.write("lastModified=" + (_lastModified != null ? _lastModified!.toString() : "null") + ", ");
    buffer.write("userID=" + "$_userID");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Workout copyWith({String? id, String? name, List<int>? type, List<int>? power, List<int>? slope, List<int>? duration, int? lastModified, String? userID}) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      power: power ?? this.power,
      slope: slope ?? this.slope,
      duration: duration ?? this.duration,
      lastModified: lastModified ?? this.lastModified,
      userID: userID ?? this.userID);
  }
  
  Workout.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _type = (json['type'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _power = (json['power'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _slope = (json['slope'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _duration = (json['duration'] as List<dynamic>)?.map((dynamic e) => e is double ? e.toInt() : e as int)?.toList(),
      _lastModified = json['lastModified'],
      _userID = json['userID'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'type': _type, 'power': _power, 'slope': _slope, 'duration': _duration, 'lastModified': _lastModified, 'userID': _userID
  };

  static final QueryField ID = QueryField(fieldName: "workout.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField TYPE = QueryField(fieldName: "type");
  static final QueryField POWER = QueryField(fieldName: "power");
  static final QueryField SLOPE = QueryField(fieldName: "slope");
  static final QueryField DURATION = QueryField(fieldName: "duration");
  static final QueryField LASTMODIFIED = QueryField(fieldName: "lastModified");
  static final QueryField USERID = QueryField(fieldName: "userID");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Workout";
    modelSchemaDefinition.pluralName = "Workouts";
    
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
      key: Workout.NAME,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.TYPE,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.POWER,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.SLOPE,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.DURATION,
      isRequired: false,
      isArray: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.collection, ofModelName: describeEnum(ModelFieldTypeEnum.int))
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.LASTMODIFIED,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Workout.USERID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _WorkoutModelType extends ModelType<Workout> {
  const _WorkoutModelType();
  
  @override
  Workout fromJson(Map<String, dynamic> jsonData) {
    return Workout.fromJson(jsonData);
  }
}