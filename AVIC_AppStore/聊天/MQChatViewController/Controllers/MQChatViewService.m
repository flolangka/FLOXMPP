//
//  MQChatViewService.m
//  MeiQiaSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 MeiQia Inc. All rights reserved.
//


#import "MQChatViewService.h"
#import "MQTextMessage.h"
#import "MQImageMessage.h"
#import "MQVoiceMessage.h"
#import "MQTextCellModel.h"
#import "MQImageCellModel.h"
#import "MQVoiceCellModel.h"
#import "MQTipsCellModel.h"
#import "MQMessageDateCellModel.h"
#import <UIKit/UIKit.h>
#import "MQToast.h"
#import "VoiceConverter.h"
#import "MQAssetUtil.h"
#import "MQBundleUtil.h"

#import "XMPPManager.h"
#import "FLODataBaseEngin.h"
#import "FLOChatMessageModel.h"
#import "FLOChatRecordModel.h"

static NSInteger const kMQChatMessageMaxTimeInterval = 60;

/** 一次获取历史消息数的个数 */
//static NSInteger const kMQChatGetHistoryMessageNumber = 20;

@interface MQChatViewService() <MQCellModelDelegate>

{
    NSString *lastMessageBody; //最后一条消息内容
    NSString *voiceRecordPath;
    NSString *imageRecordPath;
}

@end

@implementation MQChatViewService {

}

- (instancetype)initWithChatUser:(NSString *)userName chatViewWidth:(CGFloat)width
{
    if (self = [super init]) {
        //创建录音保存文件夹
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
        voiceRecordPath = [docPath stringByAppendingPathComponent:@"voiceRecord"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:voiceRecordPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:voiceRecordPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        imageRecordPath = [docPath stringByAppendingPathComponent:@"imageRecord"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imageRecordPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:imageRecordPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.cellModels = [[NSMutableArray alloc] init];
        self.chatUser = userName;
        self.chatViewWidth = width;
        
        //加载最后的20条记录
        NSArray *localRecordMessages = [[FLODataBaseEngin shareInstance] selectAllChatMessagesWithChatUser:_chatUser];
        [self addCellModelsWithMessages:localRecordMessages];
        
        //设置接收消息操作
        [XMPPManager manager].receiveMessageBlock = ^(FLOChatMessageModel *msgModel){
            id<MQCellModelProtocol> cellModel = [self cellModelWithChatMessageModel:msgModel];
            if (!cellModel) {
                return;
            }
            [self addCellModelAfterReceivedWithCellModel:cellModel];
        };
    }
    return self;
}

#pragma mark - 保存ChatRecord
- (void)saveChatRecord
{
    if (!lastMessageBody) {
        return;
    }
    NSString *timeStr = [NSString stringWithFormat:@"%f", [[[_cellModels lastObject] getCellDate] timeIntervalSince1970]];
    FLOChatRecordModel *charRecord = [[FLOChatRecordModel alloc] initWithDictionary:@{@"chatUser": _chatUser,
                                                                                      @"lastMessage": lastMessageBody,
                                                                                      @"lastTime": timeStr}];
    [[FLODataBaseEngin shareInstance] saveChatRecord:charRecord];
}

#pragma mark - 本地聊天记录
- (void)addCellModelsWithMessages:(NSArray *)messages
{
    for (int i = 0; i < messages.count; i++) {
        FLOChatMessageModel *msg = messages[i];
        id<MQCellModelProtocol> cellModel = [self cellModelWithChatMessageModel:msg];
        
        if (!cellModel) {
            continue;
        }
        [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
        [_cellModels addObject:cellModel];
    }
}

- (id<MQCellModelProtocol>)cellModelWithChatMessageModel:(FLOChatMessageModel *)msg
{
    if ([msg.messageContent hasPrefix:Message_Prefix_Text]) {
        //文字
        MQTextMessage *message = [[MQTextMessage alloc] initWithContent:[self messageBodyWithMessageContent:msg.messageContent]];
        if ([msg.messageFrom isEqualToString:_chatUser]) {
            message.fromType = MQChatMessageIncoming;
        }
        
        MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
        [cellModel updateCellMessageDate:msg.messageDate];
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        
        return cellModel;
    } else if ([msg.messageContent hasPrefix:Message_Prefix_Image]) {
        //图片
        MQImageMessage *message = [[MQImageMessage alloc] initWithImage:[UIImage imageWithContentsOfFile:[imageRecordPath stringByAppendingPathComponent:[self messageBodyWithMessageContent:msg.messageContent]]]];
        if ([msg.messageFrom isEqualToString:_chatUser]) {
            message.fromType = MQChatMessageIncoming;
        }
        
        MQImageCellModel *cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
        [cellModel updateCellMessageDate:msg.messageDate];
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        
        return cellModel;
    } else if ([msg.messageContent hasPrefix:Message_Prefix_Voice]) {
        //声音
        NSData *wavData = [NSData dataWithContentsOfFile:[voiceRecordPath stringByAppendingPathComponent:[self messageBodyWithMessageContent:msg.messageContent]]];
        MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:wavData];
        if ([msg.messageFrom isEqualToString:_chatUser]) {
            message.fromType = MQChatMessageIncoming;
        }
        
        MQVoiceCellModel *cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
        [cellModel updateCellMessageDate:msg.messageDate];
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;

        return cellModel;
    }
    return nil;
}

- (NSString *)messageBodyWithMessageContent:(NSString *)msg
{
    NSString *lastStr = [msg substringFromIndex:4];
    NSRange range = [lastStr rangeOfString:@"]"];
    return [lastStr substringFromIndex:range.location+1];
}

#pragma mark - 收到新消息
- (void)addCellModelAfterReceivedWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self didReceiveMessageWithCellModel:cellModel];
}

