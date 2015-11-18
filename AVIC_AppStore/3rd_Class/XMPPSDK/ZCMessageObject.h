//
//  ZCMessageObject.h
//  XMPPEncapsulation
//
//  Created by ZC on 14-4-10.
//  Copyright (c) 2014年 ZC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEFIND.h"

@interface ZCMessageObject : NSObject
//来自哪里
@property (nonatomic, copy) NSString *messageFrom;
//发送给谁
@property (nonatomic, copy) NSString *messageTo;
//内容:msgType为内容前缀0/1/2/3
@property (nonatomic, copy) NSString *messageContent;
//时间
@property (nonatomic, strong) NSDate *messageDate;
//聊天类型：单聊or群聊
@property (nonatomic, copy) NSString *chatType;

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to content:(NSString *)body time:(NSDate *)time chatType:(NSString *)chatType;


//数据库增删改查
+(BOOL)save:(ZCMessageObject*)aMessage;

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;

//更新类型，追加群主题
+(void)upDateType:(NSDictionary*)dic;
@end
