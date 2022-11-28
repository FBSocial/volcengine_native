import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class VolcengineNative {
  static const MethodChannel _channel = MethodChannel('volcengine_native');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /*
  初始化
   */
  static Future<void> initVolcEngine(
      {required String appId,
      required String appToken,
      String? channel}) async {
    try {
      final path = await _channel.invokeMethod("init_volc_engine", {
        "appId": appId,
        "appToken": appToken,
        "channel": channel ?? (Platform.isIOS ? "App Store" : "Android"),
      });
      return path;
    } on PlatformException catch (e) {
      rethrow;
    }
  }

  /*
  上报用户信息
   */
  static Future<void> updateReportInfo({required String userId}) async {
    try {
      final path = await _channel.invokeMethod("upload_report_info", {
        "userId": userId,
      });
      return path;
    } on PlatformException catch (e) {
      rethrow;
    }
  }
}
