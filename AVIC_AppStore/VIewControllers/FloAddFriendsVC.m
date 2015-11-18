//
//  FloAddFriendsVC.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/13.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloAddFriendsVC.h"
#import "DEFIND.h"

@interface FloAddFriendsVC ()

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;

@end

@implementation FloAddFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加好友";
}

- (IBAction)btnAction:(UIButton *)sender {
    if (_userTextField.text.length > 0) {
        ZCXMPPManager *manager = [ZCXMPPManager sharedInstance];
        [manager addSomeBody:_userTextField.text Newmessage:_messageTF.text];
        
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请求已发送" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入用户ID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
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
