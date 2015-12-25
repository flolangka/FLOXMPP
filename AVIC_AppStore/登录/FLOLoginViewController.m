//
//  FLOLoginViewController.m
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import "FLOLoginViewController.h"
#import "FLORegistViewController.h"
#import "XMPPManager.h"

@interface FLOLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation FLOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)loginAction:(UIButton *)sender {
    [self hideKeyboard];
    
    if (_userNameTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入用户名"];
        return;
    }
    if (_passwordTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入密码"];
        return;
    }
    
    [[XMPPManager manager] authorizationWithUserName:_userNameTF.text password:_passwordTF.text success:^{
        //保存用户名密码，下次自动登录
        NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
        [UD setObject:_userNameTF.text forKey:kUserName];
        [UD setObject:_passwordTF.text forKey:kPassWord];
        [UD synchronize];
        
        //跳转到主页面
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        keyWindow.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDTabbarController"];
        [keyWindow makeKeyAndVisible];
    } failure:^{
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"登录失败"];
    }];
}

- (IBAction)registerAction:(UIButton *)sender {
    [self hideKeyboard];
    
    FLORegistViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDRegisterVC"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)hideKeyboard
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameTF) {
        [_passwordTF becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}


@end
