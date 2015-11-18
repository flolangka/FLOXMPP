//
//  NSFileManager+Method.m
//  HttpRequestDemo
//
//  Created by @HUI on 14-8-28.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import "NSFileManager+Method.h"

@implementation NSFileManager (Method)
-(BOOL)timeOutWithPath:(NSString*)path timeOut:(NSTimeInterval)time{
    NSString*_path=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),path];
    NSDictionary*dic=[[NSFileManager defaultManager]attributesOfItemAtPath:_path error:nil];
    NSDate*createDate= [dic objectForKey:NSFileCreationDate];
    NSDate*date=[NSDate date];
    NSTimeInterval isTime=[date timeIntervalSinceDate:createDate];
    
    if (isTime>time) {
        return YES;
    }else{
        return NO;
    }

}
//清除所有缓存
-(void)cacheClear{
    NSString*path=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSArray*fileNameArray=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString*fileName in fileNameArray) {
        //删除文件
        [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,fileName] error:nil];
        
    }

}



@end
