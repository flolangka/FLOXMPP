//
//  WebViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-15.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView*_webView;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self createWebView];
}
-(void)createNav{
    
    UIImage*image=[[UIImage imageNamed:[NSString stringWithFormat:@"daohanglan2.png"]]stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    //刷新
    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame=CGRectMake(0, 0, 20, 20);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"shuaxin.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    //关闭浏览器
    UIButton*stopBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    stopBtn.frame=CGRectMake(0, 0, 20, 20);
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"tingzhi.png"] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*stopItem=[[UIBarButtonItem alloc]initWithCustomView:stopBtn];
    //添加右边按钮
    UIBarButtonItem*tempItem=[[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)]];
    self.navigationItem.rightBarButtonItems=@[stopItem,tempItem,rightItem];
    //返回
    UIButton*leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.bounds=CGRectMake(0, 0, 15, 20);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"fanhui2.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
}
-(void)stopBtnClick{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)rightItemClick{
    [_webView reload];
}
-(void)leftBtnClick{
    if([_webView canGoBack]){
        [_webView goBack];
    }
}
-(void)createWebView{
    _webView=[[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.scalesPageToFit=YES;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.urlStr]]]];
    [self.view addSubview:_webView];
    _webView.delegate=self;

}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    MyLog(@"请求成功");
    
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    MyLog(@"开始请求");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)erro{
    MyLog(@"请求失败");
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
