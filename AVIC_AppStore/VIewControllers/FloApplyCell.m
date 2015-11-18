//
//  FloApplyCell.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/14.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloApplyCell.h"
#import "DEFIND.h"

@implementation FloApplyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)agreeBtnAction:(UIButton *)sender {
    ZCXMPPManager *manager = [ZCXMPPManager sharedInstance];
    [manager agreeRequest:self.userNameLabel.text];
    [self configBtnDisenabled];
}

- (IBAction)rejectBtnAction:(UIButton *)sender {
    ZCXMPPManager *manager = [ZCXMPPManager sharedInstance];
    [manager reject:self.userNameLabel.text];
    [self configBtnDisenabled];
}

- (void)configBtnDisenabled
{
    self.agreeBtn.userInteractionEnabled = NO;
    self.agreeBtn.backgroundColor = [UIColor grayColor];
    self.rejectBtn.userInteractionEnabled = NO;
    self.rejectBtn.backgroundColor = [UIColor grayColor];
}

@end
