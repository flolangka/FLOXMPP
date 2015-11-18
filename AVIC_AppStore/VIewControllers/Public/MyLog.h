//
//  MyLog.h
//  AVIC_AppStore
//
//  Created by @HUI on 15-1-26.
//  Copyright (c) 2015年 HUI. All rights reserved.
//

#ifdef DEBUG
#define MyLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define MyLog(format, ...)
#endif