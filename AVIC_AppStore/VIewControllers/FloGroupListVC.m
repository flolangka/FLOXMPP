//
//  FloGroupListVC.m
//  FriendsChat
//
//  Created by admin on 15/9/16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FloGroupListVC.h"
#import "FloTabBarV.h"

@interface FloGroupListVC ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FloGroupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configTabBar];
}

- (void)configTabBar
{
    FloTabBarV *tabBarV = [[[NSBundle mainBundle] loadNibNamed:@"FloTabBarV" owner:nil options:nil] firstObject];
    tabBarV.groupImageV.image = [UIImage imageNamed:@"qunzuHL"];
    tabBarV.groupLabel.textColor = [UIColor blueColor];
    tabBarV.tabBarC = self.tabBarController;
    [self.view addSubview:tabBarV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
