//
//  RootViewController.h
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-11.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "WebRequest.h"

@interface RootViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    //下拉
    MJRefreshHeaderView*header;
    //上拉
    MJRefreshFooterView*footer;
}
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,copy)NSString*URL;//网址
@property(nonatomic,copy)NSString*space;//命名空间
@property(nonatomic,copy)NSString*methodname;//方法名
@property(nonatomic,strong)NSMutableArray*dataArr;//请求数据
@property(nonatomic,strong)NSMutableDictionary*dataDic;
@property(nonatomic,copy)NSString*themePath;//主题

-(void)creatRefresh;//刷新
-(void)createLeftBtn;//导航左按钮

@end
