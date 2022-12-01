#import "VolcengineNativePlugin.h"
#import "RangersAPM.h"
#import "RangersAPM+DebugLog.h"
#import "RangersAPM+ALog.h"

//use for test case
#import "RangersAPM+UserException.h"
#import "RangersAPM+EventMonitor.h"
#import <mach/mach.h>
//设置的内存采集启动阈值，当APP内存超过此值时将启动内存优化模块，采集APP内存状态
static float dangerousMemoryThreshold = 1024.0;


@implementation VolcengineNativePlugin


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
  }else if([@"test_crash" isEqualToString: call.method]){
      //test
      [self testCrash:call.arguments result:result];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)initVolcEngine:(NSDictionary*)arguments result:(FlutterResult)result{
    NSString *appId = [arguments objectForKey:@"appId"];
    NSString *appToken = [arguments objectForKey:@"appToken"];
    NSString *channel = [arguments objectForKey:@"channel"];
    
    RangersAPMConfig *apmConfig = [RangersAPMConfig configWithAppID:appId appToken:appToken];
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
    NSString *nickname = [arguments objectForKey:@"nickname"];
    NSString *env = [arguments objectForKey:@"env"];
    
    [RangersAPM setUserID:userId];
    if(nickname != nil){
        [RangersAPM setCustomContextValue:nickname forKey:@"nickname"];
    }
    if(env != nil){
        [RangersAPM setCustomContextValue:env forKey:@"env"];
    }
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

-(void)testCrash:(NSDictionary*)arguments result:(FlutterResult)result{
    NSString *type = [arguments objectForKey:@"type"];
    
    //数组越界闪退
    if([type isEqualToString:@"crash1"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSArray *array = [NSArray array];
                [array objectAtIndex:10];
            });
    }
    
    //子线程操作UI闪退
    if([type isEqualToString:@"crash2"]){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIView *bb = [UIView new];
            bb.backgroundColor = [UIColor redColor];

        });
    }
    
    // 死循环
    if([type isEqualToString:@"crash3"]){
        while (true) {
            NSLog(@"死循环");
        }
    }
    
    
    //错误 网络错误
    if([type isEqualToString:@"error"]){
        [RangersAPM trackAllThreadsLogExceptionType:@"testUserException"
                                       skippedDepth:0
                                     customParams:@{@"testCustomKey":@"testCustomValue"}
                                          filters:@{@"testFilterKey":@"testFilterValue"}
                                         callback:^(NSError * _Nullable error){
                                            NSLog(@"%@",error);
                                         }
        ];
    }
   
    //卡顿
    if([type isEqualToString:@"caton"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sleep(5);
        });
    }
    
    //事件分析
    //事件分析模块是一个自埋点功能，需要您手动调用接口来进行事件的记录
    if([type isEqualToString:@"event"]){
        [RangersAPM trackEvent:@"fb_event_name1"
                 metrics:@{@"metric1":@(0)}
                dimension:@{@"dimension1":@"test"}
               extraValue:@{@"extra1":@"extravalue"}];
    }
    
    //内存溢出
    if([type isEqualToString:@"memory"]){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                   while (1) {
                       if (!overMemoryThreshold()) {
                           CGSize size = CGSizeMake(1024 * 8, 1024 * 8 * 9.0f/16.0);
                           const size_t bitsPerComponent = 8;
                           const size_t bytesPerRow = size.width * 4;
                           CGContextRef ctx = CGBitmapContextCreate(calloc(sizeof(unsigned char), bytesPerRow * size.height), size.width, size.height, bitsPerComponent, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
                           CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
                           CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
                           sleep(1);
                       } else {
                           break;
                       }
                   }
               });
    }
    result(@YES);
}

//计算APP当前的内存占用，当内存占用超过内存采集启动阈值时，返回true，否则返回false
bool overMemoryThreshold(void)
{
    kern_return_t kr;
            
    task_vm_info_data_t task_vm;
    mach_msg_type_number_t task_vm_count = TASK_VM_INFO_COUNT;
    kr = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &task_vm, &task_vm_count);
               
    if (kr == KERN_SUCCESS) {
        printf("Current App Memory is :%f\n\n", task_vm.phys_footprint / (1024.0 * 1024.0));
        if (task_vm.phys_footprint / (1024.0 * 1024.0) > dangerousMemoryThreshold) {
            return true;
        } else {
            return false;
        }
    }
        
    return false;
}

@end





