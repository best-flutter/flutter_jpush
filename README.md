<p align="center">
    <a href="https://pub.flutter-io.cn/packages/flutter_jpush">
        <img src="https://img.shields.io/pub/v/flutter_jpush.svg" alt="pub package" />
    </a>
</p>


# flutter_jpush

Flutter 版本 jpush（极光推送），经过热心网友帮助，终于开发完成，目前功能比较稳定，已经上到pub。



## ROADMAP

* [x] ios
* [x] android
* [x] 集成notification
* [x] 集成message
* [x] 集成alias
* [x] 集成tags
* [ ] 后台接口放出服务
* [x] 可以运行的例子
* [x] 用户可相互自行推送


## 集成过程

### 准备工作

#### 申请key

## 申请key

进入[这里](https://www.jiguang.cn/dev/#/app/create)申请key

#### ios 证书申请

>不熟悉怎么申请戳[这里](https://www.jianshu.com/p/ae11b893284b)

### ios 集成


### android 集成



## API调用



### 1、启动

注意启动需要修改一下原生项目，这个官方也没有比较好的解决方案，所以必须做。

ios 修改 AppDelegate.m
```
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 [[FlutterJPushPlugin sharedInstance]startup:launchOptions appKey:@"你的key" channel:@"你的渠道" 
    isProduction:  是不是生产版本];
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

/// 注意底下的代码和ios的application生命周期有关。
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}


- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
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


```

android:
无须修改原生项目

dart:

在程序入口处做一下调用

```
void _startupJpush() async {
    print("初始化jpush");
    await FlutterJPush.startup();
    print("初始化jpush成功");
  }
```

### 2、获取设备唯一号

jpush在启动的时候会去连接自己的服务器，连接并注册成功之后会返回一个唯一的设备号(registrationId),

有两种方法可以得到


设置一个监听
```

FlutterJPush.addnetworkDidLoginListener((String registrationId) {
      setState(() {
        /// 用于推送
        print("收到设备号:$registrationId");
        this.registrationId = registrationId;
      });
    });

```

或者主动去取

```
FlutterJPush.getRegistrationID()
```

主动去取有可能取出来是空的



### 3、设置tag


每一个设备可以对应多个tag

```

/// 设置tags
 FlutterJPush.setTags( ["tag1","tag2" );
 
/// 新增tag
 JPushResult result = await FlutterJPush.addTags(["tag1","tag2"]);

/// 获取所有tag
  FlutterJPush.getAllTags();

```

### 4、设置和获取alias


alias为别名，别名一般来说是惟一的。

```

/// 获取别名
FlutterJPush.getAlias().then((JPushResult result) {
      if (result.isOk) {
        setState(() {
          if (mounted) _text = r.result;
        });
      }
    });

/// 设置别名

 JPushResult result = await FlutterJPush.getAlias();
if (result.isOk) {
    //设置成功
}
            


```


### 5、收到通知提醒


要处理两个监听，一个是收到了通知提醒，并出现在状态栏上面；一个是用户点击了状态栏上面的提醒，打开通知。

```
  FlutterJPush
        .addReceiveNotificationListener((JPushNotification notification) {
      setState(() {
        /// 收到推送
        print("收到推送提醒: $notification");
        notificationList.add(notification);
      });
    });

    FlutterJPush
        .addReceiveOpenNotificationListener((JPushNotification notification) {
      setState(() {
        print("打开了推送提醒: $notification");

        /// 打开了推送提醒
        notificationList.add(notification);
      });
    });

```


### 6、收到自定义消息

消息是服务端发送的一段代码,一般是json格式，app在收到消息之后，一般不直接做前台通知。

设置收到自定义消息的监听


```

    FlutterJPush.addReceiveCustomMsgListener((JPushMessage msg) {
      setState(() {
        print("收到推送消息提醒: $msg");

        /// 打开了推送提醒
        notificationList.add(msg);
      });
    });

```


## 还有疑问的话可以发issue或者加qq群854192563交流