- (void)didReceiveMessageWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [self playReceivedMessageSound];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
            [self.delegate didReceiveMessage];
        }
    }
}

#pragma 增加cellModel并刷新tableView
- (void)addCellModelAndReloadTableViewWithModel:(id<MQCellModelProtocol>)cellModel {
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
}

/**
 * 获取更多历史聊天消息
 */
- (void)startGettingHistoryMessages {
    
}

/**
 *  获取最旧的cell的日期，例如text/image/voice等
 */
- (NSDate *)getFirstServiceCellModelDate {
    for (NSInteger index = 0; index < self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
#pragma 开发者可在下面添加自己更多的业务cellModel，以便能正确获取历史消息
        if ([cellModel isKindOfClass:[MQTextCellModel class]] ||
            [cellModel isKindOfClass:[MQImageCellModel class]] ||
            [cellModel isKindOfClass:[MQVoiceCellModel class]]) {
            return [cellModel getCellDate];
        }
    }
    return [NSDate date];
}

/**
 * 发送文字消息
 */
- (void)sendTextMessageWithContent:(NSString *)content {
    MQTextMessage *message = [[MQTextMessage alloc] initWithContent:content];
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    
    //发送
    lastMessageBody = content;
    NSString *prefix = [Message_Prefix_Text stringByAppendingString:[NSString stringWithFormat:@"[%f]", [[NSDate date] timeIntervalSince1970]]];
    
    [[XMPPManager manager] sendTextMessage:[prefix stringByAppendingString:content] toUser:_chatUser];
    
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self reloadChatTableView];
    });
}

/**
 * 发送图片消息
 */
- (void)sendImageMessageWithImage:(UIImage *)image {
    MQImageMessage *message = [[MQImageMessage alloc] initWithImage:image];
    MQImageCellModel *cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    
    //发送
    lastMessageBody = @"[图片]";
    NSString *imageFileName = [_chatUser stringByAppendingFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[imageRecordPath stringByAppendingPathComponent:imageFileName] atomically:YES];
    
    NSString *prefix = [Message_Prefix_Image stringByAppendingString:[NSString stringWithFormat:@"[%f]", [[NSDate date] timeIntervalSince1970]]];
    [[XMPPManager manager] sendImageMessage:[prefix stringByAppendingString:imageFileName] image:image toUser:_chatUser];
    
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self reloadChatTableView];
    });
}

/**
 * 以AMR格式语音文件的形式，发送语音消息
 * @param filePath AMR格式的语音文件
 */
- (void)sendVoiceMessageWithAMRFilePath:(NSString *)filePath
{
    //将AMR格式转换成WAV格式，以便使iPhone能播放
    NSString *voiceFileName = [_chatUser stringByAppendingFormat:@"%f.wav", [[NSDate date] timeIntervalSince1970]];
    [VoiceConverter amrToWav:filePath wavSavePath:[voiceRecordPath stringByAppendingPathComponent:voiceFileName]];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    NSData *wavData = [NSData dataWithContentsOfFile:[voiceRecordPath stringByAppendingPathComponent:voiceFileName]];
    MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:wavData];
    [self sendVoiceMessageWithWAVData:wavData voiceMessage:message voiceFileName:voiceFileName];
}

