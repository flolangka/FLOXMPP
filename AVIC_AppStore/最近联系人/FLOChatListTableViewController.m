//
//  FLOChatListTableViewController.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOChatListTableViewController.h"
#import "XMPPManager.h"
#import "FLOFriendRequestTVC.h"
#import "FLOChatListTableViewCell.h"
#import "FLOChatListFriendRequestTVC.h"//cell
#import "FLODataBaseEngin.h"
#import "FLOChatRecordModel.h"

#import "MQChatViewManager.h"
#import "MQAssetUtil.h"
#import "NSDate+Utils.h"

@interface FLOChatListTableViewController ()

{
    XMPPManager *manager;
    NSMutableArray *dataArr;
}

@end

@implementation FLOChatListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    
    UITabBarController *tabBarController = self.tabBarController;
    UITabBarItem *item0 = tabBarController.tabBar.items[0];
    [item0 setTitle:@"消息"];
    
    dataArr = [NSMutableArray arrayWithObject:@[]];
    manager = [XMPPManager manager];
    
    __weak FLOChatListTableViewController *weakSelf = self;
    __weak NSMutableArray *weakDataArr = dataArr;
    manager.receiveFriendRequestBlock = ^(XMPPManager *xmppmanager) {
        [weakDataArr replaceObjectAtIndex:0 withObject:xmppmanager.friendRequests];
        [weakSelf.tableView reloadData];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshChatRecord];
    
    if ([manager.xmppStream isAuthenticated]) {
        //回调在进入聊天页面时会变，所以在此重置
        __weak FLOChatListTableViewController *weakSelf = self;
        __weak NSMutableArray *weakDataArr = dataArr;
        manager.receiveMessageBlock = ^(FLOChatMessageModel *msgModel) {
            NSArray *chatRecords = [[FLODataBaseEngin shareInstance] selectAllChatRecords];
            [weakDataArr removeObjectsInRange:NSMakeRange(1, weakDataArr.count-1)];
            [weakDataArr addObjectsFromArray:chatRecords];
            [weakSelf.tableView reloadData];
        };
        
        return;
    } else {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [manager autoAuthorizationSuccess:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                });
                
                [self refreshChatRecord];
            } failure:^(NSString *errorStr){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
                    [MBProgressTool showPromptViewInView:[UIApplication sharedApplication].keyWindow WithTitle:errorStr];
                });
            }];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutAction:(UIBarButtonItem *)sender {
    [manager logoutAndDisconnect];
    
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    [UD setObject:@"" forKey:kUserName];
    [UD synchronize];
    
    //删除聊天记录
    [[FLODataBaseEngin shareInstance] resetDatabase];
    
    //跳转到主页面
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDLoginVC"];
    [keyWindow makeKeyAndVisible];
}

#pragma mark - 获取chatRecord
- (void)refreshChatRecord
{
    NSArray *chatRecords = [[FLODataBaseEngin shareInstance] selectAllChatRecords];
    [dataArr removeObjectsInRange:NSMakeRange(1, dataArr.count-1)];
    [dataArr addObjectsFromArray:chatRecords];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        FLOChatListFriendRequestTVC *myCell = [tableView dequeueReusableCellWithIdentifier:@"friendRequestCellID" forIndexPath:indexPath];
        NSInteger num = [dataArr[0] count];
        myCell.imageV.image = [UIImage imageNamed:@"conversation_address-book_avatar"];
        myCell.titleL.text = [NSString stringWithFormat:@"您有%d条好友请求", num];
        cell = myCell;
    } else {
        FLOChatListTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"chatUserCellID" forIndexPath:indexPath];
        myCell.iconImageV.image = [UIImage imageNamed:@"call_list_qcall_entry"];
        
        FLOChatRecordModel *chatRecord = dataArr[indexPath.row];
        myCell.userNameL.text = chatRecord.chatUser;
        myCell.msgL.text = chatRecord.lastMessage;
        myCell.timeL.text = [NSString stringWithFormat:@"%d:%d %@", chatRecord.lastDate.hour, chatRecord.lastDate.minute, chatRecord.lastDate.stringYearMonthDayCompareToday];
        
        cell = myCell;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0 && [dataArr[0] count]>0) {
        FLOFriendRequestTVC *friendRequestTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDFiendRequestTV"];
        friendRequestTVC.dataArr = [NSMutableArray arrayWithArray:dataArr[0]];
        [self.navigationController pushViewController:friendRequestTVC animated:YES];
    } else if (indexPath.row > 0) {
        //聊天页面
        FLOChatRecordModel *chatRecord = dataArr[indexPath.row];
        
        MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
        [chatViewManager setNavTitleText:chatRecord.chatUser];
        [chatViewManager enableRoundAvatar:YES];
        [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"call_list_qcall_entry"]];
        [chatViewManager setincomingDefaultAvatarImage:[UIImage imageNamed:@"taylor_swift"]];
        [chatViewManager pushMQChatViewControllerInViewController:self];
    }
}

@end
