//
//  FLORegistViewController.m
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import "FLORegistViewController.h"
#import "XMPPManager.h"

@interface FLORegistViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTF;

@end

@implementation FLORegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)leftBarButtonAction:(UIBarButtonItem *)sender {
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerAction:(UIButton *)sender {
    [self hideKeyboard];
    
    if (_userNameTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入用户名"];
        return;
    }
    if (_passwordTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入密码"];
        return;
    }
    if (_rePasswordTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请确认密码"];
        return;
    }
    if (![_passwordTF.text isEqualToString:_rePasswordTF.text]) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"密码不一致"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[XMPPManager manager] registerWithUserName:_userNameTF.text password:_passwordTF.text success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            [MBProgressTool showPromptViewInView:self.view WithTitle:@"注册成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSString *errorStr){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [MBProgressTool showPromptViewInView:self.view WithTitle:errorStr];
            });
        }];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameTF) {
        [_passwordTF becomeFirstResponder];
    } else if (textField == _passwordTF) {
        [_rePasswordTF becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)hideKeyboard
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    [_rePasswordTF resignFirstResponder];
}

@end
