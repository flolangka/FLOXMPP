//
//  FloVoiceModel.m
//  AVIC_AppStore
//
//  Created by admin on 15/10/10.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloVoiceModel.h"

@implementation FloVoiceModel

static FloVoiceModel *_voiceModel;
+ (instancetype)shareVoiceModel
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _voiceModel = [[self alloc] init];
    });
    return _voiceModel;
}

@end
