//
//  FLOChatRecordModel.m
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLOChatRecordModel.h"

@implementation FLOChatRecordModel

- (instancetype)initWithDictionary:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
        _chatUser = infoDic[@"chatUser"];
        _lastMessage = infoDic[@"lastMessage"];
        _lastDate = [NSDate dateWithTimeIntervalSince1970:[infoDic[@"lastTime"] doubleValue]];
    }
    return self;
}

- (NSDictionary *)infoDictionary
{
    return @{@"chatUser": _chatUser,
             @"lastMessage": _lastMessage,
             @"lastTime": [NSString stringWithFormat:@"%f", [_lastDate timeIntervalSince1970]]};
}

@end
