//
//  FloTabBarV.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/29.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloTabBarV.h"
//#import "FloTabBarController.h"

static int selectedIndex = 0;

@implementation FloTabBarV

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    self.frame = CGRectMake(0, 108, SCREENWIDTH, 49);
}



- (IBAction)xiaoxiAction:(id)sender {
    if (selectedIndex == 0) {
        return;
    }
    self.tabBarC.selectedIndex = 0;
    
    selectedIndex = 0;
}

- (IBAction)txlAction:(id)sender {
    if (selectedIndex == 1) {
        return;
    }
    self.tabBarC.selectedIndex = 1;
    
    selectedIndex = 1;
}

- (IBAction)groupAction:(id)sender {
    if (selectedIndex == 2) {
        return;
    }
    self.tabBarC.selectedIndex = 2;
    
    selectedIndex = 2;
}

@end
