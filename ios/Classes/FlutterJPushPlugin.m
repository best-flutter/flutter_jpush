
#import "FlutterJpushPlugin.h"


#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "JPushActionQueue.h"
#import "JPUSHService.h"

@interface FlutterJPushPlugin ()<JPUSHRegisterDelegate> {
    BOOL _isJPushDidLogin;
}

@property (nonatomic,retain) FlutterMethodChannel* channel;

@end



@implementation FlutterJPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_jpush"
                                     binaryMessenger:[registrar messenger]];
    FlutterJPushPlugin* instance = [FlutterJPushPlugin sharedInstance];
    instance.channel = channel;
    [JPushActionQueue sharedInstance].isFlutterDidLoad = YES;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = call.method;
    if ([@"setupPush" isEqualToString:method]) {
        [self setupPush];
        result(@YES);
    }else if ([@"startup" isEqualToString:method]) {
        [self startup];
        result(@YES);
    }else if ([@"stopPush" isEqualToString:method]) {
        [self stopPush];
        result(@YES);
    } else if ([@"getLaunchAppNotification" isEqualToString:method]) {
        [self getLaunchAppNotification:result];
    } else if ([@"getApplicationIconBadge" isEqualToString:method]) {
        [self getApplicationIconBadge:result];
    } else if ([@"addEvent" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self addEvent:map[@"name"] location:map[@"location"] callback:result];
    } else if ([@"registerForRemoteNotificationTypes" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self registerForRemoteNotificationTypes:[map[@"types"] integerValue] categories:(map[@"categories"]==(id)[NSNull null] ?  nil : [NSSet setWithArray:map[@"categories"]])];
        result(@YES);
    } else if ([@"registerDeviceToken" isEqualToString:method]) {
        [self registerDeviceToken:call.arguments];
        result(@YES);
    } else if ([@"handleRemoteNotification" isEqualToString:method]) {
        [self handleRemoteNotification:call.arguments];
        result(@YES);
    } else if ([@"setTags" isEqualToString:method]) {
        [self setTags:call.arguments callback:result];
    } else if ([@"setAlias" isEqualToString:method]) {
        [self setAlias:call.arguments callback:result];
    } else if ([@"addTags" isEqualToString:method]) {
        [self addTags:call.arguments callback:result];
    } else if ([@"deleteTags" isEqualToString:method]) {
        [self deleteTags:call.arguments callback:result];
    } else if ([@"cleanTags" isEqualToString:method]) {
        [self cleanTags:result];
    } else if ([@"getAllTags" isEqualToString:method]) {
        [self getAllTags:result];
    } else if ([@"checkTagBindState" isEqualToString:method]) {
        [self checkTagBindState:call.arguments callback:result];
    } else if ([@"deleteAlias" isEqualToString:method]) {
        [self deleteAlias:result];
    } else if ([@"getAlias" isEqualToString:method]) {
        [self getAlias:result];
    } else if ([@"filterValidTags" isEqualToString:method]) {
        [self filterValidTags:(call.arguments==(id)[NSNull null] ?  nil : [NSSet setWithArray:call.arguments]) callback:result];
    } else if ([@"startLogPageView" isEqualToString:method]) {
        [self startLogPageView:call.arguments];
        result(@YES);
    } else if ([@"stopLogPageView" isEqualToString:method]) {
        [self stopLogPageView:call.arguments];
        result(@YES);
    } else if ([@"beginLogPageView" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self beginLogPageView:map[@"pageName"] duration:[map[@"seconds"] intValue]];
        result(@YES);
    } else if ([@"crashLogON" isEqualToString:method]) {
        [self crashLogON];
        result(@YES);
    } else if ([@"setLatitude" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self setLatitude:[map[@"latitude"] doubleValue] longitude:[map[@"longitude"] doubleValue]];
        result(@YES);
    } else if ([@"setLocation" isEqualToString:method]) {
        [self setLocation:call.arguments];
        result(@YES);
    } else if ([@"setLocalNotification" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self setLocalNotification:map[@"fireDate"] alertBody:map[@"alertBody"] badge:[map[@"badge"] intValue] alertAction:map[@"alertAction"] identifierKey:map[@"notificationKey"] userInfo:map[@"userInfo"] soundName:map[@"soundName"]];
        result(@YES);
    } else if ([@"sendLocalNotification" isEqualToString:method]) {
        [self sendLocalNotification:call.arguments];
        result(@YES);
    } else if ([@"showLocalNotificationAtFront" isEqualToString:method]) {
        NSDictionary* map=call.arguments;
        [self showLocalNotificationAtFront:map[@"notification"] identifierKey:map[@"notificationKey"]];
        result(@YES);
    } else if ([@"deleteLocalNotificationWithIdentifierKey" isEqualToString:method]) {
        [self deleteLocalNotificationWithIdentifierKey:call.arguments];
        result(@YES);
    } else if ([@"deleteLocalNotification" isEqualToString:method]) {
        [self deleteLocalNotification:call.arguments];
        result(@YES);
    } else if ([@"findLocalNotificationWithIdentifier" isEqualToString:method]) {
        [self findLocalNotificationWithIdentifier:call.arguments callback:result];
    } else if ([@"clearAllLocalNotifications" isEqualToString:method]) {
        [self clearAllLocalNotifications];
        result(@YES);
    } else if ([@"setBadge" isEqualToString:method]) {
        [self setBadge:[call.arguments integerValue] callback:result];
    } else if ([@"resetBadge" isEqualToString:method]) {
        [self resetBadge];
        result(@YES);
    } else if ([@"getRegistrationID" isEqualToString:method]) {
        [self getRegistrationID:result];
    } else if ([@"setDebugMode" isEqualToString:method]) {
        [self setDebugMode];
        result(@YES);
    } else if ([@"setLogOFF" isEqualToString:method]) {
        [self setLogOFF];
        result(@YES);
    } else if ([@"clearAllNotifications" isEqualToString:method]) {
        [self clearAllNotifications];
        result(@YES);
    } else if ([@"clearNotificationById" isEqualToString:method]) {
        [self clearNotificationById:[call.arguments integerValue]];
        result(@YES);
    }  else {
        result(FlutterMethodNotImplemented);
    }
}

