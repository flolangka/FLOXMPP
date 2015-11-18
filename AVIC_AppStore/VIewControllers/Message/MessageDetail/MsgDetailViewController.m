//
//  MsgDetailViewController.m
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-19.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "MsgDetailViewController.h"
#import "MessageDetailCell.h"

@interface MsgDetailViewController ()<messageDelegate>
{
    NSMutableArray*_selectedArr;//选中删除的数组
    UIImageView*_editView;//删除框
    BOOL isEditing;//是否编辑
}

@end

@implementation MsgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedArr=[NSMutableArray arrayWithCapacity:0];
    [self createNav];
    [self createTableView];
    self.dataArr=[NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"]];
}
-(void)themeChange{
    [self.tableView reloadData];
}
#pragma mark 导航
-(void)createNav{
    [self createLeftBtn];
    UIButton*rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.bounds=CGRectMake(0, 0, 25, 25);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"shanchu.png"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"queding.png"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem=rightItem;
}
-(void)rightItemClick:(UIButton*)button{
    if(_selectedArr!=nil&&isEditing){
        //[self.tableView deleteRowsAtIndexPaths:_selectedArr withRowAnimation:UITableViewRowAnimationLeft];
        NSMutableIndexSet*tempSet=[NSMutableIndexSet indexSet];
        for(id num in _selectedArr){
            [tempSet addIndex:[num intValue]];
            
        }
        [self.dataArr removeObjectsAtIndexes:tempSet];
        _selectedArr=[NSMutableArray arrayWithCapacity:0];
        
    }
    button.selected=!button.selected;
    isEditing=button.selected;
    [self.tableView reloadData];
    //_selectedArr=[NSMutableArray arrayWithCapacity:0];
}
-(void)createTableView{
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    //self.tableView.allowsMultipleSelectionDuringEditing=YES;
    [self.view addSubview:self.tableView];
    UILongPressGestureRecognizer*longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copyText:)];
    longPress.minimumPressDuration=1.0f;
    [self.tableView addGestureRecognizer:longPress];
}
#pragma mark tableView代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageDetailCell*cell;
    if(!isEditing){
        cell=[tableView dequeueReusableCellWithIdentifier:@"unEdit"];
        if(!cell){
            cell=[[MessageDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"unEdit"];
            
        }
        
    }else{
        cell=[tableView dequeueReusableCellWithIdentifier:@"Edit"];
        if(!cell){
            cell=[[MessageDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Edit"];
            
        }
        
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    //MyLog(@"%@",[cell performSelector:@selector([recursiveDescription])]);
    [cell configUI:nil indexpath:indexPath isEdit:isEditing];
    [_editView removeFromSuperview];
    if(isEditing){
        if(![_selectedArr containsObject:[NSNumber numberWithLong:indexPath.row]]){
            cell.selectedBtn.selected=NO;
        }else{
            cell.selectedBtn.selected=YES;
        }
    }
    
    return cell;
}
-(void)copyText:(UILongPressGestureRecognizer*)longPress{
    
    if(isEditing){
        return;
    }
    CGPoint point=[longPress locationInView:self.tableView];
    NSIndexPath*indexPath=[self.tableView indexPathForRowAtPoint:point];
    MessageDetailCell*cell=(MessageDetailCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.msgImageview.userInteractionEnabled=YES;
    [_editView removeFromSuperview];
    _editView=[[UIImageView alloc]initWithFrame:CGRectMake(cell.msgImageview.frame.origin.x+cell.msgImageview.frame.size.width-50, cell.msgImageview.frame.origin.y-10, 90, 35)];
    _editView.userInteractionEnabled=YES;
    _editView.image=[UIImage imageNamed:[NSString stringWithFormat:@"shanchukuang.png"]];
    [cell.contentView addSubview:_editView];
    for(int i=0;i<2;i++){
        UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(i*45, 0, 45, 35);
        button.backgroundColor=[UIColor clearColor];
        button.tag=1000+i;
        //button.showsTouchWhenHighlighted=YES;
        [button addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editView addSubview:button];
    }
}
-(void)editClick:(UIButton*)button{
    MessageDetailCell*cell=(MessageDetailCell*)[_editView.superview superview];
    NSIndexPath*indexPath=[self.tableView indexPathForCell:cell];
    MyLog(@"%ld,%ld",(long)indexPath.section,(long)indexPath.row);
    if(button.tag==1000){
        UIPasteboard*paste=[UIPasteboard generalPasteboard];
        [paste setString:cell.msgLable.text];
        MyLog(@"1");
    }else if (button.tag==1001){
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        MyLog(@"2");
    }
    [_editView removeFromSuperview];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_editView removeFromSuperview];
}
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    //return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
//    return UITableViewCellEditingStyleNone;
//}
#pragma mark cell代理方法
-(void)addRemoveRows:(UIButton*)button{
    button.selected=!button.selected;
    if(button.selected&&![_selectedArr containsObject:[NSNumber numberWithLong:button.tag-100 ]]){
        [_selectedArr  addObject:[NSNumber numberWithLong:button.tag-100]];
    }else if(!button.selected&&[_selectedArr containsObject:[NSNumber numberWithLong:button.tag-100]]){
        [_selectedArr removeObject:[NSNumber numberWithLong:button.tag-100]];
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
