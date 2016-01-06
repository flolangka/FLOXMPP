//
//  FLOGroupListTableViewController.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOGroupListTableViewController.h"
#import "XMPPManager.h"
#import "MQChatViewManager.h"

@interface FLOGroupListTableViewController ()

{
    XMPPManager *manager;
}

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation FLOGroupListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    manager = [XMPPManager manager];
    [self configDataArrWithRoomList:manager.xmppRooms];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [manager fetchXMPPRoomListSuccess:^() {
        [self configDataArrWithRoomList:manager.xmppRooms];
        [self.tableView reloadData];
    }];
}

//对聊天室分已加入和未加入
- (void)configDataArrWithRoomList:(NSArray *)roomList
{
    if (roomList.count < 1) {
        self.dataArr = @[@[], @[]];
        return;
    }
    
    NSMutableArray *didJoinRooms = [NSMutableArray array];
    NSMutableArray *waitJoinRooms = [NSMutableArray array];
    
    if (manager.didJoinRooms.count < 1) {
        waitJoinRooms = [NSMutableArray arrayWithArray:roomList];
    } else {
        for (NSString *roomName in roomList) {
            if ([manager.didJoinRooms containsObject:roomName]) {
                [didJoinRooms addObject:roomName];
            } else {
                [waitJoinRooms addObject:roomName];
            }
        }
    }
    
    self.dataArr = @[didJoinRooms, waitJoinRooms];
}

//创建聊天室
- (IBAction)addGroupAction:(UIBarButtonItem *)sender {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"新建群聊" message:@"请输入群名称" preferredStyle:UIAlertControllerStyleAlert];
    [alertC addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *roomName = alertC.textFields[0].text;
        if ([_dataArr[0] containsObject:roomName] || [_dataArr[1] containsObject:roomName]) {
            [MBProgressTool showPromptViewInView:[UIApplication sharedApplication].keyWindow WithTitle:@"聊天室已存在"];
        } else {
            [manager joinOrCreateXMPPRoom:roomName];
        }
    }];
    
    [alertC addAction:action];
    [alertC addAction:createAction];
    
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArr[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XMPPRoomCellID" forIndexPath:indexPath];
    
    cell.textLabel.text = _dataArr[indexPath.section][indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"已加入聊天室" : @"未加入聊天室";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        //加入群聊
        [manager joinOrCreateXMPPRoom:_dataArr[1][indexPath.row]];
    } else {
        //开始群聊
        MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
        [chatViewManager setNavTitleText:_dataArr[0][indexPath.row]];
        [chatViewManager setGroupChat:YES];
        [chatViewManager enableRoundAvatar:YES];
        [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"call_list_qcall_entry"]];
        [chatViewManager setincomingDefaultAvatarImage:[UIImage imageNamed:@"taylor_swift"]];
        [chatViewManager pushMQChatViewControllerInViewController:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
