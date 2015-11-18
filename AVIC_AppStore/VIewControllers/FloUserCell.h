//
//  FloUserCell.h
//  XMPPChat
//
//  Created by admin on 15/9/15.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCMessageObject;

@interface FloUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

- (void)setContentChatHistoryUserWithArray:(NSArray *)arr;

@end
