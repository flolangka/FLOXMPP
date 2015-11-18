//
//  ZCXMPPManager.m
//  XMPPEncapsulation
//
//  Created by ZC on 14-4-9.
//  Copyright (c) 2014年 ZC. All rights reserved.
//

#import "ZCXMPPManager.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
//断点续传
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
//打印信息
#import "DDLog.h"
#import "DDTTYLogger.h"
//花名册
#import "XMPPRoster.h"
//信息
#import "XMPPMessage.h"
//发送文件使用
#import "TURNSocket.h"
//名片模型
#import "XMPPvCardTempModule.h"
#import "XMPPvCardTempCoreDataStorageObject.h"
#import "XMPPvCardAvatarModule.h"
#import "ZCMessageObject.h"
//#import "SGInfoAlert.h"
#import "XMPPRoom.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
//定义的路径，documents 和caches路径
#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CACHES_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define NONE @"none"

@implementation ZCXMPPManager
#pragma mark 开启单例
static ZCXMPPManager *sharedManager;
@synthesize subscribeArray,yanzhengxiaoxi;
+(ZCXMPPManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[ZCXMPPManager alloc]init];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [sharedManager setupStream];
        sharedManager.chatPerson=NONE;
        
    });
    return sharedManager;
}
#pragma mark 查找特定房间
-(void)fetchRoomName:(NSString*)roomName Block:(void(^)(NSDictionary*))b{
/*
 查询特定房间
 */
    self.fetchRoom=b;
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    //conference 原生的
    XMPPJID* proxyCandidateJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,userDOMAIN]];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:proxyCandidateJID  elementID:@"disco" child:query];
    [xmppStream sendElement:iq];

}
#pragma mark 是否是好友
-(BOOL)isFriend:(NSString*)Str{
    /*********/
    
    NSManagedObjectContext*context=[xmppRosterStorage mainThreadManagedObjectContext];
    NSEntityDescription*entity=[NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSString*currentJid=[NSString stringWithFormat:@"%@@%@",[userDefaults objectForKey:kXMPPmyJID],userDOMAIN];
    
    NSPredicate*predicate=[NSPredicate predicateWithFormat:@"streamBareJidStr==%@",currentJid];
    NSFetchRequest*request=[[NSFetchRequest alloc]init];
    [request setEntity:entity];
    [request setPredicate:predicate];//筛选条件
    NSError*error;
    NSArray*friends=[context executeFetchRequest:request error:&error];//从数据库中取出数据
    BOOL isSucceed=NO;
    for (XMPPUserCoreDataStorageObject*object in friends) {
        
        
        if ([object.jidStr isEqualToString:Str]) {
            isSucceed=YES;
        }
    }
    
    return isSucceed;
}
#pragma mark 发现聊天室
//获得全部房间列表
-(void)searchXmppRoomBlock:(void(^)(NSMutableArray*))roomsDic
{

    self.roomsName=roomsDic;
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    
   XMPPJID* proxyCandidateJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@.%@",GROUND,userDOMAIN]];
   
  

    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:proxyCandidateJID  elementID:@"disco" child:query];
    [xmppStream sendElement:iq];

}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    
    //获得id名字
  DDXMLNode*idXML=  [iq attributeForName:@"id"];
    //转换为字符串
  NSString*str=  [idXML stringValue];
    if ([str isEqualToString:@"disco"]) {
        
       NSArray*array= [iq elementsForName:@"query"];
        NSXMLElement *query=[array firstObject];
        
        //获取命名空间
      DDXMLNode *nameSpace=  [[query namespaces]firstObject];
        //获取房间信息
        if ([[nameSpace stringValue] isEqualToString:@"http://jabber.org/protocol/disco#info"]) {
            
              DDXMLNode*typeXML=  [iq attributeForName:@"type"];
          NSString*error=  [typeXML stringValue];
            if ([error isEqualToString:@"error"]) {
                 self.fetchRoom(nil);
                return YES;
            }
            
            
          NSArray*field=  [[[query elementsForName:@"x"]firstObject]elementsForName:@"field"];
            NSString*str=[[[[field objectAtIndex:1]elementsForName:@"value"]firstObject]stringValue];
            if (str.length==0) {
                str=@"没有描述";
            }
            //人数限制
            NSString*str2=[[[[field objectAtIndex:3]elementsForName:@"value"]firstObject]stringValue];
            if (str2.length==0) {
                str2=@"0";
            }
            //创建日期
            NSString*str3=[[[[field objectAtIndex:4]elementsForName:@"value"]firstObject]stringValue];
            
            DDXMLNode*idXML1=  [iq attributeForName:@"from"];
            //转换为字符串
            NSString*str4=  [idXML1 stringValue];
            
        NSDictionary*dic=@{@"des":str,@"num":str2,@"time":str3,@"from":str4};
            
            //对数据库进行更新 310065
            [ZCMessageObject upDateType:dic];
            self.fetchRoom(dic);
            return YES;
        }
      array=  [query elementsForName:@"item"];
     
        NSMutableArray*roomArray=[NSMutableArray arrayWithCapacity:0];
        for (NSXMLElement*item in array) {
            NSMutableDictionary*room=[NSMutableDictionary dictionaryWithCapacity:0];
            
         DDXMLNode*jid=   [item attributeForName:@"jid"];
        DDXMLNode*name= [item attributeForName:@"name"];
            [room setValue:[jid stringValue] forKey:@"roomJid"];
            [room setValue:[name stringValue] forKey:@"roomName"];
            
            [roomArray addObject:room];
        }
        if (self.roomsName) {
            self.roomsName(roomArray);
        }
    }
    
    
    return YES;
}

