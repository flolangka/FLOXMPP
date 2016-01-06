//
//  MQChatViewService.h
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQBaseMessage.h"
#import <UIKit/UIKit.h>
#import "MQChatViewConfig.h"

@protocol MQChatViewServiceDelegate <NSObject>

/**
 *  获取到了更多历史消息
 *
 *  @param cellNumber 需要显示的cell数量
 *  @param isLoadOver 是否已经获取完了历史消息
 */
- (void)didGetHistoryMessagesWithCellNumber:(NSInteger)cellNumber isLoadOver:(BOOL)isLoadOver;

/**
 *  已经更新了这条消息的数据，通知tableView刷新界面
 */
- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath;

/**
 *  通知viewController更新tableView；
 */
- (void)reloadChatTableView;

/**
 *  通知viewController将tableView滚动到底部
 */
- (void)scrollTableViewToBottom;

/**
 *  通知viewController收到了消息
 */
- (void)didReceiveMessage;

/**
 *  通知viewController显示toast
 *
 *  @param content 显示的文字
 */
- (void)showToastViewWithContent:(NSString *)content;

@end

/**
 * @brief 聊天界面的ViewModel
 *
 * MQChatViewService管理者MQChatViewController中的数据
 */
@interface MQChatViewService : NSObject

//单聊对象
@property (nonatomic, copy) NSString *chatUser;

//群聊群组名称
@property (nonatomic, copy) NSString *chatRoom;

/** MQChatViewService的委托 */
@property (nonatomic, weak) id<MQChatViewServiceDelegate> delegate;

/** cellModel的缓存 */
@property (nonatomic, strong) NSMutableArray *cellModels;

/** 聊天界面的宽度 */
@property (nonatomic, assign) CGFloat chatViewWidth;

- (instancetype)initWithChatUser:(NSString *)userName chatViewWidth:(CGFloat)width;
- (instancetype)initWithChatRoom:(NSString *)roomName chatViewWidth:(CGFloat)width;

- (void)saveChatRecord;

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages;

/**
 * 发送文字消息
 */
- (void)sendTextMessageWithContent:(NSString *)content;

/**
 * 发送图片消息
 */
- (void)sendImageMessageWithImage:(UIImage *)image;

/**
 * 以AMR格式语音文件的形式，发送语音消息
 * @param filePath AMR格式的语音文件
 */
- (void)sendVoiceMessageWithAMRFilePath:(NSString *)filePath;

/**
 * 发送“用户正在输入”的消息
 */
- (void)sendUserInputtingWithContent:(NSString *)content;

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)resendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData;

/**
 *  更新cellModel中的frame，针对转屏的场景
 */
- (void)updateCellModelsFrame;

/**
 *  发送本地欢迎语消息
 *  @warnning 该消息不需要发送给后端
 */
- (void)sendLocalWelcomeChatMessage;

/**
 *  点击了某个消息
 *
 *  @param index 点击的消息index
 */
- (void)didTapMessageCellAtIndex:(NSInteger)index;



@end
