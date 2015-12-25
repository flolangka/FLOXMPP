//
//  FLOChatListTableViewCell.h
//  AVIC_AppStore
//
//  Created by admin on 15/12/25.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLOChatListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UILabel *msgL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;

@end
