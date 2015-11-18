//
//  SliderViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-14.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "SliderViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"


@interface SliderViewController ()<UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer*tapGesture;//轻击手势
}
@property(nonatomic,strong)UIViewController *LeftVC;
@property(nonatomic,strong)UIViewController *RightVC;
@property(nonatomic,strong)UIViewController *MainVC;

@end

@implementation SliderViewController

-(void)loadView
{
    UIImageView*bgImageView=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    bgImageView.userInteractionEnabled=YES;
    bgImageView.image=[UIImage imageNamed:@"sidebar_bg.jpg"];
    self.view=bgImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
}
-(void)createView{
    _MainVC=[[MainViewController alloc]init];
    _LeftVC=[[LoginViewController alloc]init];
    _MainVC.view.userInteractionEnabled=YES;
    _LeftVC.view.userInteractionEnabled=YES;
    [self.view addSubview:_LeftVC.view];
    [self.view addSubview:_MainVC.view];
    
    UISwipeGestureRecognizer*swipeGesture;//滑动手势
    swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureBegin:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_MainVC.view addGestureRecognizer:swipeGesture];
    swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureBegin:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_LeftVC.view addGestureRecognizer:swipeGesture];
    self.view.userInteractionEnabled=YES;
    
}
-(void)tapGestureBegin{
    
    [UIView animateWithDuration:0.25 animations:^{
        CGAffineTransform ident=CGAffineTransformIdentity;
        _MainVC.view.transform=ident;
    } completion:^(BOOL finished) {
        [_MainVC.view removeGestureRecognizer:tapGesture];
    }];
}


-(void)swipeGestureBegin:(UISwipeGestureRecognizer*)swipeGesture{
    if(swipeGesture.direction==UISwipeGestureRecognizerDirectionLeft){
        
        [UIView animateWithDuration:0.25 animations:^{
            
            CGAffineTransform ident=CGAffineTransformIdentity;
            _MainVC.view.transform=ident;
        } completion:^(BOOL finished) {
            [_MainVC.view removeGestureRecognizer:tapGesture];
        }];
        
        
    }else if (swipeGesture.direction==UISwipeGestureRecognizerDirectionRight){
        if(_MainVC.view.center.x==self.view.center.x){
            [UIView animateWithDuration:0.25 animations:^{
                //[setVc.view bringSubviewToFront:self.view];
                CGAffineTransform scale=CGAffineTransformMakeScale(0.8, 0.8);
                CGAffineTransform trans=CGAffineTransformMakeTranslation(300, 0);
                CGAffineTransform concat=CGAffineTransformConcat(trans, scale);
                _MainVC.view.transform=concat;
            } completion:^(BOOL finished) {
                tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureBegin)];
                tapGesture.delegate=self;
                [_MainVC.view addGestureRecognizer:tapGesture];
            }];
            
        }
        
    }
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