#pragma mark 发送邀请他人进入聊天室

-(void)inviteRoom:(XMPPRoom*)room userName:(NSString*)userName{
    
    [room inviteUser:[XMPPJID jidWithUser:userName domain:userDOMAIN resource:ZIYUANMING]  withMessage:[NSString stringWithFormat:@"邀请你加入%@的聊天室",userName]];
    //回调在通过新人进入聊天室获得
    
}
#pragma mark 拒绝进入聊天室
-(void)rejectRoom:(NSString*)roomJid{

    XMPPMessage*message=[[XMPPMessage alloc]init];
    [message addAttributeWithName:@"to" stringValue:roomJid];
    NSXMLElement*element=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
    [message addChild:element];
    [xmppStream sendElement:message];

}
#pragma mark处理接收到群邀请和群被拒绝
-(void)aboutMucRoom:(XMPPMessage*)message
{
    
    NSArray*xArray= [message elementsForName:@"x"];
    NSString*from= [[message attributeForName:@"from"]stringValue];
   DDXMLElement*element= [xArray objectAtIndex:0];
     NSString*to=[[[[element elementsForName:@"invite"] firstObject]attributeForName:@"from"] stringValue];
    
    NSArray*declineArray=[element elementsForName:@"decline"];
    NSString*reason;
    NSString*type;
    
    if (declineArray.count) {
    //别人拒绝你
        DDXMLElement*elementItem=[declineArray objectAtIndex:0];
       to= [[elementItem attributeForName:@"from"]stringValue];
        
       reason=[[elementItem attributeForName:@"reason"]stringValue];
        if (reason==nil) {
            reason=@" ";
        }
        type=@"0";
    
    }else{
     //别人邀请你
        NSArray*inviteArray=[element elementsForName:@"invite"];
        DDXMLElement*elementItem=[inviteArray firstObject];
        reason=[[elementItem attributeForName:@"reason"]stringValue];
        if (reason==nil) {
            reason=@" ";
        }
        type=@"1";
    
    }

    //房间名称        from
    //谁邀请你        to
    //邀请的理由       reason
    //type           0/1
    
    
    self.GroupCheck(@{@"from":from,@"to":to,@"reason":reason,@"type":type});
    
}

