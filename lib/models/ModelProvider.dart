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
import 'Activity.dart';
import 'Schedule.dart';
import 'Strava.dart';
import 'User.dart';
import 'Workout.dart';

export 'Activity.dart';
export 'Schedule.dart';
export 'Strava.dart';
export 'User.dart';
export 'Workout.dart';

class ModelProvider implements ModelProviderInterface {
  @override
  String version = "54f2e45ebdea0dd36ebb297f4e386f9e";
  @override
  List<ModelSchema> modelSchemas = [Activity.schema, Schedule.schema, Strava.schema, User.schema, Workout.schema];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;
  
  ModelType getModelTypeByModelName(String modelName) {
    switch(modelName) {
    case "Activity": {
    return Activity.classType;
    }
    break;
    case "Schedule": {
    return Schedule.classType;
    }
    break;
    case "Strava": {
    return Strava.classType;
    }
    break;
    case "User": {
    return User.classType;
    }
    break;
    case "Workout": {
    return Workout.classType;
    }
    break;
    default: {
    throw Exception("Failed to find model in model provider for model name: " + modelName);
    }
    }
  }
}