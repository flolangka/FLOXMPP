//
//  WebRequest.h
//  AVIC_AppStore
//
//  Created by @HUI on 14-12-29.
//  Copyright (c) 2014年 HUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequest : NSObject

@property(nonatomic,strong)id dic;

//需要block指针
@property(nonatomic,copy)void(^ webRequest)(BOOL, WebRequest *);

-(id)initWithSoap:(NSString *)soapMsg namespace:(NSString *)space urlstr:(NSString *)urlstr methodname:(NSString *)methodname Block:(void(^)(BOOL,WebRequest*))block;


@end
