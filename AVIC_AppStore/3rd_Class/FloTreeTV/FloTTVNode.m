//
//  FloTTVNode.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloTTVNode.h"


@implementation FloTTVNode

- (instancetype)initWithParentId : (int)parentId nodeId : (int)nodeId name : (NSString *)name depth : (int)depth expand : (BOOL)expand object:(id)obj{
    self = [self init];
    if (self) {
        self.parentId = parentId;
        self.nodeId = nodeId;
        self.name = name;
        self.depth = depth;
        self.expand = expand;
        self.obj = obj ? obj : nil;
    }
    return self;
}


@end
