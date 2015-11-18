//
//  MessageDetailCell.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-22.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MessageDetailCell.h"

@implementation MessageDetailCell

- (void)awakeFromNib {
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self makeUI];
    }
    return  self;
}
-(void)makeUI{
    NSString*tempPath=[NSString stringWithFormat:@"Themes/%@",THEME];
    NSString*themePath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempPath];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.2, 10, self.contentView.frame.size.width*0.6, 1)];
    _imageView.image=[UIImage imageNamed:@"jianbianxian.png"];
    [self.contentView addSubview:_imageView];
    _msgDate=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    _msgDate.center=_imageView.center;
    _msgDate.textAlignment=NSTextAlignmentCenter;
    _msgDate.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:_msgDate];
    _msgImageview=[[UIImageView alloc]initWithFrame:CGRectZero];
    _msgImageview.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/xiaoxikuang.png",themePath]];
    _msgImageview.userInteractionEnabled=YES;
    [self.contentView addSubview:_msgImageview];
    _msgLable=[[UILabel alloc]initWithFrame:CGRectZero];
    _msgLable.backgroundColor=[UIColor clearColor];
    _msgLable.numberOfLines=0;
    _msgLable.font=[UIFont systemFontOfSize:15];
    _msgLable.userInteractionEnabled=YES;
    [_msgImageview addSubview:_msgLable];
    
}
-(void)configUI:(NSDictionary*)dic indexpath:(NSIndexPath *)indexPath isEdit:(BOOL)edit{
    if([THEME isEqualToString:@"深蓝"]){
        _msgDate.textColor=[UIColor whiteColor];
        _msgLable.textColor=[UIColor whiteColor];
    }else{
        _msgDate.textColor=[UIColor blackColor];
        _msgLable.textColor=[UIColor blackColor];
    }
    _msgDate.text=@"2014-12-22";
    NSString*msg=@"关于采购更换首批烟草探测器的，关于路通公司高管任职情况的，通过对上海高航实业有限公司";
    CGSize size=[msg boundingRectWithSize:CGSizeMake(SCREENWIDTH*0.7, 1000) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;//自适应大小
    [_selectedBtn removeFromSuperview];
    if(!edit){
        
        _msgImageview.frame=CGRectMake(SCREENWIDTH*0.1, 30, size.width+20, size.height+20);
    }else{//编辑状态
        _msgImageview.frame=CGRectMake(SCREENWIDTH*0.1+20, 30, size.width+20, size.height+20);
        _selectedBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.frame=CGRectMake(10, _msgImageview.center.y-20, 30, 30);
        [_selectedBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"weixuanze.png"]] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"xuanze.png"]] forState:UIControlStateSelected];
        [_selectedBtn addTarget:self action:@selector(_selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectedBtn.tag=indexPath.row+100;
        [self.contentView addSubview:_selectedBtn];

    }
    _msgLable.frame=CGRectMake(10, 10, size.width, size.height);
    _msgLable.text=msg;
    

}
-(void)_selectedBtnClick:(UIButton*)button{
    //button.selected=!button.selected;
    if([self.delegate respondsToSelector:@selector(addRemoveRows:)]){
        [self.delegate addRemoveRows:button];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    //    CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
    CGContextStrokeRect(context, CGRectMake(5, rect.size.height, rect.size.width - 10, 0.5));
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
