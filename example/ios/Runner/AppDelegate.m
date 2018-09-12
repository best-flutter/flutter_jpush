#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "FlutterJPushPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self startupJPush:launchOptions appKey:@"2e8ee4e12160f1d3501bce0c" channel:@"jpush" isProduction:FALSE];
    [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


@end
