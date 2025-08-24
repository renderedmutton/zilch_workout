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


/** This is an auto generated class representing the Strava type in your schema. */
@immutable
class Strava extends Model {
  static const classType = const _StravaModelType();
  final String id;
  final String? _clientId;
  final String? _secret;

  @override
  getInstanceType() => classType;
  
  @override
  String getId() {
    return id;
  }
  
  String? get clientId {
    return _clientId;
  }
  
  String? get secret {
    return _secret;
  }
  
  const Strava._internal({required this.id, clientId, secret}): _clientId = clientId, _secret = secret;
  
  factory Strava({String? id, String? clientId, String? secret}) {
    return Strava._internal(
      id: id == null ? UUID.getUUID() : id,
      clientId: clientId,
      secret: secret);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Strava &&
      id == other.id &&
      _clientId == other._clientId &&
      _secret == other._secret;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Strava {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("clientId=" + "$_clientId" + ", ");
    buffer.write("secret=" + "$_secret");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Strava copyWith({String? id, String? clientId, String? secret}) {
    return Strava(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      secret: secret ?? this.secret);
  }
  
  Strava.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _clientId = json['clientId'],
      _secret = json['secret'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'clientId': _clientId, 'secret': _secret
  };

  static final QueryField ID = QueryField(fieldName: "strava.id");
  static final QueryField CLIENTID = QueryField(fieldName: "clientId");
  static final QueryField SECRET = QueryField(fieldName: "secret");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Strava";
    modelSchemaDefinition.pluralName = "Stravas";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PRIVATE,
        operations: [
          ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Strava.CLIENTID,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Strava.SECRET,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
  });
}

class _StravaModelType extends ModelType<Strava> {
  const _StravaModelType();
  
  @override
  Strava fromJson(Map<String, dynamic> jsonData) {
    return Strava.fromJson(jsonData);
  }
}