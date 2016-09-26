//
//  ViewController.m
//  BSDServer
//
//  Created by JuanFelix on 16/9/17.
//  Copyright © 2016年 JuanFelix. All rights reserved.
//

#import "ViewController.h"
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <arpa/inet.h>
#include <stdio.h>


#define SERVER_PORT 6000
#define LENGTH_OF_LISTEN_QUEUE 20
#define BUFFER_SIZE 10240

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    clients = [NSMutableArray array];
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(startSever) object:nil];
    [thread start];
}

-(void)startSever{
    //设置socket结构地址，代表服务器Internet地址、端口
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htons(INADDR_ANY);
    server_addr.sin_port = htons(SERVER_PORT);
    //创建用于internet的流协议(TCP)socket
    int server_socket = socket(PF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        printf("Create Socket Failed！\n");
        exit(1);
    }
    
    int opt = 1;
    setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    //关联socket 和 socket地址结构
    if (bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr))) {
        printf("Cannot bind Port: %d ",SERVER_PORT);
        exit(1);
    }
    //监听
    if (listen(server_socket, LENGTH_OF_LISTEN_QUEUE)) {
        printf("Server Listen Failed!");
        exit(1);
    }
    printf("Server start...\n");
    while (1) {
        struct sockaddr_in client_addr;
        socklen_t length = sizeof(client_addr);
        //阻塞 等待连接
        char * ip = nil;
        int sSocket = accept(server_socket, (struct sockaddr *)&client_addr, &length);
        if (sSocket < 0) {
            printf("Sever Accpet Failed!\n");
            break;
            
        } else {
            ip = inet_ntoa(client_addr.sin_addr);
            printf("%s 已连接\n",ip);
            [clients addObject:@{@"socket":[NSNumber numberWithInt:sSocket],@"ip":[NSString stringWithCString:ip encoding:NSUTF8StringEncoding]}];
        }
        NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(startNewCommunication:) object:@{@"socket":[NSNumber numberWithInt:sSocket],@"ip":[NSString stringWithCString:ip encoding:NSUTF8StringEncoding]}];
        [thread start];
    }
    close(server_socket);
}

-(void)startNewCommunication:(NSDictionary *)dicS{
    if ([dicS isKindOfClass:[NSDictionary class]]) {
        char buffer[BUFFER_SIZE];
        bzero(buffer, BUFFER_SIZE);
        socklen_t length = 0;
        //阻塞 等待接受
        while(length = recv([dicS[@"socket"] intValue],buffer,BUFFER_SIZE,0)){
            if (length < 0) {
                printf("Server Recieve Data Failed!\n");
                break;
                
            } else if(length > 0){
                printf("%s\n",buffer);
                
                char *resendMsg = buffer;
                //转发给其他客户端
                for (NSDictionary *cSocket in clients) {
                    if (![dicS[@"ip"] isEqualToString:cSocket[@"ip"]]) {//不发送给自己
                        if(send([cSocket[@"socket"] intValue],resendMsg,strlen(resendMsg),0)<0)
                        {
                            NSLog(@"发送给：%@失败\n",cSocket[@"ip"]);
                            continue;
                        }
                    }
                }
                bzero(buffer, BUFFER_SIZE);
            }
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
