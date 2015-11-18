//
//  MyNavigationController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-9.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setTranslucent:NO];
    UIImage*image=[[UIImage imageNamed:@"header_bg_ios7.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    // 设置导航栏文字的主题
    [bar setTitleTextAttributes:@{
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSShadowAttributeName : [NSValue valueWithUIOffset:UIOffsetZero]
                                  }];
    
    // 修改所有UIBarButtonItem的外观
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    // 修改item的背景图片
    [barItem setBackgroundImage:[UIImage imageNamed:@"header_leftbtn_nor.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barItem setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    // 修改item上面的文字样式
    NSDictionary *dict = @{
                           NSForegroundColorAttributeName : [UIColor darkGrayColor],
                           NSShadowAttributeName : [NSValue valueWithUIOffset:UIOffsetZero]
                           };
    [barItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    [barItem setTitleTextAttributes:dict forState:UIControlStateHighlighted];
    
    // 设置状态栏样式
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
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
