import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum VolcenLogLevel {
  debug,
  info,
  warn,
  error,
}

class VolcengineNative {
  static const MethodChannel _channel = MethodChannel('volcengine_native');

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
      debugPrint("initVolcEngine error: $e");
      rethrow;
    }
  }

  /*
  上报用户信息
   */
  static Future<void> reportUserInfo({required String userId}) async {
    try {
      final path = await _channel.invokeMethod("report_user_info", {
        "userId": userId,
      });
      return path;
    } on PlatformException catch (e) {
      debugPrint("updateReportInfo error: $e");
      rethrow;
    }
  }

  /*
  开启火山日志系统
   */
  static Future<void> enableRemoteLog() async {
    try {
      final path = await _channel.invokeMethod("enable_remote_log", {});
      return path;
    } on PlatformException catch (e) {
      debugPrint("enableRemoteLog error: $e");
      rethrow;
    }
  }

  /*
  上报日志
   */
  static Future<void> reportLog({
    required String log,
    VolcenLogLevel level = VolcenLogLevel.debug,
  }) async {
    try {
      final path = await _channel.invokeMethod("report_remote_log", {
        "log": log,
        "level": level.name,
      });
      return path;
    } on PlatformException catch (e) {
      debugPrint("reportLog error: $e");
      rethrow;
    }
  }
}
