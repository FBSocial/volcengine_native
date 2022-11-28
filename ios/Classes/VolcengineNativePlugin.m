#import "VolcengineNativePlugin.h"
#import "RangersAPM.h"
#import "RangersAPM+DebugLog.h"
#import "RangersAPM+ALog.h"

@implementation VolcengineNativePlugin
{
    RangersAPMConfig *apmConfig;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"volcengine_native"
            binaryMessenger:[registrar messenger]];
  VolcengineNativePlugin* instance = [[VolcengineNativePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"init_volc_engine" isEqualToString: call.method]){
      //初始化
      [self initVolcEngine:call.arguments result:result];
  }else if([@"report_user_info" isEqualToString: call.method]){
      //更新日志用户用户信息
      [self uploadReportInfo:call.arguments result:result];
  }else if([@"enable_remote_log" isEqualToString: call.method]){
      //开启日志上报
      [self enableRemoteLog:result];
  }else if([@"report_remote_log" isEqualToString: call.method]){
      //日志上报
      [self uploadLog:call.arguments result:result];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)initVolcEngine:(NSDictionary*)arguments result:(FlutterResult)result{
    NSString *appId = [arguments objectForKey:@"appId"];
    NSString *appToken = [arguments objectForKey:@"appToken"];
    NSString *channel = [arguments objectForKey:@"channel"];
    
    apmConfig = [RangersAPMConfig configWithAppID:appId appToken:appToken];
    apmConfig.channel = channel;
     
     /**
      首次启动由于没有获取到配置，无法确定需要开启哪些功能模块。可以配置此属性，来决定首次启动默认需要开启的功能模块，仅对首次启动生效，一旦拉取到配置，下次启动就会先读取本地缓存的配置来决定。
 1. 建议默认开启崩溃分析（RangersAPMCrashMonitorSwitch）、启动分析（RangersAPMLaunchMonitorSwitch）、网络分析（RangersAPMNetworkMonitorSwitch），避免一些和首次启动强相关的数据丢失.
 2. 配置默认开启模块后，新设备首次启动会默认打开这些模块，可能会出现平台上关闭了这些模块，但是依然有数据上报的情况，可能会给您的事件量造成意外的消耗；请根据您的应用情况灵活配置。
 3. 配置多个模块可以参考这种写法：RangersAPMCrashMonitorSwitch | RangersAPMNetworkMonitorSwitch | RangersAPMLaunchMonitorSwitch
      */
     apmConfig.defaultMonitors = RangersAPMCrashMonitorSwitch;
    
#if DEBUG
    //通过修改block，您可以定制自己的日志输出格式，下述代码示例是SDK内部默认的输出格式，如果您传入nil，则SDK会使用默认的格式输出日志。
    [RangersAPM allowDebugLogUsingLogger:^(NSString * _Nonnull log) {
        NSLog(@"FBDebugLog : %@", log);
    }];
#endif
    //请先于此代码开启debug日志，否则对于一些同步事件可能无法输出日志
    [RangersAPM startWithConfig:apmConfig];
    
    result(@YES);
    
}

-(void)uploadReportInfo:(NSDictionary*)arguments result:(FlutterResult)result{
    NSString *userId = [arguments objectForKey:@"userId"];
    [RangersAPM setUserID:userId];
    
    result(@YES);
}

-(void)enableRemoteLog:(FlutterResult)result{
    [RangersAPM setALogEnabled];  //启用Alog
    [RangersAPM enableConsoleLog];  //同时在控制台输出日志
    
    result(@YES);
}

-(void)uploadLog:(NSDictionary*)arguments result:(FlutterResult)result{
    NSString *log = [arguments objectForKey:@"log"];
    NSString *level = [arguments objectForKey:@"level"];
    
    if([level isEqualToString:@"debug"]){
        RANGERSAPM_ALOG_DEBUG(@"FBLogger", log);
    }else if([level isEqualToString:@"info"]){
        RANGERSAPM_ALOG_INFO(@"FBLogger", log);
    }else if([level isEqualToString:@"warn"]){
        RANGERSAPM_ALOG_WARN(@"FBLogger", log);
    }else if([level isEqualToString:@"error"]){
        RANGERSAPM_ALOG_ERROR(@"FBLogger", log);
    }
    result(@YES);
}
@end
