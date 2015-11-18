//
//  LoginViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-10.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "LoginViewController.h"
#import "SliderViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "WebRequest.h"

#import "MainViewController.h"
#import "DEFIND.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    //UIImageView*headImageView;//头像
    UITextField*userTextFiled;//用户名
    UITextField*pwdTextFiled;//密码
    UIButton*rmbButton;//记住密码
    WebRequest*web;//请求
}
@property(nonatomic,strong)NSDictionary*dataDic;//数据字典

@end

@implementation LoginViewController

-(void)loadView{
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image=[UIImage imageNamed:@"beijing.png"];
    imageView.userInteractionEnabled=YES;
    self.view = imageView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyboder) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideKeyboder) name:UIKeyboardWillHideNotification object:nil];
}
-(void)createView{
    
    UIImageView*inputImageView=[[UIImageView alloc]init];
    inputImageView.bounds=CGRectMake(0, 0, self.view.frame.size.width*0.8, self.view.frame.size.height*0.2);
    inputImageView.center=CGPointMake(self.view.center.x, self.view.center.y*0.8);
    inputImageView.image=[UIImage imageNamed:@"login.png"];
    inputImageView.userInteractionEnabled=YES;
    [self.view addSubview:inputImageView];
    
    userTextFiled=[[UITextField alloc]initWithFrame:CGRectMake(inputImageView.frame.size.width*0.1, inputImageView.frame.size.height*0.1, inputImageView.frame.size.width*0.8, inputImageView.frame.size.height*0.4)];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"username"]){
        userTextFiled.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    }
    userTextFiled.placeholder=@"输入用户名吧，亲";
    userTextFiled.returnKeyType=UIReturnKeyNext;
    userTextFiled.delegate=self;
    userTextFiled.tag=1000;
    userTextFiled.textAlignment=NSTextAlignmentLeft;
    UIView*userView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, userTextFiled.frame.size.height, userTextFiled.frame.size.height)];
    UIImageView*userLeftImage=[[UIImageView alloc]initWithFrame:CGRectMake(userTextFiled.frame.size.height*0.1, userTextFiled.frame.size.height*0.1, userTextFiled.frame.size.height*0.8, userTextFiled.frame.size.height*0.8)];
    userLeftImage.image=[UIImage imageNamed:@"yonghu.png"];
    [userView addSubview:userLeftImage];
    userTextFiled.leftViewMode=UITextFieldViewModeAlways;
    userTextFiled.leftView=userView;
    userTextFiled.clearButtonMode=YES;
    [inputImageView addSubview:userTextFiled];
    
    pwdTextFiled=[[UITextField alloc]initWithFrame:CGRectMake(userTextFiled.frame.origin.x, inputImageView.frame.size.height*0.6, userTextFiled.frame.size.width, userTextFiled.frame.size.height)];
    pwdTextFiled.secureTextEntry=YES;
    pwdTextFiled.placeholder=@"告诉我密码哦，亲";
    pwdTextFiled.returnKeyType=UIReturnKeyGo;
    pwdTextFiled.delegate=self;
    pwdTextFiled.tag=2000;
    UIImageView*pwdLeftImage=[[UIImageView alloc]initWithFrame:CGRectMake(pwdTextFiled.frame.size.height*0.1, pwdTextFiled.frame.size.height*0.1, pwdTextFiled.frame.size.height*0.8, pwdTextFiled.frame.size.height*0.8)];
    pwdLeftImage.image=[UIImage imageNamed:@"mima.png"];
    UIView*pwdView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, pwdTextFiled.frame.size.height, pwdTextFiled.frame.size.height)];
    [pwdView addSubview:pwdLeftImage];
    pwdTextFiled.leftViewMode=UITextFieldViewModeAlways;
    pwdTextFiled.leftView=pwdView;
    pwdTextFiled.clearButtonMode=YES;
    [inputImageView addSubview:pwdTextFiled];
    
//    headImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.center.x, inputImageView.frame.origin.y-self.view.frame.size.height*0.1-inputImageView.frame.size.width*0.3, inputImageView.frame.size.width*0.3, inputImageView.frame.size.width*0.3)] ;
//    headImageView.image=[UIImage imageNamed:@"logo_2.png"];
//    headImageView.layer.cornerRadius=headImageView.frame.size.width/2;
//    headImageView.clipsToBounds=YES;
//    [self.view addSubview:headImageView];
    
    rmbButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rmbButton.frame=CGRectMake(inputImageView.frame.origin.x+10, inputImageView.frame.origin.y+inputImageView.frame.size.height+20, inputImageView.frame.size.width/2, 30);
    [rmbButton setTitle:@"  记住密码" forState:UIControlStateNormal];
    [rmbButton setImage:[UIImage imageNamed:@"jizhumima.png"] forState:UIControlStateNormal];
    [rmbButton setImage:[UIImage imageNamed:@"jizhumima2.png"] forState:UIControlStateSelected];
    [rmbButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    rmbButton.selected=YES;
    [rmbButton addTarget:self action:@selector(rmbBtnClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:rmbButton];
    
    UIButton* loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"denglu.png"] forState:UIControlStateNormal];
    loginButton.bounds=CGRectMake(0, 0, self.view.frame.size.width*0.7, self.view.frame.size.width*0.1);
    loginButton.center=CGPointMake(self.view.center.x, rmbButton.frame.origin.y+rmbButton.frame.size.height+30);
    [loginButton addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}
