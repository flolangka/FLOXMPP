//
//  MessageCell.h
//  FriendsChat
//
//  Created by @HUI on 15-3-26.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMPPMessageArchiving_Message_CoreDataObject;

@interface MessageCell : UITableViewCell
{
    //左边
    //左头像
    UIImageView*leftHeaderImageView;
    //左气泡
    UIImageView*leftBubbleImageView;
    //左内容
    UILabel*leftLabel;
    //左图片
    UIImageView*leftImageView;
    //左语音
    UIButton*leftVoiceButton;
    
    //右边
    //右头像
    UIImageView*rightHeaderImageView;
    //右气泡
    UIImageView*rightBubbleImageView;
    //右内容
    UILabel*rightLabel;
    //右图片
    UIImageView*rightImageView;
    //右语音
    UIButton*rightVoiceButton;
}

//记录一个内容 这里记录内容为播放语音做预留，播放使用单例来进行播放
@property(nonatomic,copy)NSString*message;

//刷新数据
-(void)configUI:(XMPPMessageArchiving_Message_CoreDataObject*)object leftImage:(UIImage*)leftImage rightImage:(UIImage*)rightImage;

@end
