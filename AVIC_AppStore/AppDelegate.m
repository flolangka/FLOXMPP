//
//  AppDelegate.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPComment.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册本地通知
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSString *userName = [UD stringForKey:kUserName];
    NSString *password = [UD stringForKey:kPassWord];
    
    NSString *host = [UD stringForKey:kXMPPHost];
    NSString *domain = [UD stringForKey:kXMPPDomain];
    
    //是否配置了服务器
    BOOL xmppServiceDidConfig = host && domain && host.length > 0 && domain.length > 0;
    
    //是否有登陆记录（重新配置服务器时登陆记录清空）
    BOOL xmppUserDidAuthorization = userName && password && userName.length > 0 && password.length > 0;
    
    if (!xmppServiceDidConfig || !xmppUserDidAuthorization) {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SBIDLoginVC"];
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIBackgroundTaskIdentifier ID = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:ID];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