/**
 *  发送语音消息
 *
 *  @param wavData       wav数据
 *  @param message       声音消息对象
 *  @param voiceFileName 声音存储的文件名：user129323103900102.wav
 */
- (void)sendVoiceMessageWithWAVData:(NSData *)wavData voiceMessage:(MQVoiceMessage *)message voiceFileName:(NSString *)voiceFileName
{
    MQVoiceCellModel *cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    
    //声音发送
    lastMessageBody = @"[语音]";
    NSString *prefix = [Message_Prefix_Voice stringByAppendingString:[NSString stringWithFormat:@"[%f]", [[NSDate date] timeIntervalSince1970]]];
    [[XMPPManager manager] sendVoiceMessage:[prefix stringByAppendingString:voiceFileName] WavData:wavData toUser:_chatUser];
    
    //模仿发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cellModel.sendStatus = MQChatMessageSendStatusSuccess;
        [self reloadChatTableView];
    });
}

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)resendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData {
    [self.cellModels removeObjectAtIndex:index];
    //判断删除这个model的之前的model是否为date，如果是，则删除时间cellModel
    if (index < 0 || self.cellModels.count <= index-1) {
        return;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index-1];
    if (cellModel && [cellModel isKindOfClass:[MQMessageDateCellModel class]]) {
        [self.cellModels removeObjectAtIndex:index-1];
    }
    //重新发送
    if (resendData[@"text"]) {
        [self sendTextMessageWithContent:resendData[@"text"]];
    }
    if (resendData[@"image"]) {
        [self sendImageMessageWithImage:resendData[@"image"]];
    }
    if (resendData[@"voice"]) {
        [self sendVoiceMessageWithAMRFilePath:resendData[@"voice"]];
    }
}

/**
 * 发送“用户正在输入”的消息
 */
- (void)sendUserInputtingWithContent:(NSString *)content {

}

/**
 *  在尾部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beAddedCellModel 准备被add的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)addMessageDateCellAtLastWithCurrentCellModel:(id<MQCellModelProtocol>)beAddedCellModel {
    id<MQCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    NSDate *lastDate = lastCellModel ? [lastCellModel getCellDate] : [NSDate date];
    NSDate *beAddedDate = [beAddedCellModel getCellDate];
    //判断被add的cell的时间比最后一个cell的时间是否要大（说明currentCell是第一个业务cell，此时显示时间cell）
    BOOL isLastDateLargerThanNextDate = lastDate.timeIntervalSince1970 > beAddedDate.timeIntervalSince1970;
    //判断被add的cell比最后一个cell的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = beAddedDate.timeIntervalSince1970 - lastDate.timeIntervalSince1970 >= kMQChatMessageMaxTimeInterval;
    if (!isLastDateLargerThanNextDate && !isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    MQMessageDateCellModel *cellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:beAddedDate cellWidth:self.chatViewWidth];
    [self.cellModels addObject:cellModel];
    return true;
}

/**
 *  在首部增加cellModel之前，先判断两个时间间隔是否过大，如果过大，插入一个MessageDateCellModel
 *
 *  @param beInsertedCellModel 准备被insert的cellModel
 *  @return 是否插入了时间cell
 */
- (BOOL)insertMessageDateCellAtFirstWithCellModel:(id<MQCellModelProtocol>)beInsertedCellModel {
    NSDate *firstDate = [NSDate date];
    if (self.cellModels.count == 0) {
        return false;
    }
    id<MQCellModelProtocol> firstCellModel = [self.cellModels objectAtIndex:0];
    if (![firstCellModel isServiceRelatedCell]) {
        return false;
    }
    NSDate *beInsertedDate = [beInsertedCellModel getCellDate];
    firstDate = [firstCellModel getCellDate];
    //判断被insert的Cell的date和第一个cell的date的时间间隔是否超过阈值
    BOOL isDateTimeIntervalLargerThanThreshold = firstDate.timeIntervalSince1970 - beInsertedDate.timeIntervalSince1970 >= kMQChatMessageMaxTimeInterval;
    if (!isDateTimeIntervalLargerThanThreshold) {
        return false;
    }
    MQMessageDateCellModel *cellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:firstDate cellWidth:self.chatViewWidth];
    [self.cellModels insertObject:cellModel atIndex:0];
    return true;
}

