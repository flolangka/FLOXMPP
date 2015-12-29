//
//  XMPPManager.m
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import "XMPPManager.h"
#import "FLODataBaseEngin.h"
#import "FLOChatRecordModel.h"
#import "FLOChatMessageModel.h"

static NSString * const xmppHost = @"192.168.1.2";
static NSString * const xmppResource = @"iOS";
static NSUInteger xmppPort = 5222;


@interface XMPPManager()<XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate>

{
    //连接
    void(^connectSuccessBlock)();
    void(^connectFailureBlock)();
    
    //登录
    void(^authorizationSuccessBlock)();
    void(^authorizationFailureBlock)();
    
    //注册
    void(^registerSuccessBlock)();
    void(^registerFailureBlock)();
    
    //更新好友列表
    void(^fetchRosterSuccessBlock)();
    void(^fetchRosterFailureBlock)();
    
    NSString *xmppPassword;
    
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchiving;
    XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
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
    
    if ([_xmppStream isConnected]) {
        [self logoutAndDisconnect];
    }
    NSError *error;
    [_xmppStream connectWithTimeout:15 error:&error];
}

#pragma mark - 上线
- (void)autoAuthorizationSuccess:(void (^)())success failure:(void (^)())faiure
{
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    [self authorizationWithUserName:[UD stringForKey:kUserName] password:[UD stringForKey:kPassWord] success:success failure:faiure];
}

- (void)authorizationWithUserName:(NSString *)userName password:(NSString *)password success:(void (^)())success failure:(void (^)())failure
{
    xmppPassword = password;
    authorizationSuccessBlock = success;
    authorizationFailureBlock = failure;
    
    XMPPJID *xmppJID = [XMPPJID jidWithUser:userName domain:xmppDomain resource:xmppResource];
    _xmppStream.myJID = xmppJID;
    
    [self connect2ServerSuccess:^{
        NSError *error;
        [_xmppStream authenticateWithPassword:xmppPassword error:&error];
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
    
    XMPPJID *xmppJID = [XMPPJID jidWithUser:userName domain:xmppDomain resource:xmppResource];
    _xmppStream.myJID = xmppJID;
    
    [self connect2ServerSuccess:^{
        NSError *error;
        [_xmppStream registerWithPassword:xmppPassword error:&error];
    } failure:^{
        failure();
    }];
}

#pragma mark - 初始化时配置xmpp流
- (void)configXMPPStream
{
    self.xmppStream = [[XMPPStream alloc] init];
    
    _xmppStream.hostName = xmppHost;
    _xmppStream.hostPort = xmppPort;
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //允许xmpp在后台运行
    _xmppStream.enableBackgroundingOnSocket=YES;
    
    //接入断线重连模块
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect setAutoReconnect:YES];
    [xmppReconnect activate:_xmppStream];
    
    //接入好友模块，可以获取好友列表
    xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterMemoryStorage];
    _xmppRoster.autoFetchRoster = YES;
    [_xmppRoster activate:_xmppStream];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //接入消息模块，将消息存储到本地
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    [xmppMessageArchiving activate:_xmppStream];
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


#pragma mark XMPPStream代理-登录
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP>>>>登录成功");
    self.friendRequests = [NSMutableArray array];
    authorizationSuccessBlock();
    
    //上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [_xmppStream sendElement:presence];
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
    [_xmppStream sendElement:presence];
    
    [_xmppStream disconnect];
}

#pragma mark - xmppRoster
- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender
{
    self.xmppMyFriends = [sender sortedUsersByName];
    NSLog(@"获取好友列表>>%@",[sender sortedUsersByName]);
}

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    self.xmppMyFriends = [sender sortedUsersByName];
    NSLog(@"好友列表有更新>>%@",[sender sortedUsersByName]);
}

#pragma mark 添加好友 可以带一个消息
- (void)addFriend:(NSString *)userName message:(NSString*)message
{
    if (message) {
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:userName domain:xmppDomain resource:xmppResource]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        [_xmppStream sendElement:mes];
    }
    
    [_xmppRoster subscribePresenceToUser:[XMPPJID jidWithUser:userName domain:xmppDomain resource:xmppResource]];
}
#pragma mark 删除好友
- (void)deleteFriend:(NSString *)friendName
{
    XMPPJID *jid = [XMPPJID jidWithUser:friendName domain:xmppDomain resource:xmppResource];
    
    [_xmppRoster removeUser:jid];
}

#pragma mark 同意好友请求
- (void)agreeAddFriendRequest:(NSString*)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:xmppDomain resource:xmppResource];
    [_xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    [_friendRequests removeObject:name];
}
#pragma mark 拒绝好友请求
- (void)rejectAddFriendRequest:(NSString*)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:xmppDomain resource:xmppResource];
    [_xmppRoster rejectPresenceSubscriptionRequestFrom:jid];

    [_friendRequests removeObject:name];
}

#pragma mark - 收到添加好友申请
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    NSLog(@"收到好友请求>>%@", presenceFromUser);
    if (![presenceFromUser isEqualToString:myUsername]) {
        [_friendRequests addObject:presenceFromUser];
    }
    if (_receiveFriendRequestBlock) {
        _receiveFriendRequestBlock(self);
    }
}

#pragma mark 收发消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPP>>>>收到消息>>%@", [message body]);
    
    if ([message isErrorMessage]) {
        NSLog(@"收到一条错误消息>>%@", [message body]);
    } else {
        NSString *messageBody = [message body];
        NSString *sourceUser = [message.fromStr substringToIndex:[message.fromStr rangeOfString:@"@"].location];
        
        NSString *lastStr = [messageBody substringFromIndex:4];
        NSRange range = [lastStr rangeOfString:@"]"];
        NSString *timeStr = [lastStr substringToIndex:range.location];
        
        //保存聊天记录
        NSString *chatRecordMsgBody = @"";
        if ([messageBody hasPrefix:Message_Prefix_Text]) {
            chatRecordMsgBody = [lastStr substringFromIndex:range.location+1];
        } else if ([messageBody hasPrefix:Message_Prefix_Image]) {
            chatRecordMsgBody = @"[图片]";
        } else if ([messageBody hasPrefix:Message_Prefix_Voice]) {
            chatRecordMsgBody = @"[语音]";
        }
        FLOChatRecordModel *chatRecord = [[FLOChatRecordModel alloc] initWithDictionary:@{@"chatUser": sourceUser,
                                                                                          @"lastMessage": chatRecordMsgBody,
                                                                                          @"lastTime": timeStr}];
        [[FLODataBaseEngin shareInstance] saveChatRecord:chatRecord];
        
        //保存消息记录
        FLOChatMessageModel *messageModel = [[FLOChatMessageModel alloc] initWithDictionary:@{@"messageFrom": sourceUser,
                                                                                              @"messageTo": _xmppStream.myJID.user,
                                                                                              @"messageContent": messageBody}];
        [[FLODataBaseEngin shareInstance] insertChatMessages:@[messageModel]];
        
        
        if (_receiveMessageBlock) {
            _receiveMessageBlock(messageModel);
        }
    }
}

- (void)sendMessage:(NSString *)mes toUser:(NSString *)user
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:mes];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, xmppDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addChild:body];
    [_xmppStream sendElement:message];
    
    FLOChatMessageModel *messageModel = [[FLOChatMessageModel alloc] initWithDictionary:@{@"messageFrom": _xmppStream.myJID.user,
                                                                                          @"messageTo": user,
                                                                                          @"messageContent": mes}];
    [[FLODataBaseEngin shareInstance] insertChatMessages:@[messageModel]];
}


@end
