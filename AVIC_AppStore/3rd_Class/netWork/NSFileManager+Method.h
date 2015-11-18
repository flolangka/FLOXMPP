//
//  NSFileManager+Method.h
//  HttpRequestDemo
//
//  Created by @HUI on 14-8-28.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Method)
-(BOOL)timeOutWithPath:(NSString*)path timeOut:(NSTimeInterval)time;
-(void)cacheClear;
@end










