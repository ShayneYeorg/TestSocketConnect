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
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UIButton *onOffLineBtn;

@property (strong, nonatomic) NSMutableArray *arrMessages;
@property (strong, nonatomic) NSString *moduleName;
@property (assign, nonatomic) long moduleTag;
@property (assign, nonatomic) BOOL isOnline;

@end

@implementation ChatViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrMessages = [NSMutableArray array];
    self.title = [NSString stringWithFormat:@"聊天室%zd - 未上线", self.roomNum];
    self.moduleName = [NSString stringWithFormat:@"CHATROOM%zd", self.roomNum];
    self.moduleTag = _roomNum + 10;
    self.isOnline = NO;
    [self setupCallbacks];
    
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

#pragma mark - Private

- (IBAction)cleanBtnClick:(id)sender {
    [self.arrMessages removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)onOffLineBtnClick:(id)sender {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    if (!self.isOnline) {
        //要上线
        [self.onOffLineBtn setTitle:@"下线" forState:UIControlStateNormal];
        self.onOffLineBtn.backgroundColor = [UIColor redColor];
        self.isOnline = YES;
        self.title = [NSString stringWithFormat:@"聊天室%zd - 已上线", self.roomNum];
        
        //告诉全世界,哥上线了
        NSDictionary *dic = @{@"user":self.user.text, @"module":self.moduleName, OPERATION: OPERATION_ONLINE};
        [socketManager sendMessage:dic tag:self.moduleTag];
        
    } else {
        //要下线
        [self.onOffLineBtn setTitle:@"上线" forState:UIControlStateNormal];
        self.onOffLineBtn.backgroundColor = [UIColor brownColor];
        self.isOnline = NO;
        self.title = [NSString stringWithFormat:@"聊天室%zd - 未上线", self.roomNum];
        
        //告诉全世界，哥下线了
        NSDictionary *dic = @{@"user":self.user.text, @"module":self.moduleName, OPERATION: OPERATION_OFFLINE};
        [socketManager sendMessage:dic tag:self.moduleTag];
    }
}

- (IBAction)sendBtnClick:(id)sender {
    if (!self.isOnline) {
        NSLog(@"请先上线");
        return;
    }
    
    [self.view endEditing:true];
    ShYSocketManager *socketManager = [ShYSocketManager share];
    if ([socketManager isConnected]) {
        NSString *strMsg = [self.chat text];
        if (strMsg.length) {
            NSDictionary *dic = @{@"user":self.user.text, @"module":self.moduleName, @"msg":strMsg, OPERATION: OPERATION_CHAT};
            [socketManager sendMessage:dic tag:self.moduleTag];
            [self.chat setText:@""];
            [self.arrMessages addObject:dic];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
            
        }else{
            NSLog(@"信息不能为空");
        }
    }else{
        NSLog(@"未连接服务器");
    }
}

- (void)setupCallbacks {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    __weak typeof(self) weakSelf = self;
    
    //    [socketManager setDidSendMessageCallback:^{
    //        [weakSelf.chat setText:@""];
    //    } module:self.moduleName];
    
    [socketManager setDidReceiveMessageCallback:^(NSDictionary *dic) {
        [weakSelf.arrMessages addObject:dic];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    } module:self.moduleName];
}

#pragma mark - Notification

- (void)receiveSocketDidConnectNotification:(NSNotification *)notification {
    self.onOffLineBtn.userInteractionEnabled = YES;
    self.sendBtn.userInteractionEnabled = YES;
}

- (void)receiveSocketDidDisconnectNotification:(NSNotification *)notification {
    self.sendBtn.userInteractionEnabled = NO;
    [self.onOffLineBtn setTitle:@"上线" forState:UIControlStateNormal];
    self.onOffLineBtn.backgroundColor = [UIColor brownColor];
    self.onOffLineBtn.userInteractionEnabled = NO;
    self.isOnline = NO;
    self.title = [NSString stringWithFormat:@"聊天室%zd - 未上线", self.roomNum];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cellid";
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    
    id msg = [self.arrMessages objectAtIndex:indexPath.row];
    if ([msg isKindOfClass:[NSDictionary class]]) {
        if ([msg[OPERATION] isEqualToString:OPERATION_CHAT]) {
            //聊天
            NSString *user = msg[@"user"]; //这个是用户名
            if ([user isEqualToString:self.user.text]){
                [cell.textLabel setTextColor:[UIColor blueColor]];
                [cell.detailTextLabel setTextColor:[UIColor blueColor]];
                
            } else{
                [cell.textLabel setTextColor:[UIColor blackColor]];
                [cell.detailTextLabel setTextColor:[UIColor blackColor]];
            }
            cell.textLabel.text = user;
            cell.detailTextLabel.text = msg[@"msg"];
            
        } else if ([msg[OPERATION] isEqualToString:OPERATION_ONLINE]) {
            NSString *user = msg[@"user"]; //这个是用户名
            [cell.textLabel setTextColor:[UIColor redColor]];
            [cell.detailTextLabel setTextColor:[UIColor redColor]];
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@上线了", user];
            
        } else  if ([msg[OPERATION] isEqualToString:OPERATION_OFFLINE]) {
            NSString *user = msg[@"user"]; //这个是用户名
            [cell.textLabel setTextColor:[UIColor redColor]];
            [cell.detailTextLabel setTextColor:[UIColor redColor]];
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@下线了", user];
            
        } else {
            cell.textLabel.text = @"Unknown";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg];
        }
        
    } else {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg];
    }
    
    return cell;
}

@end
