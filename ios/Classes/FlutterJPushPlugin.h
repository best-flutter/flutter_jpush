#import <Flutter/Flutter.h>

@interface FlutterJPushPlugin : NSObject<FlutterPlugin>

@property(strong,nonatomic)FlutterResult asyCallback;

- (void)didRegistRemoteNotification:(NSString *)token;

-(void)startup:(NSDictionary*)launchOptions appKey:(NSString*)appKey channel:(NSString*)channel isProduction:(BOOL)isProduction;

+(FlutterJPushPlugin*)sharedInstance;
@end