#pragma mark 加入聊天室（没有就创建）
-(XMPPRoom*)xmppRoomCreateRoomName:(NSString *)roomName nickName:(NSString *)nickName MessageBlock:(void(^)(NSDictionary*))a presentBlock:(void(^)(NSDictionary*))b{
    //记录block指针，以及相应的房间jid，为消息接口准备
    self.GroupMessage=a;
    self.GroupPresent=b;
    //对出席列表字典初始化
    self.presentDic=[NSMutableDictionary dictionaryWithCapacity:0];
    NSString*str=[[roomName componentsSeparatedByString:@"@"]firstObject];
    self.nowRoomJid=str;
    //指定的房间号 如果没有就创建
    XMPPRoom* room = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,userDOMAIN]] dispatchQueue:dispatch_get_main_queue()];
    //激活
     [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:xmppStream];
    [userDefaults removeObjectForKey:GROUNDROOMCONFIG];
    //使用的昵称 进入房间的函数
    [room joinRoomUsingNickname:nickName history:nil];
    [room configureRoomUsingOptions:nil];
    return room;
  
}
#pragma mark 房间创建成功
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    
}
#pragma mark xmpp房间配置
-(void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(DDXMLElement *)configForm {

    [self configRoom:sender config:configForm];

}


#pragma mark 获得聊天室信息
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{

    //发送房间配置请求
    [sender fetchConfigurationForm];
	[sender fetchModeratorsList];
}
-(void)XmppOutRoom:(XMPPRoom*)room{
    _nowRoomJid=nil;
    [room deactivate];
    //退出房间删除该房间的配置信息
    [userDefaults removeObjectForKey:GROUNDROOMCONFIG];
    [userDefaults synchronize];
}

#pragma mark 重新配置聊天室
-(void)configRoom:(XMPPRoom*)room config:(NSXMLElement*)config{
    
    NSDictionary*dic=[userDefaults objectForKey:GROUNDNAME];
    if (dic==nil) {
        //保存配置信息
        [userDefaults setObject:[config XMLString] forKey:GROUNDROOMCONFIG];
        [userDefaults synchronize];
       

        return;
    }
    
    NSXMLElement*newConfig=nil;
    if (config) {
        newConfig=[config copy];
    }else{
        NSString*str= [userDefaults objectForKey:GROUNDROOMCONFIG];
        if (str==nil) {
            return;
        }
       newConfig=[[NSXMLElement alloc]initWithXMLString:str error:nil];
    }
    NSArray*fields=[newConfig elementsForName:@"field"];
    
    
   
    
	for (NSXMLElement *field in fields) {
        
        NSString *var = [field attributeStringValueForName:@"var"];
        //房间名称
        if ([var isEqualToString:@"muc#roomconfig_roomname"]&&[dic objectForKey:@"nikeName"]) {
                    [field removeChildAtIndex:0];
                    [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"nikeName"]]];
                }
        //房间描述
        if ([var isEqualToString:@"muc#roomconfig_roomdesc"]&&[dic objectForKey:@"desName"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"desName"]]];
        }
        //房间永久化
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]&&[dic objectForKey:@"isOpen"]) {
            if ([[dic objectForKey:@"isOpen"]isEqualToString:@"1"]) {
                [field removeChildAtIndex:0];
                [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
            }
            
        }
        //设置人数
        if ([var isEqualToString:@"muc#roomconfig_maxusers"]&&[dic objectForKey:@"num"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"num"]]];
            
        }
        
        if ([var isEqualToString:@"muc#roomconfig_changesubject"]||[var isEqualToString:@"muc#roomconfig_allowinvites"]) {
            
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [userDefaults setObject:[newConfig XMLString] forKey:GROUNDROOMCONFIG];
    //删除掉配置信息
    [userDefaults removeObjectForKey:GROUNDNAME];
    [userDefaults synchronize];
    
    [room configureRoomUsingOptions:newConfig];
}

#pragma mark room相关代理
//房间存在
//收到禁止名单列表
-(void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{

};
//收到群成员名单列表
-(void)xmppRoom:(XMPPRoom*)sender didFetchMembersList:(NSArray*)items
{
    
  NSLog(@"%@",items);
}
//收到主持人名单列表
-(void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    
    self.GroupPresent(nil);
}
//房间不存在
//没有禁止名单列表
-(void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{

}
//没有群成员名单列表
-(void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{

}
//没有主持人名单列表
-(void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    self.GroupPresent(nil);

}
//房客的进入和离开
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
}
//房客离开
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
}
//房客更新
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
}



