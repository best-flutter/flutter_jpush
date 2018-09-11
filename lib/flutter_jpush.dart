import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

enum AppState { inactive, active, background }

/// 自定义消息，一般不会在系统消息栏出现
class JPushMessage {
  // 消息主体 msg_content
  final String message;

  // content_type
  final String contentType;

  /// title
  final String title;

  /// extras
  final Map extras;

  JPushMessage({this.message, this.contentType, this.title, this.extras});

  @override
  String toString() {
    return "PushMessage:{title:$title, message:$message, contentType:$contentType, extras:$extras}";
  }
}

class JPushNotification {
  JPushNotification(
      {this.alertType,
      this.buildId,
      this.id,
      this.title,
      this.badge,
      this.content,
      this.extras,
      this.fireTime,
      this.sound,
      this.appState,
      this.fromOpen: false,
      this.subtitle});

  factory JPushNotification.fromMap(dynamic dic, bool fromOpen) {
    print("Enter new ");
    try {
      if (Platform.isIOS) {
        dynamic aps = dic['aps'];
        String appState = dic['appState'];
        AppState state;
        switch (appState) {
          case 'inactive':
            state = AppState.inactive;
            break;
          case 'active':
            state = AppState.active;
            break;
          case 'background':
            state = AppState.background;
            break;
        }
        dynamic alert = aps['alert'];
        String content;
        String title;
        String subtitle;
        if (alert is String) {
          content = alert;
        } else {
          title = alert['title'];
          content = alert['body'];
          subtitle = alert['subtitle'];
        }

        return new JPushNotification(
            title: title,
            badge: aps['badge'] as int,
            content: content,
            sound: aps['sound'],
            extras: dic['extras'],
            subtitle: subtitle,
            appState: state,
            id: dic['_j_msgid'],
            fromOpen: fromOpen,
            fireTime: new DateTime.now());
      } else {
        String content = dic['alertContent'];

        return new JPushNotification(
          title: dic['title'], //推送标题
          alertType: int.parse(dic['alerType']), //此字段应为alerType
          content: content,
          extras: dic['extras'], //附加字段
          id: dic['id'] as int,
          fromOpen: fromOpen,
          fireTime: new DateTime.now(),
        );
      }
    } catch (e) {
      print(e);

      return new JPushNotification();
    }
  }

  /// android only
  final int alertType;

  /// 是否是打开了提醒,还是直接受到的提醒
  final bool fromOpen;

  final AppState appState;

  final String subtitle;

  /// 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式
  /// Android Only
  final int buildId;

  ///  通知 id,
  final int id;

  //通知标题
  final String title;

  //通知内容
  final String content;

  //
  final dynamic extras;

  //通知触发时间(毫秒)
  final DateTime fireTime;

  //本地推送触发后应用角标值
  //iOS Only
  final int badge;

  /// ios Only sound
  final String sound;
}

class JPushAndroidInfo {
  //TO DO
}

class JPushResult {
  //出了code以外的其他数据,当code=0的时候有效
  final dynamic result;
  //code = 0 正确
  final int code;

  JPushResult({this.code, this.result});

  bool get isOk => code == 0;
}

class FlutterJPush {
  static const MethodChannel _channel = const MethodChannel('flutter_jpush');

  static bool isConnected = false;
  static String registrationID;

  static Future<dynamic> startup() async {
    _channel.setMethodCallHandler(_handler);
    return await _channel.invokeMethod("startup");
  }

  static Future<dynamic> _handler(MethodCall call) {
    //print("handle mehtod call ${call.method} ${call.arguments}");
    String method = call.method;
    switch (method) {
      case 'connectionChange':
        {
          isConnected = call.arguments;
          _connectionChangeListener.add(isConnected);
        }
        break;
      case 'networkDidLogin':
        {
          String regId = call.arguments;
          _networkDidLoginListenerListener.add(regId);
        }
        break;
      case 'receivePushMsg':
        {
          var map = call.arguments;
          var extras = map['extras'];
          if (extras != null) {
            try {
              if (extras is String) {
                extras = json.decode(extras);
              }
            } catch (e) {}
          }
          _recvCustomMsgController.add(new JPushMessage(
              title: map['title'],
              message: map['message'] ?? map['content'],
              contentType: map['contentType'] ?? map['content_type'],
              extras: extras));
        }
        break;
      case 'openNotification':
        {
          dynamic dic = call.arguments;
          _recvOpenNotificationListener
              .add(new JPushNotification.fromMap(dic, true));
        }
        break;
      case 'receiveNotification':
        {
          dynamic dic = call.arguments;
          _recvNotificationListener
              .add(new JPushNotification.fromMap(dic, false));
        }
        break;
    }
    return new Future.value(null);
  }

