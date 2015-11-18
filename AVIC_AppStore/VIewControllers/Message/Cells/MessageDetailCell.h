//
//  MessageDetailCell.h
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-22.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol messageDelegate <NSObject>

-(void)addRemoveRows:(UIButton*)button;

@end

@interface MessageDetailCell : UITableViewCell
{
    UIImageView*_imageView;//分割线
    UILabel*_msgDate;//消息发送时间
    
        //UIImageView*_editView;//删除框
}
@property(nonatomic,strong)UILabel*msgLable;//消息
@property(nonatomic,strong)UIImageView*msgImageview;//消息背景
@property(nonatomic,strong)UIButton*selectedBtn;//选中按钮
@property(nonatomic,weak)id<messageDelegate>delegate;

//数据请求
-(void)configUI:(NSDictionary*)dic indexpath:(NSIndexPath *)indexPath isEdit:(BOOL)edit;

@end
