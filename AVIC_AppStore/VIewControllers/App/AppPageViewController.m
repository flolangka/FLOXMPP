//
//  AppPageViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "AppPageViewController.h"
#import "MyappViewController.h"
#import "APPTableViewCell.h"
#import "WebViewController.h"
#import "AppDetailViewController.h"

#define COUNT 2  //
#define HEIGHT 2  //
#define key [[self.dataArr[indexPath.section]allKeys]firstObject]

@interface AppPageViewController ()
{
    UIImageView*_imageView;//下滑条
    NSString*soapMsg;//请求体
    NSString *methodname;//方法名
}


@end

@implementation AppPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self createHeadBtn];
    [self createTableView];
    [self creatRefresh];
    
    //[header beginRefreshing];
    //[self loadData];
}
#pragma mark 请求数据
-(void)loadData{
    //self.dataArr=[NSMutableArray arrayWithCapacity:0];
    
    NSString *space=@"http://app.services";//命名空间
    //请求地址
//    NSString*urlstr=@"http://121.42.8.173:8383/zh_mam/zh_mam_webservice/services/AppWebservice/";
    NSString *urlstr = sServiceAppendContent(@"/AppWebservice/");
    
    WebRequest*web=[[WebRequest alloc]initWithSoap:soapMsg namespace:space urlstr:urlstr methodname:methodname Block:^(BOOL success, WebRequest *webRequest) {
            
        if([webRequest.dic[@"msg"]isKindOfClass:[NSArray class]]){
            self.dataArr=webRequest.dic[@"msg"];
            if(self.dataArr.count==0){
                UIAlertView*alert=[[UIAlertView alloc]initWithTitle:nil message:@"没有数据哦~亲" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
        [self.tableView reloadData];
            
    }];
    
    
}
-(void)themeChange{
    [self createHeadBtn];
    
}
#pragma mark 创建导航
-(void)createNav{
    [self.navigationItem setTitle:@"应用商店"];
    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.bounds=CGRectMake(0, 0, 25, 25);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"guanli.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=rightItem;
}
-(void)rightItemClick{
    MyappViewController*vc=[[MyappViewController alloc]init];
    vc.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 创建标题按钮
-(void)createHeadBtn{
    for(int i=0;i<COUNT;i++){
        UIButton*button=(UIButton*)[self.view viewWithTag:200+i];
        if(button){
            [button removeFromSuperview];
        }
    }
    if(!_imageView){
        _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH/COUNT-40, 2)];
    }
    _imageView.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/huadongtiao.png",self.themePath]];
    NSArray*titleArr=@[@"推荐应用",@"办公模块"];
    for(int i=0;i<COUNT;i++){
        UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(SCREENWIDTH/COUNT*i, 0, SCREENWIDTH/COUNT, 50);
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithPatternImage:_imageView.image] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/xiaodaohanglan_di.png",self.themePath]] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(headBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=200+i;
        [self.view addSubview:button];
        if(i==0){
            [self headBtnClick:button];
        }
    }
}
-(void)headBtnClick:(UIButton*)button{
    _imageView.center=CGPointMake(button.center.x, button.frame.size.height-1);
    [self.view addSubview:_imageView];
    if(button.tag==200){
        soapMsg=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" >"
                         "<soap:Body>\n"
                         "<findApp xmlns=\"http://app.services\">"
                         "<userName>%@</userName>"
                         "<type>%@</type>"
                         "</findApp>"
                         "</soap:Body>\n"
                         "</soap:Envelope>",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"1"];
        methodname=@"findApp";
    }else if (button.tag==201){
        soapMsg=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" >"
                 "<soap:Body>\n"
                 "<findPlunin xmlns=\"http://app.services\">"
                 "<userName>%@</userName>"
                 "<type>%@</type>"
                 "</findPlunin>"
                 "</soap:Body>\n"
                 "</soap:Envelope>",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"1"];
        methodname=@"findPlunin";
    }
    [self loadData];
}

-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 50, SCREENWIDTH, SCREENHEIGHT-50-49-64) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:self.tableView];
}
#pragma mark tableView代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [[[self.dataArr[section]allObjects]firstObject]count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSString*key=[[self.dataArr[indexPath.section]allKeys]firstObject];
    APPTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"APP"];
    if(!cell){
        cell.cellHeight=tableView.frame.size.height/7;
        cell=[[APPTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"APP"];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    [cell UIconfig:self.dataArr[indexPath.section][key][indexPath.row] indexpath:indexPath];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataArr.count;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel*lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    lable.text=[NSString stringWithFormat:@"   %@",[[self.dataArr[section]allKeys]firstObject]];
    lable.backgroundColor=[UIColor whiteColor];
    lable.alpha=0.5;
    return lable;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArr[indexPath.section][key][indexPath.row][@"plugin_url"]!=nil){//插件
        
    }else{//应用
        AppDetailViewController*detail=[[AppDetailViewController alloc]init];
        detail.dataDic=self.dataArr[indexPath.section][key][indexPath.row];
        //detail.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:detail animated:YES];
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