  /// 初始化JPush 必须先初始化才能执行其他操作
  static Future<void> initPush() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("initPush");
    } else {
      FlutterJPush.setupPush();
    }
  }

  /**
   * iOS Only
   * 初始化 Jpush SDK 代码,
   */
  static Future<void> setupPush() async {
    await _channel.invokeMethod("setupPush");
  }

  /// 停止推送，调用该方法后将不再受到推送
  static Future<void> stopPush() async {
    await _channel.invokeMethod("stopPush");
  }

  /// 恢复推送功能，停止推送后，可调用该方法重新获得推送能力
  static Future<void> resumePush() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("resumePush");
    } else {
      FlutterJPush.setupPush();
    }
  }

  /**
   * Android Only
   */
  static Future<void> crashLogOFF() async {
    await _channel.invokeMethod("crashLogOFF");
  }

  /**
   * Android Only
   */
  static Future<void> crashLogON() async {
    await _channel.invokeMethod("crashLogON");
  }

  /**
   * Android Only
   *
   * @param {Function} cb
   */
  static Future<void> notifyJSDidLoad() async {
    await _channel.invokeMethod("notifyJSDidLoad");
  }

  /**
   * 清除通知栏的所有通知
   */
  static Future<void> clearAllNotifications() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("clearAllNotifications");
    } else {
      await FlutterJPush.setBadge(0);
    }
  }

  /**
   * Android Only
   */
  static Future<void> clearNotificationById(int id) async {
    await _channel.invokeMethod("clearNotificationById", id);
  }

  /**
   * Android Only
   */
  static Future<JPushAndroidInfo> getInfo() async {
    Map map = await _channel.invokeMethod("getInfo");
    return new JPushAndroidInfo();
  }

  /**
   * 获取当前连接状态
   * 如果连接状态变更为已连接返回 true
   * 如果连接状态变更为断开连接连接返回 false
   */
  static Future<bool> getConnectionState() async {
    return await _channel.invokeMethod("getConnectionState");
  }

  ///重新设置 Tag
  static Future<JPushResult> setTags(List<String> tags) async {
    var raw = await _channel.invokeMethod("setTags", tags);
    return new JPushResult(code: raw["errorCode"], result: raw['tags']);
  }

  ///在原有 tags 的基础上添加 tags
  static Future<JPushResult> addTags(List<String> tags) async {
    var raw = await _channel.invokeMethod("addTags", tags);
    return new JPushResult(code: raw["errorCode"], result: raw['tags']);
  }

  /**
   * 删除指定的 tags
   *
   * @param {Array} tags = [String]
   * 如果成功 result = {tags: [String]}
   * 如果失败 result = {errorCode: Int}
   *
   */
  static Future<JPushResult> deleteTags(List<String> tags) async {
    dynamic raw = await _channel.invokeMethod("deleteTags", tags);
    return new JPushResult(code: raw["errorCode"], result: raw['tags']);
  }

  /**
   * 清空所有 tags
   *
   * 如果成功 result = {tags: [String]}
   * 如果失败 result = {errorCode: Int}
   *
   */
  static Future<JPushResult> cleanTags() async {
    var data = await _channel.invokeMethod("cleanTags");
    return new JPushResult(
        code: data['errorCode'] as int, result: data['tags']);
  }

  /// 获取标签
  static Future<JPushResult> getAllTags() async {
    var data = await _channel.invokeMethod("getAllTags");
    return new JPushResult(
        code: data['errorCode'] as int, result: data['tags']);
  }

  /// 检查当前设备是否绑定该 tag
  static Future<JPushResult> checkTagBindState(String tag) async {
    var data = await _channel.invokeMethod("checkTagBindState", tag);
    return new JPushResult(
        code: data['errorCode'] as int,
        result: {"tag": data['tag'], "bindState": data['bindState']});
  }

  /// 设置别名
  static Future<JPushResult> setAlias(String alias) async {
    var data = await _channel.invokeMethod("setAlias", alias);
    return new JPushResult(
        code: data['errorCode'] as int, result: data['alias']);
  }

  /// 删除别名
  static Future<JPushResult> deleteAlias() async {
    var data = await _channel.invokeMethod("deleteAlias");
    return new JPushResult(
        code: data['errorCode'] as int, result: data['alias']);
  }

  /// 获取别名
  static Future<JPushResult> getAlias() async {
    var data = await _channel.invokeMethod("getAlias");
    return new JPushResult(
        code: data['errorCode'] as int, result: data['alias']);
  }

  /**
   * Android Only
   */
  static Future<void> setStyleBasic() async {
    await _channel.invokeMethod("setStyleBasic");
  }

  /**
   * Android Only
   */
  static Future<void> setStyleCustom() async {
    await _channel.invokeMethod("setStyleCustom");
  }

  /**
   * Android Only
   */
  static Future<void> setLatestNotificationNumber(int maxNumber) async {
    await _channel.invokeMethod("setLatestNotificationNumber", maxNumber);
  }

  /**
   * Android Only
   * @param {object} config = {"startTime": String, "endTime": String}  // 例如：{startTime: "20:30", endTime: "8:30"}
   */
  static Future<void> setSilenceTime(config) async {
    await _channel.invokeMethod("setSilenceTime", config);
  }

  /**
   * Android Only
   * @param {object} config = {"days": Array, "startHour": Number, "endHour": Number}
   * // 例如：{days: [0, 6], startHour: 8, endHour: 23} 表示星期天和星期六的上午 8 点到晚上 11 点都可以推送
   */
  static Future<void> setPushTime(config) async {
    await _channel.invokeMethod("setPushTime", config);
  }

  /**
   * Android Only
   */
  static Future<void> jumpToPushActivity(String activityName) async {
    await _channel.invokeMethod("jumpToPushActivity", activityName);
  }

  /**
   * Android Only
   */
  static Future<void> jumpToPushActivityWithParams(
      String activityName, Map<String, dynamic> map) async {
    await _channel.invokeMethod("jumpToPushActivityWithParams",
        {"activityName": activityName, map: map});
  }

  /**
   * Android Only
   */
  static Future<void> finishActivity() async {
    await _channel.invokeMethod("finishActivity");
  }

  static Map<Function, StreamSubscription> listeners = {};

  /**
   * 监听：自定义消息后事件
   */
  static void addReceiveCustomMsgListener(void onData(JPushMessage data)) {
    listeners[onData] = _recvCustomMsgController.stream.listen(onData);
  }

  /**
   * 取消监听：自定义消息后事件
   */
  static void removeReceiveCustomMsgListener(void onData(Map data)) {
    removeListener(onData);
  }

  static void removeListener(void onData(dynamic data)) {
    StreamSubscription listener = listeners[onData];
    if (listener == null) return;
    listener.cancel();
    listeners.remove(onData);
  }

  /**
   * iOS Only
   * 点击推送启动应用的时候原生会将该 notification 缓存起来，该方法用于获取缓存 notification
   * 注意：notification 可能是 remoteNotification 和 localNotification，两种推送字段不一样。
   * 如果不是通过点击推送启动应用，比如点击应用 icon 直接启动应用，notification 会返回 undefine。
   * @param {Function} cb = (notification) => {}
   */
  static getLaunchAppNotification() async {
    await _channel.invokeMethod("getLaunchAppNotification");
  }

  /**
   * @deprecated Since version 2.2.0, will deleted in 3.0.0.
   * iOS Only
   * 监听：应用没有启动的状态点击推送打开应用
   * 注意：2.2.0 版本开始，提供了 getLaunchAppNotification
   *
   * @param {Function} cb = (notification) => {}
   */
  static void addOpenNotificationLaunchAppListener(
      void onData(String registrationId)) {
    listeners[onData] =
        _openNotificationLaunchAppListener.stream.listen(onData);
  }

  /**
   * @deprecated Since version 2.2.0, will deleted in 3.0.0.
   * iOS Only
   * 取消监听：应用没有启动的状态点击推送打开应用
   */
  static removeOpenNotificationLaunchAppEventListener(
      void onData(String registrationId)) {
    removeListener(onData);
  }

  /**
   * iOS Only
   *
   * 监听：应用连接已登录
   */
  static void addnetworkDidLoginListener(void onData(String registrationId)) {
    listeners[onData] = _networkDidLoginListenerListener.stream.listen(onData);
  }

  /**
   * iOS Only
   *
   * 取消监听：应用连接已登录
   */
  static void removenetworkDidLoginListener(
      void onData(String registrationId)) {
    removeListener(onData);
  }

  static StreamController<JPushMessage> _recvCustomMsgController =
      new StreamController.broadcast();
  static StreamController<String> _openNotificationLaunchAppListener =
      new StreamController.broadcast();
  static StreamController<String> _networkDidLoginListenerListener =
      new StreamController.broadcast();
  static StreamController<JPushNotification> _recvNotificationListener =
      new StreamController.broadcast();
  static StreamController<JPushNotification> _recvOpenNotificationListener =
      new StreamController.broadcast();
  static StreamController<String> _getRegistrationIdListener =
      new StreamController.broadcast();
  static StreamController<bool> _connectionChangeListener =
      new StreamController.broadcast();
  static StreamController<Map> _receiveExtrasListener =
      new StreamController.broadcast();

  /**
   * 监听：接收推送事件
   */
  static void addReceiveNotificationListener(
      void onData(JPushNotification notification)) {
    listeners[onData] = _recvNotificationListener.stream.listen(onData);
  }

  /**
   * 取消监听：接收推送事件
   */
  static void removeReceiveNotificationListener(
      void onData(JPushNotification notification)) {
    removeListener(onData);
  }

  /**
   * 监听：点击推送事件
   */
  static void addReceiveOpenNotificationListener(
      void onData(JPushNotification notification)) {
    listeners[onData] = _recvOpenNotificationListener.stream.listen(onData);
  }

  /**
   * 取消监听：点击推送事件
   */
  static void removeReceiveOpenNotificationListener(
      void onData(JPushNotification notification)) {
    removeListener(onData);
  }

  /**
   * Android Only
   *
   * If device register succeed, the server will return registrationId
   */
  static void addGetRegistrationIdListener(void onData(String registrationId)) {
    listeners[onData] = _getRegistrationIdListener.stream.listen(onData);
  }

  /**
   * Android Only
   */
  static void removeGetRegistrationIdListener(
      void onData(String registrationId)) {
    removeListener(onData);
  }

  /**
   * 监听：连接状态变更
   * 如果连接状态变更为已连接返回 true
   * 如果连接状态变更为断开连接连接返回 false
   */
  static void addConnectionChangeListener(void onData(bool state)) {
    listeners[onData] = _connectionChangeListener.stream.listen(onData);
  }

  /**
   * 监听：连接状态变更
   * 如果连接状态变更为已连接返回 true
   * 如果连接状态变更为断开连接连接返回 false
   */
  static removeConnectionChangeListener(void onData(bool state)) {
    removeListener(onData);
  }

  /**
   * 监听：收到 Native 下发的 extra 事件
   * 返回 Object，属性和值在 Native 定义
   */
  static addReceiveExtrasListener(void onData(Map extra)) {
    listeners[onData] = _receiveExtrasListener.stream.listen(onData);
  }

  static removeReceiveExtrasListener(void onData(Map extra)) {
    removeListener(onData);
  }

  /**
   * 获取 RegistrationId
   */
  static Future<String> getRegistrationID() async {
    return await _channel.invokeMethod("getRegistrationID");
  }

  /**
   * iOS Only
   */
  static Future<String> getAppkeyWithcallback() async {
    return await _channel.invokeMethod("getAppkeyWithcallback");
  }

  /**
   * iOS Only
   */
  static Future<int> getBadge() async {
    return await _channel.invokeMethod("getApplicationIconBadge");
  }

  /**
   * iOS Only
   * 设置本地推送
   * @param {Number} date  触发本地推送的时间的时间戳(毫秒)
   * @param {String} textContain 推送消息体内容
   * @param {Int} badge  本地推送触发后 应用 Badge（小红点）显示的数字
   * @param {String} alertAction 弹框的按钮显示的内容（IOS 8默认为"打开", 其他默认为"启动"）
   * @param {String} notificationKey  本地推送标示符
   * @param {Object} userInfo 推送的附加字段 选填
   * @param {String} soundName 自定义通知声音，设置为 null 为默认声音
   */
  static Future<void> setLocalNotification(
      {double date,
      String textContain,
      int badge,
      String alertAction,
      String notificationKey,
      dynamic userInfo,
      String soundName}) async {
    await _channel.invokeMethod("setLocalNotification", {
      "date": date,
      "textContain": textContain,
      "badge": badge,
      "alertAction": alertAction,
      "notificationKey": notificationKey,
      "userInfo": userInfo,
      "soundName": soundName
    });
  }

  /**
   * @typedef Notification
   * @type {object}
   * // Android Only
   * @property {number} [buildId] - 通知样式：1 为基础样式，2 为自定义样式（需先调用 `setStyleCustom` 设置自定义样式）
   * @property {number} [id] - 通知 id, 可用于取消通知
   * @property {string} [title] - 通知标题
   * @property {string} [content] - 通知内容
   * @property {object} [extra] - extra 字段
   * @property {number} [fireTime] - 通知触发时间（毫秒）
   * // iOS Only
   * @property {number} [badge] - 本地推送触发后应用角标值
   * // iOS Only
   * @property {string} [soundName] - 指定推送的音频文件
   * // iOS 10+ Only
   * @property {string} [subtitle] - 子标题
   */

  /**
   * @param {Notification} notification
   */
  static Future<void> sendLocalNotification(
      JPushNotification notification) async {
    await _channel.invokeMethod("sendLocalNotification", notification);
  }

  /**
   * iOS Only
   * 设置应用 Badge（小红点）
   * @param {Int} badge
   */
  static Future<void> setBadge(int badge) async {
    await _channel.invokeMethod("setBadge", badge);
  }
}
