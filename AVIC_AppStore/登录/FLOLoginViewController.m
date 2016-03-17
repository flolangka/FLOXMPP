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

- (void)configXMPPService
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置服务器" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPHost];
    
        if (host && host.length > 0) {
            textField.text = host;
        } else {
            textField.placeholder = @"服务器IP";
        }
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPDomain];
        
        if (domain && domain.length > 0) {
            textField.text = domain;
        } else {
            textField.placeholder = @"服务器名称";
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (alertController.textFields[0].text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:alertController.textFields[0].text forKey:kXMPPHost];
        }
        
        if (alertController.textFields[1].text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:alertController.textFields[1].text forKey:kXMPPDomain];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //设置服务器后刷新xmppstream
        [[XMPPManager manager] refreshXMPPStream];
    }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (IBAction)configAction:(UIButton *)sender {
    [self configXMPPService];
}

- (IBAction)loginAction:(UIButton *)sender {
    [self hideKeyboard];
    
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPHost];
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPDomain];
    if (!host || !domain || host.length < 1 || domain.length < 1) {
        [self configXMPPService];
        return;
    }
    
    if (_userNameTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入用户名"];
        return;
    }
    if (_passwordTF.text.length < 1) {
        [MBProgressTool showPromptViewInView:self.view WithTitle:@"请输入密码"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[XMPPManager manager] authorizationWithUserName:_userNameTF.text password:_passwordTF.text success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            //保存用户名密码，下次自动登录
            NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
            [UD setObject:_userNameTF.text forKey:kUserName];
            [UD setObject:_passwordTF.text forKey:kPassWord];
            [UD synchronize];
            
            //跳转到主页面
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            keyWindow.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SBIDTabbarController"];
            [keyWindow makeKeyAndVisible];
        } failure:^(NSString *errorStr){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                [MBProgressTool showPromptViewInView:self.view WithTitle:errorStr];
            });
        }];
    });
    
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
