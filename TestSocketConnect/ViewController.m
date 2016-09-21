//
//  ViewController.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/20.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ViewController.h"
#import "ShYSocketManager.h"

static NSString *MODULE_NAME = @"ViewController";

@interface ViewController () <GCDAsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * arrMessages;
}
@property (weak, nonatomic) IBOutlet UITableView *tblMessageContent;

@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITextField *txtPort;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

@property (strong, nonatomic) NSString *nickName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrMessages = [[NSMutableArray alloc] init];
    [_btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnConnect setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
    [_btnConnect setTitle:@"连接" forState:UIControlStateNormal];
    [_btnConnect setTitle:@"已连接" forState:UIControlStateDisabled];
    
    
    [_btnDisconnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDisconnect setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
    [_btnDisconnect setTitle:@"断开连接" forState:UIControlStateNormal];
    [_btnDisconnect setTitle:@"连接已断开" forState:UIControlStateDisabled];
    [_btnDisconnect setEnabled:false];
    
    self.nickName = @"Shayne";
    [self setupCallbacks];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidConnectNotification:) name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidDisconnectNotification:) name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)dealloc {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    [socketManager disconnect];
}

- (IBAction)connectAction:(id)sender {
    [self.view endEditing:true];
    ShYSocketManager *socketManager = [ShYSocketManager share];
    NSString * strAddr = [_txtAddress text];
    NSString * strPort = [_txtPort text];
    if (strAddr.length && strPort.length) {
        NSError * error = nil;
        //连接服务器
        [socketManager connectToHost:strAddr onPort:strPort error:&error];
        if (error) {
            NSLog(@"连接失败: %@", error.description);
        }
    }else{
        NSLog(@"请将地址信息填写完整");
    }
}

- (IBAction)sendAction:(id)sender {
    [self.view endEditing:true];
    ShYSocketManager *socketManager = [ShYSocketManager share];
    if ([socketManager isConnected]) {
        NSString * strMsg = [_txtMessage text];
        if (strMsg.length) {
            [socketManager sendMessage:strMsg module:MODULE_NAME];
            NSDictionary *dic = @{@"from":self.nickName,@"msg":strMsg};
            [arrMessages addObject:dic];
            [_tblMessageContent reloadData];
            [_tblMessageContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
        }else{
            NSLog(@"信息不能为空");
        }
    }else{
        NSLog(@"未连接服务器");
    }
}

- (IBAction)btnDisconnect:(id)sender {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    if ([socketManager isConnected]) {
        [socketManager disconnect];
    }
}

- (void)setupCallbacks {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    __weak typeof(self) weakSelf = self;
    
    [socketManager setDidSendMessageCallback:^{
        [weakSelf.txtMessage setText:@""];
    } module:MODULE_NAME];
    
    [socketManager setDidReceiveMessageCallback:^(NSDictionary *dic) {
        
    } module:MODULE_NAME];
}

- (void)receiveSocketDidConnectNotification:(NSNotification *)notification {
    [_btnConnect setEnabled:false];
    [_btnDisconnect setEnabled:true];
}

- (void)receiveSocketDidDisconnectNotification:(NSNotification *)notification {
    [_btnConnect setEnabled:true];
    [_btnDisconnect setEnabled:false];
}


#pragma mark -
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrMessages.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellID = @"cellid";
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    id msg = [arrMessages objectAtIndex:indexPath.row];
    if ([msg isKindOfClass:[NSDictionary class]]) {
        NSString * from = msg[@"from"];
        if ([from isEqualToString:@"Server"]) {
            [cell.textLabel setTextColor:[UIColor orangeColor]];
            [cell.detailTextLabel setTextColor:[UIColor orangeColor]];
        }else if ([from isEqualToString:self.nickName]){
            [cell.textLabel setTextColor:[UIColor blueColor]];
            [cell.detailTextLabel setTextColor:[UIColor blueColor]];
        }else{
            [cell.textLabel setTextColor:[UIColor greenColor]];
            [cell.detailTextLabel setTextColor:[UIColor greenColor]];
        }
        cell.textLabel.text = msg[@"from"];
        cell.detailTextLabel.text = msg[@"msg"];
    }else{
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg];
    }
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:true];
}


#pragma mark -

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