+(FlutterJPushPlugin*)sharedInstance{
    static FlutterJPushPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FlutterJPushPlugin alloc]init];
    });
    return sharedInstance;
}



-(void)startup:(NSDictionary*)launchOptions  appKey:(NSString*)appKey channel:(NSString*)channel isProduction:(BOOL)isProduction{
    // Override point for customization after application launch.
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
}



- (id)init {
    self = [super init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self];
    
    
    [defaultCenter addObserver:self
                      selector:@selector(networkConnecting:)
                          name:kJPFNetworkIsConnectingNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(receiveRemoteNotification:)
                          name:kJPFDidReceiveRemoteNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(openNotification:)
                          name:kJPFOpenNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(openNotificationToLaunchApp:)
                          name:kJPFOpenNotificationToLaunchApp
                        object:nil];
    
    return self;
}

- (void)startup {
    [[JPushActionQueue sharedInstance] scheduleNotificationQueue];
    
    ///队列
    if ([JPushActionQueue sharedInstance].openedRemoteNotification != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotificationToLaunchApp object:[JPushActionQueue sharedInstance].openedRemoteNotification];
    }
    
    if ([JPushActionQueue sharedInstance].openedLocalNotification != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotificationToLaunchApp object:[JPushActionQueue sharedInstance].openedLocalNotification];
    }
    
    if (_isJPushDidLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFNetworkDidLoginNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJPFNetworkDidCloseNotification object:nil];
    }
}
// request push notification permissions only
-(void)setupPush{
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
}


/*
 - (void)setBridge:(RCTBridge *)bridge {
 _bridge = bridge;
 [JPushActionQueue sharedInstance].openedRemoteNotification = [_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
 if ([_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
 UILocalNotification *localNotification = [_bridge.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
 [JPushActionQueue sharedInstance].openedLocalNotification = localNotification.userInfo;// null?
 }
 
 }
 */

