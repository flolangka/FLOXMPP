//
//  MessageTableViewCell.h
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-18.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UIImageView*msgIcon;//图标
@property(nonatomic,strong)UILabel*msgTitle;//标题
@property(nonatomic,strong)UILabel*msgDescribe;//详情
@property(nonatomic,strong)UILabel*msgDate;//日期
@property(nonatomic,strong)UILabel*msgNumber;//消息条数
@property(nonatomic,assign)float cellHeight;//行高

-(void)configUI:(NSDictionary*)dic;

@end