/**
 * 从后往前从cellModels中获取到业务相关的cellModel，即text, image, voice等；
 */
/**
 *  从cellModels中搜索第一个业务相关的cellModel，即text, image, voice等；
 *  @warning 业务相关的cellModel，必须满足协议方法isServiceRelatedCell
 *
 *  @param searchIndex             search的起始位置
 *  @param isSearchFromBottomToTop search的方向 YES：从后往前搜索  NO：从前往后搜索
 *
 *  @return 搜索到的第一个业务相关的cellModel
 */
- (id<MQCellModelProtocol>)searchOneBussinessCellModelWithIndex:(NSInteger)searchIndex isSearchFromBottomToTop:(BOOL)isSearchFromBottomToTop{
    if (self.cellModels.count <= searchIndex) {
        return nil;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:searchIndex];
    //判断获取到的cellModel是否是业务相关的cell，如果不是则继续往前取
    if ([cellModel isServiceRelatedCell]){
        return cellModel;
    }
    NSInteger nextSearchIndex = isSearchFromBottomToTop ? searchIndex - 1 : searchIndex + 1;
    [self searchOneBussinessCellModelWithIndex:nextSearchIndex isSearchFromBottomToTop:isSearchFromBottomToTop];
    return nil;
}

/**
 * 通知viewController更新tableView；
 */
- (void)reloadChatTableView {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(reloadChatTableView)]) {
            [self.delegate reloadChatTableView];
        }
    }
}

#ifndef INCLUDE_MEIQIA_SDK
/**
 * 使用MQChatViewControllerDemo的时候，调试用的方法，用于收取和上一个message一样的消息
 */
- (void)loadLastMessage {
    id<MQCellModelProtocol> lastCellModel = [self searchOneBussinessCellModelWithIndex:self.cellModels.count-1 isSearchFromBottomToTop:true];
    if (lastCellModel) {
        if ([lastCellModel isKindOfClass:[MQTextCellModel class]]) {
            MQTextCellModel *textCellModel = (MQTextCellModel *)lastCellModel;
            MQTextMessage *message = [[MQTextMessage alloc] initWithContent:[textCellModel.cellText string]];
            message.fromType = MQChatMessageIncoming;
            MQTextCellModel *newCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
        } else if ([lastCellModel isKindOfClass:[MQImageCellModel class]]) {
            MQImageCellModel *imageCellModel = (MQImageCellModel *)lastCellModel;
            MQImageMessage *message = [[MQImageMessage alloc] initWithImage:imageCellModel.image];
            message.fromType = MQChatMessageIncoming;
            MQImageCellModel *newCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
        } else if ([lastCellModel isKindOfClass:[MQVoiceCellModel class]]) {
            MQVoiceCellModel *voiceCellModel = (MQVoiceCellModel *)lastCellModel;
            MQVoiceMessage *message = [[MQVoiceMessage alloc] initWithVoiceData:voiceCellModel.voiceData];
            message.fromType = MQChatMessageIncoming;
            MQVoiceCellModel *newCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:message cellWidth:self.chatViewWidth delegate:self];
            [self.cellModels addObject:newCellModel];
        }
    }
    //text message
    MQTextMessage *textMessage = [[MQTextMessage alloc] initWithContent:@"Let's Rooooooooooock~"];
    textMessage.fromType = MQChatMessageIncoming;
    MQTextCellModel *textCellModel = [[MQTextCellModel alloc] initCellModelWithMessage:textMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:textCellModel];
    //image message
    MQImageMessage *imageMessage = [[MQImageMessage alloc] initWithImagePath:@"https://s3.cn-north-1.amazonaws.com.cn/pics.meiqia.bucket/65135e4c4fde7b5f"];
    imageMessage.fromType = MQChatMessageIncoming;
    MQImageCellModel *imageCellModel = [[MQImageCellModel alloc] initCellModelWithMessage:imageMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:imageCellModel];
    //tip message
    //    MQTipsCellModel *tipCellModel = [[MQTipsCellModel alloc] initCellModelWithTips:@"主人，您的客服离线啦~" cellWidth:self.chatViewWidth];
    //    [self.cellModels addObject:tipCellModel];
    //voice message
    MQVoiceMessage *voiceMessage = [[MQVoiceMessage alloc] initWithVoicePath:@"http://7xiy8i.com1.z0.glb.clouddn.com/test.amr"];
    voiceMessage.fromType = MQChatMessageIncoming;
    MQVoiceCellModel *voiceCellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:voiceMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:voiceCellModel];
    
    [self reloadChatTableView];
    [self playReceivedMessageSound];
}
#endif

