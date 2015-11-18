//
//  FloTreeTableView.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloTreeTableView.h"
#import "FloTTVNode.h"
#import "UIImageView+WebCache.h"
#import "FloXMPPUser.h"

#import "FloUserCell.h"
#import "FloGongsiCell.h"

static BOOL userCellRegisted = NO;
static BOOL gongsiCellRegisted = NO;

@implementation FloTreeTableView

-(instancetype)initWithFrame:(CGRect)frame withData : (NSArray *)data{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        _data = data;
        _tempData = [self createTempData:data];
    }
    return self;
}

/**
 * 初始化数据源
 */
-(NSMutableArray *)createTempData : (NSArray *)data{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<data.count; i++) {
        FloTTVNode *node = [_data objectAtIndex:i];
        if (node.parentId == -1) {
            [tempArray addObject:node];
        }
    }
    return tempArray;
}


#pragma mark - UITableViewDataSource

#pragma mark - Required

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tempData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FloTTVNode *node = [_tempData objectAtIndex:indexPath.row];
    CGFloat indentationWidth = 15.f;
    if (node.obj) {
        if (!userCellRegisted) {
            UINib *nib = [UINib nibWithNibName:@"FloUserCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellID_user];
            userCellRegisted = YES;
        }
        FloUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID_user forIndexPath:indexPath];
        FloXMPPUser *user = node.obj;
        [cell.iconImageV sd_setImageWithURL:[NSURL URLWithString:user.iconUrl] placeholderImage:[UIImage imageNamed:@"DefaultHead"]];
        cell.userNameL.text = user.userName;
        
        //该约束缩进
        NSArray *constraintArray = cell.contentView.constraints;
        for (NSLayoutConstraint *constraint in constraintArray) {
            if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                constraint.constant = node.depth * indentationWidth;
            }
        }
        [cell layoutSubviews];
        
        return cell;
    } else {
        if (!gongsiCellRegisted) {
            UINib *nib = [UINib nibWithNibName:@"FloGongsiCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellID_gongsi];
            gongsiCellRegisted = YES;
        }
        FloGongsiCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID_gongsi forIndexPath:indexPath];
        cell.mainLabel.text = node.name;
        cell.imageV.image = node.expand ? [UIImage imageNamed:@"fenzhu-xia"] : [UIImage imageNamed:@"fenzhu-shang"];
        
        //改约束缩进
        NSArray *constraintArray = cell.contentView.constraints;
        for (NSLayoutConstraint *constraint in constraintArray) {
            if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                constraint.constant = node.depth * indentationWidth;
            }
        }
        [cell layoutSubviews];
        
        return cell;
    }
}


#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FloTTVNode *node = [_tempData objectAtIndex:indexPath.row];
    if (node.obj) {
        return 50;
    }
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //先修改数据源
    FloTTVNode *parentNode = [_tempData objectAtIndex:indexPath.row];
    if (_treeTableCellDelegate && [_treeTableCellDelegate respondsToSelector:@selector(cellClick:)]) {
        [_treeTableCellDelegate cellClick:parentNode];
    }
    
    NSUInteger startPosition = indexPath.row+1;
    NSUInteger endPosition = startPosition;
    parentNode.expand = !parentNode.expand;
    for (int i=0; i<_data.count; i++) {
        FloTTVNode *node = [_data objectAtIndex:i];
        if (node.parentId == parentNode.nodeId) {
            if (parentNode.expand) {
                [_tempData insertObject:node atIndex:endPosition];
                endPosition++;
            }else{
                endPosition = [self removeAllNodesAtParentNode:parentNode];
                break;
            }
        }
    }
    
    //获得需要修正的indexPath
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=startPosition; i<endPosition; i++) {
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    //插入或者删除相关节点
    if (parentNode.expand) {
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //改右侧图片
    if (!parentNode.obj && parentNode.expand) {
        FloGongsiCell *cell = (FloGongsiCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.imageV.image = [UIImage imageNamed:@"fenzhu-xia"];
    } else if (!parentNode.obj && !parentNode.expand) {
        FloGongsiCell *cell = (FloGongsiCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.imageV.image = [UIImage imageNamed:@"fenzhu-shang"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  删除该父节点下的所有子节点（包括孙子节点）
 *
 *  @param parentNode 父节点
 *
 *  @return 该父节点下一个相邻的统一级别的节点的位置
 */
-(NSUInteger)removeAllNodesAtParentNode : (FloTTVNode *)parentNode{
    NSUInteger startPosition = [_tempData indexOfObject:parentNode];
    NSUInteger endPosition = startPosition;
    for (NSUInteger i=startPosition+1; i<_tempData.count; i++) {
        FloTTVNode *node = [_tempData objectAtIndex:i];
        endPosition++;
        if (node.depth <= parentNode.depth) {
            break;
        }
        if(endPosition == _tempData.count-1){
            endPosition++;
            node.expand = NO;
            break;
        }
        node.expand = NO;
    }
    if (endPosition>startPosition) {
        [_tempData removeObjectsInRange:NSMakeRange(startPosition+1, endPosition-startPosition-1)];
    }
    return endPosition;
}

@end
