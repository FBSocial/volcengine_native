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
      await _channel.invokeMethod("init_volc_engine", {
        "appId": appId,
        "appToken": appToken,
        "channel": channel ?? (Platform.isIOS ? "App Store" : "Android"),
      });
    } on PlatformException catch (e) {
      debugPrint("initVolcEngine error: $e");
      rethrow;
    }
  }

  /*
  上报用户信息
   */
  static Future<void> reportUserInfo({
    required String userId,
    String? nickname,
    String? env,
  }) async {
    try {
      final reqData = {
        "userId": userId,
        "nickname": nickname,
        "env": env,
      };
      reqData.removeWhere((key, value) => value == null);
      await _channel.invokeMethod("report_user_info", reqData);
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
      await _channel.invokeMethod("enable_remote_log", {});
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
      await _channel.invokeMethod("report_remote_log", {
        "log": log,
        "level": level.name,
      });
    } on PlatformException catch (e) {
      debugPrint("reportLog error: $e");
      rethrow;
    }
  }
}