#pragma MQCellModelDelegate
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId {
    //获取又更新的cell的index
    NSInteger index = [self getIndexOfCellWithMessageId:messageId];
    if (index < 0) {
        return;
    }
    [self updateCellWithIndex:index];
}

- (NSInteger)getIndexOfCellWithMessageId:(NSString *)messageId {
    for (NSInteger index=0; index<self.cellModels.count; index++) {
        id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
        if ([[cellModel getCellMessageId] isEqualToString:messageId]) {
            //更新该cell
            return index;
        }
    }
    return -1;
}

//通知tableView更新该indexPath的cell
- (void)updateCellWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didUpdateCellModelWithIndexPath:)]) {
            [self.delegate didUpdateCellModelWithIndexPath:indexPath];
        }
    }
}

#pragma 更新cellModel中的frame
- (void)updateCellModelsFrame {
    for (id<MQCellModelProtocol> cellModel in self.cellModels) {
        [cellModel updateCellFrameWithCellWidth:self.chatViewWidth];
    }
}

#pragma 欢迎语
- (void)sendLocalWelcomeChatMessage {
    if (![MQChatViewConfig sharedConfig].enableChatWelcome) {
        return ;
    }
    //消息时间
    MQMessageDateCellModel *dateCellModel = [[MQMessageDateCellModel alloc] initCellModelWithDate:[NSDate date] cellWidth:self.chatViewWidth];
    [self.cellModels addObject:dateCellModel];
    //欢迎消息
    MQTextMessage *welcomeMessage = [[MQTextMessage alloc] initWithContent:[MQChatViewConfig sharedConfig].chatWelcomeText];
    welcomeMessage.fromType = MQChatMessageIncoming;
    welcomeMessage.userName = [MQChatViewConfig sharedConfig].agentName;
    welcomeMessage.userAvatarImage = [MQChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    welcomeMessage.sendStatus = MQChatMessageSendStatusSuccess;
    MQTextCellModel *cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:welcomeMessage cellWidth:self.chatViewWidth delegate:self];
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
}

#pragma 点击了某个cell
- (void)didTapMessageCellAtIndex:(NSInteger)index {
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    if ([cellModel isKindOfClass:[MQVoiceCellModel class]]) {
        MQVoiceCellModel *voiceCellModel = (MQVoiceCellModel *)cellModel;
        voiceCellModel.isPlayed = true;
#ifdef INCLUDE_MEIQIA_SDK
        [MQServiceToViewInterface didTapMessageWithMessageId:[cellModel getCellMessageId]];
#endif
    }
}

#pragma 播放声音
- (void)playReceivedMessageSound {
    if (![MQChatViewConfig sharedConfig].enableMessageSound) {
        return;
    }
    [MQChatFileUtil playSoundWithSoundFile:[MQAssetUtil resourceWithName:[MQChatViewConfig sharedConfig].incomingMsgSoundFileName]];
}

#pragma 开发者可将自定义的message添加到此方法中
/**
 *  将消息数组中的消息转换成cellModel，并添加到cellModels中去;
 *
 *  @param messages             消息实体array
 *  @param isInsertAtFirstIndex 是否将messages插入到顶部
 *
 *  @return 返回转换为cell的个数
 */