-(void)stopPush{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

-(void)getLaunchAppNotification:(FlutterResult)callback{
    NSDictionary *notification;
    if ([JPushActionQueue sharedInstance].openedRemoteNotification != nil) {
        notification = [self jpushFormatNotification: [JPushActionQueue sharedInstance].openedRemoteNotification];
        callback(notification);
        return;
    }
    
    if ([JPushActionQueue sharedInstance].openedLocalNotification != nil) {
        notification = [self jpushFormatNotification:[JPushActionQueue sharedInstance].openedLocalNotification];
        callback(notification);
        return;
    }
    
    callback([NSNull null]);
}

-(void)getApplicationIconBadge:(FlutterResult)callback{
    callback(@([UIApplication sharedApplication].applicationIconBadgeNumber));
}

// TODO:
- (void)openNotificationToLaunchApp:(NSNotification *)notification {
    NSDictionary *obj = [notification object];
    [self.channel invokeMethod:@"openNotificationLaunchApp" arguments:[self jpushFormatNotification:obj]];
}

// TODO:
- (void)openNotification:(NSNotification *)notification {
    NSDictionary *obj = [notification object];
    [self.channel invokeMethod:@"openNotification" arguments: [self jpushFormatNotification:obj]];
}

- (NSMutableDictionary *)jpushFormatNotification:(NSDictionary *)dic {
    if (!dic) {
        return @[].mutableCopy;
    }
    if (dic.count == 0) {
        return @[].mutableCopy;
    }
    
    if (dic[@"aps"]) {
        return [self jpushFormatAPNSDic:dic];
    } else {
        return [self jpushFormatLocalNotificationDic:dic];
    }
}

- (NSMutableDictionary *)jpushFormatLocalNotificationDic:(NSDictionary *)dic {
    return [NSMutableDictionary dictionaryWithDictionary:dic];
}

- (NSMutableDictionary *)jpushFormatAPNSDic:(NSDictionary *)dic {
    NSMutableDictionary *extras = @{}.mutableCopy;
    for (NSString *key in dic) {
        if([key isEqualToString:@"_j_business"]      ||
           [key isEqualToString:@"_j_msgid"]         ||
           [key isEqualToString:@"_j_uid"]           ||
           [key isEqualToString:@"actionIdentifier"] ||
           [key isEqualToString:@"aps"]) {
            continue;
        }
        // 和 android 统一将 extras 字段移动到 extras 里面
        extras[key] = dic[key];
    }
    NSMutableDictionary *formatDic = dic.mutableCopy;
    formatDic[@"extras"] = extras;
    
    // 新增 应用状态
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateInactive:
            formatDic[@"appState"] = @"inactive";
            break;
        case UIApplicationStateActive:
            formatDic[@"appState"] = @"active";
            break;
        case UIApplicationStateBackground:
            formatDic[@"appState"] = @"background";
            break;
        default:
            break;
    }
    return formatDic;
}

- (void)networkConnecting:(NSNotification *)notification {
    _isJPushDidLogin = false;
    [self.channel invokeMethod:@"connectionChange" arguments:@(NO)];
}

- (void)networkRegister:(NSNotification *)notification {
    _isJPushDidLogin = false;
    [self.channel invokeMethod:@"connectionChange" arguments:@(NO)];
}

- (void)networkDidSetup:(NSNotification *)notification {
    _isJPushDidLogin = false;
    [self.channel invokeMethod:@"connectionChange" arguments:@(YES)];
}

- (void)networkDidClose:(NSNotification *)notification {
    _isJPushDidLogin = false;
    [self.channel invokeMethod:@"connectionChange" arguments:@(NO)];
}


- (void)networkDidLogin:(NSNotification *)notification {
    _isJPushDidLogin = YES;
    [[JPushActionQueue sharedInstance] scheduleGetRidCallbacks];
    [self.channel invokeMethod:@"networkDidLogin" arguments:[JPUSHService registrationID]];
    
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    [self.channel invokeMethod:@"receivePushMsg" arguments:[notification userInfo]];
}

- (void)receiveRemoteNotification:(NSNotification *)notification {
    
    if ([JPushActionQueue sharedInstance].isFlutterDidLoad) {
        NSDictionary *obj = [notification object];
        [self.channel invokeMethod:@"receiveNotification" arguments: [self jpushFormatNotification:obj]];
    } else {
        [[JPushActionQueue sharedInstance] postNotification:notification];
    }
}


- (void)didRegistRemoteNotification:(NSString *)token {
    [self.channel invokeMethod:@"didRegisterToken" arguments:token];
}

-(void)addEvent:(NSString *)name location:(NSString *)location callback:(FlutterResult)callback{
    callback(name);
}



///----------------------------------------------------
/// @name APNs about 通知相关
///----------------------------------------------------

/*!
 * @abstract 注册要处理的远程通知类型
 *
 * @param types 通知类型
 * @param categories
 *
 * @discussion
 */
-(void)registerForRemoteNotificationTypes:(NSUInteger)types
                               categories:(NSSet *)categories{
    [JPUSHService registerForRemoteNotificationTypes:types categories:categories];
}

