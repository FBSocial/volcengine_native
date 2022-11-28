import 'dart:io';

import 'package:flutter/material.dart';
import 'package:volcengine_native/volcengine_native.dart';
import 'package:ve_apm/ve_apm.dart';
import 'package:ve_onekit/services/services.dart' as OKService;

void main() {
  // runApp(const MyApp());

  runTraceApp((observer) {
    HttpOverrides.global = ApmHttpOverrides(); //开启网络监控，如果不需要网络监控则不设置
    return MyApp(navigatorObserver: observer);
  });
}

class MyApp extends StatefulWidget {
  final NavigatorObserver navigatorObserver;

  const MyApp({Key? key, required this.navigatorObserver}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [widget.navigatorObserver],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('火山引擎'),
        ),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  try {
                    VolcengineNative.initVolcEngine(
                        appId: "appId", appToken: "appToken");
                  } catch (e) {
                    debugPrint("initVolcEngine error : $e");
                  }
                },
                child: const Text('初始化火山')),
            ElevatedButton(
                onPressed: () {
                  try {
                    VolcengineNative.reportUserInfo(userId: "userID");
                  } catch (e) {
                    debugPrint("initVolcEngine error : $e");
                  }
                },
                child: const Text('更新上报用户ID')),
            ElevatedButton(
                onPressed: () {
                  try {
                    VolcengineNative.enableRemoteLog();
                  } catch (e) {
                    debugPrint("initVolcEngine error : $e");
                  }
                },
                child: const Text('开启火山远程日志')),
            ElevatedButton(
                onPressed: () {
                  try {
                    VolcengineNative.reportLog(
                        log: "log--- ${DateTime.now()}",
                        level: VolcenLogLevel.info);
                  } catch (e) {
                    debugPrint("initVolcEngine error : $e");
                  }
                },
                child: const Text('向原生写日志')),
            ElevatedButton(
                onPressed: () {
                  try {
                    final _alog = OKService.serviceManager
                        .getService<OKService.VeAlog>()!;
                    _alog.debug(tag: 'test', message: 'debug');
                    _alog.info(tag: 'test', message: 'info');
                    _alog.warn(tag: 'test', message: 'warn');
                    _alog.error(tag: 'test', message: 'error');
                  } catch (e) {
                    debugPrint("initVolcEngine error : $e");
                  }
                },
                child: const Text('Flutter写日志')),
          ],
        ),
      ),
    );
  }
}
