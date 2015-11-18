//
//  FloTabBarV.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/29.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloTabBarV : UIView

@property (weak, nonatomic) IBOutlet UIImageView *xiaoxiImageV;
@property (weak, nonatomic) IBOutlet UILabel *xiaoxiLabel;

@property (weak, nonatomic) IBOutlet UIImageView *txlImageV;
@property (weak, nonatomic) IBOutlet UILabel *txlLabel;

@property (weak, nonatomic) IBOutlet UIImageView *groupImageV;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;

@property (nonatomic, assign) UITabBarController *tabBarC;

@end
