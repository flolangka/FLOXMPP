//
//  FLOAddFriendViewController.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOAddFriendViewController.h"
#import "XMPPManager.h"

@interface FLOAddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;

@end

@implementation FLOAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)subminRequestAction:(UIButton *)sender {
    [_userNameTF resignFirstResponder];
    [_messageTF resignFirstResponder];
    
    if (_userNameTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入用户名"];
        return;
    }
    
    [[XMPPManager manager] addFriend:_userNameTF.text message:_messageTF.text.length>0 ? _messageTF.text : nil];
    [MBProgressTool showPromptViewInView:self.view WithTitle:@"申请发送成功"];
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
