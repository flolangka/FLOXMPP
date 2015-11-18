//
//  AppDelegate.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SliderViewController.h"
#import "LoginViewController.h"
#import "ThemeManager.h"
#import "DEFIND.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSUserDefaults*user=[NSUserDefaults standardUserDefaults];
    if(![user objectForKey:@"canPush"]){
        [user setObject:@"canPush" forKey:@"canPush"];
        [user synchronize];
    }
    if([[user objectForKey:@"canPush"]isEqualToString:@"canPush"]){
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }  else {
            UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
        }
    }else{
        [[UIApplication sharedApplication]cancelAllLocalNotifications];
    }
    
    if([user boolForKey:kISLogin]){
        //self.window.rootViewController=[[SliderViewController alloc]init];
        self.window.rootViewController=[[MainViewController alloc]init];
        [[ZCXMPPManager sharedInstance] connectLogoin:^(BOOL succeed) {
            if (succeed) {
                NSLog(@"<<<<<<<自动登录成功>>>>>>>");
            }
        }];
    }else{
        if(![user objectForKey:@"isFirst"]){
            
            [user setObject:@"蓝" forKey:@"theme"];
            [user setObject:@"no" forKey:@"isFirst"];
            [user synchronize];
        }
        self.window.rootViewController=[[LoginViewController alloc]init];
    }
//    self.window.rootViewController=[[LoginViewController alloc]init];
    NSString*version=[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSLog(@"hhhhh%@",version);
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //MyLog(@"token = %@",deviceToken);
    NSString*newToken=[[[[deviceToken description]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString*oldToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    if(![oldToken isEqualToString:newToken]){
        [[NSUserDefaults standardUserDefaults]setObject:newToken forKey:@"deviceToken"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    NSLog(@"%@",newToken);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:newToken delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    //75845fb27661ccff980e4ee640c459a41ed1b03b4f3f538666db24fbbcc0b840
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"error:%@",error.description);
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //MyLog(@"%@",userInfo);
    NSString*info=[[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    if(application.applicationState==UIApplicationStateActive){
        
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"通知" message:info delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }else{
        application.applicationIconBadgeNumber++;
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
