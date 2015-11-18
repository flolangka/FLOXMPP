//
//  FloChatVoiceView.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/23.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FloChatVoiceViewDelegate <NSObject>

- (void)chatVoiceVSendVoiceMsg:(NSString *)voicePath;

@end

@interface FloChatVoiceView : UIView<UIGestureRecognizerDelegate>

{    
    UILongPressGestureRecognizer *longPressGes;
    NSTimer *collectVoiceTimer;
    NSDate *startDate;
    
    UITouch *longGesLastTouch;
    NSString *voiceSaveName;
}

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *centerBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (nonatomic, weak) id<FloChatVoiceViewDelegate> chatVoiceVDelegate;

@end


