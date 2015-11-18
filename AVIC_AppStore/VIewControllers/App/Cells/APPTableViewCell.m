//
//  APPTableViewCell.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-15.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "APPTableViewCell.h"
#import "WebViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "FMDBManager.h"

@implementation APPTableViewCell


- (void)awakeFromNib {
    // Initialization code
    
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        if(!self.cellHeight){
            self.cellHeight=SCREENHEIGHT/7;
        }
        [self makeUI];
    }
    return self;
}
-(void)makeUI{
    //MyLog(@"%f",self.frame.size.width);
    _appIcon=[[UIImageView alloc]initWithFrame:CGRectMake(self.cellHeight*0.1, self.cellHeight*0.1, self.cellHeight*0.8, self.cellHeight*0.8)];
    //_appIcon.image=[UIImage imageNamed:@"tubiao.png"];
    [self.contentView addSubview:_appIcon];
    
    _appTitle=[[UILabel alloc]initWithFrame:CGRectMake(_appIcon.frame.origin.x+_appIcon.frame.size.width+10, _appIcon.frame.origin.y+10, SCREENWIDTH*0.4, _appIcon.frame.size.height*0.3)];
    _appTitle.font=[UIFont systemFontOfSize:20];
    _appTitle.textAlignment=NSTextAlignmentLeft;
    //_appTitle.text=@"改名卡";
    
    [self.contentView addSubview:_appTitle];
    
    _appDescribe=[[UILabel alloc]initWithFrame:CGRectMake(_appTitle.frame.origin.x, _appTitle.frame.origin.y+_appTitle.frame.size.height-5, SCREENWIDTH*0.5, _appIcon.frame.size.height*0.7)];
    _appDescribe.textColor=[UIColor grayColor];
    _appDescribe.font=[UIFont systemFontOfSize:15];
    _appDescribe.textAlignment=NSTextAlignmentLeft;
    //_appDescribe.text=@"发的是公司股份公司公司法规";
    [self.contentView addSubview:_appDescribe];
    
    _rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.bounds=CGRectMake(0, 0, self.cellHeight*0.7, self.cellHeight*0.4) ;
    _rightButton.center=CGPointMake(SCREENWIDTH*0.95-_rightButton.bounds.size.width/2, self.cellHeight/2);
//    _rightButton.showsTouchWhenHighlighted=NO;
//    _rightButton.adjustsImageWhenDisabled=NO;
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"anzhuang.png"] forState:UIControlStateNormal];
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"wancheng.png"] forState:UIControlStateSelected];
    
    _rightSwitch=[[UISwitch alloc]initWithFrame:_rightButton.frame];
    [_rightSwitch addTarget:self action:@selector(rightSwitchClick) forControlEvents:UIControlEventValueChanged];
}
//按钮点击方法
-(void)rightBtnClick:(UIButton*)button{
    if(!button.selected){//安装
        NSString*url=[NSString stringWithFormat:@"https://mam.avic-intl.cn/iosinstall.jsp?appid=%@&verid=%@",self.dic[@"appid"],self.dic[@"verid"]];
        //MyLog(@"%@",url);
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        UIWebView*web=[[UIWebView alloc]init];
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [self addSubview:web];
        FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"downloadApp"];
        [manager saveModel:self.dic];
        
    }else{//完成
        UIActionSheet*sheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开",@"添加到应用列表", nil];
        [sheet showInView:self];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //MyLog(@"%ld",buttonIndex);
    if(buttonIndex==0){//打开
        if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dic[@"lift_id"]]]]){
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.dic[@"lift_id"]]]];
        }else{
            MyLog(@"no app");
        }
    }else if (buttonIndex==1){//添加
        [self SaveApp];
    }else{
        return;
    }
}
//刷新数据
-(void)UIconfig:(NSDictionary*)dic indexpath:(NSIndexPath *)indexpath{
    if([THEME isEqualToString:@"深蓝"]){
        _appTitle.textColor=[UIColor whiteColor];
    }else{
        _appTitle.textColor=[UIColor blackColor];
    }
    self.dic=dic;
    //图标路径
    NSString*icon=[dic[@"logo"] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    [_appIcon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"tubiao.png"]];
    if(dic[@"name"]!=nil&&![dic[@"name"]isEqualToString:@"(null)"]){
        _appTitle.text=dic[@"name"];
    }
    if(dic[@"remark"]!=nil&&![dic[@"remark"]isEqualToString:@"(null)"]){
       _appDescribe.text=[NSString stringWithFormat:@"%@",dic[@"remark"]];
    }
    
    //插件
    if(dic[@"plugin_url"]!=nil&&![dic[@"plugin_url"]isEqualToString:@"(null)"]){
        [_rightButton removeFromSuperview];
        [self.contentView addSubview:_rightSwitch];
        _rightSwitch.on=NO;
        FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
        NSMutableArray*arr=[manager loadModel];
        for(NSDictionary*tempdic in arr){
            if([tempdic[@"name"]isEqualToString:dic[@"name"]]){
                _rightSwitch.on=YES;
                return;
            }
            
        }
        
        
    }else{//应用
        [_rightSwitch removeFromSuperview];
        [self.contentView addSubview:_rightButton];
        [_rightButton addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"lift_id"]]]]){
            _rightButton.selected=YES;
            FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"downloadApp"];
            if(![manager isNewVersion:dic]){
                [_rightButton setBackgroundImage:[UIImage imageNamed:@"gengxin.png"] forState:UIControlStateNormal];
                _rightButton.selected=NO;
            }
            
        }else{
            _rightButton.selected=NO;
            FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
            [manager deleteApp:dic];
        }
    }
    
    _rightButton.tag=indexpath.row;
}
-(void)rightSwitchClick{
    FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
    if(_rightSwitch.on){
        [manager saveModel:self.dic];
    }else{
        [manager deleteApp:self.dic];
    }
}
//保存应用
-(void)SaveApp{
    
    FMDBManager*manager=[[FMDBManager alloc]initWithTableName:@"myApp"];
    NSMutableArray*arr=[manager loadModel];
    for(NSDictionary*tempdic in arr){
        if([tempdic[@"name"]isEqualToString:self.dic[@"name"]]){
            UIAlertView*alert=[[UIAlertView alloc]initWithTitle:nil message:@"应用已存在" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }
    BOOL saved=[manager saveModel:self.dic];
    if(saved){
        _rightButton.selected=YES;
        UIAlertView*alert=[[UIAlertView alloc]initWithTitle:nil message:@"添加成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        
    }

}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
    CGContextStrokeRect(context, CGRectMake(5, rect.size.height, rect.size.width - 10, 0.5));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
