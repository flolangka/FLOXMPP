//
//  DVIManagerViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-16.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "DVIManagerViewController.h"

@interface DVIManagerViewController ()

@end

@implementation DVIManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"设备信息";
    [self createLeftBtn];
}
-(void)themeChange{
    
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
