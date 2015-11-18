//
//  HelpViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-16.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "HelpViewController.h"
#import "WebViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"帮助";
    [self createLeftBtn];
    [self createTableView];
}
-(void)themeChange{
    
}
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        cell.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
        
    }
    if(indexPath.row==0){
        cell.textLabel.text=@"应用常见问题";
    }else if (indexPath.row==1){
        cell.textLabel.text=@"移动应用门户介绍";
    }else if (indexPath.row==2){
        cell.textLabel.text=@"版本升级介绍";
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WebViewController*web=[[WebViewController alloc]init];
    UINavigationController*nav=[[UINavigationController alloc]initWithRootViewController:web];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
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
