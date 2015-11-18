//
//  APPTableViewCell.h
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-15.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPTableViewCell : UITableViewCell<UIActionSheetDelegate>

@property(nonatomic,strong)UIImageView*appIcon;//图标
@property(nonatomic,strong)UILabel*appTitle;//名称
@property(nonatomic,strong)UILabel*appDescribe;//描述
@property(nonatomic,strong)UIButton*rightButton;//右按钮
@property(nonatomic,strong)UISwitch*rightSwitch;//右开关
@property(nonatomic,assign)float cellHeight;//行高
@property(nonatomic,strong)NSDictionary*dic;

//获取数据
-(void)UIconfig:(NSDictionary*)dic indexpath:(NSIndexPath*)indexpath;

@end
