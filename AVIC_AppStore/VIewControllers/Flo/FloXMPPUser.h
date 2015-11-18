//
//  FloXMPPUser.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/28.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloXMPPUser : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *deptName;
@property (nonatomic, copy) NSString *iconUrl;

- (instancetype)initWithUserName:(NSString *)userName deptName:(NSString *)deptName iconURL:(NSString *)iconUrl;

@end
