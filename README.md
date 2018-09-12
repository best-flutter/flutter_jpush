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
* [ ] 用户可相互自行推送




# 准备工作

## 申请key

进入[这里](https://www.jiguang.cn/dev/#/app/create)申请key

## ios 证书申请

>不熟悉怎么申请戳[这里](https://www.jianshu.com/p/ae11b893284b)


# 集成


## ios 集成

ios 修改 AppDelegate.m,新版本一行代码就可以集成了
```
增加
#include "FlutterJPushPlugin.h"

增加
 [self startupJPush:launchOptions appKey:@"你的key" channel:@"你的渠道" isProduction:是否生产版本];

```

全部的AppDelegate.m如下:

```
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "FlutterJPushPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   [self startupJPush:launchOptions appKey:@"你的key" channel:@"你的渠道" isProduction:是否生产版本];
    [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


@end

```

## android 集成

修改 `你的项目目录/android/app/build.gradle`

在`android/defaultConfig`节点修改`manifestPlaceholders`,新增极光推送key配置

```
android {
    .... 你的代码

    defaultConfig {
        .....
        manifestPlaceholders = [
               JPUSH_PKGNAME : applicationId,
               JPUSH_APPKEY : "你的极光推送key", //JPush上注册的包名对应的appkey.
               JPUSH_CHANNEL : "你的推送渠道，如果不知道填写developer-default即可",
        ]

    }

```


# API调用

### 1、启动


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
await FlutterJPush.getRegistrationID()
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

## 目前这个版本还存在编译问题，flutter官方也在积极解决
真机运行报错couldn't find "libflutter.so"

暂时的解决方法有：

build.gradle设置

```
ndk{
     abiFilters 'armeabi', 'armeabi-v7a'//, 'arm64-v8a'
}
```

或者可以增加编译选项：

```
--target-platform android-arm64 或者 --target-platform android-arm
```


## 还有疑问的话可以发issue或者加qq群854192563交流








