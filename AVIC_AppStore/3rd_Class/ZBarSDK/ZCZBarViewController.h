//
//  ZCZBarViewController.h
//  ZbarDemo
//
//  Created by ZC on 14-4-18.
//  Copyright (c) 2014年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderController.h"
#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7
@interface ZCZBarViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZBarReaderDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UIImageView*_line;
}


@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, assign) BOOL isScanning;

@property (nonatomic,copy)void(^ScanResult)(NSString*result,BOOL isSucceed);
//初始化函数
-(id)initWithBlock:(void(^)(NSString*,BOOL))a;

//正则表达式对扫描结果筛选
+(NSString*)zhengze:(NSString*)str;


@end
