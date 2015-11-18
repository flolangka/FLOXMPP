//
//  FloTTVNode.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloTTVNode : NSObject

@property (nonatomic        ) int      parentId;//父节点的id，如果为-1表示该节点为根节点
@property (nonatomic        ) int      nodeId;//本节点的id
@property (nonatomic, strong) NSString *name;//本节点的名称
@property (nonatomic        ) int      depth;//该节点的深度
@property (nonatomic        ) BOOL     expand;//该节点是否处于展开状态

@property (nonatomic, strong) id obj;//如果是叶子就要设置其里面的对象。

/**
 *快速实例化该对象模型
 */
- (instancetype)initWithParentId : (int)parentId nodeId : (int)nodeId name : (NSString *)name depth : (int)depth expand : (BOOL)expand object:(id)obj;


@end
