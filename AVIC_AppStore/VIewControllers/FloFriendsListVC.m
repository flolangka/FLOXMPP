//
//  FloFriendsListVC.m
//  FriendsChat
//
//  Created by admin on 15/9/16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FloFriendsListVC.h"
#import "FloTTVNode.h"
#import "FloTreeTableView.h"
#import "FloXMPPUser.h"
#import "FloChatVC.h"
#import "DEFIND.h"
#import "FloTabBarV.h"

@interface FloFriendsListVC ()<TreeTableCellDelegate>

@end

@implementation FloFriendsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configData];
    [self configTabBar];
}

- (void)configTabBar
{
    FloTabBarV *tabBarV = [[[NSBundle mainBundle] loadNibNamed:@"FloTabBarV" owner:nil options:nil] firstObject];
    tabBarV.txlImageV.image = [UIImage imageNamed:@"gongsiHL"];
    tabBarV.txlLabel.textColor = [UIColor blueColor];
    tabBarV.tabBarC = self.tabBarController;
    [self.view addSubview:tabBarV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configData
{
    FloTTVNode *node1 = [[FloTTVNode alloc] initWithParentId:-1 nodeId:0 name:@"中航工业" depth:0 expand:NO object:nil];
    FloTTVNode *node2 = [[FloTTVNode alloc] initWithParentId:0 nodeId:1 name:@"公司领导" depth:1 expand:NO object:nil];
    FloTTVNode *node3 = [[FloTTVNode alloc] initWithParentId:1 nodeId:2 name:@"领导1" depth:2 expand:NO object:nil];
    FloTTVNode *node4 = [[FloTTVNode alloc] initWithParentId:0 nodeId:3 name:@"财务部" depth:1 expand:NO object:nil];
    FloTTVNode *node5 = [[FloTTVNode alloc] initWithParentId:0 nodeId:4 name:@"销售部" depth:1 expand:NO object:nil];
    FloTTVNode *node6 = [[FloTTVNode alloc] initWithParentId:0 nodeId:5 name:@"应用部" depth:1 expand:NO object:nil];
    
    FloTTVNode *node7 = [[FloTTVNode alloc] initWithParentId:-1 nodeId:6 name:@"中航国际" depth:0 expand:NO object:nil];
    FloTTVNode *node8 = [[FloTTVNode alloc] initWithParentId:-1 nodeId:7 name:@"中航粮贸" depth:0 expand:NO object:nil];
    FloTTVNode *node9 = [[FloTTVNode alloc] initWithParentId:-1 nodeId:8 name:@"中航船舶" depth:0 expand:NO object:nil];
    
    FloTTVNode *node10 = [[FloTTVNode alloc] initWithParentId:-1 nodeId:9 name:@"开发测试" depth:0 expand:NO object:nil];
    FloXMPPUser *user1 = [[FloXMPPUser alloc] initWithUserName:@"hkshenmin" deptName:@"开发测试" iconURL:@"http://www.uimaker.com/uploads/allimg/120508/1_120508132202_1.png"];
    FloTTVNode *node11 = [[FloTTVNode alloc] initWithParentId:9 nodeId:10 name:@"测试人员1" depth:1 expand:NO object:user1];
    
    FloXMPPUser *user2 = [[FloXMPPUser alloc] initWithUserName:@"37559303" deptName:@"开发测试" iconURL:@"http://www.uimaker.com/uploads/allimg/120508/1_120508132202_2.png"];
    FloTTVNode *node12 = [[FloTTVNode alloc] initWithParentId:9 nodeId:11 name:@"测试人员2" depth:1 expand:NO object:user2];
    
    FloXMPPUser *user3 = [[FloXMPPUser alloc] initWithUserName:@"eg1" deptName:@"开发测试" iconURL:@"http://www.uimaker.com/uploads/allimg/120508/1_120508132202_3.png"];
    FloTTVNode *node13 = [[FloTTVNode alloc] initWithParentId:9 nodeId:12 name:@"测试人员3" depth:1 expand:NO object:user3];
    
    
    NSArray *data = @[node1,node2,node3,node4,node5,node6,node7,node8,node9,node10,node11,node12,node13];
    
    FloTreeTableView *treeTableV = [[FloTreeTableView alloc] initWithFrame:CGRectMake(0, 156, SCREENWIDTH, SCREENHEIGHT-156) withData:data];
    treeTableV.treeTableCellDelegate = self;
    [self.view addSubview:treeTableV];
}

#pragma mark treeTableViewCellDelegate
- (void)cellClick:(FloTTVNode *)node
{
    if (node.obj) {
        FloChatVC *chatVC = STORYBOARDVC(VCID_chat);
        chatVC.chatUser = node.obj;
        if (![chatVC.chatUser.userName isEqualToString:[USERDEFAULT objectForKey:kXMPPmyJID]]) {
            [self.navigationController pushViewController:chatVC animated:YES];
        } else {
            return;
        }
    }
}



@end
