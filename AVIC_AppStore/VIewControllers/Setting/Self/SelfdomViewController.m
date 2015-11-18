//
//  SelfdomViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-16.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "SelfdomViewController.h"
#import "ThemeManager.h"

@interface SelfdomViewController ()
{
    UIImageView*selecdeImage;
}

@end

@implementation SelfdomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"个性化";
    [self createLeftBtn];
    [self createView];
}
-(void)themeChange{
    
}
-(void)createView{
    selecdeImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xuanze.png"]];
    selecdeImage.bounds=CGRectMake(0, 0, 20, 20);
    self.dataArr=[NSMutableArray arrayWithObjects:@{@"name":@"蓝"},@{@"name":@"深蓝"},@{@"name":@"紫"}, nil];
    float width=self.view.frame.size.width;
    for(int i=0;i<self.dataArr.count;i++){
        UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(i%2*width*0.47+width*0.07, i/2*width*0.35+width*0.1, self.view.frame.size.width*0.4, self.view.frame.size.width*0.3);
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"beijing%d.png",i+1]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=i+1;
        [self.view addSubview:button];
        if([self.dataArr[i][@"name"]isEqualToString:THEME]){
            selecdeImage.center=CGPointMake(button.frame.size.width-5, button.frame.size.height-5);
            [button addSubview:selecdeImage];
        }
    }
    
}
-(void)buttonClick:(UIButton*)button{
    [selecdeImage removeFromSuperview];
    selecdeImage.center=CGPointMake(button.frame.size.width-5, button.frame.size.height-5);
    [button addSubview:selecdeImage];
    //[[ThemeManager sharedManager]changeTheme:self.dataArr[button.tag-1]];
    [self changeTheme:self.dataArr[button.tag-1]];
}
-(void)changeTheme:(NSDictionary*)dic{
    NSUserDefaults*user=[NSUserDefaults standardUserDefaults];
    [user setObject:dic[@"name"] forKey:@"theme"];
    [user synchronize];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Theme" object:nil];
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
