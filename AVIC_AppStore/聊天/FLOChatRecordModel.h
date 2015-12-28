//
//  FLOChatRecordModel.h
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLOChatRecordModel : NSObject

@property (nonatomic, copy) NSString *chatUser;
@property (nonatomic, copy) NSString *lastMessage;
@property (nonatomic, strong) NSDate *lastDate;

- (instancetype)initWithDictionary:(NSDictionary *)infoDic;
- (NSDictionary *)infoDictionary;

@end
