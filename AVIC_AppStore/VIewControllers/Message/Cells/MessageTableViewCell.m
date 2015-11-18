//
//  MessageTableViewCell.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-18.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

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
    
    _msgIcon=[[UIImageView alloc]initWithFrame:CGRectMake(self.cellHeight*0.1, self.cellHeight*0.1, self.cellHeight*0.8, self.cellHeight*0.8)];
    _msgIcon.layer.cornerRadius=self.cellHeight*0.4;
    _msgIcon.layer.masksToBounds=YES;
    _msgIcon.image=[UIImage imageNamed:@"tubiao_M.png"];
    [self.contentView addSubview:_msgIcon];
    _msgTitle=[[UILabel alloc]initWithFrame:CGRectMake(_msgIcon.frame.origin.x+_msgIcon.frame.size.width+10, _msgIcon.frame.origin.y+10, SCREENWIDTH*0.5, _msgIcon.frame.size.height*0.3)];
    _msgTitle.font=[UIFont systemFontOfSize:20];
    _msgTitle.textAlignment=NSTextAlignmentLeft;
    _msgTitle.text=@"北京报销";
    [self.contentView addSubview:_msgTitle];
    _msgDescribe=[[UILabel alloc]initWithFrame:CGRectMake(_msgTitle.frame.origin.x, _msgTitle.frame.origin.y+_msgTitle.frame.size.height-5, SCREENWIDTH*0.5, _msgIcon.frame.size.height*0.7)];
    _msgDescribe.font=[UIFont systemFontOfSize:15];
    _msgDescribe.textAlignment=NSTextAlignmentLeft;
    _msgDescribe.textColor=[UIColor grayColor];
    _msgDescribe.text=@"关于北京公司高管任职情况";
    [self.contentView addSubview:_msgDescribe];
    _msgDate=[[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.7, _msgTitle.frame.origin.y, SCREENWIDTH*0.2, _msgTitle.frame.size.height*0.8)];
    _msgDate.text=@"2014-11-11";
    _msgDate.textAlignment=NSTextAlignmentRight;
    [self.contentView addSubview:_msgDate];
    
}
-(void)configUI:(NSDictionary*)dic{
    if([THEME isEqualToString:@"深蓝"]){
        _msgTitle.textColor=[UIColor whiteColor];
        _msgDate.textColor=[UIColor whiteColor];
    }else{
        _msgTitle.textColor=[UIColor blackColor];
        _msgDate.textColor=[UIColor blackColor];
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
