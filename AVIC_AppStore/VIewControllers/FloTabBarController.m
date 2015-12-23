//
//  FloTabBarController.m
//  FriendsChat
//
//  Created by admin on 15/9/16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "FloTabBarController.h"
#import "DEFIND.h"

@interface FloTabBarController ()

@end

@implementation FloTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.frame = CGRectMake(0, 108, SCREENWIDTH, 49);
    self.tabBar.tintColor = [UIColor colorWithRed:9/255.0 green:138/255.0 blue:241/255.0 alpha:1.0];
    
    UITabBarItem *one = self.tabBar.items[0];
    one.selectedImage = [[UIImage imageNamed:@"lianxirenHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *two = self.tabBar.items[1];
    two.selectedImage = [[UIImage imageNamed:@"gongsiHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *three = self.tabBar.items[2];
    three.selectedImage = [[UIImage imageNamed:@"qunzuHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
