//
//  ViewController.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/20.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

static NSString *MODULE_NAME = @"MainVC";
static const long TAG = 0;

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
//@property (weak, nonatomic) IBOutlet UITableView *tblMessageContent;
//@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
//@property (weak, nonatomic) IBOutlet UITextField *txtPort;
//@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
//@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
//@property (weak, nonatomic) IBOutlet UIButton *btnSend;
//@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
//
//
//
//@property (strong, nonatomic) NSMutableArray *arrMessages;
//@property (strong, nonatomic) NSString *nickName;

@property (weak, nonatomic) IBOutlet UITextField *ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UIButton *onOffLineBtn;

@property (nonatomic, strong) ChatViewController *chatVC0; //聊天室0
@property (nonatomic, strong) ChatViewController *chatVC1; //聊天室1

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Socket Demo - 未上线";
    
    self.chatVC0 = [ChatViewController new];
    self.chatVC1 = [ChatViewController new];
    
    
    
//    self.arrMessages = [[NSMutableArray alloc] init];
//    [_btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_btnConnect setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
//    [_btnConnect setTitle:@"连接" forState:UIControlStateNormal];
//    [_btnConnect setTitle:@"已连接" forState:UIControlStateDisabled];
//    
//    
//    [_btnDisconnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_btnDisconnect setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
//    [_btnDisconnect setTitle:@"断开连接" forState:UIControlStateNormal];
//    [_btnDisconnect setTitle:@"连接已断开" forState:UIControlStateDisabled];
//    [_btnDisconnect setEnabled:false];
//    
//    self.nickName = @"模拟器";
//    [self setupCallbacks];
//
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidConnectNotification:) name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidDisconnectNotification:) name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)dealloc {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    [socketManager disconnect];
}


- (IBAction)onOffLineBtnClick:(id)sender {
    [self.view endEditing:true];
    ShYSocketManager *socketManager = [ShYSocketManager share];
    
    if (![socketManager isConnected]) {
        //要上线
        if (self.ip.text.length && self.port.text.length && self.user.text.length) {
            NSError * error = nil;
            //连接服务器
            [socketManager connectToHost:self.ip.text onPort:self.port.text error:&error];
            if (error) {
                NSLog(@"连接失败: %@", error.description);
                
            } else {
                //告诉全世界,哥上线了
                NSDictionary *dic = @{@"user":self.user.text, @"module":MODULE_NAME, OPERATION: OPERATION_ONLINE};
                [socketManager sendMessage:dic tag:TAG];
            }
            
        }else{
            NSLog(@"请将相关信息填写完整");
        }
        
        
    } else {
        //要下线
        //告诉全世界，哥下线了
        NSDictionary *dic = @{@"user":self.user.text, @"module":MODULE_NAME, OPERATION: OPERATION_OFFLINE};
        [socketManager sendMessage:dic tag:TAG];
        [socketManager disconnect];
    }
}



//
//- (IBAction)sendAction:(id)sender {
//    [self.view endEditing:true];
//    ShYSocketManager *socketManager = [ShYSocketManager share];
//    if ([socketManager isConnected]) {
//        NSString * strMsg = [_txtMessage text];
//        if (strMsg.length) {
//            NSDictionary *dic = @{@"user":self.nickName, @"module":MODULE_NAME, @"msg":strMsg, OPERATION: OPERATION_CHAT};
//            [socketManager sendMessage:dic tag:TAG];
//            [self.arrMessages addObject:dic];
//            [_tblMessageContent reloadData];
//            [_tblMessageContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
//        }else{
//            NSLog(@"信息不能为空");
//        }
//    }else{
//        NSLog(@"未连接服务器");
//    }
//}
//
//
//- (void)setupCallbacks {
//    ShYSocketManager *socketManager = [ShYSocketManager share];
//    __weak typeof(self) weakSelf = self;
//    
//    [socketManager setDidSendMessageCallback:^{
//        [weakSelf.txtMessage setText:@""];
//    } module:MODULE_NAME];
//    
//    [socketManager setDidReceiveMessageCallback:^(NSDictionary *dic) {
//        [weakSelf.arrMessages addObject:dic];
//        [weakSelf.tblMessageContent reloadData];
//        [weakSelf.tblMessageContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
//    } module:MODULE_NAME];
//}



- (void)receiveSocketDidConnectNotification:(NSNotification *)notification {
    [self.onOffLineBtn setTitle:@"下线" forState:UIControlStateNormal];
    self.onOffLineBtn.backgroundColor = [UIColor redColor];
    self.title = @"Socket Demo - 已上线";
}

- (void)receiveSocketDidDisconnectNotification:(NSNotification *)notification {
    [self.onOffLineBtn setTitle:@"上线" forState:UIControlStateNormal];
    self.onOffLineBtn.backgroundColor = [UIColor brownColor];
    self.title = @"Socket Demo - 未上线";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.navigationController pushViewController:[ChatViewController new] animated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.arrMessages.count;
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"聊天室%zd", indexPath.row];
    return cell;
    
//    static NSString * cellID = @"cellid";
//    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
//        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
//    }
//    id msg = [self.arrMessages objectAtIndex:indexPath.row];
//    if ([msg isKindOfClass:[NSDictionary class]]) {
//        if ([msg[OPERATION] isEqualToString:OPERATION_CHAT]) {
//            //聊天
//            NSString *user = msg[@"user"]; //这个是用户名
//            if ([user isEqualToString:self.nickName]){
//                [cell.textLabel setTextColor:[UIColor blueColor]];
//                [cell.detailTextLabel setTextColor:[UIColor blueColor]];
//                
//            } else{
//                [cell.textLabel setTextColor:[UIColor greenColor]];
//                [cell.detailTextLabel setTextColor:[UIColor greenColor]];
//            }
//            cell.textLabel.text = user;
//            cell.detailTextLabel.text = msg[@"msg"];
//            
//        } else if ([msg[OPERATION] isEqualToString:OPERATION_ONLINE]) {
//            NSString *user = msg[@"user"]; //这个是用户名
//            [cell.textLabel setTextColor:[UIColor orangeColor]];
//            [cell.detailTextLabel setTextColor:[UIColor orangeColor]];
//            cell.textLabel.text = @"";
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@上线了", user];
//            
//        } else  if ([msg[OPERATION] isEqualToString:OPERATION_OFFLINE]) {
//            NSString *user = msg[@"user"]; //这个是用户名
//            [cell.textLabel setTextColor:[UIColor orangeColor]];
//            [cell.detailTextLabel setTextColor:[UIColor orangeColor]];
//            cell.textLabel.text = @"";
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@下线了", user];
//            
//        } else {
//            cell.textLabel.text = @"Unknown";
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg];
//        }
//    
//    } else {
//        cell.textLabel.text = @"Unknown";
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg];
//    }
    
//    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:true];
}


#pragma mark -

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.view endEditing:true];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
