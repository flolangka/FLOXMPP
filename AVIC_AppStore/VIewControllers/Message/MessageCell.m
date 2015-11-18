//
//  MessageCell.m
//  FriendsChat
//
//  Created by @HUI on 15-3-26.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "MessageCell.h"
#import "Photo.h"
#import "ZCControl.h"
#import "DEFIND.h"

@implementation MessageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
    }
    return  self;
}

-(void)makeUI{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //左边
    //左头像
    leftHeaderImageView=[ZCControl createImageViewWithFrame:CGRectMake(10, 5, 30, 30) ImageName:nil];
    leftHeaderImageView.layer.cornerRadius=15;
    leftHeaderImageView.layer.masksToBounds=YES;
    [self.contentView addSubview:leftHeaderImageView];
    //左气泡
    leftBubbleImageView=[ZCControl createImageViewWithFrame:CGRectZero ImageName:nil];
    //chat_send_nor.png
    UIImage*leftImage=[UIImage imageNamed:@"ReceiverTextNodeBkg.png"];
    //设置拉伸规则
    leftImage=[leftImage stretchableImageWithLeftCapWidth:40 topCapHeight:28];
    leftBubbleImageView.image=leftImage;
    [self.contentView addSubview:leftBubbleImageView];
    
    //左内容
    leftLabel=[ZCControl createLabelWithFrame:CGRectZero Font:10 Text:nil];
    [leftBubbleImageView addSubview:leftLabel];
    //左图片
    leftImageView=[ZCControl createImageViewWithFrame:CGRectZero ImageName:nil];
    [leftBubbleImageView addSubview:leftImageView];
    //左语音
    leftVoiceButton=[ZCControl createButtonWithFrame:CGRectMake(20, 20, 30, 30) ImageName:nil Target:self Action:@selector(voiceButtonClick) Title:nil];
    UIImage*leftVoiceImage=[UIImage imageNamed:@"ReceiverVoiceNodePlaying.png"];
    [leftVoiceButton setImage:leftVoiceImage forState:UIControlStateNormal];
    [leftBubbleImageView addSubview:leftVoiceButton];
    
    
    //右边
    //右头像
    //[UIScreen mainScreen].bounds 获取屏幕大小 bounds的x和y永远是0
    int x=[UIScreen mainScreen].bounds.size.width;
    
    
    rightHeaderImageView=[ZCControl createImageViewWithFrame:CGRectMake(x-40, 5, 30, 30) ImageName:nil];
    rightHeaderImageView.layer.cornerRadius=15;
    rightHeaderImageView.layer.masksToBounds=YES;
    [self.contentView addSubview:rightHeaderImageView];
    //右气泡
    rightBubbleImageView=[ZCControl createImageViewWithFrame:CGRectZero ImageName:nil];
    //chat_send_nor.png
    UIImage*rightImage=[UIImage imageNamed:@"SenderTextNodeBkg.png"];
    //设置拉伸规则
    rightImage=[rightImage stretchableImageWithLeftCapWidth:40 topCapHeight:28];
    rightBubbleImageView.image=rightImage;
    [self.contentView addSubview:rightBubbleImageView];
    
    //右内容
    
    rightLabel=[ZCControl createLabelWithFrame:CGRectZero Font:10 Text:nil];
    [rightBubbleImageView addSubview:rightLabel];
    //右图片
    rightImageView=[ZCControl createImageViewWithFrame:CGRectZero ImageName:nil];
    [rightBubbleImageView addSubview:rightImageView];
    //右语音
    rightVoiceButton=[ZCControl createButtonWithFrame:CGRectMake(20, 20, 30, 30) ImageName:nil Target:self Action:@selector(voiceButtonClick) Title:nil];
    UIImage*rightVoiceImage=[UIImage imageNamed:@"SenderVoiceNodePlaying.png"];
    [rightVoiceButton setImage:rightVoiceImage forState:UIControlStateNormal];
    [rightBubbleImageView addSubview:rightVoiceButton];
    
    
}
-(void)configUI:(XMPPMessageArchiving_Message_CoreDataObject*)object leftImage:(UIImage*)leftImage rightImage:(UIImage*)rightImage{
    leftHeaderImageView.image=leftImage;
    rightHeaderImageView.image=rightImage;
    
    NSString*str=object.body;
    if (str.length > 1) {
        self.message=[str substringFromIndex:1];
        
    }
    
    //获取屏幕宽度
    int x=[UIScreen mainScreen].bounds.size.width;
    if (object.outgoing) {
        //自己
        rightHeaderImageView.hidden=NO;
        rightBubbleImageView.hidden=NO;
        leftHeaderImageView.hidden=YES;
        leftBubbleImageView.hidden=YES;
        if ([str hasPrefix:MESSAGE_Text]) {
            rightImageView.hidden=YES;
            rightVoiceButton.hidden=YES;
            rightLabel.hidden=NO;
            
            //计算文字大小
            CGSize size=[str boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil].size;
            rightLabel.frame=CGRectMake(20, 20, size.width, size.height);
            rightLabel.text=self.message;
            //气泡大小
            rightBubbleImageView.frame=CGRectMake(x-50-size.width-40, 5, size.width+40, size.height+40);
        }else{
            if ([str hasPrefix:MESSAGE_Image]) {
                //图片
                rightImageView.hidden=NO;
                rightVoiceButton.hidden=YES;
                rightLabel.hidden=YES;
                //字符串转图片
                UIImage*image=[Photo string2Image:_message];
                float width=image.size.width>160?160:image.size.width;
                float height=image.size.height>160?160:image.size.height;
                rightImageView.frame=CGRectMake(20, 20, width, height);
                rightBubbleImageView.frame=CGRectMake(x-50-width-40, 5, width+40, height+40);
                rightImageView.image=image;
            }else{
                if ([str hasPrefix:MESSAGE_Voice]) {
                    rightImageView.hidden=YES;
                    rightVoiceButton.hidden=NO;
                    rightLabel.hidden=YES;
                    
                    rightBubbleImageView.frame=CGRectMake(x-50-70, 5, 70, 70);
                }else{
                    if ([str hasPrefix:MESSAGE_File]) {
                        rightImageView.hidden=YES;
                        rightVoiceButton.hidden=YES;
                        rightLabel.hidden=NO;
                        rightLabel.text=@"文件";
                        rightLabel.frame=CGRectMake(20, 20, 100, 20);
                        rightBubbleImageView.frame=CGRectMake(x-50-140, 5, 140, 60);
                        
                    }else{
                        rightImageView.hidden=YES;
                        rightVoiceButton.hidden=YES;
                        rightLabel.hidden=NO;
                        rightLabel.text=@"未知信息";
                        rightLabel.frame=CGRectMake(20, 20, 100, 20);
                        rightBubbleImageView.frame=CGRectMake(x-50-140, 5, 140, 60);
                        
                    }
                    
                }
                
            }
            
            
        }
        
        
        
    }else{
        //对方
        rightHeaderImageView.hidden=YES;
        rightBubbleImageView.hidden=YES;
        leftHeaderImageView.hidden=NO;
        leftBubbleImageView.hidden=NO;
        
        if ([str hasPrefix:MESSAGE_Text]) {
            leftLabel.hidden=NO;
            leftImageView.hidden=YES;
            leftVoiceButton.hidden=YES;
            //计算文字大小
            CGSize size=[_message boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} context:nil].size;
            
            leftLabel.frame=CGRectMake(20, 20, size.width, size.height);
            leftBubbleImageView.frame=CGRectMake(50, 5, size.width+40, size.height+40);
            leftLabel.text=_message;
        }else{
            
            if ([str hasPrefix:MESSAGE_Image]) {
                leftLabel.hidden=YES;
                leftImageView.hidden=NO;
                leftVoiceButton.hidden=YES;
                
                UIImage*image=[Photo string2Image:_message];
                float width=image.size.width>160?160:image.size.width;
                float height=image.size.height>160?160:image.size.height;
                leftImageView.frame=CGRectMake(20, 20, width, height);
                leftBubbleImageView.frame=CGRectMake(50,5, width+40, height+40);
                leftImageView.image=image;
                
                
            }else{
                if ([str hasPrefix:MESSAGE_Voice]) {
                    leftLabel.hidden=YES;
                    leftImageView.hidden=YES;
                    leftVoiceButton.hidden=NO;
                    leftBubbleImageView.frame=CGRectMake(50, 5, 70, 70);
                }else{
                    if ([str hasPrefix:MESSAGE_File]) {
                        leftLabel.hidden=NO;
                        leftImageView.hidden=YES;
                        leftVoiceButton.hidden=YES;
                        leftLabel.text=@"文件";
                        leftLabel.frame=CGRectMake(20, 20, 100, 20);
                        leftBubbleImageView.frame=CGRectMake(50, 5, 140, 60);
                        
                    }else{
                        leftLabel.hidden=NO;
                        leftImageView.hidden=YES;
                        leftVoiceButton.hidden=YES;
                        leftLabel.text=@"未知信息";
                        leftLabel.frame=CGRectMake(20, 20, 100, 20);
                        leftBubbleImageView.frame=CGRectMake(50, 5, 140, 60);
                        
                        
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    
    
}

#pragma mark 播放语音
-(void)voiceButtonClick{
    
    
}

- (void)awakeFromNib {
    // Initialization code
    [self makeUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
