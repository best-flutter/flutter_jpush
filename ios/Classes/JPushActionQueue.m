//
//  JPushActionQueue.m
//  RCTJPushModule
//
//  Created by oshumini on 2016/12/19.
//  Copyright © 2016年 HXHG. All rights reserved.
//

#import "JPushActionQueue.h"
#import "JPUSHService.h"

@interface JPushActionQueue () {
  NSMutableArray<NSDictionary *>* _notificationQueue;
  FlutterResult getRidCallback;
}

@end

@implementation JPushActionQueue

+ (nonnull instancetype)sharedInstance {
  static JPushActionQueue* sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self new];
  });
  
  return sharedInstance;
}


- (instancetype)init
{
  self = [super init];
  if (self) {
    self.isFlutterDidLoad = NO;
    _notificationQueue = [NSMutableArray new];
    self.getRidCallbackArr = [NSMutableArray new];
  }
  
  return self;
}

- (void)postNotification:(NSNotification *)notification {
  if (!_notificationQueue) return;
    id obj = [notification object];
    [_notificationQueue insertObject:obj atIndex:0];
}

- (void)scheduleNotificationQueue {
  for (NSDictionary *notification in _notificationQueue) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kJPFDidReceiveRemoteNotification object:notification];
  }
  [_notificationQueue removeAllObjects];
}

- (void)postGetRidCallback:(FlutterResult) getRidCallback {
  if (!self.getRidCallbackArr) return;
  [self.getRidCallbackArr addObject:getRidCallback];
}

- (void)scheduleGetRidCallbacks {
  if (self.getRidCallbackArr.count == 0) return;
  for (FlutterResult callback in self.getRidCallbackArr) {
    callback(@[[JPUSHService registrationID]]);
  }
  [self.getRidCallbackArr removeAllObjects];
  
}

@end
