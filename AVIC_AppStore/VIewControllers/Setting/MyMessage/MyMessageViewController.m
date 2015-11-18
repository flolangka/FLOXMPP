//
//  MyMessageViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-16.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MyMessageViewController.h"

@interface MyMessageViewController ()

@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"个人信息";
    [self createLeftBtn];
    [self createTableView];
}
-(void)themeChange{
    
}
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    //self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }
    return 3;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    }
    if(indexPath.section==0){
        cell.imageView.image=[UIImage imageNamed:@"touxiang.png"];
        cell.textLabel.text=@"席玉山";
        cell.detailTextLabel.text=@"信息技术服务人员";
    }else{
        if(indexPath.row==0){
            cell.textLabel.text=@"邮箱";
            
            UILabel*rightLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, cell.frame.size.height*0.5)];
            rightLable.text=@"123456@qq.com";
            rightLable.textAlignment=NSTextAlignmentRight;
            cell.accessoryView=rightLable;
        }else if(indexPath.row==1){
            cell.textLabel.text=@"电话";
            
            UILabel*rightLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, cell.frame.size.height*0.5)];
            rightLable.text=@"18888888888";
            rightLable.textAlignment=NSTextAlignmentRight;
            UIButton*callButton=[UIButton buttonWithType:UIButtonTypeCustom];
            callButton.frame=CGRectMake(rightLable.frame.size.width+1, 0, rightLable.frame.size.height, rightLable.frame.size.height);
            [callButton setBackgroundImage:[UIImage imageNamed:@"dianhua.png"] forState:UIControlStateNormal];
            [callButton addTarget:self action:@selector(callClick) forControlEvents:UIControlEventTouchUpInside];
            
            UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, rightLable.frame.size.width+rightLable.frame.size.height, rightLable.frame.size.height)];
            [view addSubview:rightLable];
            [view addSubview:callButton];
            cell.accessoryView=view;
        }else{
            UILabel*rightLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, cell.frame.size.height*0.5)];
            rightLable.text=@"010-88888888";
            rightLable.textAlignment=NSTextAlignmentRight;
            UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, rightLable.frame.size.width+rightLable.frame.size.height, rightLable.frame.size.height)];
            [view addSubview:rightLable];
            cell.accessoryView=view;
        }
    }
    return cell;
}
-(void)callClick{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://10086"]];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0.00001;
    }
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return self.view.frame.size.height*0.2;
    }
    return self.view.frame.size.height*0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
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
