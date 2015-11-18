//
//  ZCXMPPManager.h
//  XMPPEncapsulation
//
//  Created by ZC on 14-4-9.
//  Copyright (c) 2014年 ZC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "XMPPFramework.h"
@class XMPPMessage,XMPPRoster,XMPPRosterCoreDataStorage,XMPPvCardAvatarModule,XMPPvCardTempModule,XMPPvCardAvatarCoreDataStorageObject,ZCMessageObject;
@interface ZCXMPPManager : NSObject
{
    XMPPStream *xmppStream;//最主要的xmpp流
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPMessageArchivingCoreDataStorage*xmppMessageArchivingCoreDataStorage;//信息列表
    XMPPMessageArchiving *xmppMessageArchivingModule;
    XMPPvCardAvatarModule*xmppvCardAvatarModule;
    XMPPvCardTempModule*xmppvCardTempModule;
    XMPPvCardCoreDataStorage*xmppvCardStorage;
   	NSString *password;
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	BOOL isXmppConnected;
    BOOL logoinorSignin;
    NSUserDefaults*userDefaults;
}


@property (nonatomic,retain)NSMutableArray*subscribeArray;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain,nonatomic)NSMutableDictionary*yanzhengxiaoxi;
//用于记录出席列表
@property(nonatomic,retain)NSMutableDictionary*presentDic;

/******************系统初始化***************************/
//获得单例
+(ZCXMPPManager*)sharedInstance;
//登录
- (BOOL)connectLogoin:(void(^)(BOOL))a;
//注册
-(void)registerMothod:(void(^)(BOOL))b;
//退出登录
- (void)disconnect;
//获得好友列表 如有新状态，通过block回调
-(NSArray*)friendsList:(void(^)(BOOL))c;
//获得头像（需要与好友列表共同使用）
- (UIImage *)avatarForUser:(XMPPUserCoreDataStorageObject *) user;
/****************消息类处理******************************/
//发送消息
-(void)sendMessageWithJID:(NSString*)jidStr Message:(NSString*)message Type:(NSString *)type;


//记录当前聊天人是谁
@property (copy,nonatomic)NSString*chatPerson;
//徽标属性,设置未读消息使用
@property(nonatomic,assign)UITabBarItem*badgeValue;

//进入聊天界面和退出聊天界面必须调用此函数 a为接收到的消息
-(void)valuationChatPersonName:(NSString*)name IsPush:(BOOL)isPush MessageBlock:(void(^)(ZCMessageObject*))a;
//获取聊天记录 数组里每个元素是XMPPMessageArchiving_Message_CoreDataObject
/*
body 内容 需要先对比类型
isOutgoing 是否是发送方
timestamp  发送的时间
 
 */
//聊天记录
-(NSArray*)messageRecord;
/****************好友类的处理********************/
//添加好友 可以带一个消息
-(void)addSomeBody:(NSString *)userId Newmessage:(NSString*)message;
//删除好友
-(void)removeBuddy:(NSString *)name;

//处理请求
//同意
-(void)agreeRequest:(NSString*)name;
//拒绝
-(void)reject:(NSString*)name;
//获得好友名片
-(XMPPvCardTemp*)friendsVcard:(NSString*)useId;
//扩展方法
-(void)friendsVcard:(NSString *)useId Block:(void(^)(BOOL,XMPPvCardTemp*))a;

/*********************个人中心********************************/

//个人中心
//接口   1、获得myVcard 2、设置自定义节点  3、更新myVcard
-(void)getMyVcardBlock:(void(^)(BOOL,XMPPvCardTemp*))c;
-(void)customVcardXML:(NSString*)Value name:(NSString*)Name myVcard:(XMPPvCardTemp*)myVcard;
-(void)upData:(XMPPvCardTemp*)vCard;


//判断好友 需要根据实际需求进行修改
-(BOOL)isFriend:(NSString*)Str;
#pragma mark 群聊


//获得所有聊天室
-(void)searchXmppRoomBlock:(void(^)(NSMutableArray*))roomsDic;

//发送聊天室信息
-(void)sendGroupMessage:(NSString*)messageStr roomName:(NSString*)roomName;
//邀请他人进入聊天室
-(void)inviteRoom:(XMPPRoom*)room userName:(NSString*)userName;
//拒绝加入聊天室
-(void)rejectRoom:(NSString*)roomJid;
//创建聊天室 b为成功加入聊天室以后
-(XMPPRoom*)xmppRoomCreateRoomName:(NSString *)roomName nickName:(NSString *)nickName MessageBlock:(void(^)(NSDictionary*))a presentBlock:(void(^)(NSDictionary*))b;
// 离开房间
-(void)XmppOutRoom:(XMPPRoom*)room;
//修改房间名称 注！必须是主持人才有此权限
-(void)configRoom:(XMPPRoom*)room config:(NSXMLElement*)config;
//查找特定房间配置
-(void)fetchRoomName:(NSString*)roomName Block:(void(^)(NSDictionary*))b;

//文件传输
#pragma mark 文件传输
-(void)test;
//视频对讲



/*block指针*/
//登录函数指针
@property(nonatomic,copy)void(^logoin)(BOOL);
//注册指针
@property(nonatomic,copy)void(^signin)(BOOL);
//接收到当前聊天人的消息指针
@property(nonatomic,copy)void(^accept)(ZCMessageObject*);

//接收个人中心Vcard回调
@property(nonatomic,copy)void(^myVcardBlock)(BOOL,XMPPvCardTemp*);
//接收好友的Vcard回调
@property(nonatomic,copy)void(^friendVcardBlock)(BOOL,XMPPvCardTemp*);

@property(nonatomic,copy)void(^friendType)(BOOL);
//接收按照搜索条件返回的房间jid和房间名称
@property(nonatomic,copy)void(^roomsName)(NSMutableArray*);
//接收群聊消息
@property(nonatomic,copy)void(^GroupMessage)(NSDictionary*);
//外部在退出当前界面时候需要修改该nowRoomjid为空
@property(nonatomic,copy)NSString*nowRoomJid;
//群验证消息回调
@property(nonatomic,copy)void(^GroupCheck)(NSDictionary*);
//用于返回出席列表，谁进入谁退出
@property(nonatomic,copy)void(^GroupPresent)(NSDictionary*);
//返回查找的房间信息
@property(nonatomic,copy)void(^fetchRoom)(NSDictionary*);
//-(void)xx;
/**********/

#pragma FLO扩展
//@property (nonatomic, readonly) XMPPStream *floXMPPStream;
//@property (nonatomic, readonly) XMPPRoster *floXMPPRoster;


@end