-(void)registerDeviceToken:(NSData *)deviceToken{
    [JPUSHService registerDeviceToken:deviceToken];
}

/*!
 * @abstract 处理收到的 APNs 消息
 */
-(void)handleRemoteNotification:(NSDictionary *)remoteInfo{
    [JPUSHService handleRemoteNotification:remoteInfo];
}


/*!
 * 设置 tags 的方法
 */
-(void)setTags:(NSArray *)tags
      callback:(FlutterResult)callback{
    
    NSSet *tagSet;
    
    if (tags != NULL) {
        tagSet = [NSSet setWithArray:tags];
    }
    
    self.asyCallback = callback;
    [JPUSHService setTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"tags": [iTags allObjects] ?: @[],
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

/*!
 * 设置 Alias 的方法
 */
-(void)setAlias:(NSString *)alias
       callback:(FlutterResult)callback{
    
    self.asyCallback = callback;
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"alias": iAlias ?: @"",
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)addTags:(NSArray *)tags
      callback:(FlutterResult)callback{
    NSSet *tagSet;
    
    if (tags != NULL) {
        tagSet = [NSSet setWithArray:tags];
    }
    [JPUSHService addTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"tags": [iTags allObjects] ?: @[],
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)deleteTags:(NSArray *)tags
         callback:(FlutterResult)callback{
    NSSet *tagSet;
    
    if (tags != NULL) {
        tagSet = [NSSet setWithArray:tags];
    }
    [JPUSHService deleteTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"tags": [iTags allObjects] ?: @[],
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)cleanTags:(FlutterResult)callback{
    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"tags": [iTags allObjects] ?: @[],
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)getAllTags:(FlutterResult)callback{
    [JPUSHService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"tags": [iTags allObjects] ?: @[],
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)checkTagBindState:(NSString *)tag
                callback:(FlutterResult)callback{
    [JPUSHService validTag:tag completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
        if (iResCode == 0) {
            callback(@{@"isBind": @(isBind),
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)deleteAlias:(FlutterResult)callback{
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"alias": iAlias ?: @"",
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

-(void)getAlias:(FlutterResult)callback{
    [JPUSHService getAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (iResCode == 0) {
            callback(@{@"alias": iAlias ?: @"",
                         @"errorCode": @(0)
                         });
        } else {
            callback(@{@"errorCode": @(iResCode)});
        }
    } seq: 0];
}

/*!
 * @abstract 过滤掉无效的 tags
 *
 * @discussion 如果 tags 数量超过限制数量, 则返回靠前的有效的 tags.
 * 建议设置 tags 前用此接口校验. SDK 内部也会基于此接口来做过滤.
 */
-(void)filterValidTags:(NSSet *)tags callback:(FlutterResult)callback{// -> nsset
    NSArray *arr = [[JPUSHService filterValidTags:tags] allObjects];
    callback(arr);
}


///----------------------------------------------------
/// @name Stats 统计功能
///----------------------------------------------------

/*!
 * @abstract 开始记录页面停留
 *
 * @param pageName 页面名称
 */
-(void)startLogPageView:(NSString *)pageName{
    [JPUSHService startLogPageView:pageName];
}

/*!
 * @abstract 停止记录页面停留
 *
 * @param pageName 页面
 */
-(void)stopLogPageView:(NSString *)pageName{
    [JPUSHService stopLogPageView:pageName];
}

/*!
 * @abstract 直接上报在页面的停留时工
 *
 * @param pageName 页面
 * @param seconds 停留的秒数
 */
-(void)beginLogPageView:(NSString *)pageName duration:(int)seconds{
    [JPUSHService beginLogPageView:pageName duration:seconds];
}

/*!
 * @abstract 开启Crash日志收集
 *
 * @discussion 默认是关闭状态.
 */
-(void)crashLogON{
    [JPUSHService crashLogON];
}

/*!
 * @abstract 地理位置上报
 *
 * @param latitude 纬度.
 * @param longitude 经度.
 *
 */
-(void)setLatitude:(double)latitude longitude:(double)longitude{
    [JPUSHService setLatitude:latitude longitude:longitude];
}

/*!
 * @abstract 地理位置上报
 *
 * @param location 直接传递 CLLocation * 型的地理信息
 *
 * @discussion 需要链接 CoreLocation.framework 并且 #import <CoreLocation/CoreLocation.h>
 */
-(void)setLocation:(CLLocation *)location{
    [JPUSHService setLocation:location];
}


///----------------------------------------------------
/// @name Local Notification 本地通知
///----------------------------------------------------

/*!
 * @abstract 本地推送，最多支持64个
 *
 * @param fireDate 本地推送触发的时间
 * @param alertBody 本地推送需要显示的内容
 * @param badge 角标的数字。如果不需要改变角标传-1
 * @param alertAction 弹框的按钮显示的内容（IOS 8默认为"打开", 其他默认为"启动"）
 * @param notificationKey 本地推送标示符
 * @param userInfo 自定义参数，可以用来标识推送和增加附加信息
 * @param soundName 自定义通知声音，设置为nil为默认声音
 *
 * @discussion 最多支持 64 个定义
 */
-(void)setLocalNotification:(NSDate *)fireDate
                  alertBody:(NSString *)alertBody
                      badge:(int)badge
                alertAction:(NSString *)alertAction
              identifierKey:(NSString *)notificationKey
                   userInfo:(NSDictionary *)userInfo
                  soundName:(NSString *)soundName{
    
    [JPUSHService setLocalNotification:fireDate
                             alertBody:alertBody
                                 badge:badge
                           alertAction:alertAction
                         identifierKey:notificationKey
                              userInfo:userInfo
                             soundName:soundName];
}

-(void)sendLocalNotification:(NSDictionary *)params{
    
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    if (params[@"title"]) {
        content.title = params[@"title"];
    }
    
    if (params[@"subtitle"]) {
        content.subtitle = params[@"subtitle"];
    }
    
    if (params[@"content"]) {
        content.body = params[@"content"];
    }
    
    if (params[@"badge"]) {
        content.badge = params[@"badge"];
    }
    
    if (params[@"action"]) {
        content.action = params[@"action"];
    }
    
    if (params[@"extra"]) {
        content.userInfo = params[@"extra"];
    }
    
    if (params[@"sound"]) {
        content.sound = params[@"sound"];
    }
    
    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        if (params[@"fireTime"]) {
            NSNumber *date = params[@"fireTime"];
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = [date doubleValue]/1000 - currentInterval;
            interval = interval>0?interval:0;
            trigger.timeInterval = interval;
        }
    }
    
    else {
        if (params[@"fireTime"]) {
            NSNumber *date = params[@"fireTime"];
            trigger.fireDate = [NSDate dateWithTimeIntervalSince1970: [date doubleValue]/1000];
        }
    }
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    request.content = content;
    request.trigger = trigger;
    
    if (params[@"id"]) {
        NSNumber *identify = params[@"id"];
        request.requestIdentifier = [identify stringValue];
    }
    request.completionHandler = ^(id result) {
        NSLog(@"result");
    };
    
    [JPUSHService addNotification:request];
    
    
    
}

/*!
 * @abstract 前台展示本地推送
 *
 * @param notification 本地推送对象
 * @param notificationKey 需要前台显示的本地推送通知的标示符
 *
 * @discussion 默认App在前台运行时不会进行弹窗，在程序接收通知调用此接口可实现指定的推送弹窗。
 */
-(void)showLocalNotificationAtFront:(UILocalNotification *)notification
                      identifierKey:(NSString *)notificationKey{
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:notificationKey];
}
/*!
 * @abstract 删除本地推送定义
 *
 * @param notificationKey 本地推送标示符
 * @param myUILocalNotification 本地推送对象
 */
-(void)deleteLocalNotificationWithIdentifierKey:(NSString *)notificationKey{
    [JPUSHService deleteLocalNotificationWithIdentifierKey:notificationKey];
}

/*!
 * @abstract 删除本地推送定义
 */
-(void)deleteLocalNotification:(UILocalNotification *)localNotification{
    [JPUSHService deleteLocalNotification:localNotification];
}

/*!
 * @abstract 获取指定通知
 *
 * @param notificationKey 本地推送标示符
 * @return 本地推送对象数组, [array count]为0时表示没找到
 */
-(void)findLocalNotificationWithIdentifier:(NSString *)notificationKey callback:(FlutterResult)callback{// nsarray
    callback([JPUSHService findLocalNotificationWithIdentifier:notificationKey]);
}

/*!
 * @abstract 清除所有本地推送对象
 */
-(void)clearAllLocalNotifications{
    [JPUSHService clearAllLocalNotifications];
}


///----------------------------------------------------
/// @name Server badge 服务器端 badge 功能
///----------------------------------------------------

/*!
 * @abstract 设置角标(到服务器)
 *
 * @param value 新的值. 会覆盖服务器上保存的值(这个用户)
 *
 * @discussion 本接口不会改变应用本地的角标值.
 * 本地仍须调用 UIApplication:setApplicationIconBadgeNumber 函数来设置脚标.
 *
 * 本接口用于配合 JPush 提供的服务器端角标功能.
 * 该功能解决的问题是, 服务器端推送 APNs 时, 并不知道客户端原来已经存在的角标是多少, 指定一个固定的数字不太合理.
 *
 * JPush 服务器端脚标功能提供:
 *
 * - 通过本 API 把当前客户端(当前这个用户的) 的实际 badge 设置到服务器端保存起来;
 * - 调用服务器端 API 发 APNs 时(通常这个调用是批量针对大量用户),
 *   使用 "+1" 的语义, 来表达需要基于目标用户实际的 badge 值(保存的) +1 来下发通知时带上新的 badge 值;
 */
-(void)setBadge:(NSInteger)value callback:(FlutterResult)callback{// ->Bool
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
    NSNumber *badgeNumber = [NSNumber numberWithBool:[JPUSHService setBadge: value]];
    callback(badgeNumber);
}

/*!
 * @abstract 重置脚标(为0)
 *
 * @discussion 相当于 [setBadge:0] 的效果.
 * 参考 [JPUSHService setBadge:] 说明来理解其作用.
 */
-(void)resetBadge{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [JPUSHService resetBadge];
}


///----------------------------------------------------
/// @name Logs and others 日志与其他
///----------------------------------------------------

/*!
 * @abstract JPush标识此设备的 registrationID
 *
 * @discussion SDK注册成功后, 调用此接口获取到 registrationID 才能够获取到.
 *
 * JPush 支持根据 registrationID 来进行推送.
 * 如果你需要此功能, 应该通过此接口获取到 registrationID 后, 上报到你自己的服务器端, 并保存下来.
 *
 * 更多的理解请参考 JPush 的文档网站.
 */
-(void)getRegistrationID:(FlutterResult)callback{// -> string
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSLog(@"simulator can not get registrationid");
    callback(@"");
#elif TARGET_OS_IPHONE//真机
    if (_isJPushDidLogin) {
        callback([JPUSHService registrationID]);
    } else {
        [[JPushActionQueue sharedInstance] postGetRidCallback:callback];
    }
#endif
}

/*!
 * @abstract 打开日志级别到 Debug
 *
 * @discussion JMessage iOS 的日志系统参考 Android 设计了级别.
 * 从低到高是: Verbose, Debug, Info, Warning, Error.
 * 对日志级别的进一步理解, 请参考 Android 相关的说明.
 *
 * SDK 默认开启的日志级别为: Info. 只显示必要的信息, 不打印调试日志.
 *
 * 调用本接口可打开日志级别为: Debug, 打印调试日志.
 */
-(void)setDebugMode{
    [JPUSHService setDebugMode];
}

/*!
 * @abstract 关闭日志
 *
 * @discussion 关于日志级别的说明, 参考 [JPUSHService setDebugMode]
 *
 * 虽说是关闭日志, 但还是会打印 Warning, Error 日志. 这二种日志级别, 在程序运行正常时, 不应有打印输出.
 *
 * 建议在发布的版本里, 调用此接口, 关闭掉日志打印.
 */
-(void)setLogOFF{
    [JPUSHService setLogOFF];
}

-(void)clearAllNotifications{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        [UNUserNotificationCenter.currentNotificationCenter removeAllPendingNotificationRequests];
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

-(void)clearNotificationById:(NSInteger)identify{
    JPushNotificationIdentifier *pushIdentify = [[JPushNotificationIdentifier alloc] init];
    pushIdentify.identifiers = @[[@(identify) description]];
    [JPUSHService removeNotification: pushIdentify];
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    [JPUSHService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:userInfo];
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [JPUSHService handleRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFOpenNotification object:userInfo];
    completionHandler();
}
@end



@implementation FlutterAppDelegate(JPush)
-(void)startupJPush:(NSDictionary*)launchOptions appKey:(NSString*)appKey channel:(NSString*)channel isProduction:(BOOL)isProduction{
    [[FlutterJPushPlugin sharedInstance]startup:launchOptions
                                         appKey:appKey channel:channel isProduction:isProduction];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}



- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   // NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}


- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)(void))completionHandler {
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)(void))completionHandler {
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}



@end


