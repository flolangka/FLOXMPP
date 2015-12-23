//
//  XMPPManager.m
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import "XMPPManager.h"
#import "XMPPComment.h"

static NSString * const xmppHost = @"192.168.1.2";
static NSUInteger xmppPort = 5222;


@interface XMPPManager()<XMPPStreamDelegate>

{
    void(^connectSuccessBlock)();
    void(^connectFailureBlock)();
    
    void(^authorizationSuccessBlock)();
    void(^authorizationFailureBlock)();
    
    void(^registerSuccessBlock)();
    void(^registerFailureBlock)();
    
    NSString *xmppPassword;
    
    XMPPStream *xmppStream;//最主要的xmpp流
}

@end

static XMPPManager *manager;

@implementation XMPPManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
        [manager configXMPPStream];
    });
    return manager;
}

#pragma mark - 连接服务器
- (void)connect2ServerSuccess:(void(^)())success failure:(void(^)())failure
{
    connectSuccessBlock = success;
    connectFailureBlock = failure;
    
    if ([xmppStream isConnected]) {
        [self logoutAndDisconnect];
    }
    NSError *error;
    [xmppStream connectWithTimeout:15 error:&error];
}

#pragma mark - 上线
- (void)authorizationWithUserName:(NSString *)userName password:(NSString *)password success:(void (^)())success failure:(void (^)())failure
{
    xmppPassword = password;
    authorizationSuccessBlock = success;
    authorizationFailureBlock = failure;
    
    XMPPJID *xmppJID = [XMPPJID jidWithString:userName];
    xmppStream.myJID = xmppJID;
    
    [self connect2ServerSuccess:^{
        NSError *error;
        [xmppStream authenticateWithPassword:xmppPassword error:&error];
    } failure:^{
        failure();
    }];
}

#pragma mark - 注册
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password success:(void (^)())success failure:(void (^)())failure
{
    xmppPassword = password;
    registerSuccessBlock = success;
    registerFailureBlock = failure;
    
    XMPPJID *xmppJID = [XMPPJID jidWithString:userName];
    xmppStream.myJID = xmppJID;
    
    [self connect2ServerSuccess:^{
        NSError *error;
        [xmppStream registerWithPassword:xmppPassword error:&error];
    } failure:^{
        failure();
    }];
}

#pragma mark - 初始化时配置xmpp流
- (void)configXMPPStream
{
    xmppStream = [[XMPPStream alloc] init];
    
    xmppStream.hostName = xmppHost;
    xmppStream.hostPort = xmppPort;
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark XMPPStream代理-连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"XMPP>>>>连接服务器成功");
    connectSuccessBlock();
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPP>>>>连接服务器失败>>%@", error.localizedDescription);
    connectFailureBlock();
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"XMPP>>>>连接服务器超时");
    connectFailureBlock();
}


#pragma mark XMPPStream代理-登录
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP>>>>登录成功");
    authorizationSuccessBlock();
    
    //上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [xmppStream sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"XMPP>>>>登录失败>>%@", error);
    authorizationFailureBlock();
}


#pragma mark XMPPStream代理-注册
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"XMPP>>>>注册成功");
    registerSuccessBlock();
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"XMPP>>>>注册失败>>%@", error);
    registerFailureBlock();
}


#pragma mark 下线并断开连接
- (void)logoutAndDisconnect{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
    
    [xmppStream disconnect];
}

#pragma mark 收发消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP>>>>收到消息>>%@", [message body]);
    
    if ([message isErrorMessage]) {
        NSLog(@"收到一条错误消息>>%@", [message body]);
    } else {
//        NSString *messageBody = [message body];
//        NSString *sourceUser = [message.fromStr substringToIndex:[message.fromStr rangeOfString:@"@"].location];
        
        //赋给消息对象
//        FloXMPPMessage *msg = [[FloXMPPMessage alloc] initWithSourceUser:sourceUser msgBody:messageBody sendTime:[NSDate date] type:FloMessageTypePlain];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPReceiveMsg object:nil userInfo:@{@"sourceName": sourceUser, @"msg": msg}];
        
        
        //将消息存储到本地数据库中，成功之后发送通知带本次消息的发送用户，接收通知方根据用户进行操作
        
        
        //当程序处于后台时
//        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
//        {
//            // We are not active, so use a local notification instead
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertAction = @"Ok";
//            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", sourceUser, messageBody];
//            
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//        }
    }
}

- (void)sendMessage:(NSString *)mes toUser:(NSString *)user
{
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:mes];
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    NSString *to = [NSString stringWithFormat:@"%@@%@", user, kHostName];
//    [message addAttributeWithName:@"to" stringValue:to];
//    [message addChild:body];
//    [xmppStream sendElement:message];
}


#pragma mark 添加好友
- (void)addSomeBody:(NSString *)userId
{
    //    XMPPRoster
}


#pragma mark 发送文件
- (void)sendFile:(NSData *)aData toJID:(XMPPJID *)aJID
{
    
}

@end