#pragma mark  离开房间[room deactivate:xmppStream];
-(void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    
	DDLogVerbose(@"%@:%@",THIS_FILE,THIS_METHOD);
}
#pragma mark 新人加入群聊
-(void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    
	DDLogVerbose(@"%@: %@",THIS_FILE,THIS_METHOD);
}
//有人退出群聊
-(void)xmppRoom:(XMPPRoom*)sender occupantDidLeave:(XMPPJID *)occupantJID
{
	DDLogVerbose(@"%@:%@",THIS_FILE,THIS_METHOD);
}
#pragma mark 群内发言可以在进入聊天室以后获得
//有人在群里发言
-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
 
    NSLog(@"可以获得用户的账号%@",[message elementID]);
    
    
    if ([sender.roomJID.user hasPrefix:self.nowRoomJid]) {
        NSDictionary*dic=@{@"message":message,@"jid":occupantJID.user};
        self.GroupMessage(dic);
    }
    [self receiveMessage:message];
	DDLogVerbose(@"%@: %@",THIS_FILE,THIS_METHOD);
}
#pragma mark 发送群聊消息
-(void)sendGroupMessage:(NSString*)messageStr roomName:(NSString*)roomName{
    
    //生成房间jid
    NSString* roomJid = [NSString stringWithFormat:@"%@@%@.%@",roomName,GROUND,userDOMAIN];
   
    XMPPMessage*aMessage=[XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJid] elementID:[userDefaults objectForKey:kXMPPmyJID]];

    //设置发送的内容
     [aMessage addChild:[DDXMLNode elementWithName:@"body" stringValue:messageStr]];
    //发送
    [xmppStream sendElement:aMessage];
    
    ZCMessageObject*model=[[ZCMessageObject alloc]initWithFrom:[userDefaults objectForKey:kXMPPmyJID] to:roomName content:messageStr time:[NSDate date] chatType:ChatType_Group];

    //保存最近聊天记录
    BOOL isSucceed=[ZCMessageObject save:model];
    if (isSucceed) {
        NSLog(@"最近聊天保存成功");
    }
    
    
    

}



#pragma mark *******************************
#pragma mark 文件传输
-(void)test{
    [TURNSocket initialize];
    [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:userDOMAIN,nil]];
    TURNSocket *objTURNSocket = [[TURNSocket alloc] initWithStream:xmppStream toJID:  [XMPPJID jidWithUser:@"123" domain:userDOMAIN resource:@"IOS"] ];
                                                                                        
    [objTURNSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue() ];
    
    
}

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    
}

- (void)turnSocketDidFail:(TURNSocket *)sender{

}
#pragma mark 个人中心
-(void)getMyVcardBlock:(void(^)(BOOL,XMPPvCardTemp*))c{
    self.myVcardBlock=c;

 XMPPvCardTemp*temp=[xmppvCardTempModule myvCardTemp];
    if (temp) {
        if (self.myVcardBlock) {
            self.myVcardBlock(YES,temp);
 
        }
    }
}
//观察myVcardTemp获取的状态
//收到xmppMyVcard的指针值
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    
    if ([jid.user isEqualToString:[userDefaults objectForKey:kXMPPmyJID]]) {
        
        
        if (self.myVcardBlock) {
            
            self.myVcardBlock(YES,vCardTemp);

        }
    }else{
    
        if (self.friendVcardBlock) {
            self.friendVcardBlock(YES,vCardTemp);
        }
    }
    
    
   
    
}


-(void)customVcardXML:(NSString*)Value name:(NSString*)Name myVcard:(XMPPvCardTemp*)myVcard
{
    NSXMLElement *elem = [myVcard elementForName:(Name)];
    
    if (elem == nil) {
        elem = [NSXMLElement elementWithName:(Name)];
        [myVcard addChild:elem];
    }
    [elem setStringValue:(Value)];
}
-(void)upData:(XMPPvCardTemp*)vCard
{
    [xmppvCardTempModule updateMyvCardTemp:vCard];
}

