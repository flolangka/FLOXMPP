//
//  FLOChatMessageModel.h
//  XMPPChat
//
//  Created by admin on 15/12/21.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLOChatRecordModel;

@interface FLOChatMessageModel : NSObject

//来自哪里
@property (nonatomic, copy) NSString *messageFrom;
//发送给谁
@property (nonatomic, copy) NSString *messageTo;
//内容:文字、声音、图片内容前缀[0]、[1]、[2]
@property (nonatomic, copy) NSString *messageContent;
//时间
@property (nonatomic, strong) NSDate *messageDate;

- (instancetype)initWithDictionary:(NSDictionary *)infoDic;
- (NSDictionary *)infoDictionary;

//生成聊天人记录
- (FLOChatRecordModel *)chatRecord;

@end
