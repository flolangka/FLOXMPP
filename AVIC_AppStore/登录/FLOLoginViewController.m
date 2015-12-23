//
//  FLOLoginViewController.m
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import "FLOLoginViewController.h"
#import "FLORegistViewController.h"
#import <MBProgressHUD.h>
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
        [self showPromptTitle:@"请输入用户名"];
        return;
    }
    if (_passwordTF.text.length < 1) {
        [self showPromptTitle:@"请输入密码"];
        return;
    }
    
    [[XMPPManager manager] authorizationWithUserName:_userNameTF.text password:_passwordTF.text success:^{
        NSLog(@"登录成功");
    } failure:^{
        NSLog(@"登录失败");
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
    [textField resignFirstResponder];
    return YES;
}

- (void)showPromptTitle:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    [hud hide:YES afterDelay:1.0];
}

@end
