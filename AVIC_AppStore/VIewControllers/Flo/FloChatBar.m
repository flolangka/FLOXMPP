//
//  FloChatBar.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/17.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

/**
 *  emoji object
 *  保存为字典形式，放入到可变数组中
 *  @{@"name": @"[微笑]",
 *    @"value": @"Expression_001@2x.png"}
 */
#define kEmojiDicName  @"name"
#define kEmojiDicValue @"value"

#import "FloChatBar.h"
#import "DEFIND.h"
#import "FloChatVC.h"
#import "FloXMPPUser.h"

#define kChatBarHeight     44
#define kSpace             5

@implementation FloChatBar

- (void)awakeFromNib
{
    [self setContent];
}

- (void)setContent
{
    isTextType = YES;
    self.bottomVVisiable = NO;
    self.keyboardVisiable = NO;
    
    lastKeyboardHeight = 0.0;
    
    [self configUI];
    self.textView.delegate = self;
    
    [self configNotification];
}

- (void)configUI
{
    self.frame = CGRectMake(0, 0, SCREENWIDTH, kChatBarHeight + kChatbarBottomVHeight);
    self.backgroundColor = self.topView.backgroundColor;
    
    [self configEmojiBtn];
    [self configAddBtn];
    [self configVoiceDownBtn];
    [self configRightView];
}