#pragma mark 同意好友请求
//同意
-(void)agreeRequest:(NSString*)name
{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:userDOMAIN resource:ZIYUANMING];
    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    XMPPPresence*temp=nil;
        for (XMPPPresence*pre in subscribeArray)
        {
            if ([pre.from.user isEqualToString:name])
            {
                temp=pre;
            }
        }

    if (temp) {
        [self.subscribeArray removeObject:temp];

    }
   }
#pragma mark 拒绝好友请求
//拒绝
-(void)reject:(NSString*)name{
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:userDOMAIN resource:ZIYUANMING];
   [xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    XMPPPresence*temp=nil;
    for (XMPPPresence*pre in subscribeArray)
    {
        if ([pre.from.user isEqualToString:name])
        {
            temp=pre;
        }
    }
    
    if (temp) {
        [self.subscribeArray removeObject:temp];
        
    }
    
}
#pragma mark 获得好友的资料Vcard
-(XMPPvCardTemp*)friendsVcard:(NSString*)useId{
    
    NSLog(@"%@",useId);
 XMPPvCardTemp*tempvCard=   [xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithUser:useId domain:userDOMAIN resource:ZIYUANMING] shouldFetch:YES];

    return tempvCard;

}
//扩展方法
-(void)friendsVcard:(NSString *)useId Block:(void(^)(BOOL,XMPPvCardTemp*))a{
    self.friendVcardBlock=a;
    XMPPvCardTemp*tempvCard=   [xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithUser:useId domain:userDOMAIN resource:ZIYUANMING] shouldFetch:YES];
    
    if (tempvCard) {
        self.friendVcardBlock(YES,tempvCard);
    }
    
    
}


