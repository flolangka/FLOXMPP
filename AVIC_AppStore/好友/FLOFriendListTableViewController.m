//
//  FLOFriendListTableViewController.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOFriendListTableViewController.h"
#import "XMPPManager.h"
#import "FLOChatListFriendRequestTVC.h"

#import "MQChatViewManager.h"
#import "MQAssetUtil.h"

@interface FLOFriendListTableViewController ()

{
    XMPPManager *manager;
    NSMutableArray *dataArr;
}

@end

@implementation FLOFriendListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    manager = [XMPPManager manager];
    [self configDataArrWithFriendList:manager.xmppMyFriends];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configDataArrWithFriendList:manager.xmppMyFriends];
    [self.tableView reloadData];
}

- (void)configDataArrWithFriendList:(NSArray *)friendList
{
    dataArr = [NSMutableArray arrayWithArray:friendList];
    
    for (int i=0; i < friendList.count; i++) {
        XMPPUserMemoryStorageObject *obj = friendList[i];
        NSString *displayName = obj.displayName;
        if ([displayName hasSuffix:xmppDomain]) {
            NSRange range = [displayName rangeOfString:xmppDomain];
            displayName = [displayName substringToIndex:range.location-1];
        }
        
        if ([manager.xmppRooms containsObject:displayName]) {
            [dataArr removeObject:obj];
        }
    }
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
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLOChatListFriendRequestTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"friendRequestCellID" forIndexPath:indexPath];
    XMPPUserMemoryStorageObject *obj = dataArr[indexPath.row];
    
    NSString *displayName = obj.displayName;
    if ([displayName hasSuffix:xmppDomain]) {
        NSRange range = [displayName rangeOfString:xmppDomain];
        displayName = [displayName substringToIndex:range.location-1];
    }
    cell.titleL.text = displayName;
    cell.imageV.image = [UIImage imageNamed:@"call_list_qcall_entry"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //聊天页面
    XMPPUserMemoryStorageObject *obj = dataArr[indexPath.row];
    NSString *displayName = obj.displayName;
    if ([displayName hasSuffix:xmppDomain]) {
        NSRange range = [displayName rangeOfString:xmppDomain];
        displayName = [displayName substringToIndex:range.location-1];
    }
    
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager setNavTitleText:displayName];
    [chatViewManager enableRoundAvatar:YES];
    [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"call_list_qcall_entry"]];
    [chatViewManager setincomingDefaultAvatarImage:[UIImage imageNamed:@"taylor_swift"]];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}


@end
