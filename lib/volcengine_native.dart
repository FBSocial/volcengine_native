
import 'dart:async';

import 'package:flutter/services.dart';

class VolcengineNative {
  static const MethodChannel _channel = MethodChannel('volcengine_native');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
