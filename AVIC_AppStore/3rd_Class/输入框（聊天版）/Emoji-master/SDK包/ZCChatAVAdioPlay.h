
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VoiceRecorderBaseVC.h"
#import "DEFIND.h"
@class ChatVoiceRecorderVC;
@interface ZCChatAVAdioPlay : NSObject<AVAudioPlayerDelegate,VoiceRecorderBaseVCDelegate>
{
    AVAudioPlayer *avAudioPlayer;   //播放器player
    BOOL isOpen;
    UIButton *oldButton;
    ChatVoiceRecorderVC*recorderVC;
}@property(nonatomic,copy)NSString*recordFilePath;

@property(nonatomic,copy)void(^endRecord)(NSString*sendStr);
//开启单例
+ (ZCChatAVAdioPlay*)sharedInstance;
//播放声音
-(void)playSetAvAudio:(NSData*)data;

//录音的处理
//开始录音
-(void)startRecording;
//结束录音  录音完成后WAV格式转换为AMR格式进行  AMR格式转换base64
-(void)endRecordingWithBlock:(void(^)(NSString*))a;

//获得录音文件夹下的所有文件
+(NSArray*)getVoiceFileName;
//清理缓存
+(void)clear;

@end
