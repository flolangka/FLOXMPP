//
//  AppDetailViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-6.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "AppDetailViewController.h"
#import "APPTableViewCell.h"
#import "MyappViewController.h"
#import "UIImageView+WebCache.h"

@interface AppDetailViewController ()

@end

@implementation AppDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNav];
    [self createTableView];
}
-(void)themeChange{
    [self.tableView reloadData];
}
-(void)createNav{
    [self createLeftBtn];
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
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-49-64) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        APPTableViewCell*cell=[[APPTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        [cell UIconfig:self.dataDic indexpath:indexPath];
        cell.appDescribe.text=self.dataDic[@"orgName"];
        UILabel*lable=[[UILabel alloc]initWithFrame:CGRectMake(0, cell.appDescribe.frame.size.height-15, cell.appDescribe.frame.size.width, 20)];
        lable.textColor=[UIColor grayColor];
        lable.font=[UIFont systemFontOfSize:10];
        lable.text=[NSString stringWithFormat:@"%@  版本 V%@",self.dataDic[@"filesize"],self.dataDic[@"version_no"]];
        [cell.appDescribe addSubview:lable];
        return cell;
    }else {
        UITableViewCell*cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        UILabel*titleLable=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREENWIDTH-20, 30)];
        titleLable.backgroundColor=[UIColor clearColor];
        titleLable.font= [UIFont systemFontOfSize:20];
        if([THEME isEqualToString:@"深蓝"]){
            titleLable.textColor=[UIColor whiteColor];
        }else{
            titleLable.textColor=[UIColor blackColor];
        }
        [cell.contentView addSubview:titleLable];
        if (indexPath.row==1||indexPath.row==3){
            UILabel*detailLable=[[UILabel alloc]initWithFrame:CGRectMake(0, titleLable.frame.size.height, titleLable.frame.size.width-10, 50)];
            detailLable.textColor=[UIColor grayColor];
            detailLable.font=[UIFont systemFontOfSize:15];
            detailLable.backgroundColor=[UIColor clearColor];
            detailLable.numberOfLines=0;
            [titleLable addSubview:detailLable];
            if(indexPath.row==1){
                titleLable.text=@"应用描述";
                detailLable.text=self.dataDic[@"remark"];
            }else{
                titleLable.text=@"更新信息";
                detailLable.text=self.dataDic[@"verDesc"];
            }
            [detailLable sizeToFit];
        }else if (indexPath.row==2){
            titleLable.text=@"屏幕截图";
            int count=3;
            UIScrollView*scrollerImage=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, SCREENWIDTH, 270)];
            scrollerImage.contentSize=CGSizeMake(200*count, 0);
            scrollerImage.contentOffset=CGPointMake(0, 0);
            scrollerImage.showsHorizontalScrollIndicator=NO;
            scrollerImage.showsVerticalScrollIndicator=NO;
            [cell.contentView addSubview:scrollerImage];
            for(int i=0;i<count;i++){
                UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(170*i+20, 10, 150, 250)];
                NSString*url=[self.dataDic[[NSString stringWithFormat:@"viewimage%d",i+1]]stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                MyLog(@"%@",url);
                //imageView.backgroundColor=[UIColor redColor];
                [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
                [scrollerImage addSubview:imageView];
            }
        }
        return cell;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 90;
    }else if (indexPath.row==1){
        return [self lableSize:self.dataDic[@"remark"]].height+50;
    }else if (indexPath.row==2){
        return 300;
    }else{
        return [self lableSize:self.dataDic[@"verDesc"]].height+50;
    }
}
-(CGSize)lableSize:(NSString*)str{
    CGSize size=[str boundingRectWithSize:CGSizeMake(SCREENWIDTH-30, 1000) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;//自适应大小
    return size;
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
