//
//  TGSFirstViewController.m
//  TestGKSession
//
//  Created by kyoko.niida on 13/02/11.
//  Copyright (c) 2013年 kyoko.niida. All rights reserved.
//

#import "TGSFirstViewController.h"

@interface TGSFirstViewController ()

@end

@implementation TGSFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    session = [[GKSession alloc] initWithSessionID:@"____tsg____" displayName:nil sessionMode:GKSessionModePeer];
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    session.available = YES;
    [sendButton setBackgroundImage:nil forState:UIControlStateNormal];
    index = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 * メモリ使用量を標準出力に吐き出します。
 * 実行されるのはDEBUG変数が定義されている時だけです。
 */
- (void) printMemorySize {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    if (task_info(current_task(), TASK_BASIC_INFO,
                  (task_info_t)&t_info, &t_info_count)!= KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s", __FUNCTION__, strerror(errno));
    }
    
    float unitSize = 1.0;
    u_int rss = t_info.resident_size;
    NSLog(@"RSS: %0.1f %@", rss/unitSize, @"Bytes");
}

- (UIImage*) createBackgroundImage:(UIColor*)color withSize:(CGSize)size {
    UIImage *screenImage;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.layer.cornerRadius = 5;
    view.clipsToBounds = true;
    view.backgroundColor = color;
    UIGraphicsBeginImageContext(size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [view release];
    return screenImage;
}

- (void) sendData {
    int size = 900;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:peerId];
    SInt8 *intData = malloc(size);
    for(int i=0; i<size; i++) {
        intData[i] = 0;
    }
    for (int i=0; i<1000; i++) {
        [session sendDataToAllPeers:[NSData dataWithBytesNoCopy:intData length:size freeWhenDone:NO] withDataMode:GKSendDataReliable error:nil];
        [NSThread sleepForTimeInterval:0.01];
        if(++index % 100 == 0) {
            [self printMemorySize];
        }
    }
    [arr release];
    free(intData);
}

- (void) send {
    [sendButton setBackgroundImage:
     [self createBackgroundImage: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]
                        withSize:[sendButton bounds].size]
                          forState:UIControlStateNormal];
    sendButton.enabled = NO;
    int count = 0;
    while (TRUE) {
        //        [self performSelector: @selector(send) withObject:NULL afterDelay:20.0];
        NSLog(@"%d times challenge.", ++count);
        [self sendData];
        [NSThread sleepForTimeInterval:20.0];
    }
}

- (IBAction) sendButtonDown:(id)sender {
    NSLog(@"send..");
    [NSThread detachNewThreadSelector:@selector(send) toTarget:self withObject:nil];
}

#pragma mark -
#pragma mark GKSessionDelegate data receive implementation

/*
 * 受信したデータを処理するためのメソッド振り分けを行う。
 */
- (void) receiveData:(NSData*)data fromPeer:(NSString*)peerId
           inSession:(GKSession*)session context:(void*)context {
    if(sendButton.enabled == YES) {
        [sendButton setBackgroundImage:
         [self createBackgroundImage: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]
                            withSize:[sendButton bounds].size]
                              forState:UIControlStateNormal];
        sendButton.enabled = NO;
    }
    if(++index % 100 == 0) {
        [self printMemorySize];
    }
}

/*
 * セッション内のpeerの状態が変更されたときに呼び出されるdelegateメソッドです。
 */
- (void)session:(GKSession*)gksession peer:(NSString*)_peerId didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"connection connected,peerId[%@] ", _peerId);
            peerId = _peerId;
            [sendButton setBackgroundImage:
             [self createBackgroundImage: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]
                                  withSize:[sendButton bounds].size]
                                    forState:UIControlStateNormal];
            sendButton.enabled = YES;
            break;
        case GKPeerStateDisconnected:
            NSLog(@"connection disconnected,peerId[%@] ", _peerId);
            break;
        case GKPeerStateAvailable:
            NSLog(@"discover,peerId[%@] ", _peerId);
            [session connectToPeer:_peerId withTimeout:10];
            break;
        case GKPeerStateUnavailable:
            NSLog(@"lost,peerId[%@] ", _peerId);
            break;
        case GKPeerStateConnecting:
            NSLog(@"try connect,peerId[%@] ", _peerId);
            break;
    }
}

/*
 * peerに接続を試みて失敗したときに呼び出されるdelegateメソッドです。
 */
- (void)session:(GKSession*)gksession connectionWithPeerFailed:(NSString*)_peerId withError:(NSError*)error {
    NSLog(@"occured connection failed error!!,%d", session.available);
    [gksession acceptConnectionFromPeer:_peerId error:nil];
}

/*
 * セッション内で重大なエラーが発生したときに呼び出されるdelegateメソッドです。
 */
- (void)session:(GKSession*)gksession didFailWithError:(NSError*)error {
    NSLog(@"occured gksession error!!");
}

/*
 * peerからの接続要求で呼び出されるdelegateメソッドです。
 */
- (void)session:(GKSession*)gksession didReceiveConnectionRequestFromPeer:(NSString*)_peerId {
    [gksession acceptConnectionFromPeer:_peerId error:nil];
}

@end
