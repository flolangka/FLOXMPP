//
//  MBProgressTool.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/24.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "MBProgressTool.h"

@implementation MBProgressTool

+ (void)showPromptViewInView:(UIView *)view WithTitle:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    [hud hide:YES afterDelay:1.0];
}

@end