- (void)configNotification
{
    [self.emojiBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self.addBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [NOTICENTER addObserver:self selector:@selector(textVTextDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [NOTICENTER addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NOTICENTER addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [self.emojiBtn removeObserver:self forKeyPath:@"selected"];
    [self.addBtn removeObserver:self forKeyPath:@"selected"];
    [NOTICENTER removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [NOTICENTER removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NOTICENTER removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma marf KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.emojiBtn) {
        if ([change[@"new"] boolValue]) {
            //被选中状态
            [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewInputText"] forState:UIControlStateNormal];
            [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewInputTextHL"] forState:UIControlStateHighlighted];
        } else {
            [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        }
    } else if (object == self.addBtn) {
        if ([change[@"new"] boolValue]) {
            [_addBtn setImage:[UIImage imageNamed:@"ToolViewInputText"] forState:UIControlStateNormal];
            [_addBtn setImage:[UIImage imageNamed:@"ToolViewInputTextHL"] forState:UIControlStateHighlighted];
        } else {
            [_addBtn setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_addBtn setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark 复原位置
- (void)hiddenChatBar
{
    if (self.keyboardVisiable) {
        [self.textView resignFirstResponder];
    } else {
        if (_emojiBtn.selected) {
            self.emojiBtn.selected = NO;
        }
        if (_addBtn.selected) {
            self.addBtn.selected = NO;
        }
        [self voiceDownBtnAction];
    }
}


/**
 *  文本框显示时:表情、附件、文本
 *  声音单独的
 */
- (void)msgTypeDidChanged
{
    if (!isTextType) {
        //声音类型，configBottomV
        [self clearSubviews:self.bottomView];
        [self.bottomView addSubview:self.collectVoiceV];
        
        if (!_bottomVVisiable) {
            [self chatbarBottomVShow];
        }
    } else {
        if (_bottomVVisiable) {
            switch (bottomType) {
                case FloBottomTypeEmoji:
                    //选择表情
                    [self clearSubviews:self.bottomView];
                    [self.bottomView addSubview:self.emojiV];
                    
                    break;
                case FloBottomTypeFile:
                    //选择附件
                    [self clearSubviews:self.bottomView];
                    [self.bottomView addSubview:self.addFileV];
                    
                    break;
                case FloBottomTypeKeyboard:
                    break;
                default:
                    break;
            }
        } else {
            switch (bottomType) {
                case FloBottomTypeEmoji:
                    //选择表情
                    [self clearSubviews:self.bottomView];
                    [self.bottomView addSubview:self.emojiV];
                    
                    [self chatbarBottomVShow];
                    break;
                case FloBottomTypeFile:
                    //选择附件
                    [self clearSubviews:self.bottomView];
                    [self.bottomView addSubview:self.addFileV];
                    
                    [self chatbarBottomVShow];
                    break;
                case FloBottomTypeKeyboard:
                    break;
                default:
                    break;
            }
        }
    }
    
    [self refreshCenterView];
    [self refreshRightView];
}

- (void)clearSubviews:(UIView *)view
{
    for (UIView *v in view.subviews) {
        [v removeFromSuperview];
    }
}


#pragma mark 表情按钮
- (void)configEmojiBtn
{
    [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_emojiBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    _emojiBtn.selected = NO;
}

- (IBAction)emojiBtnAction:(UIButton *)sender {
    
    if (_addBtn.selected) {
        self.addBtn.selected = NO;
    }
    self.emojiBtn.selected = !_emojiBtn.selected;
    if (_emojiBtn.selected) {
        isTextType = YES;
        bottomType = FloBottomTypeEmoji;
        [self msgTypeDidChanged];
        
        [self.textView resignFirstResponder];
    } else {
        isTextType = YES;
        bottomType = FloBottomTypeKeyboard;
        [self msgTypeDidChanged];
        
        [self.textView becomeFirstResponder];
    }
}

- (UIView *)emojiV
{
    if (!_emojiV) {
        _emojiV = [self configEmojiV];
    }
    return _emojiV;
}

- (NSArray *)emojis
{
    if (!_emojis) {
        _emojis = [NSMutableArray array];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"expression"
                                                              ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSArray *values = [dic.allValues sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i < values.count; i++)
        {
            NSDictionary *emoDic = @{kEmojiDicName: [dic allKeysForObject:values[i]].firstObject,
                                     kEmojiDicValue: values[i]};
            [_emojis addObject:emoDic];
        }
    }
    return _emojis;
}

- (UIView *)configEmojiV
{
    UIView *emojiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kChatbarBottomVHeight)];
    emojiView.backgroundColor = [UIColor whiteColor];
    
    int rowNum = 3;
    int listNum = 7;
    CGFloat width = SCREENWIDTH/7.0;
    CGFloat height = kChatbarBottomVHeight/4.0;
    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kChatbarBottomVHeight*rowNum/(rowNum+1))];
    scrollV.contentSize = CGSizeMake(SCREENWIDTH*self.emojis.count/20, scrollV.frame.size.height);
    scrollV.showsVerticalScrollIndicator = NO;
    scrollV.showsHorizontalScrollIndicator = NO;
    scrollV.pagingEnabled = YES;
    scrollV.delegate = self;
    
    for (int page = 0; page < ceilf(self.emojis.count/20); page++) {
        UIView *pageV = [[UIView alloc] initWithFrame:CGRectMake(page*SCREENWIDTH, 0, SCREENWIDTH, scrollV.frame.size.height)];
        pageV.backgroundColor = [UIColor clearColor];
        
        for (int r = 0; r < rowNum; r++) {
            for (int l = 0; l < listNum; l++) {
                UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                emojiBtn.frame = CGRectMake(l*width, r*height, width, height);
                //右下角为删除按钮
                if (r == rowNum-1 && l == listNum-1) {
                    [emojiBtn setImage:[UIImage imageNamed:@"DeleteEmoticonBtn"] forState:UIControlStateNormal];
                    [emojiBtn setImage:[UIImage imageNamed:@"DeleteEmoticonBtnHL"] forState:UIControlStateHighlighted];
                    [emojiBtn addTarget:self action:@selector(emojiDeleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    int index = page*20 + r*listNum + l;
                    emojiBtn.tag = index + 1000;
                    NSDictionary *emojiDic = self.emojis[index];
                    [emojiBtn setImage:[UIImage imageNamed:emojiDic[kEmojiDicValue]] forState:UIControlStateNormal];
                    [emojiBtn addTarget:self action:@selector(emojiDidSelected:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                [pageV addSubview:emojiBtn];
            }
        }
        
        [scrollV addSubview:pageV];
    }
    
    UIPageControl *pageCon = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kChatbarBottomVHeight*rowNum/(rowNum+1), SCREENWIDTH, kChatbarBottomVHeight/(rowNum+1))];
    pageCon.numberOfPages = ceilf(self.emojis.count/20);
    pageCon.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageCon.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    [pageCon addTarget:self action:@selector(pageControlTouchAction:) forControlEvents:UIControlEventValueChanged];
    
    [emojiView addSubview:scrollV];
    [emojiView addSubview:pageCon];
    return emojiView;
}

- (void)emojiDeleteBtnAction
{
    NSLog(@"删除");
}

- (void)emojiDidSelected:(UIButton *)sender
{
    int emojiIndex = sender.tag - 1000;
    NSDictionary *emojiDic = self.emojis[emojiIndex];
    NSString *emojiName = emojiDic[kEmojiDicName];
    self.textView.text = [_textView.text stringByAppendingString:emojiName];
    [self textVTextDidChanged:nil];
}

#pragma mark scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UIPageControl *pageCon;
    for (UIView *v in scrollView.superview.subviews) {
        if ([v isKindOfClass:[UIPageControl class]]) {
            pageCon = (UIPageControl *)v;
        }
    }
    
    CGPoint point = scrollView.contentOffset;
    pageCon.currentPage = (NSInteger)point.x/SCREENWIDTH;
}

#pragma mark pageControl 事件
- (void)pageControlTouchAction:(UIPageControl *)pageControl
{
    UIScrollView *scrollV;
    for (UIView *view in pageControl.superview.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollV = (UIScrollView *)view;
        }
    }
    
    int currentPage = pageControl.currentPage;
    [scrollV scrollRectToVisible:CGRectMake(SCREENWIDTH*currentPage, 0, SCREENWIDTH, scrollV.frame.size.height) animated:YES];
}


#pragma mark 附件按钮
- (void)configAddBtn
{
    [_addBtn setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_addBtn setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    _addBtn.selected = NO;
}

- (IBAction)addBtnAction:(UIButton *)sender {
    
    if (_emojiBtn.selected) {
        self.emojiBtn.selected = NO;
    }
    self.addBtn.selected = !_addBtn.selected;
    if (_addBtn.selected) {
        isTextType = YES;
        bottomType = FloBottomTypeFile;
        [self msgTypeDidChanged];
        
        [self.textView resignFirstResponder];
    } else {
        isTextType = YES;
        bottomType = FloBottomTypeKeyboard;
        [self msgTypeDidChanged];
        
        [self.textView becomeFirstResponder];
    }
}

- (UIView *)addFileV
{
    if (!_addFileV) {
        _addFileV = [self configAddFileV];
    }
    return _addFileV;
}

- (UIView *)configAddFileV
{
    UIView *addFileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kChatbarBottomVHeight)];
    
    //按钮图片与标题
    NSArray *images = @[@"jpg", @"wenjian", @"tonghua"];
    NSArray *titles = @[@"图片", @"文件", @"通话"];
    
    int rowNum = 2;
    int listNum = 4;
    CGFloat pageConHeight = 30;
    CGFloat conWidth = SCREENWIDTH/4.0;
    CGFloat conHeight = (kChatbarBottomVHeight-pageConHeight)/2.0;
    CGFloat imageVWidth = (conHeight-10-21) >= conWidth-40 ? conWidth-40 : conHeight-10-21;
    
    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kChatbarBottomVHeight-pageConHeight)];
    scrollV.contentSize = CGSizeMake(SCREENWIDTH*ceilf(images.count/8.0), scrollV.frame.size.height);
    scrollV.showsVerticalScrollIndicator = NO;
    scrollV.showsHorizontalScrollIndicator = NO;
    scrollV.pagingEnabled = YES;
    scrollV.delegate = self;
    
    for (int page = 0; page < ceilf(images.count/8.0); page++) {
        UIView *pageV = [[UIView alloc] initWithFrame:CGRectMake(page*SCREENWIDTH, 0, SCREENWIDTH, scrollV.frame.size.height)];
        pageV.backgroundColor = [UIColor clearColor];
        
        int max_r;
        if (page < ceilf(images.count/8.0)-1) {
            max_r = rowNum;
        } else {
            max_r = images.count%8 > 4 ? 2 : 1;
        }
        for (int r = 0; r < max_r; r++) {
            
            int max_l;
            if (page == ceilf(images.count/8.0)-1 && r == max_r-1) {
                max_l = images.count%4;
            } else {
                max_l = 4;
            }
            for (int l = 0; l < max_l; l++) {
                int index = page*8 + r*listNum + l;
                UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(l*conWidth, r*conHeight, conWidth, conHeight)];
                control.tag = index + 1000;
                [control addTarget:self action:@selector(addFileControlAction:) forControlEvents:UIControlEventTouchUpInside];
                
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, imageVWidth, imageVWidth)];
                imageV.image = [UIImage imageNamed:images[index]];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageVWidth+10, conWidth, conHeight-imageVWidth-10)];
                label.text = titles[index];
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [UIColor darkGrayColor];
                label.textAlignment = NSTextAlignmentCenter;
                
                [control addSubview:imageV];
                [control addSubview:label];
                [pageV addSubview:control];
            }
        }
        
        [scrollV addSubview:pageV];
    }
    
    UIPageControl *pageCon = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kChatbarBottomVHeight-pageConHeight, SCREENWIDTH, pageConHeight)];
    pageCon.numberOfPages = ceilf(images.count/8.0);
    pageCon.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageCon.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    [pageCon addTarget:self action:@selector(pageControlTouchAction:) forControlEvents:UIControlEventValueChanged];
    pageCon.hidden = pageCon.numberOfPages > 1 ? NO : YES;
    
    [addFileView addSubview:pageCon];
    [addFileView addSubview:scrollV];
    
    return addFileView;
}

