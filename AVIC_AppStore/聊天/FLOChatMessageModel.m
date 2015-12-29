//
//  FLOChatMessageModel.m
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOChatMessageModel.h"
#import "FLOChatRecordModel.h"
#import "XMPPComment.h"

@implementation FLOChatMessageModel

/**
 *  消息对象初始化方法
 *
 *  @param infoDic 参数字典
 *
 *  @return 消息对象
 */
- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _messageFrom = infoDic[@"messageFrom"];
        _messageTo = infoDic[@"messageTo"];
        _messageContent = infoDic[@"messageContent"];
        
        NSString *lastStr = [infoDic[@"messageContent"] substringFromIndex:4];
        NSRange range = [lastStr rangeOfString:@"]"];
        double timeInterval = [[lastStr substringToIndex:range.location] doubleValue];
        _messageDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    return self;
}

/**
 *  参数字典
 *
 *  @return 参数值字典，供插入数据库使用
 */
- (NSDictionary *)infoDictionary
{
    return @{@"messageFrom": _messageFrom,
             @"messageTo": _messageTo,
             @"messageContent": _messageContent};
}

- (FLOChatRecordModel *)chatRecord
{
    NSString *myUserName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    NSString *chatUser = _messageTo;
    if ([_messageTo isEqualToString:myUserName]) {
        chatUser = _messageFrom;
    }
    return [[FLOChatRecordModel alloc] initWithDictionary:@{@"chatUser": chatUser,
                                                            @"lastMessage": _messageContent,
                                                            @"lastTime": [NSString stringWithFormat:@"%f", [_messageDate timeIntervalSince1970]]}];
}

@end
