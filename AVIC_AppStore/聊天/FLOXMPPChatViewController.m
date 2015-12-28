//
//  FLOXMPPChatViewController.m
//  AVIC_AppStore
//
//  Created by admin on 15/12/25.
//  Copyright © 2015年 中航国际. All rights reserved.
//

#import "FLOXMPPChatViewController.h"
#import "FloChatBar.h"
#import "FLODataBaseEngin.h"
#import "FLOChatMessageModel.h"
#import "FLOChatRecordModel.h"
#import "XMPPManager.h"

@interface FLOXMPPChatViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (nonatomic, strong) FloChatBar *chatBar;

@property (nonatomic, strong) NSArray *localRecordArr;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FLOXMPPChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localRecordArr =[[FLODataBaseEngin shareInstance] selectAllChatMessagesWithChatUser:self.title];
    self.dataArr = [NSMutableArray arrayWithArray:_localRecordArr];
    
    [self configChatbar];
    [self configGesture];
    
    [XMPPManager manager].receiveMessageBlock = ^(FLOChatMessageModel *msgModel){
        [_dataArr addObject:msgModel];
        [self.chatTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    };
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.chatBar.textView.isFirstResponder) {
        [self.chatBar.textView resignFirstResponder];
    }
    
    //退出聊天时最后一条聊天存入chatRecord
    if (_dataArr.count>0) {
        FLOChatMessageModel *lastMessageModel = _dataArr.lastObject;
        [[FLODataBaseEngin shareInstance] saveChatRecord:[lastMessageModel chatRecord]];
    }
}

#pragma mark 触摸收起键盘
- (void)configGesture
{
    UIGestureRecognizer *ges = [[UIGestureRecognizer alloc] initWithTarget:self action:nil];
    ges.delegate = self;
    [self.chatTableView addGestureRecognizer:ges];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (_chatBar.keyboardVisiable) {
        _chatBar.bottomVVisiable = NO;
        [self.chatBar hiddenChatBar];
    } else if (_chatBar.bottomVVisiable) {
        [self.chatBar hiddenChatBar];
    }
    
    return NO;
}

- (void)configChatbar
{
    self.chatBar = [[[NSBundle mainBundle] loadNibNamed:@"FloChatBar" owner:nil options:nil] firstObject];
    
    //发送消息
    [_chatBar configParentVC:self sendMessage:^(NSString *msgBody, NSString *msgCategory) {
        if ([msgCategory isEqualToString:@"文字"]) {
            NSLog(@"文字消息>>%@", msgBody);
        } else if ([msgCategory isEqualToString:@"声音"]) {
            NSLog(@"声音消息>>%@", msgBody);
        } else if ([msgCategory isEqualToString:@"图片"]) {
            NSLog(@"图片消息>>%@", msgBody);
        } else {
            return;
        }
    }];
    [self.chatBarView addSubview:_chatBar];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
//    if (!cell) {
//        cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
//        //cell.backgroundColor=[UIColor clearColor];
//    }
//    
//    XMPPMessageArchiving_Message_CoreDataObject *object = self.tableviewDatas[indexPath.row];
//    // cell.textLabel.text=object.body;
//    [cell configUI:object leftImage:self.leftImage rightImage:self.rightImage];
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *message = [(XMPPMessageArchiving_Message_CoreDataObject*)self.tableviewDatas[indexPath.row] body];
//    if ([message hasPrefix:MESSAGE_Text]) {
//        CGSize size=[message boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
//        return size.height+55;
//    }else if ([message hasPrefix:MESSAGE_Image]){
//        UIImage *image = [Photo string2Image:[[message componentsSeparatedByString:@"@"]firstObject]];
//        return image.size.height+55;
//    } else if ([message hasPrefix:MESSAGE_Voice]){
//        return 80;
//    } else if ([message hasPrefix:MESSAGE_File]){
//        return 80;
//    } else {
//        return 80;
//    }
    return 80.;
}


@end