- (void)addFileControlAction:(UIControl *)sender
{
    int index = sender.tag-1000;
    switch (index) {
        case 0:
            [self configPictureActionSheet];
            break;
        case 1:
            NSLog(@"视频");
            break;
        case 2:
            NSLog(@"位置");
            break;
        default:
            break;
    }
}

- (void)configPictureActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
    [actionSheet showInView:self.superview.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //拍照
        [self takeAPhoto];
    } else if (buttonIndex == 1){
        //从相册中选取图片
        [self selectAPictureFromPhotoLibrary];
    }
}

- (void)takeAPhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:@"提示"
                                    message:@"该设备不支持拍照功能"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentImagePickerVCWithType:sourceType];
}

- (void)selectAPictureFromPhotoLibrary
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentImagePickerVCWithType:sourceType];
}

- (void)presentImagePickerVCWithType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController *imagePickerC = [[UIImagePickerController alloc] init];
    imagePickerC.allowsEditing = YES;
    imagePickerC.delegate = self;
    imagePickerC.sourceType = type;
    
    [self.vc presentViewController:imagePickerC animated:YES completion:nil];
}

#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //发送图片
#warning 发送图片
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 输入框
- (void)configVoiceDownBtn
{
    _voiceDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceDownBtn.frame = CGRectMake(0, 0, _centerView.frame.size.width, _centerView.frame.size.height);
    [_voiceDownBtn setImage:[[UIImage imageNamed:@"xiala"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_voiceDownBtn addTarget:self action:@selector(voiceDownBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshCenterView
{
    if (!isTextType && !_textView.hidden) {
        _textView.hidden = YES;
        [_centerView addSubview:_voiceDownBtn];
    } else if (isTextType && _textView.hidden) {
        [_voiceDownBtn removeFromSuperview];
        _textView.hidden = NO;
    }
}

//V按钮按下，切换到文本框，不获得焦点
- (void)voiceDownBtnAction
{
    isTextType = YES;
    bottomType = FloBottomTypeKeyboard;
    [self msgTypeDidChanged];
    
    [self chatBarResetFrame];
}

#pragma mark textView delegate
- (void)textVTextDidChanged:(NSNotification *)noti
{
    if (_textView.text.length > 0) {
        //显示发送
        if (!_sendBtn.hidden) {
            return;
        } else {
            [_checkoutBtn removeFromSuperview];
            _sendBtn.hidden = NO;
        }
    } else {
        //显示声音按钮
        if (_sendBtn.hidden) {
            return;
        } else {
            _sendBtn.hidden = YES;
            [_rightView addSubview:_checkoutBtn];
        }
    }
    
#warning 计算高度,改变topview的y与height
}



#pragma mark 发送/声音按钮
- (void)configRightView
{
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.layer.cornerRadius = 4.0;
    _sendBtn.frame = CGRectMake(0, kSpace, _rightView.frame.size.width, _rightView.frame.size.height-2*kSpace);
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setBackgroundColor:[UIColor blueColor]];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.hidden = YES;
    
    _checkoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkoutBtn.frame = CGRectMake(0, 0, _rightView.frame.size.width, _rightView.frame.size.height);
    [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputVoice"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputVoiceHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    [_checkoutBtn addTarget:self action:@selector(checkOutBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_rightView addSubview:_sendBtn];
    [_rightView addSubview:_checkoutBtn];
}

- (void)refreshRightView
{
    if (!isTextType) {
        [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputText"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputTextHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    } else {
        [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputVoice"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_checkoutBtn setImage:[[UIImage imageNamed:@"ToolViewInputVoiceHL"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    }
}

- (void)sendBtnAction
{
    [self sendMsg];
    _textView.text = @"";
    [self textVTextDidChanged:nil];
    [_textView resignFirstResponder];
    [self chatBarResetFrame];
}

- (void)checkOutBtnAction
{
    if (_emojiBtn.selected) {
        self.emojiBtn.selected = NO;
    }
    if (_addBtn.selected) {
        self.addBtn.selected = NO;
    }
    if (_textView.hidden) {
        isTextType = YES;
        bottomType = FloBottomTypeKeyboard;
        [self msgTypeDidChanged];
        
        [self.textView becomeFirstResponder];
    } else {
        [self.textView resignFirstResponder];
        
        isTextType = NO;
        bottomType = FloBottomTypeVoice;
        [self msgTypeDidChanged];
    }
}

#pragma mark 录音模块
- (UIView *)collectVoiceV
{
    if (!_collectVoiceV) {
        _collectVoiceV = [[[NSBundle mainBundle] loadNibNamed:@"FloChatBar" owner:nil options:nil] lastObject];
        _collectVoiceV.chatVoiceVDelegate = self;
    }
    return _collectVoiceV;
}


#pragma mark 发送消息
- (void)sendMsg
{
    ZCXMPPManager *manager = [ZCXMPPManager sharedInstance];
    //表情+文本；附件先只有图片在上面单独方法发送;声音在代理中实现
    [manager sendMessageWithJID:_chatUser.userName Message:_textView.text Type:MESSAGE_Text];
}

#pragma mark voice 发送声音代理
- (void)chatVoiceVSendVoiceMsg:(NSString *)voicePath
{
    ZCXMPPManager *manager = [ZCXMPPManager sharedInstance];
    [manager sendMessageWithJID:_chatUser.userName Message:voicePath Type:MESSAGE_Voice];
}


#pragma mark 消息类型改变时页面布局调整
- (void)keyboardWillShow:(NSNotification *)noti
{
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    if (keyboardRect.size.height > lastKeyboardHeight) {
        CGFloat upHeight = keyboardRect.size.height - lastKeyboardHeight;
        lastKeyboardHeight = keyboardRect.size.height;
        
        upHeight = _bottomVVisiable ? lastKeyboardHeight-kChatbarBottomVHeight : upHeight;
        [self chatBarUp:upHeight];
        
        _bottomVVisiable = YES;
        _keyboardVisiable = YES;
        
        NSLog(@"键盘高度>>>>>>%f<<<<<<<",upHeight);
    } else {
        return;
    }
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    CGFloat downHeight = _bottomVVisiable ? kChatbarBottomVHeight-lastKeyboardHeight : -lastKeyboardHeight;
    [self chatBarUp:downHeight];
    lastKeyboardHeight = 0.0;
    _keyboardVisiable = NO;
}

- (void)chatBarResetFrame
{
    [self chatBarUp:-kChatbarBottomVHeight];
    _bottomVVisiable = NO;
}

- (void)chatbarBottomVShow
{
    [self chatBarUp:kChatbarBottomVHeight];
    _bottomVVisiable = YES;
}

#pragma mark 键盘弹出页面布局
- (void)chatBarUp:(CGFloat)height
{
    //找到约束,更改为需要的高度
    NSArray *constraintArray = self.vc.chatBarView.constraints;
    for (NSLayoutConstraint *constraint in constraintArray) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant += height;
        }
    }
    [self.vc.view layoutSubviews];
}


@end
