//
//  JPushActionQueue.h
//  RCTJPushModule
//
//  Created by oshumini on 2016/12/19.
//  Copyright © 2016年 HXHG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#define kJPFDidReceiveRemoteNotification  @"kJPFDidReceiveRemoteNotification"

#define kJPFOpenNotification @"kJPFOpenNotification" // 通过点击通知事件
#define kJPFOpenNotificationToLaunchApp @"kJPFOpenNotificationToLaunchApp" // 通过点击通知启动应用

@interface JPushActionQueue : NSObject

@property BOOL isFlutterDidLoad;
@property NSDictionary* openedRemoteNotification;
@property NSDictionary* openedLocalNotification;
@property(strong,nonatomic)NSMutableArray<FlutterResult>* getRidCallbackArr;

+ (nonnull instancetype)sharedInstance;

- (void)postNotification:(NSNotification *)notification;
- (void)scheduleNotificationQueue;

- (void)postGetRidCallback:(FlutterResult) getRidCallback;
- (void)scheduleGetRidCallbacks;
@end
