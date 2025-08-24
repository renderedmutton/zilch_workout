import 'dart:io';

import 'package:amplify_flutter/amplify.dart';

class StorageRepository {
  Future<String> uploadFile(File file, String fileName) async {
    try {
      final result =
          await Amplify.Storage.uploadFile(local: file, key: fileName);
      print(result.key);
      return result.key;
    } catch (e) {
      throw e;
    }
  }

  Future<File> downloadFile(File local, String fileName) async {
    try {
      final result =
          await Amplify.Storage.downloadFile(key: fileName, local: local);
      return result.file;
    } catch (e) {
      throw e;
    }
  }

  /*Future<String> getUrlForFile(String fileKey) async {
    try {
      final result = await Amplify.Storage.getUrl(key: fileKey);
      return result.url;
    } catch (e) {
      throw e;
    }
  }*/
}
