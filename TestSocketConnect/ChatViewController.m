//
//  ChatViewController.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/23.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *chat;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidConnectNotification:) name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidDisconnectNotification:) name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cleanBtnClick:(id)sender {
    
}

- (IBAction)sendBtnClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(user)]) {
        UITextField *field = (UITextField *)[self.delegate user];
        if (field) {
            NSLog(@"%@", field.text);
            
        } else {
            NSLog(@"获取不到用户名");
        }
    }
}

#pragma mark - Setter

- (void)setRoomNum:(NSInteger)roomNum {
    _roomNum = roomNum;
    self.title = [NSString stringWithFormat:@"聊天室%zd", _roomNum];
}

#pragma mark - Notification

- (void)receiveSocketDidConnectNotification:(NSNotification *)notification {
    self.sendBtn.userInteractionEnabled = YES;
    self.title = [NSString stringWithFormat:@"聊天室%zd - 已上线", self.roomNum];
}

- (void)receiveSocketDidDisconnectNotification:(NSNotification *)notification {
    self.sendBtn.userInteractionEnabled = NO;
    self.title = [NSString stringWithFormat:@"聊天室%zd - 未上线", self.roomNum];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = @"123";
    return cell;
}

@end
