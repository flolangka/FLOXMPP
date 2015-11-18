//
//  FloTreeTableView.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FloTTVNode;

@protocol TreeTableCellDelegate <NSObject>

-(void)cellClick : (FloTTVNode *)node;

@end


@interface FloTreeTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , weak) id<TreeTableCellDelegate> treeTableCellDelegate;
@property (nonatomic , strong) NSArray *data;//传递过来已经组织好的数据（全量数据）
@property (nonatomic , strong) NSMutableArray *tempData;//用于存储数据源（部分数据）

-(instancetype)initWithFrame:(CGRect)frame withData : (NSArray *)data;

@end
