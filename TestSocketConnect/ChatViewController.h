//
//  ChatViewController.h
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/23.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShYSocketManager.h"

@interface ChatViewController : UIViewController

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger roomNum; //聊天室编号

@end
