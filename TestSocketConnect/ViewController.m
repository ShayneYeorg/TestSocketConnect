//
//  ViewController.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/20.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface ViewController () <GCDAsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * arrMessages;
    GCDAsyncSocket * _asyncSocket;
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

-(void)dealloc{
    [_asyncSocket disconnect];
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arrMessages = [[NSMutableArray alloc] init];
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
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
}

- (IBAction)connectAction:(id)sender {
    [self.view endEditing:true];
    NSString * strAddr = [_txtAddress text];
    NSString * strPort = [_txtPort text];
    if (strAddr.length && strPort.length) {
        NSError * error = nil;
        //连接服务器
        [_asyncSocket connectToHost:strAddr onPort:[strPort intValue] error:&error];
        if (error) {
            NSLog(@"连接失败: %@", error.description);
        }
    }else{
        NSLog(@"请将地址信息填写完整");
    }
}

- (IBAction)sendAction:(id)sender {
    [self.view endEditing:true];
    if ([_asyncSocket isConnected]) {
        NSString * strMsg = [_txtMessage text];
        if (strMsg.length) {
            NSData * data = [strMsg dataUsingEncoding:NSUTF8StringEncoding];
            [_asyncSocket writeData:data withTimeout:-1 tag:0];
            NSDictionary * dic = @{@"from":self.nickName,@"msg":strMsg};
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

- (void)sendMessage:(NSString *)msg {
    
}

- (IBAction)btnDisconnect:(id)sender {
    if ([_asyncSocket isConnected]) {
        [_asyncSocket disconnect];
    }
}

#pragma mark -

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接...%@", err.description);
    [_btnConnect setEnabled:true];
    [_btnDisconnect setEnabled:false];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"已连接: %@, 端口: %d", host, port);
    [_btnConnect setEnabled:false];
    [_btnDisconnect setEnabled:true];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (obj) {
        [arrMessages addObject:obj];
    }else{
        [arrMessages addObject:[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    }
    
    [_tblMessageContent reloadData];
    [_tblMessageContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"已发送Tag: %ld", tag);
    [_txtMessage setText:@""];
    [sock readDataWithTimeout:-1 tag:tag];
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


#pragma mark -

-(NSString *)jsonString:(NSDictionary *)dicMsg{
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicMsg options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
