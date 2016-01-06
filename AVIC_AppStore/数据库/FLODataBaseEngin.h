//
//  FLODataBaseEngin.h
//  AVIC_AppStore
//
//  Created by admin on 15/12/25.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLOChatRecordModel;
@class FLOChatMessageModel;

@interface FLODataBaseEngin : NSObject

+ (instancetype)shareInstance;

//清除用户的数据(将应用中的数据库替换document中的数据库)
- (void)resetDatabase;

//聊天人记录
- (void)saveChatRecord:(FLOChatRecordModel *)chatRecord;
- (NSArray *)selectAllChatRecords;

//聊天消息记录
- (void)insertChatMessages:(NSArray *)chatMessages;
- (NSArray *)selectAllChatMessagesWithChatUser:(NSString *)chatUser;

- (BOOL)messageIsExits:(FLOChatMessageModel *)message;
- (NSArray *)selectAllChatMessagesWithChatRoom:(NSString *)roomName;

@end
