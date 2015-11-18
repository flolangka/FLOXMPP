//
//  FloChatVC.h
//  AVIC_AppStore
//
//  Created by admin on 15/9/13.
//  Copyright (c) 2015年 中航国际. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FloXMPPUser;

@interface FloChatVC : UIViewController

@property (nonatomic, strong) FloXMPPUser *chatUser;

@property (weak, nonatomic) IBOutlet UIView *chatBarView;

@end
