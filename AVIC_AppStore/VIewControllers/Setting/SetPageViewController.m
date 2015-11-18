//
//  SetPageViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-8.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "SetPageViewController.h"
#import "LoginViewController.h"
#import "MyMessageViewController.h"
#import "DVIManagerViewController.h"
#import "SelfdomViewController.h"
#import "HelpViewController.h"
#import "DEFIND.h"

#define bgHEIGHT 0.2

@interface SetPageViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIButton*headBtn;
    UIImagePickerController*imagePick;
}

@property(nonatomic,strong)NSArray*titleArr;
@property(nonatomic,strong)NSArray*imageArr;
@property(nonatomic,strong)NSData*imageData;

@end

@implementation SetPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"设置";
    [self createView];
    [self loadData];
}
-(void)themeChange{
    [self.tableView reloadData];
}
-(void)loadData{
    //NSString*key=(NSString*)kCFBundleInfoDictionaryVersionKey;
    NSString*version=[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    NSString*str=[NSString stringWithFormat:@"当前版本  V%@",version];
    self.titleArr=@[@" 个人信息",@" 消息推送",@" 设备管理",@"个性化 ",@"技术支持",str,@"帮助"];
    self.imageArr=@[@"gerenxinxi.png",@"xiaoxituisong.png",@"shebeiguanli.png",@"gexinghua.png",@"jishuzhichi.png",@"dangqianbanben.png",@"bangzhu.png"];
    //MyLog(@"%@",[[NSBundle mainBundle]resourcePath]);
}
-(void)createView{
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height-60;
    UIImageView*bgImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height*bgHEIGHT)];
    bgImage.image=[UIImage imageNamed:@"shangchuanbeijing.png"];
    bgImage.userInteractionEnabled=YES;
    [self.view addSubview:bgImage];
    //头像
    headBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    headBtn.bounds=CGRectMake(0, 0, bgImage.frame.size.height*0.8, bgImage.frame.size.height*0.8);
    headBtn.center=bgImage.center;
    //headBtn.backgroundColor=[UIColor redColor];
    headBtn.layer.cornerRadius=headBtn.frame.size.width/2;
    headBtn.layer.masksToBounds=YES;
    [headBtn setImage:[UIImage imageNamed:@"xiangji.png"] forState:UIControlStateNormal];
    [headBtn setBackgroundImage:[UIImage imageNamed:@"quan.png"] forState:UIControlStateNormal];
    [headBtn addTarget:self action:@selector(headBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgImage addSubview:headBtn];
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, bgImage.frame.size.height, width, height*(1-bgHEIGHT)) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    //self.tableView.sectionIndexTrackingBackgroundColor=[UIColor blueColor];
    [self.view addSubview:self.tableView];
    
}
//头像点击方法
-(void)headBtnClick{
    UIActionSheet*action=[[UIActionSheet alloc]initWithTitle:@"选择头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
    [action showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==2){//取消按钮
        return;
    }
    //初始化相机
    imagePick=[[UIImagePickerController alloc]init];
    imagePick.delegate=self;
    if(buttonIndex==0){//相机
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){//判断前置相机是否可用
            imagePick.sourceType=UIImagePickerControllerSourceTypeCamera;
            imagePick.cameraDevice=UIImagePickerControllerCameraDeviceFront;//打开前置相机
        }else{
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"摄像头故障" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }else if (buttonIndex==1){//相册
        imagePick.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePick.accessibilityLanguage=UIImagePickerControllerCropRect;
    }
    //弹出动画
    imagePick.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    imagePick.allowsEditing=YES;
    [self presentViewController:imagePick animated:YES completion:nil];
}
-(void)cancelCamera{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 拍照代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage*image=[info objectForKey:UIImagePickerControllerOriginalImage];
    if(UIImagePNGRepresentation(image)==nil){//将图片转化为数据流
        self.imageData=UIImageJPEGRepresentation(image, 1);
    }else{
        self.imageData=UIImagePNGRepresentation(image);
    }
    [headBtn setImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableView代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        //cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UIImage*image=[UIImage imageNamed:@"jiantou_s.png"];
//        image=[UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationLeft];
        cell.accessoryView=[[UIImageView alloc]initWithImage:image];
        cell.backgroundColor=[UIColor clearColor];
        UIView*view=[[UIView alloc]initWithFrame:CGRectMake(10, cell.frame.size.height-1, SCREENWIDTH-20, 1)];
        view.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.5];
        [cell.contentView addSubview:view];
    }
    cell.textLabel.text=self.titleArr[indexPath.row];
    if([THEME isEqualToString:@"深蓝"]){
        cell.textLabel.textColor=[UIColor whiteColor];
    }else{
        cell.textLabel.textColor=[UIColor blackColor];
    }
    
    cell.imageView.frame=CGRectMake(0, 0, cell.frame.size.height*0.8, cell.frame.size.height*0.8) ;
    cell.imageView.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.themePath,self.imageArr[indexPath.row]]];
    if(indexPath.row==1){//消息推送
        UISwitch*_switch=[[UISwitch alloc]init];
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"canPush"]isEqualToString:@"canPush"]){
            _switch.on=YES;
        }else{
            _switch.on=NO;
        }
        [_switch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView=_switch;
        
    }else if (indexPath.row==4){//技术支持
        UILabel*lable=[[UILabel alloc]init];
        lable.bounds=CGRectMake(0, 0, 100, cell.contentView.frame.size.height/2);
        lable.textAlignment=NSTextAlignmentRight;
        lable.backgroundColor=[UIColor clearColor];
        lable.textColor=[UIColor grayColor];
        lable.text=@"HUI";
        cell.accessoryView=lable;
    }
    return cell;
}
//推送开关点击方法
-(void)switchClick:(UISwitch*)_switch{
    if(_switch.on){
        [[NSUserDefaults standardUserDefaults]setObject:@"canPush" forKey:@"canPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"notPush" forKey:@"canPush"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
//段尾控件
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds=CGRectMake(0, 10, view.frame.size.width*0.9, 40);
    button.center=view.center;
    //button.backgroundColor=[UIColor redColor];
    //[button setTitle:@"注销" forState:UIControlStateNormal];
    //button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
    [button setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/zhuxiao.png",self.themePath]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}
//注销点击方法
-(void)buttonClick:(UIButton*)button{
    [USERDEFAULT setBool:NO forKey:kISLogin];
    [USERDEFAULT synchronize];
    [[ZCXMPPManager sharedInstance] disconnect];
    
    LoginViewController*vc=[[LoginViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height*0.09;
}
//点击方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController*vc;
    switch (indexPath.row) {
        case 0:
        {
            vc=[[MyMessageViewController alloc]init];
        }
            break;
        case 1:
            
            break;
        case 2:
        {
            vc=[[DVIManagerViewController alloc]init];
        }
            break;
        case 3:
        {
            vc=[[SelfdomViewController alloc]init];
        }
            break;
        case 5:
            
            break;
        case 6:
        {
            vc=[[HelpViewController alloc]init];
        }
            break;
            
        default:
            break;
    }
    if(vc){
        vc.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:vc animated:YES];
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
