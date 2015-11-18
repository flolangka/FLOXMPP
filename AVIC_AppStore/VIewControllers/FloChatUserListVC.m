//
//  FloChatUserListVC.m
//  FriendsChat
//
//  Created by admin on 15/9/15.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FloChatUserListVC.h"
#import "FloUserCell.h"
#import "ZCMessageObject.h"
#import "FloChatVC.h"
#import "FloXMPPUser.h"
#import "FloTabBarV.h"

#define kNoNewApply @"未有新消息"

@interface FloChatUserListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableviewDatas;

@end

static BOOL nibsRegistered = NO;

@implementation FloChatUserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configTabBar];
    
    //消除下面多余的横线
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [NOTICENTER addObserver:self selector:@selector(refreshData:) name:kXMPPNewMsgNotifaction object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)configTabBar
{
    FloTabBarV *tabBarV = [[[NSBundle mainBundle] loadNibNamed:@"FloTabBarV" owner:nil options:nil] firstObject];
    tabBarV.xiaoxiImageV.image = [UIImage imageNamed:@"lianxirenHL"];
    tabBarV.xiaoxiLabel.textColor = [UIColor blueColor];
    tabBarV.tabBarC = self.tabBarController;
    [self.view addSubview:tabBarV];
}

- (void)loadData
{
    self.tableviewDatas = [NSMutableArray array];
    if ([ZCXMPPManager sharedInstance].subscribeArray.count > 0) {
        [_tableviewDatas addObject:[NSString stringWithFormat:@"您有%d条好友请求",[ZCXMPPManager sharedInstance].subscribeArray.count]];
    }else{
        [_tableviewDatas addObject:kNoNewApply];
    }
    
    [_tableviewDatas addObjectsFromArray:[ZCMessageObject fetchRecentChatByPage:20]];
    [self.tableView reloadData];
}

- (IBAction)exitAction:(UIBarButtonItem *)sender {
    [self goToLogin];
}

- (void)goToLogin
{
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [NOTICENTER postNotificationName:kNOTI_XMPPChatDismiss object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark noti
- (void)refreshData:(NSNotification *)noti
{
    [self loadData];
    NSLog(@"消息>>>>%d",[ZCXMPPManager sharedInstance].subscribeArray.count);
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableviewDatas.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"FloUserCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellID_user];
        nibsRegistered = YES;
    }
    
    FloUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID_user forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.userNameL.text = _tableviewDatas[0];
        cell.iconImageV.image = [UIImage imageNamed:@"ali08"];
    } else {
        [cell setContentChatHistoryUserWithArray:_tableviewDatas[indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:STORYBOARDVC(VCID_ChuliMsgVC) animated:YES];
    } else {
        FloChatVC *chatVC = STORYBOARDVC(VCID_chat);
        FloUserCell *cell = (FloUserCell *)[tableView cellForRowAtIndexPath:indexPath];
        chatVC.chatUser = [[FloXMPPUser alloc] initWithUserName:cell.userNameL.text deptName:@"开发测试" iconURL:@"http://www.uimaker.com/uploads/allimg/120508/1_120508132202_3.png"];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    
    //选中后取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)dealloc
{
    nibsRegistered = NO;
    [NOTICENTER removeObserver:self name:kXMPPNewMsgNotifaction object:nil];
}



@end