-(void)rmbBtnClick{
    rmbButton.selected=!rmbButton.selected;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==userTextFiled){
        //[userTextFiled resignFirstResponder];
        [pwdTextFiled becomeFirstResponder];
    }else if (textField==pwdTextFiled){
        [self loginClick];
    }
    return YES;
}
#pragma mark 登陆
-(void)loginClick{
    [self hideKeyboder];
    //[self craeteRequest];
    if(!userTextFiled.text.length||!pwdTextFiled.text.length){
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或密码为空！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }else{
        
        //MyLog(@"%@",self.dataDic);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self craeteRequest];
            [self loginSuccess];
        });
        
    }
}
#pragma mark 发送请求
-(void)craeteRequest{
    
    //soap请求体
    NSString*soapMsg=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" >"
                   "<soap:Body>\n"
                   "<userCheck xmlns=\"http://user.services\">"
                   "<userName>%@</userName>"
                   "<password>%@</password>"
                   "</userCheck>"
                   "</soap:Body>\n"
                   "</soap:Envelope>",userTextFiled.text,pwdTextFiled.text];
    NSString *space=@"http://user.services";
    NSString *methodname=@"userCheckRequest";
    NSString *urlstr = sServiceAppendContent(@"/UserWebservice?wsdl");
    //创建请求
    web=[[WebRequest alloc]initWithSoap:soapMsg namespace:space urlstr:urlstr methodname:methodname Block:^(BOOL success, WebRequest *webRequest) {
        if(success){
            self.dataDic=webRequest.dic;
            if(self.dataDic){
                if([[self.dataDic objectForKey:@"success"] intValue]==1){
                    //登录成功
                    [self loginSuccess];
                }else {
                    UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或密码错误！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                }
            }
        }
    }];
    
}

- (void)loginSuccess
{
    //保存用户名和状态
    NSUserDefaults*user=[NSUserDefaults standardUserDefaults];
    [user setObject:userTextFiled.text forKey: kUserName];
    [user setObject:pwdTextFiled.text forKey: kPassword];
    if(rmbButton.selected){
        [user setBool:YES forKey:kISLogin];
    }
    [user synchronize];
    
#if 0
    //跳转到主界面
    SliderViewController*vc=[[SliderViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
#endif
#if 1
    [user setObject:userTextFiled.text forKey:kXMPPmyJID];
    [user setObject:pwdTextFiled.text forKey:kXMPPmyPassword];
    [user synchronize];
    
    [[ZCXMPPManager sharedInstance] connectLogoin:^(BOOL succeed) {
        if (succeed) {
            //NSLog(@"登陆成功");
            
            MainViewController *mvc = [[MainViewController alloc] init];
            [self presentViewController:mvc animated:YES completion:nil];
            
        }else{
            //NSLog(@"密码错误或者用户名不存在");
            UIAlertView*al=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或密码错误" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [al show];
            
        }
    }];

    
#endif
}

- (void)saveUserInfo{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    //保存用户的资料--主要是ID
    //1.创建数据库
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
    
    //2.获取数据库并打开
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if (![database open]) {
        //            MyLog(@"Open database failed");
        return;
    }
    if(![database tableExists:@"user"]){
        //创建表 User
        [database executeUpdate:@"create table user (user_name,user_password,time)"];
    }
    //插入数据
    if (userTextFiled) {
        
        BOOL delete = [database executeUpdate:@"delete from user"];
        
        if (delete) {
            BOOL insert = [database executeUpdate:@"insert into user values (?,?,?)",userTextFiled.text,pwdTextFiled.text,currentDateStr,nil ];
            if (insert) {
            }
        }
        [database close];
    }else{
        [database close];
    }
}
#pragma mark 弹出键盘
-(void)showKeyboder{
    if(self.view.center.y==self.view.superview.center.y){
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center=CGPointMake(self.view.center.x, self.view.center.y-100);
            //headImageView.transform=CGAffineTransformMakeScale(0, 0);
        }];
    }
}
#pragma mark 隐藏键盘
-(void)hideKeyboder{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center=self.view.superview.center;
        //headImageView.transform=CGAffineTransformMakeScale(1, 1);
    }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)dealloc{
    userTextFiled=nil;
    pwdTextFiled=nil;
    web=nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
