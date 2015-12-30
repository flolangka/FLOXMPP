//
//  XMPPManager.h
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPComment.h"
@class FLOChatMessageModel;

static NSString * const xmppDomain = @"192.168.1.2";    //需要与host一致否则在登录时可能会失败

@interface XMPPManager : NSObject

@property (nonatomic, strong) XMPPStream *xmppStream;//最主要的xmpp流
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) NSArray *xmppMyFriends;
@property (nonatomic, strong) NSMutableArray *friendRequests;

@property (nonatomic, copy) void (^receiveFriendRequestBlock)(XMPPManager *);
@property (nonatomic, copy) void (^receiveMessageBlock)(FLOChatMessageModel *);

+ (instancetype)manager;

//登录上线
- (void)autoAuthorizationSuccess:(void(^)())success failure:(void(^)(NSString *))faiure;
- (void)authorizationWithUserName:(NSString *)userName password:(NSString *)password success:(void(^)())success failure:(void(^)(NSString *))failure;

//新用户注册
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password success:(void(^)())success failure:(void(^)(NSString *))failure;

//注销
- (void)logoutAndDisconnect;

//好友操作
- (void)addFriend:(NSString *)userName message:(NSString*)message;
- (void)deleteFriend:(NSString *)friendName;

//好友申请操作
- (void)agreeAddFriendRequest:(NSString*)name;
- (void)rejectAddFriendRequest:(NSString*)name;

//发消息
- (void)sendTextMessage:(NSString *)mes toUser:(NSString *)user;
- (void)sendImageMessage:(NSString *)mes image:(UIImage *)image toUser:(NSString *)user;
- (void)sendVoiceMessage:(NSString *)mes WavData:(NSData *)wavData toUser:(NSString *)user;


@end