- (NSInteger)saveToCellModelsWithMessages:(NSArray *)messages isInsertAtFirstIndex:(BOOL)isInsertAtFirstIndex{
    NSInteger cellNumber = 0;
    NSMutableArray *historyMessages = [[NSMutableArray alloc] initWithArray:messages];
    if (isInsertAtFirstIndex) {
        //如果是历史消息，则将历史消息插入到cellModels的首部
        [historyMessages removeAllObjects];
        for (MQBaseMessage *message in messages) {
            [historyMessages insertObject:message atIndex:0];
        }
    }
    for (MQBaseMessage *message in historyMessages) {
        id<MQCellModelProtocol> cellModel;
        if ([message isKindOfClass:[MQTextMessage class]]) {
            cellModel = [[MQTextCellModel alloc] initCellModelWithMessage:(MQTextMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQImageMessage class]]) {
            cellModel = [[MQImageCellModel alloc] initCellModelWithMessage:(MQImageMessage *)message cellWidth:self.chatViewWidth delegate:self];
        } else if ([message isKindOfClass:[MQVoiceMessage class]]) {
            cellModel = [[MQVoiceCellModel alloc] initCellModelWithMessage:(MQVoiceMessage *)message cellWidth:self.chatViewWidth delegate:self];
        }
        if (cellModel) {
            if (isInsertAtFirstIndex) {
                BOOL isInsertDateCell = [self insertMessageDateCellAtFirstWithCellModel:cellModel];
                if (isInsertDateCell) {
                    cellNumber ++;
                }
                [self.cellModels insertObject:cellModel atIndex:0];
                cellNumber ++;
            } else {
                BOOL isAddDateCell = [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
                if (isAddDateCell) {
                    cellNumber ++;
                }
                [self.cellModels addObject:cellModel];
                cellNumber ++;
            }
        }
    }
    [self reloadChatTableView];
    return cellNumber;
}

#ifdef INCLUDE_MEIQIA_SDK

#pragma 顾客上线的逻辑
- (void)setClientOnline {
    //上线
    __weak typeof(self) weakSelf = self;
    serviceToViewInterface = [[MQServiceToViewInterface alloc] init];
    [MQServiceToViewInterface setScheduledAgentWithAgentId:[MQChatViewConfig sharedConfig].scheduledAgentId agentGroupId:[MQChatViewConfig sharedConfig].scheduledGroupId];
    if ([MQChatViewConfig sharedConfig].MQClientId.length == 0 && [MQChatViewConfig sharedConfig].customizedId.length > 0) {
        [serviceToViewInterface setClientOnlineWithCustomizedId:[MQChatViewConfig sharedConfig].customizedId success:^(BOOL completion, NSString *agentName, NSArray *receivedMessages) {
            if (!completion) {
                //没有分配到客服
                agentName = [MQBundleUtil localizedStringForKey: agentName && agentName.length>0 ? agentName : @"no_agent_title"];
            }
            //获取顾客信息
            [weakSelf getClientInfo];
            //更新客服聊天界面标题
            [weakSelf updateChatTitleWithAgentName:agentName];
            if (receivedMessages) {
                [weakSelf saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex:false];
                if (weakSelf.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(scrollTableViewToBottom)]) {
                        [weakSelf.delegate scrollTableViewToBottom];
                    }
                }
            }
        } receiveMessageDelegate:self];
        return;
    }
    [serviceToViewInterface setClientOnlineWithClientId:[MQChatViewConfig sharedConfig].MQClientId success:^(BOOL completion, NSString *agentName, NSArray *receivedMessages) {
        if (!completion) {
            //没有分配到客服
            agentName = [MQBundleUtil localizedStringForKey: agentName && agentName.length>0 ? agentName : @"no_agent_title"];
        }
        //获取顾客信息
        [weakSelf getClientInfo];
        //更新客服聊天界面标题
        [weakSelf updateChatTitleWithAgentName:agentName];
        if (receivedMessages) {
            [weakSelf saveToCellModelsWithMessages:receivedMessages isInsertAtFirstIndex:false];
            if (weakSelf.delegate) {
                if ([weakSelf.delegate respondsToSelector:@selector(scrollTableViewToBottom)]) {
                    [weakSelf.delegate scrollTableViewToBottom];
                }
            }
        }
    } receiveMessageDelegate:self];
}

//获取顾客信息
- (void)getClientInfo {
    NSDictionary *clientInfo = [MQServiceToViewInterface getCurrentClientInfo];
    [MQServiceToViewInterface downloadMediaWithUrlString:[clientInfo objectForKey:@"avatar"] progress:^(float progress) {
    } completion:^(NSData *mediaData, NSError *error) {
        [MQChatViewConfig sharedConfig].outgoingDefaultAvatarImage = [UIImage imageWithData:mediaData];
    }];
}

- (void)updateChatTitleWithAgentName:(NSString *)agentName {
    NSString *viewTitle = agentName;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didScheduleClientWithViewTitle:)]) {
            [self.delegate didScheduleClientWithViewTitle:viewTitle];
        }
    }
}

- (void)addSystemTips{
    if (!isThereNoAgent) {
        return;
    }
    isThereNoAgent = false;
    if (!addedNoAgentTip) {
        addedNoAgentTip = true;
        [self addTipCellModelWithTips:[MQBundleUtil localizedStringForKey:@"no_agent_tips"]];
    }
}

