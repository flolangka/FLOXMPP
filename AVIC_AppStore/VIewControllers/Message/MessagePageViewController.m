//
//  MessagePageViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MessagePageViewController.h"
#import "MessageTableViewCell.h"
#import "MsgDetailViewController.h"

@interface MessagePageViewController ()
{
    int isOpen[4];
}

@end

@implementation MessagePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"消息";
    [self createView];
    self.dataArr=[NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"]];
}

-(void)themeChange{
    [self.tableView reloadData];
}

-(void)createView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-49-64) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}


#pragma mark tableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return isOpen[section]>0?0:[self.dataArr[section]count];
    return self.dataArr.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[MessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        cell.backgroundColor=[UIColor clearColor];
    }
    [cell configUI:nil];
    UILabel*lable=[[UILabel alloc]initWithFrame:CGRectMake(cell.msgIcon.frame.size.width-10, 10, 20, 20)];
    lable.backgroundColor=[UIColor redColor];
    lable.text=@"2";
    lable.textColor=[UIColor whiteColor];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.clipsToBounds=YES;
    lable.layer.cornerRadius=10;
    lable.tag=333+indexPath.row;
    [cell.contentView addSubview:lable];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MsgDetailViewController*vc=[[MsgDetailViewController alloc]init];
    vc.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vc animated:YES];
    UILabel*lable=(UILabel*)[self.tableView viewWithTag:333+indexPath.row];
    [lable removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
