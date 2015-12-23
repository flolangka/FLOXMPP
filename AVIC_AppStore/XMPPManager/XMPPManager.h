//
//  XMPPManager.h
//  FloXMPP
//
//  Created by admin on 15/12/23.
//  Copyright © 2015年 flolangka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPManager : NSObject

+ (instancetype)manager;

//登录上线
- (void)authorizationWithUserName:(NSString *)userName password:(NSString *)password success:(void(^)())success failure:(void(^)())failure;

//新用户注册
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password success:(void(^)())success failure:(void(^)())failure;

@end