#pragma mark 别人是否同意好友请求以及上线下线更新
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{  //
    
    NSString *presenceType = [presence type];
    
    NSLog(@"好友状态更新   user--%@   type---%@  status--%@ ",[[presence from] user],presenceType,[presence status]);
    XMPPJID *jid = [XMPPJID jidWithUser:[presence from].user domain:userDOMAIN resource:ZIYUANMING];
    if ([presenceType isEqualToString:@"subscribe"]) {
        if (subscribeArray.count==0) {
            [self.subscribeArray addObject:presence];
        }else{
            BOOL isExist=NO;
            for (XMPPPresence*pre in subscribeArray)
            {
                if ([pre.from.user isEqualToString:presence.from.user])
                {
                    isExist=YES;
                }
            }
            if (!isExist) {
                [self.subscribeArray addObject:presence];
            }
        }

        
    }
    if ([presenceType isEqualToString:@"unsubscribed"]) {
        //拒绝
        [xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    }
    if ([presenceType isEqualToString:@"unsubscribe"]) {
        [xmppRoster unsubscribePresenceFromUser:jid];
    }
    if ([presenceType isEqualToString:@"subscribed"]) {
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];//同意
    }
    if (self.friendType) {
        self.friendType(YES);
    }
   
 
    
    
//	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

#pragma mark 添加好友 可以带一个消息
-(void)addSomeBody:(NSString *)userId Newmessage:(NSString*)message
{//添加好友
    if (message) {
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:userId domain:userDOMAIN resource:ZIYUANMING]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        [xmppStream sendElement:mes];
    }
    
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithUser:userId domain:userDOMAIN resource:ZIYUANMING]];
}
#pragma mark 删除好友
-(void)removeBuddy:(NSString *)name
{//删除好友
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:userDOMAIN resource:ZIYUANMING];
    
    [ xmppRoster removeUser:jid];
}
#pragma mark 发送消息
-(void)sendMessageWithJID:(NSString*)jidStr Message:(NSString*)message Type:(NSString *)type{
    
   
   NSArray*array= [jidStr componentsSeparatedByString:@"@"];
    
    NSLog(@"截取出来的~%@",array);
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:array[0] domain:userDOMAIN resource:ZIYUANMING]];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"%@%@",type,message]]];
    
    //执行发送消息
    [xmppStream sendElement:mes];

    //messageFrom,messageTo,messageContent,messageDate,messageType
    ZCMessageObject*model=[[ZCMessageObject alloc]initWithFrom:[userDefaults objectForKey:kXMPPmyJID] to:array[0] content:[NSString stringWithFormat:@"%@%@",type,message] time:[NSDate date] chatType:ChatType_single];
    //保存最近聊天记录
    
    BOOL isSucceed=[ZCMessageObject save:model];
    if (isSucceed) {
        NSLog(@">>>>>发送消息存储数据库成功<<<<<<");
    }

    
    //进行广播
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:nil];
}
/****************************/
#pragma mark 消息发送完成 有待测试
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
}
#pragma mark 消息发送失败 有待测试
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
}
#pragma mark 处理接收到的单聊群聊消息（内部调用）
-(void)receiveMessage:(XMPPMessage*)message{
    
    NSString*fromName=[[[[message from]bare]componentsSeparatedByString:@"@"]objectAtIndex:0];
    NSString*type=[[[[message from]bare]componentsSeparatedByString:@"@"]objectAtIndex:1];
    
    NSString*body=[[message elementForName:@"body"] stringValue];
    ZCMessageObject*object=[[ZCMessageObject alloc]initWithFrom:fromName to:[userDefaults objectForKey:kXMPPmyJID] content:body time:[NSDate date] chatType:[type hasPrefix:userDOMAIN] ? ChatType_single : ChatType_Group];
    
    [ZCMessageObject save:object];
    if (![self.chatPerson isEqualToString:NONE]) {
      
        self.accept(object);
    }else{
        
        NSString*numStr=  [self saveWeiduMessage:fromName];
        
        if (self.badgeValue) {
            self.badgeValue.badgeValue=numStr;
        }
        
        if ([yanzhengxiaoxi objectForKey:fromName]) {
            [yanzhengxiaoxi setObject:body forKey:fromName];//判断是否是验证信息的消息
            
        }
    }
     [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:nil];
}
/****************************/
#pragma mark 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{

    if ([[message elementForName:@"body"] stringValue]) {
        [self receiveMessage:message];
    }

  NSXMLElement*mucElement=  [message elementForName:@"x"];
   NSArray*spaceArray= [mucElement namespaces];
    
   [spaceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       if ([[obj stringValue] isEqualToString:@"http://jabber.org/protocol/muc#user"]) {
           [self aboutMucRoom:message];
           
       }
   }];
}

