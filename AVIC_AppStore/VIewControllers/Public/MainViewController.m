//
//  MainViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-10.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MainViewController.h"
#import "HomePageViewController.h"
#import "AppPageViewController.h"
#import "MessagePageViewController.h"
#import "SetPageViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addViewControllers];
    [self createItems];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createItems) name:@"Theme" object:nil];
}
-(void)createItems{
    //NSString*themePath=[NSString stringWithFormat:@"%@/%@",LIBPATH,THEME];
    NSString*tempPath=[NSString stringWithFormat:@"Themes/%@",THEME];
    NSString*themePath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempPath];
    
    UIImage*image2=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/xiaodaohanglan_di.png",themePath]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    image2=[image2 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.tabBar setBackgroundImage:image2];
    //[self.tabBar setTranslucent:NO];
    
    NSArray*titleArray=@[@"首页",@"应用",@"消息",@"设置"];
    NSArray*imageArr=@[@"shouye_1.png",@"yingyong_1.png",@"xiaoxi_1.png",@"shezhi_1.png"];
    NSArray*selectedImageArr=@[@"shouye.png",@"yingyong.png",@"xiaoxi.png",@"shezhi.png"];
    for(int i=0;i<self.tabBar.items.count;i++){
        UITabBarItem*item=self.tabBar.items[i];
        item.title=titleArray[i];
        item.titlePositionAdjustment=UIOffsetMake(0, -2);
        [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
        
        if([THEME isEqualToString:@"深蓝"]){
            [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
        }else{
            [item setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10],NSForegroundColorAttributeName:[UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/huadongtiao.png",themePath]]]} forState:UIControlStateSelected];
        }
        UIImage*image=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",themePath,imageArr[i]]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage*selectedImage=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",themePath,selectedImageArr[i]]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.image=image;
        item.selectedImage=selectedImage;
    }
}
-(void)addViewControllers{
    UINavigationController*homeNav=[[UINavigationController alloc]initWithRootViewController:[[HomePageViewController alloc]init]];
    homeNav.title=@"首页";
    UINavigationController*appNav=[[UINavigationController alloc]initWithRootViewController:[[AppPageViewController alloc]init]];
    appNav.title=@"应用";
    UINavigationController*messageNav=[[UINavigationController alloc]initWithRootViewController:[[MessagePageViewController alloc]init]];
    messageNav.title=@"消息";
    UINavigationController*setNav=[[UINavigationController alloc]initWithRootViewController:[[SetPageViewController alloc]init]];
    setNav.title=@"设置";
    self.viewControllers=@[homeNav,appNav,messageNav,setNav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Theme" object:nil];
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
