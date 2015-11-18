//
//  FloXMPPUser.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloXMPPUser.h"

@implementation FloXMPPUser

- (instancetype)initWithUserName:(NSString *)userName deptName:(NSString *)deptName iconURL:(NSString *)iconUrl
{
    self = [super init];
    if (self) {
        self.userName = userName;
        self.deptName = deptName;
        self.iconUrl = iconUrl;
    }
    return self;
}

@end
