//
//  FLOFriendRequestTVC.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOFriendRequestTVC.h"
#import "FLOFriendRequestTVCell.h"
#import "XMPPManager.h"

@interface FLOFriendRequestTVC ()

@end

@implementation FLOFriendRequestTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)agreeAction:(UIButton *)sender {
    FLOFriendRequestTVCell *cell = (FLOFriendRequestTVCell *)[[sender superview] superview];
    NSIndexPath *indexPAth = [self.tableView indexPathForCell:cell];
    
    [[XMPPManager manager] agreeAddFriendRequest:_dataArr[indexPAth.row]];
    
    [self.dataArr removeObjectAtIndex:indexPAth.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPAth] withRowAnimation:UITableViewRowAnimationTop];
}

- (IBAction)rejectAction:(UIButton *)sender {
    FLOFriendRequestTVCell *cell = (FLOFriendRequestTVCell *)[[sender superview] superview];
    NSIndexPath *indexPAth = [self.tableView indexPathForCell:cell];
    
    [[XMPPManager manager] rejectAddFriendRequest:_dataArr[indexPAth.row]];
    
    [self.dataArr removeObjectAtIndex:indexPAth.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPAth] withRowAnimation:UITableViewRowAnimationTop];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLOFriendRequestTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequestTVCellID" forIndexPath:indexPath];
    
    cell.userNameL.text = _dataArr[indexPath.row];
    cell.iconImageV.image = [UIImage imageNamed:@"conversation_address-book_avatar"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
}

@end
