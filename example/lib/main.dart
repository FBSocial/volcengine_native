import 'package:flutter/material.dart';
import 'package:volcengine_native/volcengine_native.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
                child: const Text('写日志')),
          ],
        ),
      ),
    );
  }
}
