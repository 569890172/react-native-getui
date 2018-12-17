/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#define kGtAppId           @""
#define kGtAppKey          @""
#define kGtAppSecret       @""

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
  [self registerRemoteNotification];
  NSURL *jsCodeLocation;
  #ifdef DEBUG
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  #else
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  #endif

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"pushDemoWithFramework"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

// 注册APNs
- (void)registerRemoteNotification {
  float systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
  if (systemVersion >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError * _Nullable error) {
      if (!error) {
        NSLog(@"通知权限请求成功！");
      } else {
        NSLog(@"通知权限请求失败！");
      }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#else
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
  } else if (systemVersion >= 8.0) {
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  } else {
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
  }
}

// 注册通知成功回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString *deviceTokenString = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
  NSLog(@"收到deviceToken：%@",  deviceTokenString);
  [GeTuiSdk registerDeviceTokenData:deviceToken];
}

// 收到远程消息通知,透传推送消息(iOS 10 以前)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [GeTuiSdk handleRemoteNotification:userInfo];
  NSLog(@"收到远程消息通知，透传消息%@", userInfo);
  [[NSNotificationCenter defaultCenter]postNotificationName:GT_DID_RECEIVE_REMOTE_NOTIFICATION object:@{@"type":@"GT_APNS",@"userInfo":userInfo}];
  completionHandler(UIBackgroundFetchResultNewData);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  NSLog(@"前台获取到通知：%@", notification.request.content.userInfo);
  // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
  [[NSNotificationCenter defaultCenter]postNotificationName:GT_DID_RECEIVE_REMOTE_NOTIFICATION object:@{@"type":@"GT_APNS",@"userInfo":notification.request.content.userInfo}];
  completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  NSLog(@"点击通知进入App时触发：%@", response.notification.request.content.userInfo);
  // [ GTSdk ]：将收到的APNs信息传给个推统计
  [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
  [[NSNotificationCenter defaultCenter]postNotificationName:GT_DID_CLICK_NOTIFICATION object:response.notification.request.content.userInfo];
  completionHandler();
}

#endif

#pragma mark - GeTuiSdkDelegate

//SDK收到透传消息回调
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
  [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
  NSString *payloadMsg = nil;
  if (payloadData) {
    payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
  }
  NSDictionary *userInfo = @{@"taskId":taskId,@"msgId":msgId,@"payloadMsg":payloadMsg,@"offLine":offLine?@"YES":@"NO"};
  NSLog(@"收到远程消息通知，透传消息%@", userInfo);
  [[NSNotificationCenter defaultCenter]postNotificationName:GT_DID_RECEIVE_REMOTE_NOTIFICATION object:@{@"type":@"GT_PAYLOAD",@"userInfo":userInfo}];
}

// SDK启动成功返回clientId
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
  NSLog(@"注册clientid：%@", clientId);
  [[NSNotificationCenter defaultCenter]postNotificationName:GT_DID_REGISTE_CLIENTID object:clientId];
}

// SDK遇到错误回调
- (void)GeTuiSdkDidOccurError:(NSError *)error {}

// SDK运行状态通知
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {}

// SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {}

// SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {}

@end
