//
//  HomePageViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "HomePageViewController.h"
#import "UIButton+WebCache.h"
#import "FMDBManager.h"
#import "WebViewController.h"

@interface HomePageViewController ()
{
    UIButton*headButton;
    UIView*appView;
    //UIImageView*rightImage;
    UIScrollView*scrollView;
}

@property(nonatomic,strong)NSMutableArray*appArr;

@end

@implementation HomePageViewController

-(void)viewWillAppear:(BOOL)animated{
//    [self loadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self createView];
    
    [NOTICENTER addObserver:self selector:@selector(xmppChanDismiss:) name:kNOTI_XMPPChatDismiss object:nil];
}

- (void)xmppChanDismiss:(NSNotification *)noti
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)themeChange{
    [self createNav];
}
#pragma mark 请求数据
-(void)loadData{
    self.dataArr=[NSMutableArray arrayWithCapacity:0];
    
    //soap请求体
    NSString*soapMsg=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                      "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" >"
                      "<soap:Body>\n"
                      "<findMsg xmlns=\"http://msg.services\">"
                      "<userName>%@</userName>"
                      "</findMsg>"
                      "</soap:Body>\n"
                      "</soap:Envelope>",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    NSString *space=@"http://msg.services";
    NSString *methodname=@"findMsg";
//    NSString*urlstr=@"http://121.42.8.173:8383/zh_mam/zh_mam_webservice/services/MsgWebservice/";
    NSString *urlstr = sServiceAppendContent(@"/MsgWebservice/");
    WebRequest *web=[[WebRequest alloc]initWithSoap:soapMsg namespace:space urlstr:urlstr methodname:methodname Block:^(BOOL success, WebRequest *webRequest) {
        if(success){
            if([webRequest.dic[@"msg"] isKindOfClass:[NSArray class]]){
                NSArray*arr=webRequest.dic[@"msg"];
                self.dataArr=[NSMutableArray arrayWithArray:arr];
                if(self.dataArr.count!=0){
                    if(!headButton.selected){
                        [self buttonClick];
                    }
                    [self.tableView reloadData];
                }else{
                    if(headButton.selected){
                        [self buttonClick];
                    }
                }
            }
        }else{
            if(headButton.selected){
                [self buttonClick];
            }
        }
    }];
    //获取app
    FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
    self.appArr=[manager loadModel];
    [scrollView removeFromSuperview];
    [self createScroleView];
}
#pragma mark 创建导航条
-(void)createNav{
    UIImage*image=[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/daohanglanbeijing.png",self.themePath]]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    int width=self.navigationController.navigationBar.frame.size.width;
    int height=self.navigationController.navigationBar.frame.size.height;
    UILabel*lable=[[UILabel alloc]initWithFrame:CGRectMake(width*0.7, height*0.7-5, width*0.3, height*0.3)];
    lable.text=[NSString stringWithFormat:@"您好，%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    lable.textColor=[UIColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1];
    lable.font=[UIFont systemFontOfSize:10];
    lable.textAlignment=NSTextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:lable];
}
#pragma mark 创建tableView
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, headButton.frame.size.height+1, self.view.frame.size.width, self.view.frame.size.height*0.3) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //self.tableView.alpha=0.2;
    [self.view addSubview:self.tableView];
}
#pragma mark 创建View
-(void)createView{
    headButton=[UIButton buttonWithType:UIButtonTypeCustom];
    headButton.frame=CGRectMake(0, 0, self.view.frame.size.width, 40);
    [headButton setBackgroundImage:[UIImage imageNamed:@"daibangongzuo-_di-2.png"] forState:UIControlStateNormal];
    [headButton setBackgroundImage:[UIImage imageNamed:@"daibangongzuo-_di.png"] forState:UIControlStateSelected];
    [headButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    UILabel*lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    lable.text=@"  待办工作";
    lable.font=[UIFont boldSystemFontOfSize:18];
    lable.textAlignment=NSTextAlignmentLeft;
    [headButton addSubview:lable];
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, headButton.frame.size.height, headButton.frame.size.width, 1)];
    imageView.image=[UIImage imageNamed:@"fengexian.png"];
    [headButton addSubview:imageView];
    [self.view addSubview:headButton];
    [self createTableView];
    [self createAppView];
    [self buttonClick];
}
-(void)createAppView{
    appView=[[UIView alloc]initWithFrame:CGRectMake(0, self.tableView.frame.size.height+headButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.6)];
    [self.view addSubview:appView];
    UILabel*titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    titleLable.text=@"  常用应用";
    titleLable.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"daibangongzuo.png"]]];
    titleLable.textAlignment=NSTextAlignmentLeft;
    titleLable.font=[UIFont boldSystemFontOfSize:18];
    [appView addSubview:titleLable];
    UIImageView*imageView1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, titleLable.frame.size.width, 1)];
    imageView1.image=[UIImage imageNamed:@"fengexian.png"];
    UIImageView*imageView2=[[UIImageView alloc]initWithFrame:CGRectMake(0, titleLable.frame.size.height, titleLable.frame.size.width, 1)];
    imageView2.image=[UIImage imageNamed:@"fengexian.png"];
    [titleLable addSubview:imageView1];
    [titleLable addSubview:imageView2];
    [self createScroleView];
}
-(void)createScroleView{
    double width=appView.frame.size.width/4;
    //double Y=titleLable.frame.origin.y+titleLable.frame.size.height;
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, appView.frame.size.width, appView.frame.size.height)];
    scrollView.contentSize=CGSizeMake(0, self.appArr.count*width/4);
    [appView addSubview:scrollView];
    //获取app
    FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
    self.appArr=[manager loadModel];
    
    //添加通讯录
    NSDictionary *chatApp = @{@"logo": @"http://http://img4.imgtn.bdimg.com/it/u=3580936225,861174013&fm=21&gp=0.jpg",
                              @"name": @"通讯录"};
    [_appArr addObject:chatApp];
    
    for(int i=0;i<self.appArr.count;i++){
        UIImageView*appImage=[[UIImageView alloc]initWithFrame:CGRectMake(i%4*width, i/4*(width+20), width, width+20) ];
        appImage.image=[UIImage imageNamed:@"kuang.png"];
        appImage.userInteractionEnabled=YES;
        [scrollView addSubview:appImage];
        UIButton*appBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        appBtn.bounds=CGRectMake(0, 0, width-20, width-20);
        appBtn.center=CGPointMake(width/2, appImage.center.y-5);
        [appBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.appArr[i][@"logo"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"yuyin-zu"]];
        [appBtn addTarget:self action:@selector(appBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        appBtn.tag=1100+i;
        [appImage addSubview:appBtn];
        
        UILabel*appLable=[[UILabel alloc]initWithFrame:CGRectMake(-10, appBtn.frame.size.height, appBtn.frame.size.width+20, 20)];
        appLable.text=self.appArr[i][@"name"];
        appLable.textColor=[UIColor grayColor];
        appLable.font=[UIFont systemFontOfSize:15];
        appLable.textAlignment=NSTextAlignmentCenter;
        [appBtn addSubview:appLable];
    }
    //[scrollView reloadInputViews];
}
-(void)appBtnClick:(UIButton*)button{
    if ([self.appArr[button.tag-1100][@"name"] isEqualToString:@"通讯录"]) {
        //跳转到聊天        
        [self presentViewController:STORYBOARDVC(VCID_TabBarController) animated:YES completion:^{
            self.tabBarController.tabBar.hidden = YES;
        }];
        
        return;
    }
    
    if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.appArr[button.tag-1100][@"lift_id"]]]]){//应用
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.appArr[button.tag-1100][@"lift_id"]]]];
    }else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.appArr[button.tag-1100][@"plugin_url"]]]]){//插件
        WebViewController*web=[[WebViewController alloc]init];
        web.urlStr=self.appArr[button.tag-1100][@"plugin_url"];
        UINavigationController*nav=[[UINavigationController alloc]initWithRootViewController:web];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }else{
        
    }
}
#pragma  mark tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        cell.backgroundColor=[UIColor clearColor];
    }
    //MyLog(@"~~%@",self.dataArr[indexPath.row][@"fd_name"]);
    cell.textLabel.text=self.dataArr[indexPath.row][@"fd_name"];
    cell.textLabel.textColor=[UIColor grayColor];
    //右边lable
    UILabel*rightLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    rightLable.text=self.dataArr[indexPath.row][@"fd_from_system"];
    rightLable.textAlignment=NSTextAlignmentRight;
    rightLable.textColor=[UIColor grayColor];
    cell.accessoryView=rightLable;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.tableView.frame.size.height/5;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark 顶部按钮点击方法
-(void)buttonClick{
    headButton.selected=!headButton.selected;
    if(headButton.selected){
        //rightImage.image=[UIImage imageNamed:@"jiantou.png"];
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.frame=CGRectMake(10, headButton.frame.size.height+1, self.view.frame.size.width-20, SCREENHEIGHT*0.3);
            appView.frame=CGRectMake(0, self.tableView.frame.size.height+headButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.6);
            [self.tableView reloadData];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        //rightImage.image=[UIImage imageNamed:@"jiantou_s.png"];
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.frame=CGRectMake(10, headButton.frame.size.height+1, self.view.frame.size.width-20, 0);
            appView.frame=CGRectMake(0, headButton.frame.size.height, self.view.frame.size.width, self.view.frame.size.height*0.6);
        } completion:^(BOOL finished) {
            
        }];
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
