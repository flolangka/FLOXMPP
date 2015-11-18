//
//  MyappViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-10.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MyappViewController.h"
#import "FMDBManager.h"
#import "UIImageView+WebCache.h"
#import "APPTableViewCell.h"
#import "WebViewController.h"

@interface MyappViewController ()
{
    FMDBManager*manager;
}

@end

@implementation MyappViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self createTableView];
    [self loadData];
}
-(void)themeChange{
    [self.tableView reloadData];
}
-(void)loadData{
    manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
    self.dataArr=[manager loadModel];
    [self.tableView reloadData];
}
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //_tableView.editing=NO;
    [self.view addSubview:self.tableView];
}
//导航条
-(void)createNav{
    self.title=@"我的应用";
    [self createLeftBtn];
    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.bounds=CGRectMake(0, 0, 25, 25);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"bianji.png"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"queding.png"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=rightItem;
}
//编辑按钮
-(void)rightItemClick:(UIButton*)button{
    button.selected=!button.selected;
    self.tableView.editing=button.selected;
    
    if(!button.selected){
        [manager loadUpdata:self.dataArr];
    }
}
#pragma mark tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    APPTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[APPTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
        cell.backgroundColor=[UIColor clearColor];
        
    }
    [cell UIconfig:self.dataArr[indexPath.row] indexpath:indexPath];
    cell.rightButton.hidden=YES;
    cell.rightSwitch.hidden=YES;

    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"lift_id"]]]]){//应用
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"lift_id"]]]];
    }else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"plugin_url"]]]]){//插件
        WebViewController*web=[[WebViewController alloc]init];
        web.urlStr=self.dataArr[indexPath.row][@"plugin_url"];
        UINavigationController*nav=[[UINavigationController alloc]initWithRootViewController:web];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }else{
        
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        [self.dataArr removeObjectAtIndex:indexPath.row];
        //[self.tableView reloadData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [manager loadUpdata:self.dataArr];
    }
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSString*str=self.dataArr[sourceIndexPath.row];
    [self.dataArr removeObjectAtIndex:sourceIndexPath.row];
    //插入新数据
    [self.dataArr insertObject:str atIndex:destinationIndexPath.row];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 1;
//}
//行缩进

//-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSUInteger row = [indexPath row];
//    return row;
//}

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
