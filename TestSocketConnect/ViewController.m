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

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UIButton *onOffLineBtn;

@property (nonatomic, strong) ChatViewController *chatVC0; //聊天室0
@property (nonatomic, strong) ChatViewController *chatVC1; //聊天室1

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Socket Demo - 未连接";
    self.chatVC0 = [ChatViewController new];
    self.chatVC0.roomNum = 0;
    self.chatVC1 = [ChatViewController new];
    self.chatVC1.roomNum = 1;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidConnectNotification:) name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveSocketDidDisconnectNotification:) name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)dealloc {
    ShYSocketManager *socketManager = [ShYSocketManager share];
    [socketManager disconnect];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SOCKET_DID_CONNECT object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SOCKET_DID_DISCONNECT object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)onOffLineBtnClick:(id)sender {
    [self.view endEditing:true];
    ShYSocketManager *socketManager = [ShYSocketManager share];
    
    if (![socketManager isConnected]) {
        //要上线
        if (self.ip.text.length && self.port.text.length) {
            NSError * error = nil;
            //连接服务器
            [socketManager connectToHost:self.ip.text onPort:self.port.text error:&error];
            if (error) {
                NSLog(@"连接失败: %@", error.description);
            }
            
        } else {
            NSLog(@"信息不全");
        }
        
    } else {
        //要下线
        [socketManager disconnect];
    }
}



- (void)receiveSocketDidConnectNotification:(NSNotification *)notification {
    [self.onOffLineBtn setTitle:@"断开" forState:UIControlStateNormal];
    self.onOffLineBtn.backgroundColor = [UIColor redColor];
    self.title = @"Socket Demo - 已连接";
}

- (void)receiveSocketDidDisconnectNotification:(NSNotification *)notification {
    [self.onOffLineBtn setTitle:@"连接" forState:UIControlStateNormal];
    self.onOffLineBtn.backgroundColor = [UIColor brownColor];
    self.title = @"Socket Demo - 未连接";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:self.chatVC0 animated:YES];
        
    } else {
        [self.navigationController pushViewController:self.chatVC1 animated:YES];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"聊天室%zd", indexPath.row];
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:true];
}


#pragma mark -

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}



@end
