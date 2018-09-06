import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:flutter_jpush_example/alias_test.dart';
import 'package:flutter_jpush_example/info_test.dart';
import 'package:flutter_jpush_example/push_test.dart';
import 'package:flutter_jpush_example/tag_test.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = false;
  String registrationId;
  List notificationList = [];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startupJpush();

    FlutterJPush.addConnectionChangeListener((bool connected) {
      setState(() {
        /// 是否连接，连接了才可以推送
        print("连接状态改变:$connected");
        this.isConnected = connected;
        if (connected) {
          FlutterJPush.getRegistrationID().then((String regId) {
            print("主动获取设备号:$regId");
            setState(() {
              this.registrationId = regId;
            });
          });
        }
      });
    });

    FlutterJPush.addnetworkDidLoginListener((String registrationId) {
      setState(() {
        /// 用于推送
        print("收到设备号:$registrationId");
        this.registrationId = registrationId;
      });
    });

    FlutterJPush.addReceiveNotificationListener(
        (JPushNotification notification) {
      setState(() {
        /// 收到推送
        print("收到推送提醒: $notification");
        notificationList.add(notification);
      });
    });

    FlutterJPush.addReceiveOpenNotificationListener(
        (JPushNotification notification) {
      setState(() {
        print("打开了推送提醒: $notification");

        /// 打开了推送提醒
        notificationList.add(notification);
      });
    });

    FlutterJPush.addReceiveCustomMsgListener((JPushMessage msg) {
      setState(() {
        print("收到推送消息提醒: $msg");

        /// 打开了推送提醒
        notificationList.add(msg);
      });
    });
  }

  void _startupJpush() async {
    print("初始化jpush");
    await FlutterJPush.startup();
    print("初始化jpush成功");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('JPush Example'),
        ),
        body: new IndexedStack(
          children: <Widget>[
            new Info(
              notificationList: notificationList,
              registrationId: registrationId,
              isConnected: isConnected,
            ),
            new TagSet(),
            new AliasSet(),
            new PushTest()
          ],
          index: _index,
        ),
        bottomNavigationBar: new BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
                title: new Text("Info"), icon: new Icon(Icons.info)),
            new BottomNavigationBarItem(
                title: new Text("Tag"), icon: new Icon(Icons.tag_faces)),
            new BottomNavigationBarItem(
                title: new Text("Alias"), icon: new Icon(Icons.nature)),
          ],
          onTap: (int index) {
            setState(() {
              _index = index;
            });
          },
          currentIndex: _index,
        ),
      ),
    );
  }
}