#pragma MQServiceToViewInterfaceDelegate
- (void)didReceiveHistoryMessages:(NSArray *)messages {
    NSInteger cellNumber = 0;
    NSInteger messageNumber = 0;
    if (messages.count > 0) {
        cellNumber = [self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:true];
        messageNumber = messages.count;
    }
    //如果没有获取更多的历史消息，则也需要通知界面取消刷新indicator
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didGetHistoryMessagesWithCellNumber:isLoadOver:)]) {
            [self.delegate didGetHistoryMessagesWithCellNumber:cellNumber isLoadOver:messageNumber < kMQChatGetHistoryMessageNumber];
        }
    }
}

- (void)didReceiveNewMessages:(NSArray *)messages {
    if (messages.count == 0) {
        return;
    }
    //转换message to cellModel，并缓存
    [self saveToCellModelsWithMessages:messages isInsertAtFirstIndex:false];
    //eventMessage不响铃声
    if (messages.count > 1 || ![[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
        [self playReceivedMessageSound];
    }
    //更新界面title
    [self updateChatTitleWithAgentName:[MQServiceToViewInterface getCurrentAgentName]];
    //通知界面收到了消息
    BOOL isRefreshView = true;
    if (![MQChatViewConfig sharedConfig].enableEventDispaly && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
        isRefreshView = false;
    } else {
        if (messages.count == 1 && [[messages firstObject] isKindOfClass:[MQEventMessage class]]) {
            MQEventMessage *eventMessage = [messages firstObject];
            if (eventMessage.eventType == MQChatEventTypeAgentInputting) {
                isRefreshView = false;
            }
        }
    }
    if (self.delegate && isRefreshView) {
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
            [self.delegate didReceiveMessage];
        }
    }
}

- (void)didReceiveTipsContent:(NSString *)tipsContent {
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:tipsContent cellWidth:self.chatViewWidth];
    [self addCellModelAfterReceivedWithCellModel:cellModel];
}

- (void)addCellModelAfterReceivedWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addMessageDateCellAtLastWithCurrentCellModel:cellModel];
    [self didReceiveMessageWithCellModel:cellModel];
}

- (void)didReceiveMessageWithCellModel:(id<MQCellModelProtocol>)cellModel {
    [self addCellModelAndReloadTableViewWithModel:cellModel];
    [self playReceivedMessageSound];
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage)]) {
            [self.delegate didReceiveMessage];
        }
    }
}

- (void)didRedirectWithAgentName:(NSString *)agentName {
    [self updateChatTitleWithAgentName:agentName];
}

- (void)didSendMessageWithNewMessageId:(NSString *)newMessageId
                          oldMessageId:(NSString *)oldMessageId
                        newMessageDate:(NSDate *)newMessageDate
                            sendStatus:(MQChatMessageSendStatus)sendStatus
{
    //如果新的messageId和旧的messageId不同，且是发送成功状态，则表明肯定是分配成功的
    if (![newMessageId isEqualToString:oldMessageId] && sendStatus == MQChatMessageSendStatusSuccess) {
        NSString *agentName = [MQServiceToViewInterface getCurrentAgentName];
        isThereNoAgent = ![MQServiceToViewInterface isThereAgent];
        if (agentName.length > 0) {
            [self updateChatTitleWithAgentName:agentName];
        }
    } else {
        isThereNoAgent = true;
    }
    if (isThereNoAgent) {
        [self addSystemTips];
        [self updateChatTitleWithAgentName:[MQBundleUtil localizedStringForKey:@"no_agent_title"]];
    }
    NSInteger index = [self getIndexOfCellWithMessageId:oldMessageId];
    if (index < 0) {
        return;
    }
    id<MQCellModelProtocol> cellModel = [self.cellModels objectAtIndex:index];
    [cellModel updateCellMessageId:newMessageId];
    [cellModel updateCellSendStatus:sendStatus];
    if (newMessageDate) {
        [cellModel updateCellMessageDate:newMessageDate];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateCellWithIndex:index];
    });
}

- (void)addTipCellModelWithTips:(NSString *)tips {
    MQTipsCellModel *cellModel = [[MQTipsCellModel alloc] initCellModelWithTips:tips cellWidth:self.chatViewWidth];
    [self.cellModels addObject:cellModel];
    [self reloadChatTableView];
}

#endif

@end
