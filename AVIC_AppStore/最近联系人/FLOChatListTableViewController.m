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
#import <AudioToolbox/AudioToolbox.h>
#import <FLEXManager.h>

#import "MQChatViewManager.h"
#import "MQAssetUtil.h"
#import "NSDate+Utils.h"

@interface FLOChatListTableViewController ()

{
    XMPPManager *manager;
    NSMutableArray *dataArr;
    CALayer *topPromptLayer;
}

@end

@implementation FLOChatListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    [self configTabBar];
    topPromptLayer = [self promptLayer];
    
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
        [[UIApplication sharedApplication].keyWindow.layer addSublayer:topPromptLayer];
        [manager autoAuthorizationSuccess:^{
            AudioServicesPlaySystemSound(1055);
            [topPromptLayer removeFromSuperlayer];
            
            [self refreshChatRecord];
        } failure:^(NSString *errorStr){
            [topPromptLayer removeFromSuperlayer];
            
            [MBProgressTool showPromptViewInView:[UIApplication sharedApplication].keyWindow WithTitle:errorStr];
        }];
    }
}

//连接服务器提示框
- (CALayer *)promptLayer
{
    CALayer *proLayer = [[CALayer alloc] init];
    proLayer.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 24);
    proLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9].CGColor;
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.frame = CGRectMake(0, 3, [UIScreen mainScreen].bounds.size.width, 21);
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.alignmentMode = @"center";
    textLayer.fontSize = 13;
    textLayer.string = @"服务器跑了，正在拼命追赶....";
    
    [proLayer addSublayer:textLayer];
    return proLayer;
}

- (void)configTabBar
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    [tabBar setTintColor:[UIColor colorWithRed:0 green:180./255 blue:255./255 alpha:1.0]];
    UITabBarItem *item0 = tabBar.items[0];
    [item0 setTitle:@"消息"];
    [item0 setSelectedImage:[[UIImage imageNamed:@"tab_recent_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBar.items[1] setSelectedImage:[[UIImage imageNamed:@"tab_buddy_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBar.items[2] setSelectedImage:[[UIImage imageNamed:@"tab_qworld_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
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
    
    //删除图片、语音数据
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:@"voiceRecord"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:@"imageRecord"] error:nil];
    
    //跳转到主页面
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDLoginVC"];
    [keyWindow makeKeyAndVisible];
}

- (IBAction)FLEXAction:(UIBarButtonItem *)sender {
    [[FLEXManager sharedManager] showExplorer];
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
        myCell.titleL.text = [NSString stringWithFormat:@"您有%ld条好友请求", num];
        cell = myCell;
    } else {
        FLOChatListTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"chatUserCellID" forIndexPath:indexPath];
        
        FLOChatRecordModel *chatRecord = dataArr[indexPath.row];
        if (chatRecord.chatUser.length > 0) {
            myCell.userNameL.text = chatRecord.chatUser;
            myCell.iconImageV.image = [UIImage imageNamed:@"call_list_qcall_entry"];
        } else {
            myCell.userNameL.text = chatRecord.chatRoom;
            myCell.iconImageV.image = [UIImage imageNamed:@"aio_voiceChange_effect_2"];
        }
        myCell.msgL.text = chatRecord.lastMessage;
        myCell.timeL.text = [NSString stringWithFormat:@"%ld:%ld %@", chatRecord.lastDate.hour, chatRecord.lastDate.minute, chatRecord.lastDate.stringYearMonthDayCompareToday];
        
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
        friendRequestTVC.hidesBottomBarWhenPushed = YES;
        friendRequestTVC.dataArr = [NSMutableArray arrayWithArray:dataArr[0]];
        [self.navigationController pushViewController:friendRequestTVC animated:YES];
    } else if (indexPath.row > 0) {
        //聊天页面
        FLOChatRecordModel *chatRecord = dataArr[indexPath.row];
        
        MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
        if (chatRecord.chatUser.length > 0) {
            [chatViewManager setNavTitleText:chatRecord.chatUser];
        } else {
            [manager joinOrCreateXMPPRoom:chatRecord.chatRoom];
            
            [chatViewManager setGroupChat:YES];
            [chatViewManager setNavTitleText:chatRecord.chatRoom];
        }
        [chatViewManager enableRoundAvatar:YES];
        [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"call_list_qcall_entry"]];
        [chatViewManager setincomingDefaultAvatarImage:[UIImage imageNamed:@"taylor_swift"]];
        [chatViewManager pushMQChatViewControllerInViewController:self];
    }
}

@end
