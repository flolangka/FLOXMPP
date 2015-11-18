//
//  FloChatBar.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/17.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FloChatVoiceView.h"

@class FloChatVC;
@class FloXMPPUser;

typedef enum {
    FloBottomTypeKeyboard,
    FloBottomTypeEmoji,
    FloBottomTypeVoice,
    FloBottomTypeFile
} FloBottomType;

@interface FloChatBar : UIView<UITextViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FloChatVoiceViewDelegate>

{
    BOOL isTextType;
    FloBottomType bottomType;
    UIButton *_voiceDownBtn;
    UIButton *_sendBtn;
    UIButton *_checkoutBtn;
    
    CGFloat lastKeyboardHeight;
}

//必须设置的
@property (nonatomic, assign) FloChatVC *vc;
@property (nonatomic, assign) FloXMPPUser *chatUser;


@property (nonatomic) BOOL bottomVVisiable;
@property (nonatomic) BOOL keyboardVisiable;

@property (nonatomic, strong) UIView *emojiV;
@property (nonatomic, strong) UIView *addFileV;
@property (nonatomic, strong) FloChatVoiceView *collectVoiceV;

@property (nonatomic, strong) NSMutableArray *emojis;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (void)hiddenChatBar;

@end
