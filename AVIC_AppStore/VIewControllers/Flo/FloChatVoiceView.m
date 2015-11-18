//
//  FloChatVoiceView.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/23.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloChatVoiceView.h"
#import "DEFIND.h"
#import "AFNetworking.h"

@implementation FloChatVoiceView

- (void)awakeFromNib
{
    [self configBottomBorder];
    [self reset];
}

- (void)configBottomBorder
{
    self.cancelBtn.layer.borderWidth = 1.0;
    self.cancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sendBtn.layer.borderWidth = 1.0;
    self.sendBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;    
}

#pragma mark 初始状态
- (void)reset
{
    if (![_topLabel.text isEqualToString:@"按住说话"]) {
        self.topLabel.text = @"按住说话";
    }
    self.rightBtn.hidden = YES;
    self.leftBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.sendBtn.hidden = YES;
    
    //中间按钮：改图片、加长按手势、移除target
    [self.centerBtn setImage:[UIImage imageNamed:@"yuyin-anjian"] forState:UIControlStateNormal];
    [self.centerBtn removeTarget:self action:@selector(playOrPauseVoice:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!longPressGes) {
        [self configLongPressGestureRecognizer];
    }
    if (![self.centerBtn.gestureRecognizers containsObject:longPressGes]) {
        [self.centerBtn addGestureRecognizer:longPressGes];
    }
}

#pragma mark 长按录音
- (void)configLongPressGestureRecognizer
{
    longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGes.delegate = self;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"录音开始");
        
        self.leftBtn.hidden = NO;
        self.rightBtn.hidden = NO;
        self.topLabel.text = @"0:00";
        [self startTimer];
        [self startCollectVoice];
        
        [UIView transitionWithView:self.centerBtn duration:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.centerBtn.transform = CGAffineTransformScale(self.centerBtn.transform, 0.75, 0.75);
        } completion:^(BOOL finished) {
            [UIView transitionWithView:_cancelBtn duration:0.25 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.centerBtn.transform = CGAffineTransformScale(self.centerBtn.transform, 4/3.0, 4/3.0);
            } completion:nil];
        }];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded){
        NSLog(@"录音结束");
        
        collectVoiceTimer.fireDate = [NSDate distantFuture];
        if (CGRectContainsPoint(_leftBtn.frame, [longGesLastTouch locationInView:self])) {
            //等待播放状态
            NSLog(@"等待播放");
            [self stopCollectAndSend:NO];
            [self.centerBtn removeGestureRecognizer:longPressGes];
            [self playReadying];
        } else if (CGRectContainsPoint(_rightBtn.frame, [longGesLastTouch locationInView:self])) {
            //删除
            NSLog(@"删除");
            [self stopCollectAndDel];
            [self reset];
        } else {
            NSLog(@"发送");
            [self stopCollectAndSend:YES];
            [self reset];
        }
    }
}

#pragma mark 录音时滑动
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    longGesLastTouch = touch;
    return YES;
}

#pragma mark 录音计时
- (void)startTimer
{
    if (!collectVoiceTimer) {
        collectVoiceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    }
    
    startDate = [NSDate date];
    collectVoiceTimer.fireDate = [NSDate date];
    [collectVoiceTimer fire];
}

- (void)timerEvent
{
    NSString *timeStr;
    NSTimeInterval collectTime = [[NSDate date] timeIntervalSinceDate:startDate];
    if (collectTime >= 120) {
        //最长时间120秒，自动进入待播放状态
        collectVoiceTimer.fireDate = [NSDate distantFuture];
        [self playReadying];
        timeStr = @"2:00";
    } else if (collectTime >= 60) {
        int secondInt = (int)collectTime - 60;
        NSString *second = secondInt > 9 ? [NSString stringWithFormat:@"%d",secondInt] : [NSString stringWithFormat:@"0%d",secondInt];
        timeStr = [NSString stringWithFormat:@"1:%@",second];
    } else {
        int secondInt = (int)collectTime;
        NSString *second = secondInt > 9 ? [NSString stringWithFormat:@"%d",secondInt] : [NSString stringWithFormat:@"0%d",secondInt];
        timeStr = [NSString stringWithFormat:@"0:%@",second];
    }
    self.topLabel.text = timeStr;
}

#pragma mark 录音
- (void)startCollectVoice
{
    
}

- (void)stopCollectVoice
{
    //声音文件名：当前用户名+时间
    voiceSaveName = [[USERDEFAULT objectForKey:kXMPPmyJID] stringByAppendingString:[NSString stringWithFormat:@"_%d",(int)[[NSDate date] timeIntervalSince1970]]];
    
    //判断文件夹是否存在，不存在就创建保存声音的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:PATH_DOC error:nil];
    if (![contents containsObject:@"voiceDict"]) {
        [fileManager createDirectoryAtPath:PATH_VOICE withIntermediateDirectories:YES attributes:NO error:nil];
    }
    NSString *savePath = [PATH_VOICE stringByAppendingPathComponent:voiceSaveName];
    
#warning 保存声音
}

- (void)stopCollectAndSend:(BOOL)send
{
    [self stopCollectVoice];
    if (send) {
        [self sendVoiceMsg];
    }
}

- (void)stopCollectAndDel
{
    [self stopCollectVoice];
    [self deleteVoice];
}

- (void)sendVoiceMsg
{
    //上传服务器
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kVOICE_Service]];
    NSString *fileServicePath = [kVOICE_Service stringByAppendingPathComponent:voiceSaveName];
    
    NSURL *filePath = [NSURL fileURLWithPath:[PATH_VOICE stringByAppendingPathComponent:voiceSaveName]];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"录音上传服务器失败>>>>Error: %@", error);
        } else {
            //xmpp发送本条消息
            if (_chatVoiceVDelegate && [_chatVoiceVDelegate respondsToSelector:@selector(chatVoiceVSendVoiceMsg:)]) {
                [_chatVoiceVDelegate chatVoiceVSendVoiceMsg:fileServicePath];
            }
        }
    }];
    [uploadTask resume];
    
    //在聊天界面中显示本条录音，但xmpp不发送
    
}

- (void)deleteVoice
{
    
}


#pragma mark 等待播放
- (void)playReadying
{
    [self.centerBtn setImage:[UIImage imageNamed:@"yuyin-anjian"] forState:UIControlStateNormal];
    [self.centerBtn addTarget:self action:@selector(playOrPauseVoice:) forControlEvents:UIControlEventTouchUpInside];
    self.leftBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.cancelBtn.hidden = NO;
    self.sendBtn.hidden = NO;
}

- (IBAction)cancelBtn:(UIButton *)sender {
    //删除语音
    [self deleteVoice];
    [self reset];
}

- (IBAction)sendBtn:(UIButton *)sender {
    [self sendVoiceMsg];
    [self reset];
}

- (void)playOrPauseVoice:(UIButton *)sender
{
    
}

- (void)dealloc
{
    [collectVoiceTimer invalidate];
}


/*
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextMoveToPoint(ctx, 0, _cancelBtn.frame.origin.y);
    CGContextAddLineToPoint(ctx, SCREENWIDTH, _cancelBtn.frame.origin.y);
    CGContextMoveToPoint(ctx, _sendBtn.frame., ;)
}
*/


@end
