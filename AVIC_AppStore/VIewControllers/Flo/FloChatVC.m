//
//  FloChatVC.m
//  AVIC_AppStore
//
//  Created by admin on 15/9/13.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import "FloChatVC.h"
#import "FloChatBar.h"
#import "DEFIND.h"
#import "MessageCell.h"
#import "Photo.h"
#import "FloXMPPUser.h"

@interface FloChatVC ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

{
    ZCXMPPManager *manager;
}

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (nonatomic, strong) NSMutableArray *tableviewDatas;
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, strong) FloChatBar *chatBar;

@end

@implementation FloChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _chatUser.userName;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self configNotification];
    
    manager = [ZCXMPPManager sharedInstance];
    [manager valuationChatPersonName:[NSString stringWithFormat:@"%@@%@",self.chatUser.userName,userDOMAIN] IsPush:YES MessageBlock:^(ZCMessageObject *message) {
        [self loadChatHistory];
        
    }];
    
    [self configChatbar];
    [self loadChatHistory];
    [self configIcon];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.chatBar.textView.isFirstResponder) {
        [self.chatBar.textView resignFirstResponder];
    }
}

- (void)configNotification
{
    UIGestureRecognizer *ges = [[UIGestureRecognizer alloc] initWithTarget:self action:nil];
    ges.delegate = self;
    [self.chatTableView addGestureRecognizer:ges];
}

#pragma mark 触摸
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


#pragma mark 页面初始化
- (void)configChatbar
{
    self.chatBar = [[[NSBundle mainBundle] loadNibNamed:@"FloChatBar" owner:nil options:nil] firstObject];
    self.chatBar.chatUser = _chatUser;
    self.chatBar.vc = self;
    [self.chatBarView addSubview:self.chatBar];
}

- (void)loadChatHistory
{
    NSArray *array = [manager messageRecord];
    self.tableviewDatas = [NSMutableArray arrayWithArray:array];
    [self.chatTableView reloadData];
    if (self.tableviewDatas.count) {
        [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableviewDatas.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)configIcon
{
    [manager getMyVcardBlock:^(BOOL isFinish, XMPPvCardTemp *vcard) {
        if (isFinish) {
            if (vcard.photo) {
                self.rightImage = [UIImage imageWithData:vcard.photo];
            }else{
                self.rightImage = [UIImage imageNamed:@"DefaultHead"];
            }
            [_chatTableView reloadData];
        }
    }];
    
    [manager friendsVcard:self.chatUser.userName Block:^(BOOL isFinish, XMPPvCardTemp *vcard) {
        if (isFinish) {
            if (vcard.photo) {
                self.leftImage=[UIImage imageWithData:vcard.photo];
            }else{
                self.leftImage=[UIImage imageNamed:@"DefaultHead"];
                
            }
            [_chatTableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableviewDatas.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        //cell.backgroundColor=[UIColor clearColor];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *object = self.tableviewDatas[indexPath.row];
    // cell.textLabel.text=object.body;
    [cell configUI:object leftImage:self.leftImage rightImage:self.rightImage];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = [(XMPPMessageArchiving_Message_CoreDataObject*)self.tableviewDatas[indexPath.row] body];
    if ([message hasPrefix:MESSAGE_Text]) {
        CGSize size=[message boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
        return size.height+55;
    }else if ([message hasPrefix:MESSAGE_Image]){
        UIImage *image = [Photo string2Image:[[message componentsSeparatedByString:@"@"]firstObject]];
        return image.size.height+55;
    } else if ([message hasPrefix:MESSAGE_Voice]){
        return 80;
    } else if ([message hasPrefix:MESSAGE_File]){
        return 80;
    } else {
        return 80;
    }
}

@end