#pragma mark 好友列表
-(NSArray*)friendsList:(void(^)(BOOL))c{
    self.friendType=c;
    NSManagedObjectContext*context=[xmppRosterStorage mainThreadManagedObjectContext];
    NSEntityDescription*entity=[NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSString*currentJid=[NSString stringWithFormat:@"%@@%@",[userDefaults objectForKey:kXMPPmyJID],userDOMAIN];
    
    //谓词搜索条件为streamBareJidStr关键词
     NSPredicate*predicate=[NSPredicate predicateWithFormat:@"streamBareJidStr==%@",currentJid];
    NSFetchRequest*request=[[NSFetchRequest alloc]init];
    [request setEntity:entity];
    [request setPredicate:predicate];//筛选条件
    NSError*error;
    NSArray*friends=[context executeFetchRequest:request error:&error];//从数据库中取出数据
    NSMutableArray*guanzhu=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray*beiguanzhu=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray*duifang=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray*haoyou=[NSMutableArray arrayWithCapacity:0];
    
    for (XMPPUserCoreDataStorageObject*object in friends) {
        
        if ([object.subscription isEqualToString:@"to"]) {
            [guanzhu addObject:object];
            
        }else{
            if ([object.subscription isEqualToString:@"from"]) {
                [beiguanzhu addObject:object];
            }else{
                if ([object.subscription isEqualToString:@"none"]) {
                    [duifang addObject:object];
                }else{
                    if ([object.subscription isEqualToString:@"both"]) {
                        [haoyou addObject:object];
                                           }
                }}}}

        

        

    NSLog(@"%d",haoyou.count);

    NSArray*list=@[haoyou,guanzhu,beiguanzhu,duifang];

    return list;

}
//获得头像
- (UIImage *)avatarForUser:(XMPPUserCoreDataStorageObject *) user
{
    UIImage* photo;
    if (user.photo)
    {
        photo = user.photo;
    }
    else
    {
        NSData *photoData =  [xmppvCardAvatarModule photoDataForJID:user.jid];;
        XMPPvCardTemp*myVcard1 =  [xmppvCardTempModule vCardTempForJID: user.jid shouldFetch:YES];
        
        if (photoData != nil) {
            
            NSLog(@"获得头像的是谁----%@",user.jidStr);
            
            photo = [UIImage imageWithData:[myVcard1 photo]];
        } else {
            NSLog(@"头像没有获得的是谁----%@",user.jidStr);
            photo=[UIImage imageNamed:@"logo_2@2x.png"];
        }
    }
    
    return photo;
    
}

#pragma mark 注册
-(void)registerMothod:(void(^)(BOOL))b
{
    logoinorSignin=YES;
    sharedManager.signin=b;
    //进行连接，连接失败 在进行注册操作
    [sharedManager connectLogoin:^(BOOL isSucceed) {
        //登录必定是失败，然后进行注册步骤
       
        if ([xmppStream supportsInBandRegistration]) {
            
            NSError *error ;
            [xmppStream setMyJID:[XMPPJID jidWithUser:[userDefaults objectForKey:kXMPPmyJID] domain:userDOMAIN resource:@"IOS"]];
            
            //domain 服务器主机名字
            //resource 这个是一个标示
            if (![xmppStream registerWithPassword:[userDefaults objectForKey:kXMPPmyPassword]error:&error]) {
                
                sharedManager.signin(NO);
            }
        }

    }];

    

}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    //重复注册了用户名
    [xmppStream disconnect];
   sharedManager.signin(NO);
    logoinorSignin=NO;
    NSLog(@"注册名已存在");
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{//注册成功
   
    [xmppStream disconnect];
     sharedManager.signin(YES);
    logoinorSignin=NO;
    NSLog(@"注册成功");
}

#pragma mark Connect/disconnect  登录

- (BOOL)connectLogoin:(void(^)(BOOL))a
{
    sharedManager.logoin=a;
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    

	NSString *myJID = [userDefaults stringForKey:kXMPPmyJID];
	NSString *myPassword = [userDefaults stringForKey:kXMPPmyPassword];
    
    NSLog(@"%@",myJID);

	
	if (myJID == nil || myPassword == nil) {
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"警告" message:@"检查是否输入了用户名密码" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
		return NO;
	}

    [xmppStream setMyJID:[XMPPJID jidWithUser:myJID domain:IP resource:ZIYUANMING]];
    password=myPassword;
	NSError *error = nil;
    //进行连接
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"连接错误");
        
        UIAlertView*al=[[UIAlertView alloc]initWithTitle:nil message:@"服务器连接失败" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [al show];
        
        
        return NO;
    }
    
    
	return YES;
    
}
- (void)disconnect
{
   
    [userDefaults removeObjectForKey:kXMPPmyJID];
    [userDefaults removeObjectForKey:kXMPPmyPassword];
    [userDefaults synchronize];
    
    //发送离线消息
	[self goOffline];
	[xmppStream disconnect];
}
- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
    
    
}

#pragma mark XMPPStream Delegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    
    //将要开始连接
    NSLog(@"将要开始连接");
    
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	NSLog(@"连接成功%@",password);
	
	isXmppConnected = YES;
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSLog(@"完成认证，发送在线状态");
	[self goOnline];
    [xmppRoster fetchRoster];
    sharedManager.logoin(YES);
    
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	NSLog(@"认证错误");
    if (!logoinorSignin) {
      [xmppStream disconnect];
    }
    
    sharedManager.logoin(NO);
    
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	//DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
        #pragma clang diagnostic pop
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
 
}


- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    // type="available" is implicit
    [xmppStream sendElement:presence];
    NSLog(@"发送完在线状态");
	
}
#pragma mark 设置当前聊天人是谁
-(void)valuationChatPersonName:(NSString*)name IsPush:(BOOL)isPush MessageBlock:(void(^)(ZCMessageObject*))a
{
    self.accept=a;
    if (isPush) {
        self.chatPerson=name;
    }else{
        self.chatPerson=NONE;
    }
}
#pragma mark 保存未读消息
-(NSString*)saveWeiduMessage:(NSString*)fromName
{
   
    NSMutableDictionary*weiduMessage=[NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:weiduMESSAGE]];
    if (weiduMessage==nil) {
        weiduMessage=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    int pageNum;
    
    if (![weiduMessage objectForKey:fromName]) {
        pageNum=1;
    }else{
        pageNum=[[weiduMessage objectForKey:fromName] intValue];
        pageNum++;
    }
    [weiduMessage setObject:[NSString stringWithFormat:@"%d",pageNum] forKey:fromName];
    
    NSArray*numArray=[weiduMessage allValues];
    int num=0;
    for (NSString*str in numArray) {
        num=+[str intValue];
    }
    
    [userDefaults setObject:weiduMessage forKey:weiduMESSAGE];
    [userDefaults synchronize];
    
    return [NSString stringWithFormat:@"%d",num];
}
-(NSArray*)messageRecord{
    NSManagedObjectContext *context = [xmppMessageArchivingCoreDataStorage  mainThreadManagedObjectContext ];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    //判断是否有联系人
    if ([self.chatPerson isEqualToString:NONE]) {
        return nil;
    }
    //搜索当前联系人的信息
    NSPredicate*predicate=[NSPredicate predicateWithFormat:@"bareJidStr==%@",self.chatPerson];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
#pragma  mark 按照时间进行筛选
    
    [request setPredicate:predicate];//筛选条件
    NSError *error ;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    
    NSLog(@"%d",messages.count);
    
    for (XMPPMessageArchiving_Message_CoreDataObject *object in messages) {
        NSLog(@"y用户列表%@",object.bareJidStr);
        
    }
   
    return messages;


}
#pragma mark --------配置XML流---------
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    userDefaults=[NSUserDefaults standardUserDefaults];
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
    xmppReconnect = [[XMPPReconnect alloc] init];

    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    xmppvCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    
	[xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
	[xmppStream setHostName:IP];
	[xmppStream setHostPort:5222];
	
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    self.subscribeArray=[NSMutableArray arrayWithCapacity:0];
    
    NSString*myjid=  [userDefaults objectForKey:kXMPPmyJID];
    if ([userDefaults objectForKey:myjid]) {
        self.yanzhengxiaoxi=[userDefaults objectForKey:myjid];
    }else{
        self.yanzhengxiaoxi=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    [xmppRosterStorage mainThreadManagedObjectContext];
    
}
#pragma mark 更新花名册状态！发生在好友请求里面
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    NSLog(@"花名册代理触发   user--%@   type---%@  status--%@ ",[[presence from] user],presenceType,[presence status]);
    XMPPJID *jid = [XMPPJID jidWithUser:[presence from].user domain:userDOMAIN resource:ZIYUANMING];
    
    if ([presenceType isEqualToString:@"unsubscribed"]) {
        
        [xmppRoster rejectPresenceSubscriptionRequestFrom:jid];//拒绝
    }
    
    if ([presenceType isEqualToString:@"subscribed"]) {
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];//同意
    }
    
    
}



- (void)dealloc
{
    
    
	[self teardownStream];
    
}
- (void)teardownStream
{
    
	[xmppStream removeDelegate:self];
    
	[xmppReconnect         deactivate];
    [xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    
    
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    
}


#pragma mark FLO扩展
/*- (XMPPStream *)floXMPPStream
{
    return xmppStream;
}

-  (XMPPRoster *)floXMPPRoster
{
    return xmppRoster;
}*/

@end
