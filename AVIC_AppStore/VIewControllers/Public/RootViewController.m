//
//  RootViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-11.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

//创建页面背景
-(void)createBgView{
    //self.themePath=[NSString stringWithFormat:@"%@/%@",LIBPATH,THEME];
    NSString*tempPath=[NSString stringWithFormat:@"Themes/%@",THEME];
    self.themePath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempPath];
    //导航栏
    if([THEME isEqualToString:@"蓝"]){
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1]}];

    }else{
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    }
    
    
    UIImage*image=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/daohanglan.png",self.themePath]]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //背景图
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    imageView.image=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/neirongbeijing.png",self.themePath]]stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    imageView.userInteractionEnabled=YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
    [self themeChange];
    //MyLog(@"%@",[NSString stringWithFormat:@"%@/themes/%@/neirongbeijing.png",LIBPATH,THEME]);
}
-(void)viewWillAppear:(BOOL)animated{
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[header beginRefreshing];
    [self createBgView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createBgView) name:@"Theme" object:nil];//主题切换的通知
    
}

#pragma mark 主题切换
-(void)themeChange{
    //切换主题  子类可重写
    
}
#pragma mark 创建导航条
-(void)createLeftBtn{
    UIButton*leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.bounds=CGRectMake(0, 0, 18, 25);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"fanhui.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
}
-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 创建刷新
-(void)creatRefresh{
    __weak RootViewController*vc=self;
    header=[MJRefreshHeaderView header];
    header.scrollView=_tableView;
    header.beginRefreshingBlock=^(MJRefreshBaseView*refresh){
        [vc loadData:refresh];
    };
    footer=[MJRefreshFooterView footer];
    footer.scrollView=_tableView;
    footer.beginRefreshingBlock=^(MJRefreshBaseView*refresh){
        [vc loadData:refresh];
    };
}
#pragma mark 刷新数据
-(void)loadData:(MJRefreshBaseView*)refresh{
    if(refresh==header){//下拉刷新
        [self loadData];
        
        [header endRefreshing];
    }else{//上拉加载
        [footer endRefreshing];
    }
}
#pragma mark 请求数据
-(void)loadData{
    //子类重写
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    return  cell;
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
