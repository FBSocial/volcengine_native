package com.idreamsky.volcengine_native;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.apm.insight.MonitorCrash;
import com.apm.insight.log.VLog;
import com.bytedance.apm.insight.ApmInsight;
import com.bytedance.apm.insight.ApmInsightInitConfig;
import com.bytedance.apm.insight.IDynamicParams;


/** VolcengineNativePlugin */
public class VolcengineNativePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "volcengine_native");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void initCrash(String appId,String appToken,{}){
    MonitorCrash.Config config = MonitorCrash.Config.app(appId)
            .token(appToken)// 设置鉴权token，可从平台应用信息处获取，token错误无法上报数据
//              .versionCode(1)// 可选，默认取PackageInfo中的versionCode
//              .versionName("1.0")// 可选，默认取PackageInfo中的versionName
//              .channel("test")// 可选，设置App发布渠道，在平台可以筛选
//              .url("www.xxx.com")// 默认不需要，私有化部署才配置上报地址
            //可选，可以设置自定义did，不设置会使用内部默认的
//              .dynamicParams(new MonitorCrash.Config.IDynamicParams() {
//                  @Override
//                  public String getDid() {//返回空会使用内部默认的did
//                      return null;
//                  }
//
//                  @Override
//                  public String getUserId() {
//                      return null;
//                  }
//              })
            //可选，添加业务自定义数据，在崩溃详情页->现场数据展示
//              .customData(crashType -> {
//                  HashMap<String, String> map = new HashMap<>();
//                  map.put("app_custom", "app_value");
//                  return map;
//              })
            .build();
    MonitorCrash monitorCrash = MonitorCrash.init(this, config);
  }


  public void initApm(String appId, String appToken) {
    ApmInsightInitConfig.Builder builder = ApmInsightInitConfig.builder();
    //设置分配的appid
    builder.aid(appId);
    //设置分配的AppToken
    builder.token(appToken);
    //是否开启卡顿功能
    builder.blockDetect(true);
    //是否开启严重卡顿功能
    builder.seriousBlockDetect(true);
    //是否开启流畅性和丢帧
    builder.fpsMonitor(true);
    //控制是否打开WebVeiw监控
    builder.enableWebViewMonitor(true);
    //控制是否打开内存监控
    builder.memoryMonitor(true);
    //控制是否打开电量监控
    builder.batteryMonitor(true);
    //控制是否打开CPU监控
    builder.cpuMonitor(true);
    //控制是否打开磁盘监控
    builder.diskMonitor(true);
    //是否打印日志，注：线上release版本要配置为false
    builder.debugMode(true);
    //默认不需要，私有化部署才需要配置数据上报的域名 （内部有默认域名，测试支持设置http://www.xxx.com  默认是https协议
    //builder.defaultReportDomain("www.xxx.com");
    //设置渠道。1.3.16版本增加接口
    builder.channel("google play");
    //打开自定义日志回捞能力。1.4.1版本新增接口
    builder.enableLogRecovery(true);
    //设置数据和Rangers Applog数据打通，设备标识did必填。1.3.16版本增加接口
    builder.setDynamicParams(new IDynamicParams() {
      @Override
      public String getUserUniqueID() {
        //可选。依赖AppLog可以通过AppLog.getUserUniqueID()获取，否则可以返回null。
        return null;
      }

      @Override
      public String getAbSdkVersion() {
        //可选。如果依赖AppLog可以通过AppLog.getAbSdkVersion()获取，否则可以返回null。getAbSdkVersion是回调类的参数可以初始化后再设置。
        return null;
      }

      @Override
      public String getSsid() {
        //可选。依赖AppLog可以通过AppLog.getSsid()获取，否则可以返回null。getSsid是回调类的参数可以初始化后再设置。
        return null;
      }

      @Override
      public String getDid() {
        //1.4.0版本及以上可选，其他版本必填。设备的唯一标识，如果依赖AppLog可以通过 AppLog.getDid() 获取，也可以自己生成。getDid是回调类的参数可以初始化后再设置。
        return null;
      }

      @Override
      public String getUserId() {
        //可选。用户的唯一标识，支持用户自定义user_id把平台数据和自己用户关联起来。getUserId是回调类的参数可以初始化后再设置。
        return "userid";
      }

    });
    ApmInsight.getInstance().init(this, builder.build());
    //初始化自定日志，配置自定义日志最大占用磁盘，内部一般配置20，代表最大20M磁盘占用。1.4.1版本开始存在这个api
    VLog.init(this, 20);
  }
}
