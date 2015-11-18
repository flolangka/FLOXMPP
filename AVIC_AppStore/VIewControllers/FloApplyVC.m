//
//  FloApplyVC.m
//  FriendsChat
//
//  Created by admin on 15/9/16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FloApplyVC.h"
#import "FloApplyCell.h"
#import "DEFIND.h"

@interface FloApplyVC ()<UITableViewDelegate, UITableViewDataSource>

{
    ZCXMPPManager *manager;
}

@property (nonatomic, strong) NSMutableArray *datas;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FloApplyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    manager = [ZCXMPPManager sharedInstance];
    self.datas = manager.subscribeArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FloApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chuliUserCellID" forIndexPath:indexPath];
    
    XMPPPresence *presence = self.datas[indexPath.row];
    cell.userNameLabel.text = presence.from.user;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
