//
//  ThemeManager.m
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import "ThemeManager.h"
#import "ZipArchive.h"

@implementation ThemeManager

static ThemeManager*manager;
+(ThemeManager*)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[ThemeManager alloc]init];
    });
    return manager;
}
//-(id)init{
//    if(self=[super init]){
//        [self writeToFile];
//    }
//    return  self;
//}
-(void)writeToFile:(NSString*)fileName{
    //if(![[NSUserDefaults standardUserDefaults]objectForKey:@"isFirst"]){
        NSString*path=[[NSBundle mainBundle]pathForResource:fileName ofType:@"zip"];
        NSData*data=[NSData dataWithContentsOfFile:path];
        if(data){
            [data writeToFile:[NSString stringWithFormat:@"%@/%@.zip",LIBPATH,fileName] atomically:YES];
            ZipArchive*zip=[[ZipArchive alloc]init];
            [zip UnzipOpenFile:[NSString stringWithFormat:@"%@/%@.zip",LIBPATH,fileName]];
            [zip UnzipFileTo:[NSString stringWithFormat:@"%@/%@",LIBPATH,fileName] overWrite:YES];
            [zip UnzipCloseFile];
            
        }
        
    //}
}
-(void)changeTheme:(NSDictionary*)dic{
    NSUserDefaults*user=[NSUserDefaults standardUserDefaults];
    [user setObject:dic[@"name"] forKey:@"theme"];
    [user synchronize];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Theme" object:nil];
}


@end
