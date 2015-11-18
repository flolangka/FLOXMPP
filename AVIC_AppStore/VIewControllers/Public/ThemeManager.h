//
//  ThemeManager.h
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-16.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

+(ThemeManager*)sharedManager;
-(void)writeToFile:(NSString*)fileName;
-(void)changeTheme:(NSDictionary*)dic;

@end
