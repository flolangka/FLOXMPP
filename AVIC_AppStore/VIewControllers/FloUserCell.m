//
//  FloUserCell.m
//  XMPPChat
//
//  Created by admin on 15/9/15.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "FloUserCell.h"
#import "ZCMessageObject.h"

@implementation FloUserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentChatHistoryUserWithArray:(NSArray *)arr
{
    self.iconImageV.image = [UIImage imageNamed:@"sticker_tab_youxihou"];
    self.userNameL.text = arr[2];
    
    self.rightLabel.text = [self timeAgo:arr[1]];
    if ([arr[0] hasPrefix:MESSAGE_Text]) {
        self.detailL.text = [arr[0] substringFromIndex:1];
    } else {
        if ([arr[0] hasPrefix:MESSAGE_Image]) {
            self.detailL.text = @"[图片]";
        } else if([arr[0] hasPrefix:MESSAGE_Voice]){
            self.detailL.text = @"[语音]";
        } else if([arr[0] hasPrefix:MESSAGE_File]){
            self.detailL.text = @"[文件]";
        } else {
            self.detailL.text = @"";
        }
    }
}

-(NSString *)timeAgo:(NSDate *)date{
    //计算跟当前时间的时间差
    NSTimeInterval time = -[date timeIntervalSinceNow];
    
    if (time < 60) {
        return @"刚刚";
    }else if (time < 3600) {
        return [NSString stringWithFormat:@"%d 分钟前", (NSInteger)time/60];
    }else if (time < 3600 * 24) {
        return [NSString stringWithFormat:@"%d 小时前", (NSInteger)time/3600];
    }else if (time < 3600 * 24 * 30){
        return [NSString stringWithFormat:@"%d 天前", (NSInteger)time/(3600 * 24)];
    }else{
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
}


@end
