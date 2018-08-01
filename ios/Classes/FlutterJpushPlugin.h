#import <Flutter/Flutter.h>

@interface FlutterJpushPlugin : NSObject<FlutterPlugin>

@property(strong,nonatomic)FlutterResult asyCallback;

- (void)didRegistRemoteNotification:(NSString *)token;

-(void)startup:(NSDictionary*)launchOptions appKey:(NSString*)appKey channel:(NSString*)channel isProduction:(BOOL)isProduction;

+(FlutterJpushPlugin*)sharedInstance;
@end
